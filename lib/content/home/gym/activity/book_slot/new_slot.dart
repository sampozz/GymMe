import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewSlot extends StatefulWidget {
  final String gymId;
  final String activityId;

  const NewSlot({super.key, required this.gymId, required this.activityId});

  @override
  State<NewSlot> createState() => _NewSlotState();
}

class _NewSlotState extends State<NewSlot> {
  final _formKey = GlobalKey<FormState>();
  final _slotDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _maxUsersCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _untilCtrl = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  DateTime? _selectedUntilDate;
  String _recurrence = 'None';

  @override
  void dispose() {
    _slotDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _maxUsersCtrl.dispose();
    _roomCtrl.dispose();
    _untilCtrl.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Slot newSlot = Slot(
      gymId: widget.gymId,
      activityId: widget.activityId,
      startTime: DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      ),
      endTime: DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      ),
      maxUsers: int.parse(_maxUsersCtrl.text),
      room: _roomCtrl.text.isNotEmpty ? _roomCtrl.text : 'Room not available',
      bookedUsers: [],
    );

    await Provider.of<SlotProvider>(
      context,
      listen: false,
    ).createSlot(newSlot, _recurrence, _selectedUntilDate);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (context.mounted && pickedDate != null) {
      setState(() {
        if (controller == _slotDateCtrl) {
          _selectedDate = pickedDate;
        } else if (controller == _untilCtrl) {
          _selectedUntilDate = pickedDate;
        }
        controller.text = DateFormat(
          DateFormat.YEAR_MONTH_DAY,
        ).format(pickedDate);
      });
    }
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (context.mounted && pickedTime != null) {
      setState(() {
        if (controller == _startTimeCtrl) {
          _selectedStartTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else if (controller == _endTimeCtrl) {
          _selectedEndTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
        controller.text = pickedTime.format(context);
      });
    }
  }

  Widget _buildRecurreceForm() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Repeat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: Text('Select Recurrence'),
                value: 'None',
                items:
                    <String>[
                      'None',
                      'Daily',
                      'Weekly',
                      'Monthly',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _recurrence = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        TextFormField(
          enabled: _recurrence != 'None',
          controller: _untilCtrl,
          decoration: InputDecoration(
            labelText: 'Repeat until',
            border: OutlineInputBorder(),
          ),
          readOnly: true,
          onTap: () => _selectDate(_untilCtrl),
          validator:
              (value) =>
                  _recurrence != 'None' ? _validateMandatory(value) : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Slot')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _slotDateCtrl,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_slotDateCtrl),
                  validator: (value) => _validateMandatory(value),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _startTimeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(_startTimeCtrl),
                  validator: (value) => _validateMandatory(value),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _endTimeCtrl,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(_endTimeCtrl),
                  validator: (value) => _validateMandatory(value),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _maxUsersCtrl,
                  decoration: InputDecoration(
                    labelText: 'Max Reservations',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _roomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                _buildRecurreceForm(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _submitForm(),
                  child: Text('Create Slot'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
