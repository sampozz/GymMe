import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:http/http.dart' as http;

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
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set gym.
  Future<String?> addGym(Gym gym) async {
    try {
      var ref = await FirebaseFirestore.instance
          .collection('gym')
          .withConverter(
            fromFirestore: Gym.fromFirestore,
            toFirestore: (Gym gym, options) => gym.toFirestore(),
          )
          .add(gym);
      return ref.id;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }

  /// Updates a gym in the Firestore 'gym' collection.
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set gym.
  Future<String?> updateGym(Gym gym) async {
    try {
      await FirebaseFirestore.instance
          .collection('gym')
          .doc(gym.id)
          .set(gym.toFirestore(), SetOptions(merge: true));
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
  Future<String?> deleteGym(String gymId) async {
    try {
      await FirebaseFirestore.instance.collection('gym').doc(gymId).delete();
      return gymId;
    } catch (e) {
      // TODO: Handle error
      print(e);
      rethrow;
    }
  }

  /// Updates the gym document in the Firestore 'gym' collection with the new activity.
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set activity.
  Future<void> setActivity(Gym gym) async {
    try {
      await FirebaseFirestore.instance.collection('gym').doc(gym.id).update({
        'activities':
            gym.activities.map((activity) => activity.toFirestore()).toList(),
      });
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

  /// Uploads an image to Imgur and returns the URL
  Future<String> uploadImage(String base64Image) async {
    String clientId = 'f48b0bfb16767e7';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgur.com/3/upload'),
    );

    request.headers['Authorization'] = 'Client-ID $clientId';
    request.fields['type'] = 'base64';
    request.fields['image'] = base64Image;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return responseData['data']['link'];
    } else {
      throw Exception(
        'Failed to upload image: ${responseData['data']['error']}',
      );
    }
  }
}
