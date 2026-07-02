import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../ride/shared/models/shared_ride_models.dart';
import '../../../ride/passenger/presentation/cubit/location_cubit/location_picker_state.dart';
import '../../data/address_model.dart';
import '../cubit/saved_places_cubit.dart';
import '../cubit/saved_places_state.dart';
import 'widgets/address_form_field_widget.dart';
import 'widgets/address_type_selector_widget.dart';
import 'widgets/map_picker_button.dart';

class AddressCreateView extends StatefulWidget {
  const AddressCreateView({super.key});

  @override
  State<AddressCreateView> createState() => _AddressCreateViewState();
}

class _AddressCreateViewState extends State<AddressCreateView> {
  late final _formKey = GlobalKey<FormState>();
  late final _labelCtl = TextEditingController();
  late final _addressCtl = TextEditingController();
  late final _buildingCtl = TextEditingController();
  late final _floorCtl = TextEditingController();
  late final _doorCtl = TextEditingController();
  late final _descCtl = TextEditingController();
  late AddressType _selectedType = AddressType.home;
  CoordinatePoint? _pickedLocation;

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
          prev.createAddressStatus != curr.createAddressStatus,
      listener: (context, state) {
        if (state.createAddressStatus == CreateAddressStatus.success) {
          AppToast.success('Address added');
          context.pop();
        } else if (state.createAddressStatus == CreateAddressStatus.failure) {
          AppToast.error(state.errorMessage);
        }
      },
      child: AppScaffold(
        showAppBar: true,
        appBarTitle: 'Add Place',
        onLeadingTap: () => context.pop(),
        bottomNavigationBar: BlocBuilder<SavedPlacesCubit, SavedPlacesState>(
          buildWhen: (prev, curr) =>
              prev.createAddressStatus != curr.createAddressStatus,
          builder: (context, state) {
            final isLoading =
                state.createAddressStatus == CreateAddressStatus.loading;
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
                    : const Text('Add Place'),
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
    cubit.addAddress(AddressModel(
      type: _selectedType,
      label: _labelCtl.text.trim(),
      address: _addressCtl.text.trim(),
      latitude: _pickedLocation?.lat ?? 0.0,
      longitude: _pickedLocation?.lng ?? 0.0,
      building: _buildingCtl.text.trim().nullIfEmpty,
      floor: _floorCtl.text.trim().nullIfEmpty,
      door: _doorCtl.text.trim().nullIfEmpty,
      description: _descCtl.text.trim().nullIfEmpty,
    ));
  }

  Future<void> _pickFromMap() async {
    final result = await context.push<CoordinatePoint>(
      RouteNames.locationPicker,
      extra: const LocationPickerArgs(label: 'Address Location'),
    );
    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _addressCtl.text = result.address;
      });
    }
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
