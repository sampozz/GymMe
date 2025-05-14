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

  Widget buildFormField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isMandatory,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
        validator: isMandatory ? (value) => _validateMandatory(value) : null,
      ),
    );
  }

  Widget buildFormCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: widget.user?.email,
                  icon: Icon(Icons.email_outlined),
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
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                controller: birthDateCtrl,
                decoration: InputDecoration(
                  labelText: 'Birth date',
                  icon: Icon(Icons.date_range_outlined),
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

            // Save button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(alignment: Alignment.center),
                    onPressed: _isSaving ? null : _saveChanges,
                    child: Text("Save changes"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                child: Form(key: _formKey, child: buildFormCard()),
              ),
    );
  }
}
