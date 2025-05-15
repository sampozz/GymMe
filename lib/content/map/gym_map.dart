import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/map_provider.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/map/gym_bottom_sheet.dart';
import 'package:flutter/foundation.dart';

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

    _initializeUserLocation();
    _loadGymList();

    searchBarController.addListener(_searchList);
  }

  @override
  void deactivate() {
    if (mapController != null) {
      mapProvider?.saveMapState(_currentPosition, _currentZoom);
      mapController = null;
    }

    super.deactivate();
  }

  @override
  void dispose() {
    searchBarController.removeListener(_searchList);
    searchBarController.dispose();

    super.dispose();
  }

  Future<void> _initializeUserLocation() async {
    try {
      final position = await mapProvider?.getUserLocation();

      if (position != null && mounted) {
        setState(() {
          if (!initialized) {
            _currentPosition = LatLng(position.latitude, position.longitude);
          }
          _locationGranted = true;
        });

        if (mapController != null) {
          _updateCameraPosition();
        }
      } else {
        setState(() {
          _locationGranted = false;
        });

        if (mounted && !initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission denied. Go to settings to enable it.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
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

  void _showGymDetails(String gymId) {
    int gymIndex = gymList!.indexWhere((gym) => gym.id == gymId);
    if (gymIndex != -1) {
      Future.microtask(() {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: kIsWeb ? Colors.transparent : Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              final Gym gym = gymList![gymIndex];

              return PointerInterceptor(child: GymBottomSheet(gymId: gym.id!));
            },
          );
        }
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });

    try {
      if (mapProvider != null) {
        final gyms = await mapProvider!.getGymLocations(gymList);

        if (mounted) {
          setState(() {
            _markers = mapProvider!.getMarkers(
              gyms,
              onMarkerTap: (gymName, gymId) {
                _showGymDetails(gymId);
              },
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to load gym locations')));
      }
    }

    if (!initialized) {
      _updateCameraPosition();
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _currentZoom = position.zoom;
    });
  }

  void _updateCameraPosition() {
    if (mapController != null && mounted) {
      try {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: _currentZoom),
          ),
        );
      } catch (e) {
        print('Error updating camera position: $e');
      }
    }
  }

  void _searchList() {
    final String query = searchBarController.text.toLowerCase();

    if (query.isNotEmpty) {
      setState(() {
        searchList =
            gymList
                ?.where(
                  (gym) =>
                      gym.name.toLowerCase().contains(query) ||
                      gym.address.toLowerCase().contains(query),
                )
                .toList();
      });
    } else {
      setState(() {
        searchList = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useMobileLayout =
        context.watch<ScreenProvider>().useMobileLayout;

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
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(11, 20),
        ),

        // Location Button
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            onPressed:
                _locationGranted
                    ? () async {
                      final position = await mapProvider?.getUserLocation();
                      if (position != null) {
                        setState(() {
                          _currentPosition = LatLng(
                            position.latitude,
                            position.longitude,
                          );
                        });
                        _updateCameraPosition();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Location permission denied. Go to settings to enable it.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                    : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Location permission denied. Go to settings to enable it.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
            backgroundColor: _locationGranted ? Colors.blue : Colors.grey,
            foregroundColor:
                _locationGranted ? Colors.white : Colors.grey.shade300,
            tooltip:
                _locationGranted
                    ? 'Go to user location'
                    : 'Access to user location denied',
            child: const Icon(Icons.my_location),
          ),
        ),

        // Search Bar
        if (useMobileLayout)
          Positioned(top: 48, left: 16, right: 16, child: _buildSearchBar())
        else
          Positioned(
            top: 20,
            left: 20,
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width < 700
                      ? MediaQuery.of(context).size.width - 306
                      : 400,
              child: _buildSearchBar(),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return PointerInterceptor(
      child: SearchAnchor(
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
            trailing:
                controller.text.isNotEmpty
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
            hintText: 'Search for gyms or locations...',
            hintStyle: WidgetStatePropertyAll<TextStyle>(
              TextStyle(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        },
        suggestionsBuilder: (
          BuildContext context,
          SearchController controller,
        ) {
          if (searchList == null || searchList!.isEmpty) {
            return [
              PointerInterceptor(
                child: const ListTile(title: Text('No results found')),
              ),
            ];
          }

          return searchList!
              .map(
                (gym) => PointerInterceptor(
                  child: ListTile(
                    title: Text(gym.name),
                    subtitle: Text(gym.address),
                    onTap: () {
                      setState(() {
                        if (_markers.isNotEmpty &&
                            _markers.containsKey(gym.id)) {
                          _currentPosition = _markers[gym.id]!.position;
                        }
                      });
                      _updateCameraPosition();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (gym.id != null) {
                          _showGymDetails(gym.id!);
                        }
                      });
                      controller.closeView(gym.name);
                    },
                  ),
                ),
              )
              .toList();
        },
      ),
    );
  }
}
