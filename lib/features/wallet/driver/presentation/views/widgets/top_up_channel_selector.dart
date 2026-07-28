import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../data/models/wallet_models.dart';

/// How the driver handed the money over: cash at an office, or a bank
/// transfer. Both need a receipt either way.
class TopUpChannelSelector extends StatelessWidget {
  const TopUpChannelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TopUpChannel selected;
  final ValueChanged<TopUpChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final channel in TopUpChannel.values) ...[
          Expanded(
            child: _ChannelOption(
              channel: channel,
              isSelected: channel == selected,
              onTap: () => onChanged(channel),
            ),
          ),
          if (channel != TopUpChannel.values.last) SizedBox(width: 10.w),
        ],
      ],
    );
  }
}

class _ChannelOption extends StatelessWidget {
  const _ChannelOption({
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  final TopUpChannel channel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderDefault(context),
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              channel == TopUpChannel.cash
                  ? Icons.payments_rounded
                  : Icons.account_balance_rounded,
              size: 19.w,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                channel.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium(context).copyWith(
                  color: isSelected ? AppColors.primary : AppColors.text(context),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
