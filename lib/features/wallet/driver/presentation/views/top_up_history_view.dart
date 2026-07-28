import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_slim_app_bar.dart';
import '../../data/models/wallet_models.dart';
import '../cubit/top_up_cubit/top_up_cubit.dart';
import '../cubit/top_up_cubit/top_up_state.dart';
import 'widgets/top_up_history_card.dart';
import 'widgets/wallet_placeholders.dart';

/// The driver's own top-up requests, newest first, filterable by status.
class TopUpHistoryView extends StatefulWidget {
  const TopUpHistoryView({super.key});

  @override
  State<TopUpHistoryView> createState() => _TopUpHistoryViewState();
}

class _TopUpHistoryViewState extends State<TopUpHistoryView> {
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
      context.read<TopUpCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppSlimAppBar(title: 'Top-up history'),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<TopUpCubit, TopUpState>(
              buildWhen: (prev, curr) => prev.filter != curr.filter,
              builder: (context, state) => _StatusFilterBar(
                selected: state.filter,
                onChanged: (status) => context.read<TopUpCubit>().loadHistory(
                      filter: status,
                      clearFilter: status == null,
                    ),
              ),
            ),
            Expanded(
              child: BlocBuilder<TopUpCubit, TopUpState>(
                builder: (context, state) {
                  if (state.topUps.isEmpty) {
                    return _buildEmptyState(state);
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<TopUpCubit>().loadHistory(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      itemCount:
                          state.topUps.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.topUps.length) {
                          return WalletListFooter(
                              isLoading: state.isLoadingMore);
                        }
                        return TopUpHistoryCard(topUp: state.topUps[index]);
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

  Widget _buildEmptyState(TopUpState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == TopUpStatusUi.failure) {
      return WalletMessage(
        icon: Icons.error_outline_rounded,
        text: state.errorMessage.isEmpty
            ? 'Something went wrong'
            : state.errorMessage,
      );
    }
    return const WalletMessage(
      icon: Icons.add_card_rounded,
      text: 'No top-up requests yet.',
    );
  }
}

/// `null` means "all statuses" — the API's `status` filter is optional.
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onChanged});

  final TopUpStatus? selected;
  final ValueChanged<TopUpStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final status in TopUpStatus.values)
            _FilterChip(
              label: status.label,
              isSelected: selected == status,
              onTap: () => onChanged(status),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        showCheckmark: false,
        side: BorderSide(
          color:
              isSelected ? AppColors.primary : AppColors.borderDefault(context),
          width: 1.w,
        ),
      ),
    );
  }
}
