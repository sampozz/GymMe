import 'package:dima_project/content/map/map_service.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/map/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class MapProvider with ChangeNotifier {
  final MapService _mapService;
  Locations? _gymLocationsList;

  MapProvider({MapService? mapService})
    : _mapService = mapService ?? MapService();

  Future<Locations> getGymLocations(List<Gym>? gymList) async {
    var data = await _mapService.fetchGymLocations(gymList);
    _gymLocationsList = data;
    notifyListeners();
    return data;
  }

  Future<Position?> getUserLocation() async {
    var data = await _mapService.fetchUserLocation();
    notifyListeners();
    return data;
  }
}
