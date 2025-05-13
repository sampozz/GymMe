import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewMyData extends StatefulWidget {
  final User? user;

  const NewMyData({Key? key, this.user}) : super(key: key);

  @override
  _NewMyDataState createState() => _NewMyDataState();
}

class _NewMyDataState extends State<NewMyData> {
  final _formKey = GlobalKey<FormState>();

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
    setState(() {
      _isSaving = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Aggiorna i dati dell'utente nel provider e su Firestore
      await userProvider.updateUserProfile(
        displayName: nameCtrl.text,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
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
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      // Gestisci eventuali errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There\'s been an issue during the update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user ?? Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: Text('Modify data')),
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
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Surname
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Name and Surname',
                          icon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _validateMandatory(value),
                      ),
                      SizedBox(height: 16),
                      // Email (read-only)
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: widget.user?.email,
                          icon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Phone number
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          icon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => _validateMandatory(value),
                      ),
                      SizedBox(height: 16),
                      // Address
                      TextFormField(
                        controller: addressCtrl,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          icon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Tax code
                      TextFormField(
                        controller: taxCodeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tax code',
                          icon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Birth date
                      TextFormField(
                        controller: birthDateCtrl,
                        decoration: InputDecoration(
                          labelText: 'Birth date',
                          icon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
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
                      SizedBox(height: 16),
                      // Birth place
                      TextFormField(
                        controller: birthPlaceCtrl,
                        decoration: InputDecoration(
                          labelText: 'Birth place',
                          icon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // Save button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                              ),
                              onPressed: _isSaving ? null : _saveChanges,
                              child: Text("Save changes"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
