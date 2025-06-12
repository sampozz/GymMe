import 'package:dima_project/models/activity_model.dart';
import 'package:dima_project/models/gym_model.dart';
import 'package:dima_project/services/gym_service.dart';
import 'package:flutter/material.dart';

class GymProvider with ChangeNotifier {
  final GymService _gymService;
  List<Gym>? _gymList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();
    String? gymId = await _gymService.addGym(gym);
    _isLoading = false;
    gym.id = gymId;
    _gymList!.insert(0, gym);
    notifyListeners();
  }

  /// Updates a gym in the gym list.
  Future<void> updateGym(Gym gym) async {
    _isLoading = true;
    notifyListeners();
    await _gymService.updateGym(gym);
    _isLoading = false;
    var index = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![index] = gym;
    notifyListeners();
  }

  /// Removes a gym from the gym list.
  Future<void> removeGym(Gym gym) async {
    _isLoading = true;
    notifyListeners();
    await _gymService.deleteGym(gym.id!);
    _isLoading = false;
    _gymList!.removeWhere((element) => element.id == gym.id);
    notifyListeners();
  }

  /// Adds a new activity to the gym list.
  Future<void> addActivity(Gym gym, Activity activity) async {
    _isLoading = true;
    notifyListeners();
    await _gymService.setActivity(gym);
    _isLoading = false;
    var index = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![index].activities.add(activity);
    notifyListeners();
  }

  /// Updates an activity in the gym list.
  Future<void> updateActivity(Gym gym, Activity activity) async {
    _isLoading = true;
    notifyListeners();
    await _gymService.setActivity(gym);
    _isLoading = false;
    var gymIndex = _gymList!.indexWhere((element) => element.id == gym.id);
    var activityIndex = _gymList![gymIndex].activities.indexWhere(
      (element) => element.id == activity.id,
    );
    _gymList![gymIndex].activities[activityIndex] = activity;
    notifyListeners();
  }

  /// Removes an activity from the gym list.
  Future<void> removeActivity(Gym gym, Activity activity) async {
    _isLoading = true;
    notifyListeners();
    await _gymService.deleteActivity(gym, activity);
    _isLoading = false;
    var gymIndex = _gymList!.indexWhere((element) => element.id == gym.id);
    _gymList![gymIndex].activities.remove(activity);
    notifyListeners();
  }

  int getGymIndex(Gym gym) {
    return _gymList!.indexWhere((element) => element.id == gym.id);
  }

  /// Uploads an image to the gym service and returns the URL.
  Future<String> uploadImage(String base64Image) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = await _gymService.uploadImage(base64Image);
    _isLoading = false;
    notifyListeners();
    return imageUrl;
  }
}
