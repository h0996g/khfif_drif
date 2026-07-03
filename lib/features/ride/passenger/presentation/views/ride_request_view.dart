import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../shared/widgets/app_slim_app_bar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../data/models/passenger_ride_models.dart';
import '../cubit/location_cubit/location_picker_state.dart';
import '../cubit/ride_request_cubit/ride_request_cubit.dart';
import '../cubit/ride_request_cubit/ride_request_state.dart';
import 'widgets/ride/dashed_connector_widget.dart';
import 'widgets/ride/female_only_widget.dart';
import 'widgets/ride/location_picker_card.dart';
import 'widgets/ride/section_label_widget.dart';
import 'widgets/ride/service_type_selector.dart';
import 'widgets/ride/vehicle_category_selector.dart';

class RideRequestView extends StatefulWidget {
  const RideRequestView({super.key});

  @override
  State<RideRequestView> createState() => _RideRequestViewState();
}

class _RideRequestViewState extends State<RideRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _fareCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _packageNoteCtrl = TextEditingController();

  CoordinatePoint? _pickup;
  CoordinatePoint? _dropoff;

  @override
  void dispose() {
    _fareCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _packageNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final label = isPickup ? 'Pickup Location' : 'Drop-off Location';
    final result = await context.push<CoordinatePoint>(
      RouteNames.locationPicker,
      extra: LocationPickerArgs(label: label),
    );
    if (result != null) {
      setState(() {
        if (isPickup) {
          _pickup = result;
        } else {
          _dropoff = result;
        }
      });
    }
  }

  void _submit(RideRequestCubit cubit, RideRequestState state) {
    if (_pickup == null) {
      AppToast.error('Please set a pickup location');
      return;
    }
    if (_dropoff == null) {
      AppToast.error('Please set a drop-off location');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final isDelivery = state.serviceType == ServiceType.delivery;

    cubit.submitRide(
      CreateRideRequest(
        pickup: _pickup!,
        dropoff: _dropoff!,
        serviceType: state.serviceType,
        vehicleCategory: state.vehicleCategory,
        femaleOnly: state.femaleOnly,
        proposedFare: int.parse(_fareCtrl.text),
        recipientName: isDelivery ? _recipientNameCtrl.text.trim() : null,
        recipientPhone: isDelivery ? _recipientPhoneCtrl.text.trim() : null,
        packageNote: isDelivery && _packageNoteCtrl.text.trim().isNotEmpty
            ? _packageNoteCtrl.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideRequestCubit, RideRequestState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == RideRequestStatus.success) {
          context.pushReplacement(
            RouteNames.waitingOffers,
            extra: WaitingOffersArgs(
              pickup: _pickup!,
              dropoff: _dropoff!,
              proposedFare: int.parse(_fareCtrl.text),
              serviceType: state.serviceType,
              vehicleCategory: state.vehicleCategory,
              response: state.createRideResponse!,
            ),
          );
        } else if (state.status == RideRequestStatus.failure) {
          AppToast.error(
            state.errorMessage.isNotEmpty
                ? state.errorMessage
                : 'Failed to create ride. Please try again.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppSlimAppBar(
          title: 'Book a Ride',
          onLeadingTap: () => context.pop(),
        ),
        body: BlocBuilder<RideRequestCubit, RideRequestState>(
          builder: (context, state) {
            final cubit = context.read<RideRequestCubit>();

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Service Type ─────────────────────────────────
                          ServiceTypeSelector(
                            selected: state.serviceType,
                            onChanged: cubit.setServiceType,
                          ),

                          SizedBox(height: 20.h),

                          // ── Vehicle ───────────────────────────────────────
                          const SectionLabelWidget(label: 'Vehicle'),
                          SizedBox(height: 10.h),
                          VehicleCategorySelector(
                            serviceType: state.serviceType,
                            selected: state.vehicleCategory,
                            onChanged: cubit.setVehicleCategory,
                          ),

                          SizedBox(height: 24.h),

                          // ── Locations ─────────────────────────────────────
                          const SectionLabelWidget(label: 'Locations'),
                          SizedBox(height: 10.h),

                          LocationPickerCard(
                            label: 'Pickup',
                            icon: Icons.trip_origin_rounded,
                            iconColor: AppColors.primary,
                            address: _pickup?.address,
                            onTap: () => _pickLocation(isPickup: true),
                          ),

                          SizedBox(height: 6.h),
                          const DashedConnectorWidget(),
                          SizedBox(height: 6.h),

                          LocationPickerCard(
                            label: 'Drop-off',
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFFEF4444),
                            address: _dropoff?.address,
                            onTap: () => _pickLocation(isPickup: false),
                          ),

                          SizedBox(height: 20.h),

                          // ── Delivery details ──────────────────────────────
                          if (state.serviceType == ServiceType.delivery) ...[
                            const SectionLabelWidget(
                                label: 'Delivery Details'),
                            SizedBox(height: 10.h),
                            AppTextField(
                              controller: _recipientNameCtrl,
                              hintText: 'Recipient name',
                              prefixIcon:
                                  const Icon(Icons.person_outline_rounded),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Recipient name is required'
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            AppTextField(
                              controller: _recipientPhoneCtrl,
                              hintText: 'Recipient phone',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Recipient phone is required'
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            AppTextField(
                              controller: _packageNoteCtrl,
                              hintText: 'Package note (optional)',
                              prefixIcon:
                                  const Icon(Icons.inventory_2_outlined),
                            ),
                            SizedBox(height: 20.h),
                          ],

                          // ── Female only ───────────────────────────────────
                          FemaleOnlyWidget(
                            value: state.femaleOnly,
                            onChanged: cubit.setFemaleOnly,
                          ),

                          SizedBox(height: 20.h),

                          // ── Proposed Fare ─────────────────────────────────
                          const SectionLabelWidget(
                              label: 'Proposed Fare (DZD)'),
                          SizedBox(height: 10.h),
                          AppTextField(
                            controller: _fareCtrl,
                            hintText: 'e.g. 1000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            validator: (v) {
                              final fare = int.tryParse(v ?? '');
                              if (fare == null) return 'Enter a valid amount';
                              if (fare < 100) return 'Minimum fare is 100 DZD';
                              if (fare > 50000) {
                                return 'Maximum fare is 50,000 DZD';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      12.h,
                      20.w,
                      MediaQuery.of(context).padding.bottom + 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.06),
                          blurRadius: 16.r,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: PrimaryButton(
                      label: 'Find a Driver',
                      isLoading: state.status == RideRequestStatus.loading,
                      onPressed: () => _submit(cubit, state),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
