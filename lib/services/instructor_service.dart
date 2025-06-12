import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/instructor_model.dart';

class InstructorService {
  final FirebaseFirestore _firestore;

  InstructorService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Instructor>> fetchInstructors() async {
    List<Instructor> instructors = [];
    var snapshot =
        await _firestore
            .collection('instructor')
            .withConverter(
              fromFirestore: Instructor.fromFirestore,
              toFirestore: (instructor, options) => instructor.toFirestore(),
            )
            .get();
    instructors = snapshot.docs.map((doc) => doc.data()).toList();
    return instructors;
  }

  Future<Instructor?> fetchInstructorById(String instructorId) async {
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
  }

  Future<String?> addInstructor(Instructor instructor) async {
    var ref = await _firestore
        .collection('instructor')
        .withConverter(
          fromFirestore: Instructor.fromFirestore,
          toFirestore: (instructor, options) => instructor.toFirestore(),
        )
        .add(instructor);
    return ref.id;
  }

  Future<void> deleteInstructor(Instructor instructor) async {
    _firestore.collection('instructor').doc(instructor.id).delete();
  }
}
