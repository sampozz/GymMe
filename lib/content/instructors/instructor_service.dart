import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/instructors/instructor_model.dart';

class InstructorService {
  final FirebaseFirestore _firestore;

  InstructorService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Instructor>> fetchInstructors() async {
    List<Instructor> instructors = [];
    try {
      var snapshot =
          await _firestore
              .collection('instructor')
              .withConverter(
                fromFirestore: Instructor.fromFirestore,
                toFirestore: (instructor, options) => instructor.toFirestore(),
              )
              .get();
      instructors = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
    return instructors;
  }

  Future<Instructor?> fetchInstructorById(String instructorId) async {
    try {
      var instructorDoc =
          await _firestore
              .collection('instructor')
              .doc(instructorId)
              .withConverter(
                fromFirestore: Instructor.fromFirestore,
                toFirestore: (instructor, options) => instructor.toFirestore(),
              )
              .get();

      if (!instructorDoc.exists) {
        // Instructor not found
        return null;
      }
      return instructorDoc.data();
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }

  Future<String?> addInstructor(Instructor instructor) async {
    try {
      var ref = await _firestore
          .collection('instructor')
          .withConverter(
            fromFirestore: Instructor.fromFirestore,
            toFirestore: (instructor, options) => instructor.toFirestore(),
          )
          .add(instructor);
      return ref.id;
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }

  Future<void> deleteInstructor(Instructor instructor) async {
    try {
      _firestore.collection('instructor').doc(instructor.id).delete();
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }
}
