import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/driver_ride_models.dart';

/// Local warning tier for the 30s..10s urgency window — no app-wide token
/// exists for amber, so it's kept as a single shared constant here.
const Color _warningAmber = Color(0xFFF59E0B);

/// Shared green→amber→red urgency ladder used by both the top progress bar
/// and the footer countdown pill, so they can't drift out of sync.
Color _urgencyColor(num remainingSeconds) {
  if (remainingSeconds <= 10) return AppColors.error;
  if (remainingSeconds <= 30) return _warningAmber;
  return AppColors.primary;
}

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

  @override
  Widget build(BuildContext context) {
    final m = compact ? _CardMetrics.compact : _CardMetrics.normal;

    return Container(
      margin: EdgeInsets.only(bottom: m.cardBottomMargin.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(m.cardRadius.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: m.shadowAlpha),
            blurRadius: m.shadowBlur.r,
            offset: Offset(0, m.shadowOffsetY.h),
          ),
        ],
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
                  // --- Header: service / vehicle chips / female-only · fare ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _ServiceTypeChip(
                              serviceType: ride.serviceType,
                              iconSize: m.serviceIconSize,
                              hPad: m.chipHPad,
                              vPad: m.chipVPad,
                            ),
                            if (ride.vehicleCategory != null)
                              _ServiceVehicleChip(
                                category: ride.vehicleCategory!,
                                iconSize: m.serviceIconSize,
                                hPad: m.chipHPad,
                                vPad: m.chipVPad,
                              ),
                            if (ride.femaleOnly) const _FemaleOnlyBadge(),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _FareBlock(
                        amount: ride.proposedFare,
                        fareFontSize: m.fareFontSize,
                        captionFontSize: m.fareCaptionSize,
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
                    child: Container(
                      width: 1.5.w,
                      height: m.connectorHeight.h,
                      color: AppColors.textSecondary(context)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  _LocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.error,
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
    required this.shadowAlpha,
    required this.shadowBlur,
    required this.shadowOffsetY,
    required this.chipHPad,
    required this.chipVPad,
    required this.fareFontSize,
    required this.fareCaptionSize,
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
  final double shadowAlpha;
  final double shadowBlur; // .r
  final double shadowOffsetY; // .h
  final double chipHPad; // .w
  final double chipVPad; // .h
  final double fareFontSize; // .sp
  final double fareCaptionSize; // .sp

  /// Tightened base size used in the available-rides list.
  static const normal = _CardMetrics(
    cardBottomMargin: 8,
    cardRadius: 12,
    contentPadding: 10,
    contentTop: 8,
    serviceIconSize: 14,
    gapHeaderRoute: 6,
    connectorHeight: 10,
    connectorInset: 6.5,
    gapRouteFooter: 8,
    metaIconSize: 12,
    countdownIconSize: 12,
    buttonHeight: 30,
    buttonRadius: 8,
    buttonGap: 6,
    ignoreButtonHPad: 10,
    bidButtonHPad: 20,
    progressHeight: 3,
    locationIconSize: 14,
    locationSpacing: 6,
    shadowAlpha: 0.06,
    shadowBlur: 12,
    shadowOffsetY: 3,
    chipHPad: 8,
    chipVPad: 4,
    fareFontSize: 17,
    fareCaptionSize: 10,
  );

  /// One step tighter — used by the floating [BroadcastOverlay].
  static const compact = _CardMetrics(
    cardBottomMargin: 4,
    cardRadius: 10,
    contentPadding: 8,
    contentTop: 6,
    serviceIconSize: 13,
    gapHeaderRoute: 4,
    connectorHeight: 8,
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
    locationIconSize: 13,
    locationSpacing: 5,
    shadowAlpha: 0.05,
    shadowBlur: 8,
    shadowOffsetY: 2,
    chipHPad: 6,
    chipVPad: 3,
    fareFontSize: 14,
    fareCaptionSize: 9,
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
    final color = _urgencyColor(remainingSeconds);

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
    final color = _urgencyColor(clamped.inSeconds);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: widget.iconSize.w, color: color),
          SizedBox(width: 4.w),
          Text(
            _formatRemaining(clamped),
            style: AppTextStyles.labelSmall(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

/// Colored pill surfacing whether the request is a Ride or a Delivery, so
/// drivers can tell the two apart at a glance without reading the addresses.
class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({
    required this.serviceType,
    required this.iconSize,
    required this.hPad,
    required this.vPad,
  });

  static const Color _deliveryColor = Color(0xFF3B82F6);

  final ServiceType serviceType;
  final double iconSize;
  final double hPad;
  final double vPad;

  @override
  Widget build(BuildContext context) {
    final color =
        serviceType == ServiceType.delivery ? _deliveryColor : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad.w, vertical: vPad.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(serviceType.icon, size: iconSize.w, color: color),
          SizedBox(width: 3.w),
          Text(
            serviceType.label,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quiet neutral pill surfacing the ride's vehicle category (icon + label),
/// data that previously existed on the model but was never rendered.
class _ServiceVehicleChip extends StatelessWidget {
  const _ServiceVehicleChip({
    required this.category,
    required this.iconSize,
    required this.hPad,
    required this.vPad,
  });

  final VehicleCategory category;
  final double iconSize;
  final double hPad;
  final double vPad;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad.w, vertical: vPad.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: iconSize.w, color: color),
          SizedBox(width: 3.w),
          Text(
            category.label,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-aligned proposed-fare block, the card's primary visual hook.
class _FareBlock extends StatelessWidget {
  const _FareBlock({
    required this.amount,
    required this.fareFontSize,
    required this.captionFontSize,
  });

  final int amount;
  final double fareFontSize;
  final double captionFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_formatFare(amount)} DZD',
          style: AppTextStyles.headingSmall(context).copyWith(
            fontSize: fareFontSize.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.1,
          ),
        ),
        Text(
          'proposed fare',
          style: AppTextStyles.labelSmall(context).copyWith(
            color: AppColors.textSecondary(context),
            fontSize: captionFontSize.sp,
          ),
        ),
      ],
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
