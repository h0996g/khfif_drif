import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/token_payload.dart';
import 'ride_socket_service.dart';

/// Streams the driver's GPS position upstream as `driver.location` envelopes
/// every 5s while the driver socket is connected.
///
/// Armed by [DriverAvailabilityCubit] on go-online and disarmed on
/// go-offline. While armed it follows [RideSocketService.statusStream], so it
/// also pauses/resumes automatically across the service's own
/// reconnect/backoff cycles — no extra wiring needed beyond the initial
/// start/stop call. Implemented as a static singleton to match
/// [RideSocketService].
///
/// See `swagger/epic-03-ride.md` §7/§9/§11.
final class DriverLocationStreamer {
  DriverLocationStreamer._();

  static const Duration _interval = Duration(seconds: 15);

  static StreamSubscription<RideSocketStatus>? _statusSub;
  static Timer? _timer;
  static bool _armed = false;

  /// Arms the streamer. Idempotent. Syncs against the socket's *current*
  /// status immediately, so calling this right after a successful
  /// [RideSocketService.connect] starts sending without waiting for the next
  /// status event.
  static void start() {
    if (_armed) return;
    _armed = true;
    _statusSub ??= RideSocketService.statusStream.listen(_onStatus);
    _sync(RideSocketService.status);
  }

  /// Disarms the streamer and stops any in-flight timer. Idempotent.
  static void stop() {
    _armed = false;
    _statusSub?.cancel();
    _statusSub = null;
    _stopTimer();
  }

  /// Disarms the streamer and disconnects the driver socket together.
  /// Idempotent — safe to call even if neither was running.
  static Future<void> stopAndDisconnect() async {
    stop();
    await RideSocketService.disconnect();
  }

  static void _onStatus(RideSocketStatus status) {
    if (_armed) _sync(status);
  }

  static void _sync(RideSocketStatus status) {
    final shouldStream = status == RideSocketStatus.connected &&
        RideSocketService.activeRole == ActiveRole.driver;
    if (shouldStream) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  static void _startTimer() {
    if (_timer != null) return;
    unawaited(_tick());
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  static void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _tick() async {
    try {
      if (!await _hasLocationPermission()) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final envelope = {
        'type': 'driver.location',
        'payload': {
          'lat': position.latitude,
          'lng': position.longitude,
          'capturedAt': position.timestamp.toUtc().toIso8601String(),
          'accuracyM': position.accuracy,
        },
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      final sent = RideSocketService.send(envelope);
      _log('${sent ? 'sent' : 'send skipped'} driver.location $envelope');
    } catch (e) {
      _log('tick failed: $e');
    }
  }

  /// Same permission flow as `LocationPickerCubit.init()` — request once if
  /// undetermined, otherwise silently skip the tick when denied. No error is
  /// surfaced; the driver stays online/connected regardless.
  static Future<bool> _hasLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static void _log(String msg) {
    if (kDebugMode) debugPrint('[DriverLocationStreamer] $msg');
  }
}
