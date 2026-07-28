import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/passenger_ride_models.dart';
import '../../../../../shared/utils/fare_formatter.dart';
import '../../../../../shared/utils/name_initials.dart';

class OfferCard extends StatefulWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.isAccepting,
    this.proposedFare,
    required this.onAccept,
    required this.onRefuse,
    required this.onExpired,
  });

  final OfferEntry offer;
  final bool isAccepting;

  /// The fare the passenger originally proposed. When provided, the card shows
  /// how each offer compares (higher / lower / matching).
  final int? proposedFare;

  final VoidCallback onAccept;
  final VoidCallback onRefuse;
  final VoidCallback onExpired;

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  late int _secondsLeft;
  late final int _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = max(
      0,
      DateTime.parse(widget.offer.expiresAt)
          .difference(DateTime.now())
          .inSeconds,
    );
    // Capture the window at mount to drive the bar's fill fraction.
    _totalSeconds = max(1, _secondsLeft);
    if (_secondsLeft > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } else {
      // Already expired when mounted — remove on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onExpired());
    }
  }

  void _tick(Timer _) {
    if (_secondsLeft <= 1) {
      _timer?.cancel();
      widget.onExpired();
    } else {
      setState(() => _secondsLeft--);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final etaMin =
        offer.etaSeconds != null ? (offer.etaSeconds! / 60).ceil() : null;
    final progress = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);
    final isLow = _secondsLeft <= 10;
    final accent = isLow ? AppColors.error : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDefault(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withValues(alpha: AppColors.isDark(context) ? 0.30 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Countdown bar across the top edge (drains over the offer window).
          _CountdownBar(progress: progress, color: accent),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FareStub(
                  fare: offer.fare,
                  proposedFare: widget.proposedFare,
                ),
                const _VerticalDashedLine(),
                Expanded(
                  child: _DriverSide(
                    initials: initialsOf(offer.driverFullName),
                    name: offer.driverFullName,
                    ratingAvg: offer.driverRatingAvg,
                    vehicleModel: offer.vehicleModel,
                    vehiclePlate: offer.vehiclePlate,
                    etaMin: etaMin,
                    secondsLeft: _secondsLeft,
                    timerColor: accent,
                    isAccepting: widget.isAccepting,
                    onAccept: widget.onAccept,
                    onRefuse: widget.onRefuse,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top-edge countdown bar ───────────────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      minHeight: 3.h,
      backgroundColor: AppColors.borderDefault(context),
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }
}

// ── Fare "stub" — tinted left block holding the price + delta ────────────────

class _FareStub extends StatelessWidget {
  const _FareStub({required this.fare, required this.proposedFare});

  final int fare;
  final int? proposedFare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      color: AppColors.primary.withValues(alpha: 0.07),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatFare(fare),
                  style: AppTextStyles.headingSmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(width: 3.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text(
                    'DZD',
                    style: AppTextStyles.labelSmall(context).copyWith(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (proposedFare != null) ...[
            SizedBox(height: 5.h),
            _FareDeltaChip(diff: fare - proposedFare!),
          ],
        ],
      ),
    );
  }
}

class _FareDeltaChip extends StatelessWidget {
  const _FareDeltaChip({required this.diff});

  final int diff;

  @override
  Widget build(BuildContext context) {
    // For a passenger: cheaper or matching is good (primary), costlier is bad
    // (error).
    final bool costlier = diff > 0;
    final color = costlier ? AppColors.error : AppColors.primary;

    final icon = diff == 0
        ? Icons.check_rounded
        : (costlier ? Icons.north_rounded : Icons.south_rounded);
    final label = diff == 0 ? 'Match' : '${diff.abs()} DZD';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.w, color: color),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed ticket perforation ────────────────────────────────────────────────

class _VerticalDashedLine extends StatelessWidget {
  const _VerticalDashedLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: SizedBox(
        width: 2.w,
        child: CustomPaint(
          painter: _DashedLinePainter(color: AppColors.borderDefault(context)),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;
    const dashHeight = 3.0;
    const gap = 3.0;
    for (double y = 0; y < size.height; y += dashHeight + gap) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ── Driver side — identity, ETA/timer, and actions ───────────────────────────

class _DriverSide extends StatelessWidget {
  const _DriverSide({
    required this.initials,
    required this.name,
    required this.ratingAvg,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.etaMin,
    required this.secondsLeft,
    required this.timerColor,
    required this.isAccepting,
    required this.onAccept,
    required this.onRefuse,
  });

  final String initials;
  final String name;
  final double? ratingAvg;
  final String vehicleModel;
  final String? vehiclePlate;
  final int? etaMin;
  final int secondsLeft;
  final Color timerColor;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: AppTextStyles.labelSmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    _MetaLine(
                      ratingAvg: ratingAvg,
                      vehicleModel: vehicleModel,
                      vehiclePlate: vehiclePlate,
                    ),
                  ],
                ),
              ),
              if (etaMin != null) ...[
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.w,
                          color: AppColors.textSecondary(context),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '$etaMin min',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${secondsLeft}s',
                      style: AppTextStyles.labelSmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: timerColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text(context),
                    side: BorderSide(color: AppColors.borderDefault(context)),
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: isAccepting ? null : onRefuse,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 14.w),
                        SizedBox(width: 4.w),
                        Text(
                          'Decline',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: isAccepting
                                ? AppColors.buttonDisabledText(context)
                                : AppColors.text(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: isAccepting ? null : onAccept,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 15.w),
                        SizedBox(width: 4.w),
                        Text(
                          'Accept',
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.ratingAvg,
    required this.vehicleModel,
    required this.vehiclePlate,
  });

  final double? ratingAvg;
  final String vehicleModel;
  final String? vehiclePlate;

  @override
  Widget build(BuildContext context) {
    final hasRating = ratingAvg != null;
    return Row(
      children: [
        if (hasRating) ...[
          Icon(Icons.star_rounded, size: 12.w, color: AppColors.text(context)),
          SizedBox(width: 2.w),
          Text(
            ratingAvg!.toStringAsFixed(1),
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.text(context),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ] else
          Text(
            'New',
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        SizedBox(width: 5.w),
        Text(
          '·',
          style: AppTextStyles.labelSmall(context)
              .copyWith(color: AppColors.textSecondary(context)),
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            vehiclePlate != null
                ? '$vehicleModel · $vehiclePlate'
                : vehicleModel,
            style: AppTextStyles.labelSmall(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
