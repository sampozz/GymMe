import 'package:dima_project/models/instructor_model.dart';
import 'package:dima_project/services/instructor_service.dart';
import 'package:flutter/material.dart';

class InstructorProvider extends ChangeNotifier {
  final InstructorService _instructorService;
  List<Instructor>? _instructorList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InstructorProvider({InstructorService? instructorService})
    : _instructorService = instructorService ?? InstructorService();

  /// Getter for the instructors. If the list is empty, fetch it from the service.
  List<Instructor>? get instructorList {
    if (_instructorList == null) {
      getInstructorList();
    }
    return _instructorList;
  }

  Future<List<Instructor>?> getInstructorList() async {
    _instructorList = await _instructorService.fetchInstructors();
    notifyListeners();
    return _instructorList;
  }

  Future<void> deleteInstructor(Instructor instructor) async {
    await _instructorService.deleteInstructor(instructor);
    _instructorList!.removeWhere((element) => element.id == instructor.id);
    notifyListeners();
  }

  Future<String?> addInstructor(Instructor instructor) async {
    _isLoading = true;
    notifyListeners();
    String? instructorId = await _instructorService.addInstructor(instructor);
    if (instructorId != null) {
      instructor.id = instructorId;
      _instructorList!.add(instructor);
    }
    _isLoading = false;
    notifyListeners();
    return instructorId;
  }
}
