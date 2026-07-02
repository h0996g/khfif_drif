import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class NominatimPlace {
  const NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lng,
  });

  final String displayName;
  final double lat;
  final double lng;

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'] as String? ?? '',
      lat: double.tryParse(json['lat'] as String? ?? '0') ?? 0,
      lng: double.tryParse(json['lon'] as String? ?? '0') ?? 0,
    );
  }
}

/// Arguments passed to the [RouteNames.locationPicker] route.
class LocationPickerArgs {
  const LocationPickerArgs({this.label = 'Location', this.initial});

  /// Title shown on the bottom confirm card.
  final String label;

  /// Optional coordinate to pre-select (e.g. when editing a saved place).
  /// When set, the map opens centered here with the pin already dropped.
  final LatLng? initial;
}

// Algeria center as fallback
const _kDefaultCenter = LatLng(36.7538, 3.0588);

class LocationPickerState extends Equatable {
  const LocationPickerState({
    this.mapCenter = _kDefaultCenter,
    this.selectedPosition,
    this.pickedAddress = '',
    this.isGeocoding = false,
    this.searchResults = const [],
    this.isSearching = false,
    this.isLocating = false,
    this.errorMessage,
  });

  /// Camera center — updated by init(), goToMyLocation() and selectResult().
  final LatLng mapCenter;

  /// The tapped/selected coordinate. Null means no selection yet (pin hidden).
  final LatLng? selectedPosition;

  final String pickedAddress;
  final bool isGeocoding;
  final List<NominatimPlace> searchResults;
  final bool isSearching;

  /// True while fetching the device's current GPS position.
  final bool isLocating;

  final String? errorMessage;

  LocationPickerState copyWith({
    LatLng? mapCenter,
    LatLng? selectedPosition,
    bool clearSelectedPosition = false,
    String? pickedAddress,
    bool? isGeocoding,
    List<NominatimPlace>? searchResults,
    bool? isSearching,
    bool? isLocating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationPickerState(
      mapCenter: mapCenter ?? this.mapCenter,
      selectedPosition: clearSelectedPosition
          ? null
          : (selectedPosition ?? this.selectedPosition),
      pickedAddress: pickedAddress ?? this.pickedAddress,
      isGeocoding: isGeocoding ?? this.isGeocoding,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isLocating: isLocating ?? this.isLocating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        mapCenter,
        selectedPosition,
        pickedAddress,
        isGeocoding,
        searchResults,
        isSearching,
        isLocating,
        errorMessage,
      ];
}
