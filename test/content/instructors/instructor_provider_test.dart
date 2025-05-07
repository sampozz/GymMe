import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../service_test.mocks.dart';

void main() {
  group('InstructorProvider', () {
    late InstructorProvider instructorProvider;
    final mockInstructorService = MockInstructorService();

    setUp(() {
      when(
        mockInstructorService.addInstructor(any),
      ).thenAnswer(((_) async => 'new_id'));
      when(
        mockInstructorService.deleteInstructor(any),
      ).thenAnswer((_) async => '1');
      instructorProvider = InstructorProvider(
        instructorService: mockInstructorService,
      );
    });

    test('fetchInstructors returns a list of instructors', () async {
      final instructors = await instructorProvider.getInstructorList();
      expect(instructors, isA<List<Instructor>>());
    });

    test('addInstructor adds an instructor and returns its ID', () async {
      final instructor = Instructor(id: 'new_id', name: 'John Doe');
      instructorProvider.getInstructorList(); // Ensure the list is initialized
      final id = await instructorProvider.addInstructor(instructor);
      expect(id, isNotNull);
    });

    test('deleteInstructor deletes an instructor', () async {
      instructorProvider.getInstructorList(); // Ensure the list is initialized
      final instructor = Instructor(id: 'delete_id', name: 'Jane Doe');
      await instructorProvider.deleteInstructor(instructor);
      // Verify that the instructor was deleted
      verify(mockInstructorService.deleteInstructor(any)).called(1);
    });
  });
}
