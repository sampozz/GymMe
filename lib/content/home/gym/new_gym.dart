import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewGym extends StatefulWidget {
  final Gym? gym;

  const NewGym({super.key, this.gym});

  @override
  State<NewGym> createState() => _NewGymState();
}

class _NewGymState extends State<NewGym> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? imageBytes;

  late TextEditingController nameCtrl;
  late TextEditingController descrCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController openTimeCtrl;
  late TextEditingController closeTimeCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.gym?.name ?? '');
    descrCtrl = TextEditingController(text: widget.gym?.description ?? '');
    addressCtrl = TextEditingController(text: widget.gym?.address ?? '');
    phoneCtrl = TextEditingController(text: widget.gym?.phone ?? '');
    openTimeCtrl = TextEditingController(
      text: DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(widget.gym?.openTime ?? DateTime(0)),
    );
    closeTimeCtrl = TextEditingController(
      text: DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(widget.gym?.closeTime ?? DateTime(0)),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descrCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    openTimeCtrl.dispose();
    closeTimeCtrl.dispose();
    super.dispose();
  }

  void _createOrUpdateGym() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String imageUrl = widget.gym?.imageUrl ?? '';
    if (imageBytes != null) {
      final base64Image = base64Encode(imageBytes!);

      imageUrl = await Provider.of<GymProvider>(
        context,
        listen: false,
      ).uploadImage(base64Image);
    }

    Gym newGym =
        widget.gym?.copyWith(
          name: nameCtrl.text,
          description: descrCtrl.text,
          address: addressCtrl.text,
          phone: phoneCtrl.text,
          imageUrl: imageUrl,
          openTime: DateTime.parse('1985-05-12 ${openTimeCtrl.text}'),
          closeTime: DateTime.parse('1985-05-12 ${closeTimeCtrl.text}'),
        ) ??
        Gym(
          name: nameCtrl.text,
          description: descrCtrl.text,
          address: addressCtrl.text,
          phone: phoneCtrl.text,
          imageUrl: imageUrl,
          openTime: DateTime.parse('1985-05-12 ${openTimeCtrl.text}'),
          closeTime: DateTime.parse('1985-05-12 ${closeTimeCtrl.text}'),
          activities: [],
        );

    if (widget.gym == null) {
      await Provider.of<GymProvider>(context, listen: false).addGym(newGym);
    } else {
      await Provider.of<GymProvider>(context, listen: false).updateGym(newGym);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _showTimePicker(bool openTime) async {
    final TimeOfDay? time = await showTimePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextColor: Colors.black,
              entryModeIconColor: Colors.black,
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final DateTime selectedTime = DateTime(0, 0, 0, time.hour, time.minute);
      setState(() {
        openTime
            ? openTimeCtrl.text = DateFormat(
              DateFormat.HOUR24_MINUTE,
            ).format(selectedTime)
            : closeTimeCtrl.text = DateFormat(
              DateFormat.HOUR24_MINUTE,
            ).format(selectedTime);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.watch<GymProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.gym == null ? 'Add gym' : 'Edit gym')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateMandatory(value),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: descrCtrl,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: addressCtrl,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateMandatory(value),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: openTimeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Open Time',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _showTimePicker(true),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: closeTimeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Close Time',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _showTimePicker(false),
                ),
                SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => _showFilePicker(),
                  icon: Icon(Icons.image),
                  label: Text('Upload Image'),
                ),
                SizedBox(height: 20),
                imageBytes != null
                    ? Image.memory(
                      imageBytes!,
                      height: 100,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                    : Text(widget.gym?.imageUrl ?? 'No image selected'),
                SizedBox(height: 20),
                TextButton(
                  onPressed: isLoading ? null : () => _createOrUpdateGym(),
                  child:
                      isLoading
                          ? SizedBox(
                            width: 25,
                            child: CircularProgressIndicator(),
                          )
                          : widget.gym == null
                          ? Text('Add Gym')
                          : Text('Update Gym'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
