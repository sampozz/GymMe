import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

@JsonSerializable()
class Gym {
  Gym({
    required this.address,
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
  Map<String, dynamic> toJson() => _$GymToJson(this);

  final String address;
  final String id;
  final double lat;
  final double lng;
  final String name;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.gyms,
  });

  factory Locations.fromJson(Map<String, dynamic> json) => _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Gym> gyms;
}

Future<Map <String, double>> getCoordinatesFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      return {
        'lat': locations.first.latitude,
        'lng': locations.first.longitude,
      };
    }
    return { 'lat': 0.0, 'lng': 0.0 }; // Return a default value if no location is found
  }
  catch (e) {
    if (kDebugMode) {
      print('Error geocoding address: $e');
    }
    return { 'lat': 0.0, 'lng': 0.0 }; // Return a default value if an error occurs
  }
}

Future<Locations> getGymLocations() async {
  try {
    //final firestoreInstance = FirebaseFirestore.instance;
    //final gymsCollection = await firestoreInstance.collection('gym').get();

    //List<Gym> gyms = [];


    // TODO: wait for response and if successful return json.decode as Map<String, dynamic>
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the request fails (possible problems with web)

  return rootBundle.loadString('assets/locations.json')
    .then((jsonString) {
      return Locations.fromJson(json.decode(jsonString) as Map<String, dynamic>
      );
    })
    .catchError((e) {
      if (kDebugMode) {
        print(e);
      }
      return Locations(gyms: []);
    });
}