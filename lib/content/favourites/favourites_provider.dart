import 'package:dima_project/content/favourites/favourites_service.dart';
import 'package:flutter/material.dart';

class FavouritesProvider with ChangeNotifier {
  final FavouritesService _favouritesService;

  // Dependency injection, needed for unit testing
  FavouritesProvider({FavouritesService? favouritesService})
    : _favouritesService = favouritesService ?? FavouritesService();

  // TODO: implement gym provider
}
