import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/map_provider.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

class GymMap extends StatefulWidget {
  const GymMap({super.key});

  @override
  State<GymMap> createState() => _GymAppState();
}

class _GymAppState extends State<GymMap> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  List<Gym>? gymList;
  LatLng _currentPosition = const LatLng(45.46427, 9.18951);
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadGymList();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await context.read<MapProvider>().getUserLocation();

      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationGranted = true;
        });
      } else {
        setState(() {
          _locationGranted = false;
        });
      }

      _updateCameraPosition();
      
    } catch (e) {
      setState(() {
        _locationGranted = false;
      });
      print('Error getting user location: $e');
    }
  }

  Future<void> _loadGymList() async {
    final gyms = await context.read<GymProvider>().getGymList();
    if (mounted) {
      setState(() {
        gymList = gyms;
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (_locationGranted) {
      _updateCameraPosition();
    }
    
    try {
      final gyms = await context.read<MapProvider>().getGymLocations(gymList);
      
      if (mounted) {
        setState(() {
          _markers.clear();
          for (final gym in gyms.gyms) {
            final marker = Marker(
              markerId: MarkerId(gym.id),
              position: LatLng(gym.lat, gym.lng),
              infoWindow: InfoWindow(
                title: gym.name,
                snippet: gym.address,
              ),
            );
            _markers[gym.id] = marker;
          }
        });
      }
    } catch (e) {
      print('Error loading gym locations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to load gym locations')),
        );
      }
    }
  }
  
  void _updateCameraPosition() {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 14,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement map interface
    return GoogleMap(
      onMapCreated: _onMapCreated,
      cloudMapId: '7a4015798822680c',
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 14,
      ),
      markers: _markers.values.toSet(),
      myLocationEnabled: _locationGranted,
      myLocationButtonEnabled: true,
    );
  }
}
