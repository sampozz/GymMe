import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/content/instructors/instructors_page.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewActivity extends StatefulWidget {
  final Gym gym;
  final Activity? activity;

  const NewActivity({super.key, required this.gym, this.activity});

  @override
  State<NewActivity> createState() => _NewActivityState();
}

class _NewActivityState extends State<NewActivity> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleCtrl;
  late TextEditingController descrCtrl;
  late TextEditingController priceCtrl;
  String? instructorId;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.activity?.title ?? '');
    descrCtrl = TextEditingController(text: widget.activity?.description ?? '');
    priceCtrl = TextEditingController(
      text: widget.activity?.price.toString() ?? '',
    );
    instructorId = widget.activity?.instructorId;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descrCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  /// Create a new gym and add it to the gym list
  void _createOrUpdateActivity() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Activity newActivity =
        widget.activity?.copyWith(
          id: widget.activity?.id ?? '',
          title: titleCtrl.text,
          description: descrCtrl.text,
          price: double.tryParse(priceCtrl.text) ?? 0.0,
          instructorId: instructorId,
        ) ??
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleCtrl.text,
          description: descrCtrl.text,
          price: double.tryParse(priceCtrl.text) ?? 0.0,
          instructorId: instructorId,
        );

    if (widget.activity == null) {
      await Provider.of<GymProvider>(
        context,
        listen: false,
      ).addActivity(widget.gym, newActivity);
    } else {
      await Provider.of<GymProvider>(
        context,
        listen: false,
      ).updateActivity(widget.gym, newActivity);
    }

    // Clear the controllers after use if needed
    titleCtrl.clear();
    descrCtrl.clear();
    priceCtrl.clear();

    // Navigate back to the previous page
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget _buildDropDownMenu(List<Instructor>? instructors) {
    Instructor noInstructor = Instructor(name: 'No instructor selected');
    var items =
        instructors?.map((Instructor instructor) {
          return DropdownMenuItem<Instructor>(
            value: instructor,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      instructor.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Image.asset(
                          'assets/avatar.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(instructor.title, style: TextStyle(fontSize: 12)),
                    Text(
                      instructor.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList();

    items?.add(
      DropdownMenuItem<Instructor>(
        value: noInstructor,
        child: Text(noInstructor.name),
      ),
    );

    return DropdownButtonFormField<Instructor>(
      items: items,
      decoration: InputDecoration(
        labelText: 'Instructor',
        border: OutlineInputBorder(),
      ),
      onChanged: (Instructor? selectedInstructor) {
        if (selectedInstructor != null) {
          setState(() {
            instructorId = selectedInstructor.id!;
          });
        }
      },
      value: instructors?.firstWhere(
        (Instructor instructor) => instructor.id == instructorId,
        orElse: () => noInstructor,
      ),
      selectedItemBuilder:
          (context) =>
              items
                  ?.map((DropdownMenuItem elem) => Text(elem.value.name))
                  .toList() ??
              [],
    );
  }

  void _navigateToInstructors() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InstructorsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.watch<GymProvider>().isLoading;
    List<Instructor>? instructors =
        Provider.of<InstructorProvider>(context).instructorList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activity == null ? 'Add activity' : 'Update activity',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
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
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildDropDownMenu(instructors),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToInstructors(),
                child: Text('Edit instructors'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: isLoading ? null : () => _createOrUpdateActivity(),
                child:
                    isLoading
                        ? SizedBox(
                          width: 25,
                          child: CircularProgressIndicator(),
                        )
                        : widget.activity == null
                        ? Text('Add activity')
                        : Text('Update activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
