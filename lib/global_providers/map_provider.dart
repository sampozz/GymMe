import 'package:dima_project/content/map/map_service.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/map/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class MapProvider with ChangeNotifier {
  final MapService _mapService;
  Locations? _gymLocationsList;
  Position? _userLocation;
  LatLng? _savedPosition;
  double? _savedZoom;
  final Map<String, Marker> _markers = {};
  bool _isInitialized = false;

  MapProvider({MapService? mapService})
    : _mapService = mapService ?? MapService();

  LatLng get savedPosition => _savedPosition ?? const LatLng(45.46427, 9.18951);
  double get savedZoom => _savedZoom ?? 14.0;
  bool get isInitialized => _isInitialized;

  Future<Locations> getGymLocations(List<Gym>? gymList) async {
    var data = await _mapService.fetchGymLocations(gymList);
    _gymLocationsList = data;
    notifyListeners();
    return data;
  }

  Future<Position?> getUserLocation() async {
    var data = await _mapService.fetchUserLocation();
    _userLocation = data;
    notifyListeners();
    return data;
  }

  Map<String, Marker> getMarkers(
    Locations gyms, {
    Function(String gymName, String gymId)? onMarkerTap,
  }) {
    _isInitialized = (!_isInitialized) ? true : _isInitialized;

    _markers.clear();
    for (final gym in gyms.gyms) {
      final marker = Marker(
        markerId: MarkerId(gym.id),
        position: LatLng(gym.lat, gym.lng),
        onTap: () {
          if (onMarkerTap != null) {
            onMarkerTap(gym.name, gym.id);
          }
        },
      );
      _markers[gym.id] = marker;
    }
    notifyListeners();

    return _markers;
  }

  void saveMapState(LatLng? position, double? zoom) {
    _savedPosition = position;
    _savedZoom = zoom;
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }
}
