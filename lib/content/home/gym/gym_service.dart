import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

class GymService {
  /// Fetches a list of gyms from the Firestore 'gym' collection.
  /// Returns a list of Gym objects.
  /// Throws a FirebaseException if there is an error during the fetch operation.
  Future<List<Gym>> fetchGymList() async {
    List<Gym> gymList = [];
    try {
      var gymsRef = await FirebaseFirestore.instance.collection('gym').get();
      for (var doc in gymsRef.docs) {
        gymList.add(Gym.fromJson(doc.id, doc.data()));
      }
    } catch (e) {
      // TODO: Handle error
      print(e);
    }

    return gymList;
  }
}
