import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../home/passenger/presentation/views/widgets/top_bar.dart';
import '../../../shared/widgets/ride_history_date_range_dialog.dart';
import '../../../shared/widgets/ride_history_filter_bar.dart';
import '../cubit/passenger_ride_history_cubit/passenger_ride_history_cubit.dart';
import '../cubit/passenger_ride_history_cubit/passenger_ride_history_state.dart';
import 'widgets/passenger_ride_history/passenger_ride_history_card.dart';

class PassengerRideHistoryView extends StatefulWidget {
  const PassengerRideHistoryView({super.key});

  @override
  State<PassengerRideHistoryView> createState() =>
      _PassengerRideHistoryViewState();
}

class _PassengerRideHistoryViewState extends State<PassengerRideHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<PassengerRideHistoryCubit>().loadMore();
    }
  }

  Future<void> _openDateRangeDialog(BuildContext context) async {
    final cubit = context.read<PassengerRideHistoryCubit>();
    final filter = cubit.state.filter;
    final result = await showRideHistoryDateRangeDialog(
      context,
      from: filter.from,
      to: filter.to,
    );
    if (result == null) return;
    cubit.loadHistory(
      filter: filter.copyWith(from: () => result.from, to: () => result.to),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<PassengerRideHistoryCubit, PassengerRideHistoryState>(
              buildWhen: (prev, curr) => prev.filter != curr.filter,
              builder: (context, state) {
                final hasDateRange =
                    state.filter.from != null || state.filter.to != null;
                return Column(
                  children: [
                    TopBar(
                      title: 'Ride History',
                      trailingIcon: hasDateRange
                          ? Icons.event_available_rounded
                          : Icons.calendar_month_rounded,
                      onTrailingTap: () => _openDateRangeDialog(context),
                    ),
                    RideHistoryFilterBar(
                      filter: state.filter,
                      onChanged: (updated) =>
                          context.read<PassengerRideHistoryCubit>().loadHistory(
                                filter: updated,
                              ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocConsumer<PassengerRideHistoryCubit,
                  PassengerRideHistoryState>(
                listenWhen: (prev, curr) =>
                    prev.errorMessage != curr.errorMessage &&
                    curr.errorMessage.isNotEmpty &&
                    curr.rides.isNotEmpty,
                // Transient refresh/loadMore failures: toast them instead of
                // wiping the cards already on screen.
                listener: (context, state) =>
                    AppToast.error(state.errorMessage),
                builder: (context, state) {
                  if (state.rides.isEmpty) return _buildEmptyState(state);

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context
                        .read<PassengerRideHistoryCubit>()
                        .loadHistory(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      itemCount:
                          state.rides.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.rides.length) {
                          return _ListFooter(isLoading: state.isLoadingMore);
                        }
                        return PassengerRideHistoryCard(
                            ride: state.rides[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full-screen placeholder shown while the first page is loading, on a
  /// first-load failure, or when the passenger has no history yet.
  Widget _buildEmptyState(PassengerRideHistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == PassengerRideHistoryStatus.failure) {
      return _Message(
        icon: Icons.error_outline_rounded,
        text: state.errorMessage.isEmpty
            ? 'Something went wrong'
            : state.errorMessage,
      );
    }
    return const _Message(
      icon: Icons.history_rounded,
      text: 'No rides yet. Your completed and cancelled rides will '
          'appear here.',
    );
  }

}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.w, color: AppColors.textSecondary(context)),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
