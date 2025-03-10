import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GymMap extends StatefulWidget {
  const GymMap({super.key});

  @override
  State<GymMap> createState() => _GymAppState();
}

class _GymAppState extends State<GymMap> {
  late GoogleMapController mapController;

  // TODO: request access and use user location data
  // point to center of Milan
  final LatLng _center = const LatLng(45.46427, 9.18951);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement map screen
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14,
        ),
      );
  }
}
