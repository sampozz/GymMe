import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewActivity extends StatelessWidget {
  final Gym gym;
  final Activity? activity;

  NewActivity({super.key, required this.gym, this.activity});

  final TextEditingController nameCtrl = TextEditingController();

  /// Create a new gym and add it to the gym list
  void _createOrUpdateActivity(BuildContext context) async {
    Activity newActivity =
        activity?.copyWith(name: nameCtrl.text) ??
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameCtrl.text,
        );

    if (activity == null) {
      await Provider.of<GymProvider>(
        context,
        listen: false,
      ).addActivity(gym, newActivity);
    } else {
      await Provider.of<GymProvider>(
        context,
        listen: false,
      ).updateActivity(gym, newActivity);
    }

    // Clear the controllers after use if needed
    nameCtrl.clear();

    // Navigate back to the previous page
    if (context.mounted) {
      // TODO: find way to navigate to the gym page with the updated activity list
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    nameCtrl.text = activity?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Add activity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // TODO: implement form validation
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Activity Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _createOrUpdateActivity(context),
                child:
                    activity == null
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
