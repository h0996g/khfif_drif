import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/models/passenger_profile_model.dart';
import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/auth/data/repo/driver_repository.dart';
import '../../features/auth/data/repo/profile_repository.dart';
import '../../features/auth/presentation/cubit/otp_cubit/otp_cubit.dart';
import '../../features/auth/presentation/cubit/passenger_profile_cubit/passenger_profile_cubit.dart';
import '../../features/auth/presentation/cubit/phone_cubit/phone_cubit.dart';
import '../../features/auth/presentation/views/mode_selection_view.dart';
import '../../features/auth/presentation/views/otp_verification_view.dart';
import '../../features/auth/presentation/views/passenger/passenger_profile_view.dart';
import '../../features/auth/presentation/views/phone_entry_view.dart';
import '../../features/auth/presentation/cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../features/auth/presentation/cubit/kyc_status_cubit/kyc_status_cubit.dart';
import '../../features/auth/presentation/views/driver/driver_status_review_view.dart';
import '../../features/auth/presentation/views/driver/driver_registration_view.dart';
import '../../features/auth/presentation/views/driver/driver_rejection_view.dart';
import '../../features/home/driver/presentation/views/driver_home_view.dart';
import '../../features/home/driver/presentation/cubit/driver_home_cubit.dart';
import '../../features/home/driver/presentation/views/driver_home_shell.dart';
import '../../features/profile/driver/presentation/views/driver_profile_view.dart';
import '../../features/home/passenger/presentation/cubit/passenger_home_cubit.dart';
import '../../features/home/passenger/presentation/views/passenger_home_view.dart';
import '../../features/profile/shared/cubit/email_edit_cubit.dart';
import '../../features/profile/shared/cubit/phone_edit_cubit.dart';
import '../../features/profile/passenger/presentation/cubit/passenger_profile_edit_cubit.dart';
import '../../features/profile/shared/views/email_edit_view.dart';
import '../../features/profile/shared/views/phone_edit_view.dart';
import '../../features/profile/passenger/presentation/views/passenger_profile_edit_view.dart';
import '../../features/saved_places/data/address_repository.dart';
import '../../features/saved_places/presentation/cubit/saved_places_cubit.dart';
import '../../features/saved_places/presentation/views/saved_places_view.dart';
import '../../features/saved_places/data/address_model.dart';
import '../../features/saved_places/presentation/views/address_create_view.dart';
import '../../features/saved_places/presentation/views/address_edit_view.dart';
import '../../features/ride/passenger/data/models/passenger_ride_models.dart';
import '../presentation/cubit/web_socket_connection_cubit/web_socket_connection_cubit.dart';
import '../../features/ride/passenger/data/passenger_ride_repository.dart';
import '../../features/ride/passenger/presentation/cubit/location_cubit/location_picker_cubit.dart';
import '../../features/ride/passenger/presentation/cubit/location_cubit/location_picker_state.dart';
import '../../features/ride/passenger/presentation/cubit/passenger_active_ride_cubit/passenger_active_ride_cubit.dart';
import '../../features/ride/passenger/presentation/cubit/passenger_ride_history_cubit/passenger_ride_history_cubit.dart';
import '../../features/ride/passenger/presentation/cubit/ride_request_cubit/ride_request_cubit.dart';
import '../../features/ride/passenger/presentation/cubit/waiting_offers_cubit/waiting_offers_cubit.dart';
import '../../features/ride/passenger/presentation/views/location_picker_view.dart';
import '../../features/ride/passenger/presentation/views/passenger_active_ride_view.dart';
import '../../features/ride/passenger/presentation/views/passenger_ride_history_view.dart';
import '../../features/ride/passenger/presentation/views/ride_request_view.dart';
import '../../features/ride/passenger/presentation/views/waiting_offers_view.dart';
import '../../features/ride/driver/data/driver_availability_repository.dart';
import '../../features/ride/driver/data/driver_ride_repository.dart';
import '../../features/ride/driver/presentation/cubit/available_rides_cubit/available_rides_cubit.dart';
import '../../features/ride/driver/presentation/cubit/driver_active_ride_cubit/driver_active_ride_cubit.dart';
import '../../features/ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_cubit.dart';
import '../../features/ride/driver/presentation/cubit/driver_ride_detail_cubit/driver_ride_detail_cubit.dart';
import '../../features/ride/driver/presentation/cubit/driver_ride_history_cubit/driver_ride_history_cubit.dart';
import '../../features/ride/driver/presentation/views/available_rides_view.dart';
import '../../features/ride/driver/presentation/views/driver_active_ride_view.dart';
import '../../features/ride/driver/presentation/views/driver_ride_detail_view.dart';
import '../../features/ride/driver/presentation/views/driver_ride_history_view.dart';
import '../../features/wallet/driver/data/receipt_picker_service.dart';
import '../../features/wallet/driver/data/wallet_repository.dart';
import '../../features/wallet/driver/presentation/cubit/top_up_cubit/top_up_cubit.dart';
import '../../features/wallet/driver/presentation/cubit/wallet_cubit/wallet_cubit.dart';
import '../../features/wallet/driver/presentation/views/driver_wallet_view.dart';
import '../../features/wallet/driver/presentation/views/top_up_form_view.dart';
import '../../features/wallet/driver/presentation/views/top_up_history_view.dart';
import '../session/auth_session.dart';
import 'route_names.dart';

final class AppRouter {
  AppRouter._();

  static const _authRepository = AuthRepository();
  static const _profileRepository = ProfileRepository();
  static const _driverRepository = DriverRepository();

  static final GoRouter router = GoRouter(
    initialLocation: AuthSession.resolveInitialRoute(),
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Page not found')),
    ),
    routes: [
      GoRoute(
        path: RouteNames.phone,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<PhoneCubit>(
            create: (_) => PhoneCubit(_authRepository),
            child: const PhoneEntryView(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.extra is String ? state.extra as String : '';
          return BlocProvider<OtpCubit>(
            create: (_) => OtpCubit(_authRepository, phoneNumber: phone),
            child: const OtpVerificationView(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (BuildContext context, GoRouterState state) {
          // Generic home placeholder — replaced per user type in Story 7+.
          return const Scaffold(
            body: Center(child: Text('Home — Story 7+')),
          );
        },
      ),
      GoRoute(
        path: RouteNames.modeSelection,
        builder: (BuildContext context, GoRouterState state) {
          return const ModeSelectionView();
        },
      ),
      GoRoute(
        path: RouteNames.passengerProfile,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<PassengerProfileCubit>(
            create: (_) => PassengerProfileCubit(_profileRepository),
            child: const PassengerProfileView(),
          );
        },
      ),
      ShellRoute(
          builder: (context, state, child) => BlocProvider(
                create: (context) => PassengerHomeCubit(_profileRepository)
                  ..getProfile()
                  ..checkActiveRide(),
                child: PassengerHomeShell(child: child),
              ),
          routes: [
            GoRoute(
              path: RouteNames.passengerHome,
              builder: (BuildContext context, GoRouterState state) {
                return const PassengerHomeView();
              },
            ),
            GoRoute(
              path: RouteNames.passengerProfileEdit,
              builder: (context, state) {
                return BlocProvider<PassengerProfileEditCubit>(
                  create: (_) => PassengerProfileEditCubit(_profileRepository),
                  child: const PassengerProfileEditView(),
                );
              },
            ),
            GoRoute(
              path: RouteNames.passengerEmailEdit,
              builder: (context, state) {
                final currentEmail =
                    state.extra is String ? state.extra as String : '';
                return BlocProvider<EmailEditCubit>(
                  create: (_) => EmailEditCubit(
                    _profileRepository,
                    initialEmail: currentEmail,
                  ),
                  child: EmailEditView(
                    onSuccess: (email) {
                      context.read<PassengerHomeCubit>().updateEmail(email);
                    },
                  ),
                );
              },
            ),
            GoRoute(
              path: RouteNames.passengerPhoneEdit,
              builder: (context, state) {
                final currentPhone =
                    state.extra is String ? state.extra as String : '';
                return BlocProvider<PhoneEditCubit>(
                  create: (_) => PhoneEditCubit(
                    _profileRepository,
                    currentPhone: currentPhone,
                  ),
                  child: PhoneEditView(
                    onSuccess: (phone) {
                      context.read<PassengerHomeCubit>().updatePhone(phone);
                    },
                  ),
                );
              },
            ),
            GoRoute(
              path: RouteNames.rideRequest,
              builder: (context, state) {
                return BlocProvider<RideRequestCubit>(
                  create: (_) =>
                      RideRequestCubit(const PassengerRideRepository()),
                  child: const RideRequestView(),
                );
              },
            ),
            GoRoute(
              path: RouteNames.locationPicker,
              builder: (context, state) {
                final extra = state.extra;
                final args = extra is LocationPickerArgs
                    ? extra
                    : LocationPickerArgs(
                        label: (extra as String?) ?? 'Location');
                return BlocProvider<LocationPickerCubit>(
                  create: (_) =>
                      LocationPickerCubit()..init(initial: args.initial),
                  child: LocationPickerView(args: args),
                );
              },
            ),
            GoRoute(
              path: RouteNames.waitingOffers,
              builder: (context, state) {
                final args = state.extra as WaitingOffersArgs;
                return BlocProvider<WaitingOffersCubit>(
                  create: (_) => WaitingOffersCubit(
                    const PassengerRideRepository(),
                    args.response.rideRequestId,
                  )..startPolling(),
                  child: WaitingOffersView(args: args),
                );
              },
            ),
            GoRoute(
              path: RouteNames.passengerActiveRide,
              builder: (context, state) {
                return BlocProvider<PassengerActiveRideCubit>(
                  create: (_) => PassengerActiveRideCubit(
                    const PassengerRideRepository(),
                  )..loadActiveRide(),
                  child: const PassengerActiveRideView(),
                );
              },
            ),
            GoRoute(
              path: RouteNames.passengerRideHistory,
              builder: (context, state) {
                return BlocProvider<PassengerRideHistoryCubit>(
                  create: (_) => PassengerRideHistoryCubit(
                    const PassengerRideRepository(),
                  )..loadHistory(),
                  child: const PassengerRideHistoryView(),
                );
              },
            ),
            ShellRoute(
              builder: (context, state, child) => BlocProvider(
                create: (_) =>
                    SavedPlacesCubit(const AddressRepository())..getAddresses(),
                child: child,
              ),
              routes: [
                GoRoute(
                  path: RouteNames.savedPlaces,
                  builder: (context, state) => const SavedPlacesView(),
                ),
                GoRoute(
                  path: RouteNames.addressForm,
                  builder: (context, state) => const AddressCreateView(),
                ),
                GoRoute(
                  path: RouteNames.addressEdit,
                  builder: (context, state) {
                    return AddressEditView(
                      address: state.extra as AddressModel,
                    );
                  },
                ),
              ],
            ),
          ]),
      GoRoute(
        path: RouteNames.driverProfile,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<DriverProfileCubit>(
            create: (_) => DriverProfileCubit(
              _driverRepository,
              passengerProfile: state.extra as PassengerProfileModel?,
            ),
            child: const DriverRegistrationView(),
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => DriverHomeCubit(_driverRepository)
                ..getProfile()
                ..checkActiveRide(),
            ),
            BlocProvider(
              create: (_) =>
                  DriverAvailabilityCubit(const DriverAvailabilityRepository()),
            ),
            BlocProvider<WebSocketConnectionCubit>(
              create: (_) => WebSocketConnectionCubit(),
            ),
            // Shell-scoped so it keeps collecting `ride.broadcast` events while
            // the driver is online, regardless of which screen is showing.
            BlocProvider<AvailableRidesCubit>(
              create: (_) => AvailableRidesCubit(const DriverRideRepository()),
            ),
            // Shell-scoped too: the balance gate is read by the availability
            // toggle in the drawer as well as the wallet screens, and wallet
            // events land on the same driver socket at any time.
            BlocProvider<WalletCubit>(
              create: (_) => WalletCubit(const WalletRepository())..load(),
            ),
          ],
          child: DriverHomeShell(child: child),
        ),
        routes: [
          GoRoute(
            path: RouteNames.driverHome,
            builder: (BuildContext context, GoRouterState state) {
              return const DriverHomeView();
            },
          ),
          GoRoute(
            path: RouteNames.driverProfileEdit,
            builder: (context, state) {
              return const DriverProfileView();
            },
          ),
          GoRoute(
            path: RouteNames.driverEmailEdit,
            builder: (context, state) {
              final currentEmail =
                  state.extra is String ? state.extra as String : '';
              return BlocProvider<EmailEditCubit>(
                create: (_) => EmailEditCubit(
                  _profileRepository,
                  initialEmail: currentEmail,
                ),
                child: EmailEditView(
                  onSuccess: (email) {
                    context.read<DriverHomeCubit>().updateEmail(email);
                  },
                ),
              );
            },
          ),
          GoRoute(
            path: RouteNames.driverPhoneEdit,
            builder: (context, state) {
              final currentPhone =
                  state.extra is String ? state.extra as String : '';
              return BlocProvider<PhoneEditCubit>(
                create: (_) => PhoneEditCubit(
                  _profileRepository,
                  currentPhone: currentPhone,
                ),
                child: PhoneEditView(
                  onSuccess: (phone) {
                    context.read<DriverHomeCubit>().updatePhone(phone);
                  },
                ),
              );
            },
          ),
          GoRoute(
            path: RouteNames.availableRides,
            builder: (context, state) {
              return const AvailableRidesView();
            },
          ),
          GoRoute(
            path: RouteNames.driverRideHistory,
            builder: (context, state) {
              return BlocProvider<DriverRideHistoryCubit>(
                create: (_) => DriverRideHistoryCubit(
                  const DriverRideRepository(),
                )..loadHistory(),
                child: const DriverRideHistoryView(),
              );
            },
          ),
          GoRoute(
            path: RouteNames.driverWallet,
            builder: (context, state) => const DriverWalletView(),
          ),
          GoRoute(
            path: RouteNames.driverTopUp,
            builder: (context, state) {
              return BlocProvider<TopUpCubit>(
                create: (_) => TopUpCubit(
                    const WalletRepository(), ReceiptPickerService()),
                child: const TopUpFormView(),
              );
            },
          ),
          GoRoute(
            path: RouteNames.driverTopUpHistory,
            builder: (context, state) {
              return BlocProvider<TopUpCubit>(
                create: (_) => TopUpCubit(
                  const WalletRepository(),
                  ReceiptPickerService(),
                )..loadHistory(),
                child: const TopUpHistoryView(),
              );
            },
          ),
          GoRoute(
            path: RouteNames.driverActiveRide,
            builder: (context, state) {
              return BlocProvider<DriverActiveRideCubit>(
                create: (_) =>
                    DriverActiveRideCubit(const DriverRideRepository()),
                child: const DriverActiveRideView(),
              );
            },
          ),
          GoRoute(
            path: RouteNames.driverRideDetail,
            builder: (context, state) {
              final rideId = state.extra is String ? state.extra as String : '';
              return BlocProvider<DriverRideDetailCubit>(
                create: (_) => DriverRideDetailCubit(
                  const DriverRideRepository(),
                  rideId: rideId,
                )..load(),
                child: const DriverRideDetailView(),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.driverStatusReview,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<KycStatusCubit>(
            create: (_) => KycStatusCubit(_driverRepository),
            child: const DriverStatusReviewView(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.driverRejection,
        builder: (BuildContext context, GoRouterState state) {
          final reason = state.extra is String ? state.extra as String : '';
          return DriverRejectionView(rejectionReason: reason);
        },
      ),
    ],
  );
}
