import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../ride/passenger/presentation/cubit/location_cubit/location_picker_state.dart';
import '../../../ride/shared/models/shared_ride_models.dart';
import '../../data/address_model.dart';
import '../cubit/saved_places_cubit.dart';
import '../cubit/saved_places_state.dart';
import 'widgets/address_form_field_widget.dart';
import 'widgets/address_type_selector_widget.dart';
import 'widgets/map_picker_button.dart';

class AddressEditView extends StatefulWidget {
  const AddressEditView({super.key, required this.address});

  final AddressModel address;

  @override
  State<AddressEditView> createState() => _AddressEditViewState();
}

class _AddressEditViewState extends State<AddressEditView> {
  late final _formKey = GlobalKey<FormState>();
  late final _labelCtl = TextEditingController(text: widget.address.label);
  late final _addressCtl =
      TextEditingController(text: widget.address.address);
  late final _buildingCtl =
      TextEditingController(text: widget.address.building);
  late final _floorCtl = TextEditingController(text: widget.address.floor);
  late final _doorCtl = TextEditingController(text: widget.address.door);
  late final _descCtl =
      TextEditingController(text: widget.address.description);
  late AddressType _selectedType = widget.address.type;
  late CoordinatePoint? _pickedLocation = (widget.address.latitude != 0 ||
          widget.address.longitude != 0)
      ? CoordinatePoint(
          address: widget.address.address,
          lat: widget.address.latitude,
          lng: widget.address.longitude,
        )
      : null;

  @override
  void dispose() {
    _labelCtl.dispose();
    _addressCtl.dispose();
    _buildingCtl.dispose();
    _floorCtl.dispose();
    _doorCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SavedPlacesCubit>();

    return BlocListener<SavedPlacesCubit, SavedPlacesState>(
      listenWhen: (prev, curr) =>
          prev.updateAddressStatus != curr.updateAddressStatus,
      listener: (context, state) {
        if (state.updateAddressStatus == UpdateAddressStatus.success) {
          AppToast.success('Address updated');
          context.pop();
        } else if (state.updateAddressStatus == UpdateAddressStatus.failure) {
          AppToast.error(state.errorMessage);
        }
      },
      child: AppScaffold(
        showAppBar: true,
        appBarTitle: 'Edit Place',
        onLeadingTap: () => context.pop(),
        bottomNavigationBar: BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
          buildWhen: (prev, curr) =>
              prev.updateAddressStatus != curr.updateAddressStatus,
          builder: (context, state) {
            final isLoading =
                state.updateAddressStatus == UpdateAddressStatus.loading;
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _submit(cubit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: Size.fromHeight(48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.white),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            );
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AddressTypeSelectorWidget(
                  selected: _selectedType,
                  onChanged: (t) => setState(() => _selectedType = t),
                ),
                SizedBox(height: 20.h),
                AddressFormFieldWidget(
                    controller: _labelCtl, label: 'Label', isRequired: true),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AddressFormFieldWidget(
                        controller: _addressCtl,
                        label: 'Address',
                        isRequired: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      height: 56.h,
                      child: MapPickerButton(
                        hasLocation: _pickedLocation != null,
                        onTap: _pickFromMap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AddressFormFieldWidget(
                    controller: _buildingCtl, label: 'Building'),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                        child: AddressFormFieldWidget(
                            controller: _floorCtl, label: 'Floor')),
                    SizedBox(width: 12.w),
                    Expanded(
                        child: AddressFormFieldWidget(
                            controller: _doorCtl, label: 'Door')),
                  ],
                ),
                SizedBox(height: 12.h),
                AddressFormFieldWidget(
                    controller: _descCtl, label: 'Description', maxLines: 2),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(SavedPlacesCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.updateAddress(widget.address.id!, {
      'type': _selectedType.apiValue,
      'label': _labelCtl.text.trim(),
      'address': _addressCtl.text.trim(),
      'latitude': _pickedLocation?.lat ?? 0.0,
      'longitude': _pickedLocation?.lng ?? 0.0,
      if (_buildingCtl.text.isNotEmpty) 'building': _buildingCtl.text.trim(),
      if (_floorCtl.text.isNotEmpty) 'floor': _floorCtl.text.trim(),
      if (_doorCtl.text.isNotEmpty) 'door': _doorCtl.text.trim(),
      if (_descCtl.text.isNotEmpty) 'description': _descCtl.text.trim(),
    });
  }

  Future<void> _pickFromMap() async {
    final result = await context.push<CoordinatePoint>(
      RouteNames.locationPicker,
      extra: LocationPickerArgs(
        label: 'Address Location',
        initial: _pickedLocation == null
            ? null
            : LatLng(_pickedLocation!.lat, _pickedLocation!.lng),
      ),
    );
    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _addressCtl.text = result.address;
      });
    }
  }
}
