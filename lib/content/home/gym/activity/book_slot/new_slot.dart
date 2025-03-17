import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewSlot extends StatelessWidget {
  final String gymId;
  final String activityId;

  final _formKey = GlobalKey<FormState>();
  final _slotTimeCtrl = TextEditingController();
  final _maxUsersCtrl = TextEditingController();

  NewSlot({super.key, required this.gymId, required this.activityId});

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Slot newSlot = Slot(
        gymId: gymId,
        activityId: activityId,
        start: DateTime.parse(_slotTimeCtrl.text),
        maxUsers: int.parse(_maxUsersCtrl.text),
      );

      Provider.of<SlotProvider>(context, listen: false).createSlot(newSlot);
    }

    Navigator.pop(context);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (context.mounted && pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _slotTimeCtrl.text = fullDateTime.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _slotTimeCtrl,
                decoration: InputDecoration(labelText: 'Slot Time'),
                readOnly: true,
                onTap: () => _selectDateTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a slot time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _maxUsersCtrl,
                decoration: InputDecoration(labelText: 'Max Reservations'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the maximum number of reservations';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text('Create Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
