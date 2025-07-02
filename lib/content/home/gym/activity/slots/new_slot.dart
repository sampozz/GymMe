import 'package:gymme/models/slot_model.dart';
import 'package:gymme/providers/slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewSlot extends StatefulWidget {
  final String gymId;
  final String activityId;
  final Slot? oldSlot;

  const NewSlot({
    super.key,
    required this.gymId,
    required this.activityId,
    this.oldSlot,
  });

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.oldSlot != null) {
      _slotDateCtrl.text = DateFormat(
        DateFormat.YEAR_MONTH_DAY,
      ).format(widget.oldSlot!.startTime);
      _startTimeCtrl.text = DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(widget.oldSlot!.startTime);
      _endTimeCtrl.text = DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(widget.oldSlot!.endTime);
      _maxUsersCtrl.text = widget.oldSlot!.maxUsers.toString();
      _roomCtrl.text = widget.oldSlot!.room;
      _selectedDate = widget.oldSlot!.startTime;
      _selectedStartTime = widget.oldSlot!.startTime;
      _selectedEndTime = widget.oldSlot!.endTime;
      _recurrence = 'None';
      _selectedUntilDate = null;
      _untilCtrl.text = '';
    } else {
      _slotDateCtrl.text = DateFormat(
        DateFormat.YEAR_MONTH_DAY,
      ).format(DateTime.now());
      _startTimeCtrl.text = DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(DateTime.now());
      _endTimeCtrl.text = DateFormat(
        DateFormat.HOUR24_MINUTE,
      ).format(DateTime.now().add(const Duration(hours: 1)));
      _maxUsersCtrl.text = '1';
      _roomCtrl.text = '';
      _selectedDate = DateTime.now();
      _selectedStartTime = DateTime.now();
      _selectedEndTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

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

    setState(() {
      _isLoading = true;
    });

    DateTime startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    DateTime endTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    Slot newSlot =
        widget.oldSlot?.copyWith(
          startTime: startTime,
          endTime: endTime,
          maxUsers: int.parse(_maxUsersCtrl.text),
          room:
              _roomCtrl.text.isNotEmpty ? _roomCtrl.text : 'Room not available',
        ) ??
        Slot(
          gymId: widget.gymId,
          activityId: widget.activityId,
          startTime: startTime,
          endTime: endTime,
          maxUsers: int.parse(_maxUsersCtrl.text),
          room:
              _roomCtrl.text.isNotEmpty ? _roomCtrl.text : 'Room not available',
        );

    if (widget.oldSlot != null) {
      await Provider.of<SlotProvider>(
        context,
        listen: false,
      ).updateSlot(newSlot);
    } else {
      await Provider.of<SlotProvider>(
        context,
        listen: false,
      ).createSlot(newSlot, _recurrence, _selectedUntilDate);
    }

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

    if (context.mounted && time != null) {
      setState(() {
        if (controller == _startTimeCtrl) {
          _selectedStartTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            time.hour,
            time.minute,
          );
        } else if (controller == _endTimeCtrl) {
          _selectedEndTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            time.hour,
            time.minute,
          );
        }
        controller.text = DateFormat(
          DateFormat.HOUR24_MINUTE,
        ).format(DateTime(0, 0, 0, time.hour, time.minute));
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.oldSlot == null ? 'Create new slot' : 'Edit slot'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: Key('dateField'),
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
                  key: Key('startTimeField'),
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
                  key: Key('endTimeField'),
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
                  key: Key('maxUsersField'),
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
                  key: Key('roomField'),
                  controller: _roomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                if (widget.oldSlot == null) _buildRecurreceForm(),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : TextButton(
                      onPressed: () => _submitForm(),
                      child: Text(
                        widget.oldSlot == null ? 'Create Slot' : 'Update Slot',
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
