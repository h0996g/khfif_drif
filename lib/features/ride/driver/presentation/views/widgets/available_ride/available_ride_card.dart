import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/driver_ride_models.dart';

/// A single incoming ride request shown to the driver. Service & vehicle chips
/// and an optional female-only badge on top, the pickup→dropoff route, a meta
/// row with a live expiry countdown and distance, then the proposed fare and a
/// Bid button. A draining [LinearProgressIndicator] at the top of the card
/// shows time remaining visually.
///
/// Pass [compact] for the floating [BroadcastOverlay] to render the same card
/// at a tighter density.
class AvailableRideCard extends StatelessWidget {
  const AvailableRideCard({
    super.key,
    required this.ride,
    required this.onBid,
    this.onIgnore,
    this.onExpired,
    this.compact = false,
  });

  final AvailableRequestCard ride;
  final VoidCallback onBid;
  final VoidCallback? onIgnore;
  final VoidCallback? onExpired;

  /// Shrinks every dimension for the floating [BroadcastOverlay].
  final bool compact;

  static const Color _dropoffColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final m = compact ? _CardMetrics.compact : _CardMetrics.normal;

    return Container(
      margin: EdgeInsets.only(bottom: m.cardBottomMargin.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(m.cardRadius.r),
        border: Border.all(color: AppColors.borderDefault(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(m.cardRadius.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Linear timer bar ---
            _ExpiryProgressBar(
              expiresAt: ride.expiresAt,
              barHeight: m.progressHeight,
              onExpired: onExpired,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(m.contentPadding.w, m.contentTop.h,
                  m.contentPadding.w, m.contentPadding.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: service / vehicle / female-only · fare ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (ride.femaleOnly) ...[
                        SizedBox(width: 6.w),
                        const _FemaleOnlyBadge(),
                      ],
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_formatFare(ride.proposedFare)} DZD',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'proposed fare',
                            style: AppTextStyles.labelSmall(context).copyWith(
                              color: AppColors.textSecondary(context),
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: m.gapHeaderRoute.h),

                  // --- Route: pickup → dropoff ---
                  _LocationRow(
                    icon: Icons.trip_origin_rounded,
                    iconColor: AppColors.primary,
                    address: ride.pickup.address,
                    iconSize: m.locationIconSize,
                    spacing: m.locationSpacing,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: m.connectorInset.w),
                    child: SizedBox(
                      height: m.connectorHeight.h,
                      child: VerticalDivider(
                        color: AppColors.borderDefault(context),
                        thickness: 1.5,
                        width: 1,
                      ),
                    ),
                  ),
                  _LocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: _dropoffColor,
                    address: ride.dropoff.address,
                    iconSize: m.locationIconSize,
                    spacing: m.locationSpacing,
                  ),
                  SizedBox(height: m.gapRouteFooter.h),

                  // --- Footer: countdown · distance · Ignore · Bid ---
                  Row(
                    children: [
                      _ExpiryCountdown(
                        expiresAt: ride.expiresAt,
                        iconSize: m.countdownIconSize,
                      ),
                      if (ride.distanceMeters != null) ...[
                        _MetaDot(),
                        Icon(Icons.straighten_rounded,
                            size: m.metaIconSize.w,
                            color: AppColors.textSecondary(context)),
                        SizedBox(width: 2.w),
                        Text(
                          _formatDistance(ride.distanceMeters!),
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary(context),
                          side: BorderSide(
                              color: AppColors.borderDefault(context)),
                          minimumSize: Size(0, m.buttonHeight.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                              horizontal: m.ignoreButtonHPad.w),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(m.buttonRadius.r),
                          ),
                        ),
                        onPressed: onIgnore,
                        child: Text(
                          'Ignore',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: m.buttonGap.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: Size(0, m.buttonHeight.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                              horizontal: m.bidButtonHPad.w),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(m.buttonRadius.r),
                          ),
                        ),
                        onPressed: onBid,
                        child: Text(
                          'Bid',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDistance(int meters) =>
    meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '$meters m';

/// Space-groups thousands for readability: 1200 → "1 200".
String _formatFare(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// All tunable dimensions for [AvailableRideCard], stored as raw values so the
/// `.w/.h/.r` ScreenUtil scaling is applied at each use site. Two presets:
/// [normal] (list view) and [compact] (floating overlay).
class _CardMetrics {
  const _CardMetrics({
    required this.cardBottomMargin,
    required this.cardRadius,
    required this.contentPadding,
    required this.contentTop,
    required this.serviceIconSize,
    required this.gapHeaderRoute,
    required this.connectorHeight,
    required this.connectorInset,
    required this.gapRouteFooter,
    required this.metaIconSize,
    required this.countdownIconSize,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonGap,
    required this.ignoreButtonHPad,
    required this.bidButtonHPad,
    required this.progressHeight,
    required this.locationIconSize,
    required this.locationSpacing,
  });

  final double cardBottomMargin; // .h
  final double cardRadius; // .r
  final double contentPadding; // .w
  final double contentTop; // .h
  final double serviceIconSize; // .w
  final double gapHeaderRoute; // .h
  final double connectorHeight; // .h
  final double connectorInset; // .w
  final double gapRouteFooter; // .h
  final double metaIconSize; // .w
  final double countdownIconSize; // .w
  final double buttonHeight; // .h
  final double buttonRadius; // .r
  final double buttonGap; // .w
  final double ignoreButtonHPad; // .w
  final double bidButtonHPad; // .w
  final double progressHeight; // .h
  final double locationIconSize; // .w
  final double locationSpacing; // .w

  /// Tightened base size used in the available-rides list.
  static const normal = _CardMetrics(
    cardBottomMargin: 8,
    cardRadius: 12,
    contentPadding: 10,
    contentTop: 8,
    serviceIconSize: 14,
    gapHeaderRoute: 6,
    connectorHeight: 8,
    connectorInset: 6.5,
    gapRouteFooter: 8,
    metaIconSize: 12,
    countdownIconSize: 12,
    buttonHeight: 30,
    buttonRadius: 8,
    buttonGap: 6,
    ignoreButtonHPad: 10,
    bidButtonHPad: 18,
    progressHeight: 2.5,
    locationIconSize: 13,
    locationSpacing: 6,
  );

  /// One step tighter — used by the floating [BroadcastOverlay].
  static const compact = _CardMetrics(
    cardBottomMargin: 4,
    cardRadius: 10,
    contentPadding: 8,
    contentTop: 6,
    serviceIconSize: 13,
    gapHeaderRoute: 4,
    connectorHeight: 6,
    connectorInset: 6,
    gapRouteFooter: 6,
    metaIconSize: 11,
    countdownIconSize: 11,
    buttonHeight: 28,
    buttonRadius: 8,
    buttonGap: 5,
    ignoreButtonHPad: 8,
    bidButtonHPad: 14,
    progressHeight: 2.5,
    locationIconSize: 12,
    locationSpacing: 5,
  );
}

/// Full-width draining progress bar at the top of the card.
/// Rebuilds every second; only this widget re-renders, not the card.
class _ExpiryProgressBar extends StatefulWidget {
  const _ExpiryProgressBar({
    required this.expiresAt,
    required this.barHeight,
    this.onExpired,
  });

  final String expiresAt;
  final double barHeight;
  final VoidCallback? onExpired;

  @override
  State<_ExpiryProgressBar> createState() => _ExpiryProgressBarState();
}

class _ExpiryProgressBarState extends State<_ExpiryProgressBar> {
  Timer? _timer;
  DateTime? _deadline;
  late double _totalSeconds;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _deadline = DateTime.tryParse(widget.expiresAt);
    if (_deadline != null) {
      _totalSeconds =
          _deadline!.difference(DateTime.now()).inSeconds.toDouble();
      if (_totalSeconds <= 0) _totalSeconds = 1;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (!_expired && _deadline!.isBefore(DateTime.now())) {
          _expired = true;
          widget.onExpired?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _deadline == null
        ? Duration.zero
        : _deadline!.difference(DateTime.now());
    final remainingSeconds =
        remaining.isNegative ? 0.0 : remaining.inSeconds.toDouble();
    final progress = (remainingSeconds / _totalSeconds).clamp(0.0, 1.0);

    final Color color;
    if (remainingSeconds <= 10) {
      color = const Color(0xFFEF4444);
    } else if (remainingSeconds <= 30) {
      color = const Color(0xFFF59E0B);
    } else {
      color = AppColors.primary;
    }

    return LinearProgressIndicator(
      value: progress,
      minHeight: widget.barHeight.h,
      backgroundColor: AppColors.borderDefault(context),
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }
}

/// Live `m:ss` text countdown to [expiresAt] (ISO-8601), floored at `0:00`.
class _ExpiryCountdown extends StatefulWidget {
  const _ExpiryCountdown({
    required this.expiresAt,
    required this.iconSize,
  });

  final String expiresAt;
  final double iconSize;

  @override
  State<_ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<_ExpiryCountdown> {
  Timer? _timer;
  late DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _deadline = DateTime.tryParse(widget.expiresAt);
    if (_deadline != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _deadline == null
        ? Duration.zero
        : _deadline!.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final isUrgent = clamped.inSeconds <= 10;
    final color =
        isUrgent ? const Color(0xFFEF4444) : AppColors.textSecondary(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: widget.iconSize.w, color: color),
        SizedBox(width: 4.w),
        Text(
          _formatRemaining(clamped),
          style: AppTextStyles.labelSmall(context).copyWith(color: color),
        ),
      ],
    );
  }
}

String _formatRemaining(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _FemaleOnlyBadge extends StatelessWidget {
  const _FemaleOnlyBadge();

  static const Color _color = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.female_rounded, size: 14.w, color: _color),
          SizedBox(width: 3.w),
          Text(
            'Women',
            style: AppTextStyles.labelSmall(context).copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        '·',
        style: AppTextStyles.labelSmall(context).copyWith(
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.address,
    required this.iconSize,
    required this.spacing,
  });

  final IconData icon;
  final Color iconColor;
  final String address;
  final double iconSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize.w, color: iconColor),
        SizedBox(width: spacing.w),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.bodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
