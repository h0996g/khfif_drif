import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../home/passenger/presentation/views/widgets/top_bar.dart';
import '../../../shared/widgets/ride_history_date_range_dialog.dart';
import '../../../shared/widgets/ride_history_filter_bar.dart';
import '../cubit/driver_ride_history_cubit/driver_ride_history_cubit.dart';
import '../cubit/driver_ride_history_cubit/driver_ride_history_state.dart';
import 'widgets/driver_ride_history/driver_ride_history_card.dart';

class DriverRideHistoryView extends StatefulWidget {
  const DriverRideHistoryView({super.key});

  @override
  State<DriverRideHistoryView> createState() => _DriverRideHistoryViewState();
}

class _DriverRideHistoryViewState extends State<DriverRideHistoryView> {
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
      context.read<DriverRideHistoryCubit>().loadMore();
    }
  }

  Future<void> _openDateRangeDialog(BuildContext context) async {
    final cubit = context.read<DriverRideHistoryCubit>();
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
            BlocBuilder<DriverRideHistoryCubit, DriverRideHistoryState>(
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
                          context.read<DriverRideHistoryCubit>().loadHistory(
                                filter: updated,
                              ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocConsumer<DriverRideHistoryCubit,
                  DriverRideHistoryState>(
                listenWhen: (prev, curr) =>
                    prev.errorMessage != curr.errorMessage &&
                    curr.errorMessage.isNotEmpty &&
                    curr.rides.isNotEmpty,
                listener: _onFailureWithList,
                builder: (context, state) {
                  if (state.rides.isEmpty) return _buildEmptyState(state);

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<DriverRideHistoryCubit>().loadHistory(),
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
                        return DriverRideHistoryCard(ride: state.rides[index]);
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
  /// first-load failure, or when the driver has no history yet.
  Widget _buildEmptyState(DriverRideHistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == DriverRideHistoryStatus.failure) {
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

  /// Surface transient failures (refresh / loadMore) as a snackbar instead of
  /// wiping the cards that are already on screen.
  void _onFailureWithList(
    BuildContext context,
    DriverRideHistoryState state,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
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
