import 'package:gymme/models/gym_model.dart';
import 'package:gymme/models/location_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class MapService {
  //Verifies current location permission
  Future<LocationPermission> checkLocationPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  //Requests location permission
  Future<LocationPermission> requestLocationPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  //Fetches user location or returns null if permission is denied
  Future<Position?> fetchUserLocation() async {
    try {
      LocationPermission permission = await checkLocationPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return null;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //Fetches gym locations with coordinates
  Future<Locations> fetchGymLocations(List<Gym>? gymList) async {
    try {
      List<GymLocation> gymLocationsList = [];

      // Process each gym
      for (var gym in gymList ?? []) {
        final String id = gym.id;
        final String name = gym.name;
        final String address = gym.address;

        // Get coordinates from address using geocoding
        final coordinates = await _getCoordinatesFromAddress(address);

        // Create GymLocation object with all data
        final gymLocation = GymLocation(
          id: id,
          name: name,
          address: address,
          lat: coordinates['lat'] ?? 0,
          lng: coordinates['lng'] ?? 0,
        );

        gymLocationsList.add(gymLocation);
      }

      // Create a Locations object
      return Locations(gyms: gymLocationsList);
    } catch (e) {
      // Return empty locations if error occurs
      return Locations(gyms: []);
    }
  }

  // For testing purposes
  final bool? forceWebBehavior;
  MapService({this.forceWebBehavior});

  // Helper function to get coordinates from address
  Future<Map<String, double>> _getCoordinatesFromAddress(String address) async {
    final useWebBehavior = forceWebBehavior ?? kIsWeb; // For testing purposes
    if (useWebBehavior) {
      return _getCoordinatesFromAddressWeb(address);
    } else {
      return _getCoordinatesFromAddressMobile(address);
    }
  }

  // Helper function to get coordinates from address on mobile
  Future<Map<String, double>> _getCoordinatesFromAddressMobile(
    String address,
  ) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        return {'lat': location.latitude, 'lng': location.longitude};
      }
      return {'lat': 0, 'lng': 0}; // Default coordinates if geocoding fails
    } catch (e) {
      return {'lat': 0, 'lng': 0}; // Default coordinates if geocoding fails
    }
  }

  // Helper function to get coordinates from address on web
  Future<Map<String, double>> _getCoordinatesFromAddressWeb(
    String address,
  ) async {
    final apiKey = 'AIzaSyA78dAdSxee-z3tu89roFSfuihVVTjMGHY';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {'lat': location['lat'], 'lng': location['lng']};
        }
      }

      return {'lat': 0, 'lng': 0}; // Default coordinates if geocoding fails
    } catch (e) {
      return {'lat': 0, 'lng': 0}; // Default coordinates if geocoding fails
    }
  }
}
