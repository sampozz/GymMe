import 'package:dima_project/content/home/gym/activity/activity_model.dart';
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
    String? gymId = await _gymService.addGym(gym);
    if (gymId != null) {
      gym.id = gymId;
      _gymList!.add(gym);
      notifyListeners();
    }
  }

  /// Updates a gym in the gym list.
  Future<void> updateGym(Gym gym) async {
    await _gymService.updateGym(gym);
    var index = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![index] = gym;
    notifyListeners();
  }

  /// Removes a gym from the gym list.
  Future<void> removeGym(Gym gym) async {
    await _gymService.deleteGym(gym.id!);
    _gymList!.removeWhere((element) => element.id == gym.id);
    notifyListeners();
  }

  /// Adds a new activity to the gym list.
  Future<void> addActivity(Gym gym, Activity activity) async {
    await _gymService.setActivity(gym.id!, activity);
    var index = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![index].activities.add(activity);
    notifyListeners();
  }

  /// Updates an activity in the gym list.
  Future<void> updateActivity(Gym gym, Activity activity) async {
    await _gymService.setActivity(gym.id!, activity);
    var gymIndex = _gymList!.indexWhere((element) => element.id == gym.id);
    var activityIndex = _gymList![gymIndex].activities.indexWhere(
      (element) => element.id == activity.id,
    );
    _gymList![gymIndex].activities[activityIndex] = activity;
    notifyListeners();
  }

  /// Removes an activity from the gym list.
  Future<void> removeActivity(Gym gym, Activity activity) async {
    await _gymService.deleteActivity(gym, activity);
    var gymIndex = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![gymIndex].activities.remove(activity);
    notifyListeners();
  }

  int getGymIndex(Gym gym) {
    return _gymList!.indexWhere((element) => element.id == gym.id);
  }
}
