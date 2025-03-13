import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_service.dart';
import 'package:flutter/material.dart';

class GymProvider with ChangeNotifier {
  final GymService _gymService;
  List<Gym>? _gymList;

  /// Getter for the gym list. If the list is null, fetch it from the service.
  List<Gym>? get gymList {
    if (_gymList == null) {
      getGymList();
    }
    return _gymList;
  }

  // Dependency injection, needed for unit testing
  GymProvider({GymService? gymService})
    : _gymService = gymService ?? GymService();

  /// Returns a list of Gym objects.
  Future<List<Gym>> getGymList() async {
    var data = await _gymService.fetchGymList();
    _gymList = data;
    notifyListeners();
    return data;
  }

  /// Adds a new gym to the gym list.
  Future<void> addGym(Gym gym) async {
    await _gymService.setGym(gym);
    _gymList!.add(gym);
    notifyListeners();
  }

  /// Updates a gym in the gym list.
  Future<void> updateGym(Gym gym) async {
    await _gymService.setGym(gym);
    var index = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![index] = gym;
    notifyListeners();
  }

  /// Removes a gym from the gym list.
  Future<void> removeGym(Gym gym) async {
    await _gymService.deleteGym(gym);
    _gymList!.remove(gym);
    notifyListeners();
  }
}
