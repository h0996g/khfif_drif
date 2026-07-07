import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Result of [showRideHistoryDateRangeDialog]: the edited from/to dates.
typedef RideHistoryDateRange = ({DateTime? from, DateTime? to});

/// Compact popover (not a full sheet) for picking the ride-history date
/// range. Triggered from the top bar's calendar icon. Returns the edited
/// range, or `null` if dismissed without confirming.
Future<RideHistoryDateRange?> showRideHistoryDateRangeDialog(
  BuildContext context, {
  required DateTime? from,
  required DateTime? to,
}) {
  return showDialog<RideHistoryDateRange>(
    context: context,
    builder: (_) => _DateRangeDialog(initialFrom: from, initialTo: to),
  );
}

class _DateRangeDialog extends StatefulWidget {
  const _DateRangeDialog({this.initialFrom, this.initialTo});

  final DateTime? initialFrom;
  final DateTime? initialTo;

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  late DateTime? _from = widget.initialFrom;
  late DateTime? _to = widget.initialTo;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDate(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  void _clear() {
    HapticFeedback.selectionClick();
    setState(() {
      _from = null;
      _to = null;
    });
  }

  void _done() => Navigator.pop(context, (from: _from, to: _to));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background(context),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Date range', style: AppTextStyles.headingSmall(context)),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'From',
                    value: _from == null ? 'Any' : _formatDate(_from!),
                    isSet: _from != null,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _DateButton(
                    label: 'To',
                    value: _to == null ? 'Any' : _formatDate(_to!),
                    isSet: _to != null,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _from == null && _to == null ? null : _clear,
                    child: Text(
                      'Clear dates',
                      style: AppTextStyles.labelLarge(context).copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      child: InkWell(
                        onTap: _done,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Center(
                          child: Text(
                            'Done',
                            style: AppTextStyles.labelLarge(context).copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.isSet,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSet
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSet
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.borderDefault(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall(context).copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSet ? AppColors.primary : AppColors.text(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
