import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/widgets/app_toast.dart';
import '../../../../data/models/driver_ride_models.dart';
import '../../../../../passenger/presentation/views/widgets/location/map_button.dart';

/// Full-screen live map for the driver's active ride. Shows pickup and dropoff
/// markers plus the driver's own GPS position (when available), with built-in
/// zoom controls.
class ActiveRideMap extends StatefulWidget {
  const ActiveRideMap({
    super.key,
    required this.ride,
    required this.driverPosition,
  });

  final ActiveDriverRideResponse ride;
  final Position? driverPosition;

  @override
  State<ActiveRideMap> createState() => _ActiveRideMapState();
}

class _ActiveRideMapState extends State<ActiveRideMap> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Recenters the camera on the driver's own live GPS position (already
  /// streamed by the parent view). Keeps the current zoom level.
  void _goToDriverLocation() {
    final position = widget.driverPosition;
    if (position == null) {
      AppToast.error('Locating your position, please wait.');
      return;
    }
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      _mapController.camera.zoom,
    );
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + 1).clamp(0, 19));
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom - 1).clamp(0, 19));
  }

  @override
  Widget build(BuildContext context) {
    final pickupPoint = LatLng(widget.ride.pickup.lat, widget.ride.pickup.lng);
    final dropoffPoint =
        LatLng(widget.ride.dropoff.lat, widget.ride.dropoff.lng);
    final centerLat =
        (widget.ride.pickup.lat + widget.ride.dropoff.lat) / 2;
    final centerLng =
        (widget.ride.pickup.lng + widget.ride.dropoff.lng) / 2;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'khfif_drif',
            ),
            MarkerLayer(
              markers: [
                // Pickup marker
                Marker(
                  point: pickupPoint,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.trip_origin_rounded,
                        color: AppColors.white, size: 16.w),
                  ),
                ),
                // Dropoff marker
                Marker(
                  point: dropoffPoint,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_rounded,
                        color: AppColors.white, size: 16.w),
                  ),
                ),
                // Driver's own GPS position
                if (widget.driverPosition != null)
                  Marker(
                    point: LatLng(
                      widget.driverPosition!.latitude,
                      widget.driverPosition!.longitude,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(Icons.directions_car_rounded,
                          color: AppColors.white, size: 16.w),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Map controls: current location + zoom in/out (top-right)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          right: 16.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MapButton(
                icon: Icons.my_location_rounded,
                onTap: _goToDriverLocation,
              ),
              SizedBox(height: 12.h),
              MapButton(
                icon: Icons.add_rounded,
                onTap: _zoomIn,
              ),
              SizedBox(height: 12.h),
              MapButton(
                icon: Icons.remove_rounded,
                onTap: _zoomOut,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
