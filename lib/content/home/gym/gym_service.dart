import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:http/http.dart' as http;

class GymService {
  final FirebaseFirestore _firestore;

  GymService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches a list of gyms from the Firestore 'gym' collection.
  /// Returns a list of Gym objects.
  Future<List<Gym>> fetchGymList() async {
    List<Gym> gymList = [];
    var gymsRef =
        await _firestore
            .collection('gym')
            .withConverter(
              fromFirestore: Gym.fromFirestore,
              toFirestore: (Gym gym, options) => gym.toFirestore(),
            )
            .get();
    for (var doc in gymsRef.docs) {
      gymList.add(doc.data());
    }

    return gymList;
  }

  /// Sets a gym in the Firestore 'gym' collection.
  /// Returns the id of the set gym.
  Future<String> addGym(Gym gym) async {
    var ref = await _firestore
        .collection('gym')
        .withConverter(
          fromFirestore: Gym.fromFirestore,
          toFirestore: (Gym gym, options) => gym.toFirestore(),
        )
        .add(gym);
    return ref.id;
  }

  /// Updates a gym in the Firestore 'gym' collection.
  Future<void> updateGym(Gym gym) async {
    await _firestore
        .collection('gym')
        .doc(gym.id)
        .set(gym.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes a gym from the Firestore 'gym' collection.
  Future<void> deleteGym(String gymId) async {
    await _firestore.collection('gym').doc(gymId).delete();
  }

  /// Updates the gym document in the Firestore 'gym' collection with the new activity.
  Future<void> setActivity(Gym gym) async {
    await _firestore.collection('gym').doc(gym.id).update({
      'activities':
          gym.activities.map((activity) => activity.toFirestore()).toList(),
    });
  }

  /// Deletes an activity from the Firestore 'gym' collection.
  Future<void> deleteActivity(Gym gym, Activity activity) async {
    await _firestore.collection('gym').doc(gym.id).update({
      'activities': FieldValue.arrayRemove([activity.toFirestore()]),
    });
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
