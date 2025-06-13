import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewMyData extends StatefulWidget {
  final User? user;

  const NewMyData({super.key, this.user});

  @override
  State<NewMyData> createState() => _NewMyDataState();
}

class _NewMyDataState extends State<NewMyData> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? imageBytes;

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController taxCodeCtrl;
  late TextEditingController birthPlaceCtrl;
  late TextEditingController birthDateCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user?.displayName ?? '');
    phoneCtrl = TextEditingController(text: widget.user?.phoneNumber ?? '');
    addressCtrl = TextEditingController(text: widget.user?.address ?? '');
    taxCodeCtrl = TextEditingController(text: widget.user?.taxCode ?? '');
    birthPlaceCtrl = TextEditingController(text: widget.user?.birthPlace ?? '');
    birthDateCtrl = TextEditingController(
      text:
          widget.user?.birthDate != null
              ? '${widget.user?.birthDate!.day}/${widget.user?.birthDate!.month}/${widget.user?.birthDate!.year}'
              : '',
    );
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
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    taxCodeCtrl.dispose();
    birthPlaceCtrl.dispose();
    birthDateCtrl.dispose();
    super.dispose();
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var snackBar = ScaffoldMessenger.of(context);

    String imageUrl = widget.user?.photoURL ?? '';
    if (imageBytes != null) {
      final base64Image = base64Encode(imageBytes!);

      imageUrl = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).uploadImage(base64Image);
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Aggiorna i dati dell'utente nel provider e su Firestore
      await userProvider.updateUserProfile(
        displayName: nameCtrl.text,
        photoURL: imageUrl,
        phoneNumber: phoneCtrl.text,
        address: addressCtrl.text,
        taxCode: taxCodeCtrl.text,
        birthPlace: birthPlaceCtrl.text,
        birthDate:
            birthDateCtrl.text.isNotEmpty
                ? DateFormat('dd/MM/yyyy').parse(birthDateCtrl.text)
                : null,
      );

      setState(() {
        _isSaving = false;
      });

      // Mostra un messaggio di successo
      snackBar.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outlined, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Changes saved successfully!')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      nameCtrl.clear();
      phoneCtrl.clear();
      addressCtrl.clear();
      taxCodeCtrl.clear();
      birthPlaceCtrl.clear();
      birthDateCtrl.clear();

      // Torna alla pagina precedente
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      // Gestisci eventuali errori
      snackBar.showSnackBar(
        SnackBar(
          content: Text('There\'s been an issue during the update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildFormField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isMandatory,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
          border: InputBorder.none,
        ),
        validator: isMandatory ? (value) => _validateMandatory(value) : null,
      ),
    );
  }

  Widget buildProfilePicture() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child:
            imageBytes != null
                ? Image.memory(
                  imageBytes!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
                : (widget.user?.photoURL != null &&
                        widget.user!.photoURL.isNotEmpty
                    ? Image.network(
                      widget.user!.photoURL,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/avatar.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Icon(Icons.person, size: 60, color: Colors.grey[400])),
      ),
    );
  }

  Widget buildFormCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _showFilePicker,
                    child: buildProfilePicture(),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _showFilePicker,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(75),
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            SizedBox(height: 8),
            buildFormField(
              'Name and Surname',
              Icons.person_outlined,
              nameCtrl,
              true,
            ),
            SizedBox(height: 10),

            // Email (read-only)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: widget.user?.email,
                  icon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 10),

            buildFormField(
              'Phone number',
              Icons.phone_outlined,
              phoneCtrl,
              true,
            ),
            SizedBox(height: 10),
            buildFormField('Address', Icons.home_outlined, addressCtrl, false),
            SizedBox(height: 10),
            buildFormField(
              'Tax code',
              Icons.badge_outlined,
              taxCodeCtrl,
              false,
            ),
            SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                controller: birthDateCtrl,
                decoration: InputDecoration(
                  labelText: 'Birth date',
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: InputBorder.none,
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat(
                      'dd/MM/yyyy',
                    ).format(pickedDate);
                    birthDateCtrl.text = formattedDate;
                  }
                },
              ),
            ),

            // Birth date
            SizedBox(height: 10),

            buildFormField(
              'Birth place',
              Icons.location_on_outlined,
              birthPlaceCtrl,
              false,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('Modify data'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body:
          _isSaving
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(12.0),
                child: Form(key: _formKey, child: buildFormCard()),
              ),
      // Save button
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: Icon(Icons.save_outlined),
            label: Text("Save changes", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
