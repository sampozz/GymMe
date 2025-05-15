import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InstructorService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late InstructorService instructorService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      instructorService = InstructorService(firestore: fakeFirestore);
    });

    test('fetchInstructors returns a list of instructors', () async {
      // Add test data to fake firestore
      await fakeFirestore.collection('instructor').doc('1').set({
        'name': 'John Doe',
        'specialization': 'Yoga',
        'bio': 'Yoga expert',
      });
      await fakeFirestore.collection('instructor').doc('2').set({
        'name': 'Jane Smith',
        'specialization': 'Pilates',
        'bio': 'Pilates expert',
      });

      // Call the method being tested
      final instructors = await instructorService.fetchInstructors();

      // Verify results
      expect(instructors.length, 2);
      expect(instructors[0].id, isNotEmpty);
      expect(instructors[1].id, isNotEmpty);
    });

    test('fetchInstructorById returns an instructor', () async {
      // Add test data to fake firestore
      await fakeFirestore.collection('instructor').doc('1').set({
        'name': 'John Doe',
        'specialization': 'Yoga',
        'bio': 'Yoga expert',
      });

      // Call the method being tested
      final instructor = await instructorService.fetchInstructorById('1');

      // Verify results
      expect(instructor, isNotNull);
      expect(instructor?.id, '1');
    });

    test(
      'fetchInstructorById returns null for non-existent instructor',
      () async {
        // Call the method being tested
        final instructor = await instructorService.fetchInstructorById(
          'non-existent',
        );

        // Verify results
        expect(instructor, isNull);
      },
    );

    test('addInstructor adds an instructor and returns its ID', () async {
      // Create test instructor
      final newInstructor = Instructor(
        id: '', // ID will be assigned by Firestore
        name: 'New Instructor',
      );

      // Call the method being tested
      final instructorId = await instructorService.addInstructor(newInstructor);

      // Verify results
      expect(instructorId, isNotNull);
      expect(instructorId, isNotEmpty);

      // Verify the instructor was actually added to Firestore
      final docSnapshot =
          await fakeFirestore.collection('instructor').doc(instructorId).get();

      expect(docSnapshot.exists, true);
      expect(docSnapshot.data()?['name'], 'New Instructor');
    });

    test('deleteInstructor deletes an instructor', () async {
      // Add test data to fake firestore
      await fakeFirestore.collection('instructor').doc('1').set({
        'name': 'John Doe',
        'specialization': 'Yoga',
        'bio': 'Yoga expert',
      });

      // Verify the instructor exists before deletion
      var docSnapshot =
          await fakeFirestore.collection('instructor').doc('1').get();
      expect(docSnapshot.exists, true);

      // Call the method being tested
      await instructorService.deleteInstructor(Instructor(id: '1'));

      // Verify the instructor was deleted
      docSnapshot = await fakeFirestore.collection('instructor').doc('1').get();
      expect(docSnapshot.exists, false);
    });

    test('instructor copyWith creates a copy with modified fields', () {
      final instructor = Instructor(
        id: '1',
        name: 'John Doe',
        photo: 'photo_url',
        title: 'Yoga Instructor',
      );

      final modifiedInstructor = instructor.copyWith(
        name: 'Jane Doe',
        title: 'Pilates Instructor',
      );

      expect(modifiedInstructor.id, '1');
      expect(modifiedInstructor.name, 'Jane Doe');
      expect(modifiedInstructor.photo, 'photo_url');
      expect(modifiedInstructor.title, 'Pilates Instructor');
    });

    test(
      'instructorProvider.instructorList returns a list of instructors',
      () async {
        // Add test data to fake firestore
        await fakeFirestore.collection('instructor').doc('1').set({
          'name': 'John Doe',
          'specialization': 'Yoga',
          'bio': 'Yoga expert',
        });
        await fakeFirestore.collection('instructor').doc('2').set({
          'name': 'Jane Smith',
          'specialization': 'Pilates',
          'bio': 'Pilates expert',
        });

        // Call the method being tested
        final instructors = await instructorService.fetchInstructors();

        // Verify results
        expect(instructors.length, 2);
      },
    );
  });
}
