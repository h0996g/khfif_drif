import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../shared/widgets/bottomsheets/app_option_sheet.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../../saved_places/data/address_model.dart';
import '../../../../saved_places/data/address_repository.dart';
import '../../../../saved_places/presentation/views/widgets/address_type_icon_widget.dart';
import '../../data/models/passenger_ride_models.dart';
import '../cubit/location_cubit/location_picker_cubit.dart';
import '../cubit/location_cubit/location_picker_state.dart';
import 'widgets/location/location_search_bar.dart';
import 'widgets/location/map_button.dart';
import 'widgets/location/search_results_list.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key, this.args = const LocationPickerArgs()});

  final LocationPickerArgs args;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _addressRepository = const AddressRepository();
  Timer? _searchDebounce;
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationPickerCubit>().init(initial: widget.args.initial);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<LocationPickerCubit>().search(query);
    });
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + 1).clamp(0, 19));
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom - 1).clamp(0, 19));
  }

  /// Moves the camera to the device's current GPS position.
  ///
  /// Drives the camera move directly from the tap (rather than relying on the
  /// state-driven `BlocListener`) so it fires even when the freshly-fetched
  /// position equals the already-stored [LocationPickerState.mapCenter] — which
  /// happens whenever the user has panned the map without the pin following.
  /// On failure, shows a toast instead of moving the camera.
  Future<void> _goToMyLocation() async {
    final cubit = context.read<LocationPickerCubit>();
    final ok = await cubit.goToMyLocation();
    if (!mounted) return;
    if (ok) {
      _mapController.move(
          cubit.state.mapCenter, _mapController.camera.zoom);
    } else {
      AppToast.error(
          cubit.state.errorMessage ?? 'Could not get your location.');
    }
  }

  Future<void> _pickFromFavorites() async {
    setState(() => _isLoadingFavorites = true);
    try {
      final addresses = await _addressRepository.getAddresses();
      if (!mounted) return;
      if (addresses.isEmpty) {
        AppToast.warning('No saved addresses yet.');
        return;
      }
      final selected = await showAppOptionSheet<AddressModel>(
        context: context,
        title: 'Saved Addresses',
        options: [
          for (final address in addresses)
            AppSheetOption(
              leading: AddressTypeIconWidget(type: address.type, size: 40.w),
              label: address.label,
              subtitle: address.address,
              value: address,
            ),
        ],
      );
      if (selected != null && mounted) {
        context.read<LocationPickerCubit>().selectSavedAddress(selected);
      }
    } catch (e) {
      if (mounted) AppToast.error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingFavorites = false);
    }
  }

  void _confirm(LocationPickerState state) {
    final pos = state.selectedPosition!;
    context.pop(CoordinatePoint(
      address: state.pickedAddress.isNotEmpty
          ? state.pickedAddress
          : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
      lat: pos.latitude,
      lng: pos.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationPickerCubit, LocationPickerState>(
      listenWhen: (prev, curr) => prev.mapCenter != curr.mapCenter,
      listener: (context, state) {
        _mapController.move(state.mapCenter, _mapController.camera.zoom);
      },
      child: Scaffold(
        body: BlocBuilder<LocationPickerCubit, LocationPickerState>(
          builder: (context, state) {
            final cubit = context.read<LocationPickerCubit>();

            return Stack(
              children: [
                // ── Map ──────────────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.mapCenter,
                    initialZoom: 15,
                    onTap: (tapPosition, latLng) => cubit.onMapTap(latLng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.khfif.drif',
                    ),
                    if (state.selectedPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: state.selectedPosition!,
                            width: 44.w,
                            height: 44.w,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 44.w,
                              color: AppColors.primary,
                              shadows: [
                                Shadow(
                                  color:
                                      AppColors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // ── Geocoding indicator ───────────────────────────────────────
                if (state.isGeocoding)
                  const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),

                // ── Top-right controls: my location + favorites + zoom ────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70.h,
                  right: 16.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MapButton(
                        icon: Icons.my_location_rounded,
                        isLoading: state.isLocating,
                        onTap: _goToMyLocation,
                      ),
                      SizedBox(height: 12.h),
                      MapButton(
                        icon: Icons.star_rounded,
                        isLoading: _isLoadingFavorites,
                        onTap: _pickFromFavorites,
                      ),
                      SizedBox(height: 12.h),
                      MapButton(
                        icon: Icons.add_rounded,
                        onTap: _zoomIn,
                      ),
                      SizedBox(height: 12.h),
                      MapButton(
                        icon: Icons.remove_rounded,
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),

                // ── Top overlay (back + search) ───────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12.h,
                  left: 16.w,
                  right: 16.w,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          MapButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.pop(),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: LocationSearchBar(
                              controller: _searchCtrl,
                              focusNode: _searchFocus,
                              hint: 'Search for a location…',
                              isLoading: state.isSearching,
                              onChanged: _onSearchChanged,
                              onClear: () {
                                _searchCtrl.clear();
                                cubit.clearSearch();
                                _searchFocus.unfocus();
                              },
                            ),
                          ),
                        ],
                      ),
                      if (state.searchResults.isNotEmpty)
                        SearchResultsList(
                          results: state.searchResults,
                          onSelect: (place) {
                            _searchCtrl.text = place.displayName;
                            cubit.selectResult(place);
                            _searchFocus.unfocus();
                          },
                        ),
                    ],
                  ),
                ),

                // ── Bottom confirm card ───────────────────────────────────────
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 20.r,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16.w,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              widget.args.label,
                              style:
                                  AppTextStyles.labelSmall(context).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          state.pickedAddress.isNotEmpty
                              ? state.pickedAddress
                              : 'Tap on the map to select a location',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.text(context),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 14.h),
                        PrimaryButton(
                          label: 'Confirm Location',
                          isEnabled: state.selectedPosition != null &&
                              !state.isGeocoding,
                          onPressed: () => _confirm(state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
