import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../firestore_test.mocks.dart';

void main() {
  group('InstructorService', () {
    provideDummy<Instructor>(Instructor(id: '1'));
    test('fetchInstructors returns a list of instructors', () async {
      final mockFirebase = MockFirebaseFirestore();

      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      when(
        mockFirebase.collection('instructor'),
      ).thenReturn(mockCollectionReference);

      final mockCollectionReferenceInstructor =
          MockCollectionReference<Instructor>();
      when(
        mockCollectionReference.withConverter(
          fromFirestore: anyNamed('fromFirestore'),
          toFirestore: anyNamed('toFirestore'),
        ),
      ).thenReturn(mockCollectionReferenceInstructor);

      final mockQuerySnapshot = MockQuerySnapshot<Instructor>();
      when(
        mockCollectionReferenceInstructor.get(),
      ).thenAnswer((_) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs).thenReturn([
        MockQueryDocumentSnapshot<Instructor>(),
        MockQueryDocumentSnapshot<Instructor>(),
      ]);

      final instructorService = InstructorService(firestore: mockFirebase);

      final instructors = await instructorService.fetchInstructors();

      expect(instructors, isA<List<Instructor>>());
    });

    test('fetchInstructorById returns an instructor', () async {
      final mockFirebase = MockFirebaseFirestore();

      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      when(
        mockFirebase.collection('instructor'),
      ).thenReturn(mockCollectionReference);

      final mockDocumentReference =
          MockDocumentReference<Map<String, dynamic>>();
      when(mockCollectionReference.doc('1')).thenReturn(mockDocumentReference);

      final mockDocumentReferenceInstructor =
          MockDocumentReference<Instructor>();
      when(
        mockDocumentReference.withConverter(
          fromFirestore: anyNamed('fromFirestore'),
          toFirestore: anyNamed('toFirestore'),
        ),
      ).thenReturn(mockDocumentReferenceInstructor);

      final mockDocumentSnapshot = MockDocumentSnapshot<Instructor>();
      when(
        mockDocumentReferenceInstructor.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(Instructor(id: '1'));

      final instructorService = InstructorService(firestore: mockFirebase);

      final instructor = await instructorService.fetchInstructorById('1');

      expect(instructor, isA<Instructor>());
      expect(instructor?.id, '1');
    });

    test('addInstructor adds an instructor and returns its ID', () async {
      final mockFirebase = MockFirebaseFirestore();

      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      when(
        mockFirebase.collection('instructor'),
      ).thenReturn(mockCollectionReference);

      final mockCollectionReferenceInstructor =
          MockCollectionReference<Instructor>();
      when(
        mockCollectionReference.withConverter(
          fromFirestore: anyNamed('fromFirestore'),
          toFirestore: anyNamed('toFirestore'),
        ),
      ).thenReturn(mockCollectionReferenceInstructor);

      final mockDocumentReference = MockDocumentReference<Instructor>();
      when(
        mockCollectionReferenceInstructor.add(any),
      ).thenAnswer((_) async => mockDocumentReference);

      when(mockDocumentReference.id).thenReturn('1');

      final instructorService = InstructorService(firestore: mockFirebase);

      final instructorId = await instructorService.addInstructor(
        Instructor(id: '1'),
      );

      expect(instructorId, '1');
    });

    test('deleteInstructor deletes an instructor', () async {
      final mockFirebase = MockFirebaseFirestore();

      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      when(
        mockFirebase.collection('instructor'),
      ).thenReturn(mockCollectionReference);

      final mockDocumentReference =
          MockDocumentReference<Map<String, dynamic>>();
      when(mockCollectionReference.doc('1')).thenReturn(mockDocumentReference);

      when(mockDocumentReference.delete()).thenAnswer((_) async {});

      final instructorService = InstructorService(firestore: mockFirebase);

      final instructor = Instructor(id: '1');
      await instructorService.deleteInstructor(instructor);

      verify(mockDocumentReference.delete()).called(1);
    });
  });
}
