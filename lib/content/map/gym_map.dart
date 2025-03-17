import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../src/locations.dart' as locations;

class GymMap extends StatefulWidget {
  const GymMap({super.key});

  @override
  State<GymMap> createState() => _GymAppState();
}

class _GymAppState extends State<GymMap> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  LatLng _currentPosition = const LatLng(45.46427, 9.18951);
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately
        setState(() {
          _locationGranted = false;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationGranted = true;
        });
      } else {
        setState(() {
          _locationGranted = false;
        });
      }

            if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 14,
          ),
        ));
      }
    } catch (e) {
      // Handle any errors that might occur during the permission request
      setState(() {
        _locationGranted = false;
      });
      print('Error getting location permissions: $e');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
        if (_locationGranted) {
      _updateCameraPosition();
    }
    
    final gyms = await locations.getGymLocations();
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
  
  // Metodo separato per aggiornare la posizione della camera
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
