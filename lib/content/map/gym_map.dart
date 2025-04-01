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
  MapProvider? mapProvider;
  Map<String, Marker> _markers = {};
  List<Gym>? gymList;
  LatLng _currentPosition = const LatLng(45.46427, 9.18951);
  double _currentZoom = 14;
  bool _locationGranted = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    mapProvider = context.read<MapProvider>();
    initialized = mapProvider?.isInitialized ?? false;

    if (!initialized) {
      print("enter here");
      _loadGymList();
    } else {
      _currentPosition = mapProvider?.savedPosition ?? _currentPosition;
      _currentZoom = mapProvider?.savedZoom ?? _currentZoom;
    }

    _getUserLocation();
  }

  @override
  void dispose() {
    mapProvider?.saveMapState(_currentPosition, _currentZoom);
    
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await mapProvider?.getUserLocation();

      if (position != null) {
        print(initialized);
        if (!initialized) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _locationGranted = true;
          });
        } else {
          setState(() {
            _locationGranted = true;
          });
        }
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
      if (mapProvider != null) {
        final gyms = await mapProvider!.getGymLocations(gymList);
        
        if (mounted) {
          setState(() {
            _markers = mapProvider!.getMarkers(gyms);
          });
        }
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

  void _onCameraMove(CameraPosition position) {
      setState(() {
        _currentPosition = position.target;
        _currentZoom = position.zoom;
      });
  }
  
  void _updateCameraPosition() {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentZoom,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // La mappa come primo elemento (in background)
        GoogleMap(
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          cloudMapId: '7a4015798822680c',
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: _currentZoom,
          ),
          markers: _markers.values.toSet(),
          myLocationEnabled: _locationGranted,
          zoomControlsEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(11, 20),
        ),
        
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            onPressed: _locationGranted ? () async {
              final position = await mapProvider?.getUserLocation();
              if (position != null) {
                setState(() {
                  _currentPosition = LatLng(position.latitude, position.longitude);
                });
              }
              _updateCameraPosition();
            } : null,
            backgroundColor: _locationGranted ? Colors.blue : Colors.grey,
            foregroundColor: _locationGranted ? Colors.white : Colors.grey.shade300,
            tooltip: _locationGranted 
                ? 'Go to user location'
                : 'Access to user location denied',
            child: const Icon(Icons.my_location),
          ),
        ),
        
        Positioned(
          top: 48,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca palestre...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
