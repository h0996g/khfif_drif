import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../saved_places/data/address_model.dart';
import 'location_picker_state.dart';

class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit() : super(const LocationPickerState());

  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {'User-Agent': 'khfif_drif/1.0'},
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  Future<void> init({LatLng? initial}) async {
    // When an initial position is provided (e.g. editing a saved place),
    // open centered on it with the pin already dropped and address resolved.
    if (initial != null) {
      emit(state.copyWith(
        mapCenter: initial,
        selectedPosition: initial,
        isGeocoding: true,
        clearError: true,
      ));
      await _reverseGeocode(initial);
      return;
    }

    final position = await _fetchPosition();
    // Only center the camera — no pin, no geocoding until user taps.
    if (position != null) {
      emit(state.copyWith(mapCenter: position));
    }
    // If position is null, silently fall back to the default Algeria center.
  }

  /// Recenters the camera on the device's current GPS position.
  /// Keeps any existing pin/selection intact.
  Future<void> goToMyLocation() async {
    emit(state.copyWith(isLocating: true, clearError: true));
    final position = await _fetchPosition();
    if (position != null) {
      emit(state.copyWith(mapCenter: position, isLocating: false));
    } else {
      emit(state.copyWith(isLocating: false));
    }
  }

  /// Resolves GPS permissions and returns the current position, or null on any
  /// failure (service disabled, permission denied, timeout, …).
  Future<LatLng?> _fetchPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  void onMapTap(LatLng position) {
    emit(state.copyWith(
      selectedPosition: position,
      pickedAddress: '',
      isGeocoding: true,
      clearError: true,
    ));
    _reverseGeocode(position);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
        },
      );
      final address = response.data?['display_name'] as String? ?? '';
      emit(state.copyWith(pickedAddress: address, isGeocoding: false));
    } catch (_) {
      emit(state.copyWith(
        isGeocoding: false,
        pickedAddress:
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      ));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }
    emit(state.copyWith(isSearching: true, searchResults: [], clearError: true));
    try {
      final response = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
        },
      );
      final results = (response.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(NominatimPlace.fromJson)
          .toList();
      emit(state.copyWith(searchResults: results, isSearching: false));
    } catch (_) {
      emit(state.copyWith(searchResults: [], isSearching: false));
    }
  }

  void selectResult(NominatimPlace place) {
    final position = LatLng(place.lat, place.lng);
    // Move camera AND drop pin at the search result, using displayName directly.
    emit(state.copyWith(
      mapCenter: position,
      selectedPosition: position,
      pickedAddress: place.displayName,
      searchResults: [],
      isSearching: false,
    ));
  }

  void clearSearch() {
    emit(state.copyWith(searchResults: [], isSearching: false));
  }

  void selectSavedAddress(AddressModel address) {
    final position = LatLng(address.latitude, address.longitude);
    // Move camera AND drop pin at the saved address, using its stored address text directly.
    emit(state.copyWith(
      mapCenter: position,
      selectedPosition: position,
      pickedAddress: address.address,
      searchResults: [],
      isSearching: false,
    ));
  }

  @override
  Future<void> close() {
    _dio.close();
    return super.close();
  }
}
