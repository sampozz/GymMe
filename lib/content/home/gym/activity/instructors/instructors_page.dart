import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dima_project/models/instructor_model.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  late InstructorProvider instructorProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController titleCtrl = TextEditingController();
  Uint8List? imageBytes;
  bool creatingInstructor = false;

  @override
  void initState() {
    super.initState();
    instructorProvider = context.read<InstructorProvider>();
  }

  List<Widget> _buildInstructorList(List<Instructor>? instructors) {
    return instructors?.map((instructor) {
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: Image.network(
                  instructor.photo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Image.asset('assets/avatar.png', fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            title: Text(instructor.title),
            subtitle: Text(instructor.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                instructorProvider.deleteInstructor(instructor);
              },
            ),
          );
        }).toList() ??
        [];
  }

  Widget _buildNewInstructorForm() {
    bool isLoading = context.watch<InstructorProvider>().isLoading;

    return creatingInstructor
        ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('nameCtrl'),
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateMandatory(value),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title (eg. Yoga Instructor)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => _showFilePicker(),
                  icon: Icon(Icons.image),
                  label: Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                Text(
                  imageBytes != null ? 'Image selected' : 'No image selected',
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: isLoading ? null : () => _createInstructor(),
                  child:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          )
                          : const Text('Confirm'),
                ),
              ],
            ),
          ),
        )
        : Container();
  }

  void _showFilePicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (result.files.first.bytes != null) {
        // Use bytes if available
        setState(() {
          imageBytes = result.files.first.bytes;
        });
      } else if (result.files.first.path != null) {
        // Fallback: Read bytes from the file path
        final filePath = result.files.first.path!;
        final file = File(filePath);
        final bytes = await file.readAsBytes();
        setState(() {
          imageBytes = bytes;
        });
      }
    }
  }

  void _createInstructor() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = '';
      if (imageBytes != null) {
        final base64Image = base64Encode(imageBytes!);
        imageUrl = await Provider.of<GymProvider>(
          context,
          listen: false,
        ).uploadImage(base64Image);
      }

      Instructor newInstructor = Instructor(
        name: nameCtrl.text,
        title: titleCtrl.text,
        photo: imageUrl,
      );
      instructorProvider.addInstructor(newInstructor).then((value) {
        if (value != null) {
          setState(() {
            creatingInstructor = false;
          });
        }
      });
    }
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<Instructor>? instructors =
        context.watch<InstructorProvider>().instructorList;

    return Scaffold(
      appBar: AppBar(title: const Text('Instructors')),
      body: Column(
        children: [
          ..._buildInstructorList(instructors),
          const SizedBox(height: 20),
          _buildNewInstructorForm(),
          const SizedBox(height: 20),
          if (!creatingInstructor)
            TextButton(
              onPressed: () {
                setState(() {
                  creatingInstructor = !creatingInstructor;
                });
              },
              child: const Text('New Instructor'),
            ),
        ],
      ),
    );
  }
}
