import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

class GymService {
  /// Fetches a list of gyms from the Firestore 'gym' collection.
  /// Returns a list of Gym objects.
  /// Throws a FirebaseException if there is an error during the fetch operation.
  Future<List<Gym>> getGymList() async {
    var snapshot = await FirebaseFirestore.instance.collection('gym').get();
    List<Gym> gymList = [];
    for (var doc in snapshot.docs) {
      try {
        gymList.add(Gym.fromJson(doc.data()));
      } catch (e) {
        // TODO: Handle error
      }
    }

    return gymList;
  }
}
