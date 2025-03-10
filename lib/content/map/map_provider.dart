import 'package:dima_project/content/map/map_service.dart';
import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  MapService _mapService;

  // Dependency injection, needed for unit testing
  MapProvider({MapService? mapService})
    : _mapService = mapService ?? MapService();

  // TODO: implement map provider
}
