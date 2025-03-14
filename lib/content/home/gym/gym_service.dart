import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

class GymService {
  /// Fetches a list of gyms from the Firestore 'gym' collection.
  /// Returns a list of Gym objects.
  /// Throws a FirebaseException if there is an error during the fetch operation.
  Future<List<Gym>> fetchGymList() async {
    List<Gym> gymList = [];
    try {
      var gymsRef =
          await FirebaseFirestore.instance
              .collection('gym')
              .withConverter(
                fromFirestore: Gym.fromFirestore,
                toFirestore: (Gym gym, options) => gym.toFirestore(),
              )
              .get();
      for (var doc in gymsRef.docs) {
        gymList.add(doc.data());
      }
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }

    return gymList;
  }

  /// Sets a gym in the Firestore 'gym' collection.
  /// If the gym does not exist, it will be created.
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set gym.
  Future<String?> setGym(Gym gym) async {
    try {
      await FirebaseFirestore.instance
          .collection('gym')
          .withConverter(
            fromFirestore: Gym.fromFirestore,
            toFirestore: (Gym gym, options) => gym.toFirestore(),
          )
          .doc(gym.id)
          .set(gym);
      return gym.id;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }

  /// Deletes a gym from the Firestore 'gym' collection.
  /// Throws a FirebaseException if there is an error during the delete operation.
  /// Returns the id of the deleted gym.
  Future<String?> deleteGym(Gym gym) async {
    try {
      await FirebaseFirestore.instance.collection('gym').doc(gym.id).delete();
      return gym.id;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }

  /// Updates the gym document in the Firestore 'gym' collection with the new activity.
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set activity.
  Future<String?> setActivity(Gym gym, Activity activity) async {
    try {
      await FirebaseFirestore.instance.collection('gym').doc(gym.id).update({
        'activities': FieldValue.arrayUnion([activity.toFirestore()]),
      });
      return activity.id;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }

  /// Deletes an activity from the Firestore 'gym' collection.
  /// Throws a FirebaseException if there is an error during the delete operation.
  /// Returns the id of the deleted activity.
  Future<String?> deleteActivity(Gym gym, Activity activity) async {
    try {
      await FirebaseFirestore.instance.collection('gym').doc(gym.id).update({
        'activities': FieldValue.arrayRemove([activity.toFirestore()]),
      });
      return activity.id;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }
}
