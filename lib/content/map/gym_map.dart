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
  final TextEditingController searchBarController = TextEditingController();
  MapProvider? mapProvider;
  Map<String, Marker> _markers = {};
  List<Gym>? gymList;
  List<Gym>? searchList;
  LatLng _currentPosition = const LatLng(45.46427, 9.18951);
  double _currentZoom = 14;
  bool _locationGranted = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    mapProvider = context.read<MapProvider>();
    initialized = mapProvider?.isInitialized ?? false;

    if (initialized) {
      _currentPosition = mapProvider?.savedPosition ?? _currentPosition;
      _currentZoom = mapProvider?.savedZoom ?? _currentZoom;
    }
    _loadGymList();
    _getUserLocation();
    searchBarController.addListener(_searchList);
  }

  @override
  void dispose() {
    // Rimuovi il listener prima di distruggere il widget
    searchBarController.removeListener(_searchList);
    // Rilascia il controller
    searchBarController.dispose();
    
    mapProvider?.saveMapState(_currentPosition, _currentZoom);
    
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await mapProvider?.getUserLocation();

      if (position != null) {
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

  void _searchList() {
    final String query = searchBarController.text.toLowerCase();
    
    if(query.isNotEmpty) {
      setState(() {
        searchList = gymList?.where((gym) =>
          gym.name.toLowerCase().contains(query) ||
          gym.address.toLowerCase().contains(query)
        ).toList(); 
      });
    } else {
      setState(() {
        searchList = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Stack(
      children: [
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
        
        // Location Button (Mantieni questa posizione)
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
        
        if (isDesktop)
          Positioned(
            top: 16,
            left: 16,
            child: SizedBox(
              width: 400,
              child: _buildSearchBar(),
            ),
          )
        else
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: _buildSearchBar(), /*SizedBox(
              width: double.infinity,
              child: _buildSearchBar(),
            ),*/
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        controller.addListener(() {
          searchBarController.text = controller.text;
        });
        return SearchBar(
          controller: controller,
          onChanged: (value) {
            controller.openView();
            _searchList();
          },
          trailing: controller.text.isNotEmpty
                    ? [
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            searchBarController.clear();
                          },
                        ),
                      ]
                    : null,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search),
          elevation: WidgetStateProperty.all(0),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        if (searchList == null || searchList!.isEmpty) {
          return [
            const ListTile(
              title: Text('No results found'),
            ),
          ];
        }
        
        return searchList!.map((gym) => ListTile(
          title: Text(gym.name),
          subtitle: Text(gym.address),
          onTap: () {
            setState(() {
              if(_markers.isNotEmpty && _markers.containsKey(gym.id)) {
                _currentPosition = _markers[gym.id]!.position;
              }
            });
            _updateCameraPosition();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (gym.id != null) {
                mapController?.showMarkerInfoWindow(MarkerId(gym.id!));
              }
            });
            controller.closeView(gym.name);
          },
        )).toList();
      },
    );
  }
}
