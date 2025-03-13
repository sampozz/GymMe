import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewGym extends StatelessWidget {
  final Gym? gym;

  NewGym({super.key, this.gym});

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  /// Create a new gym and add it to the gym list
  void _createOrUpdateGym(BuildContext context) async {
    Gym newGym =
        gym?.copyWith(
          name: nameCtrl.text,
          address: addressCtrl.text,
          phone: phoneCtrl.text,
        ) ??
        Gym(
          name: nameCtrl.text,
          address: addressCtrl.text,
          phone: phoneCtrl.text,
        );

    if (gym == null) {
      await Provider.of<GymProvider>(context, listen: false).addGym(newGym);
    } else {
      await Provider.of<GymProvider>(context, listen: false).updateGym(newGym);
    }

    // Clear the controllers after use if needed
    nameCtrl.clear();
    addressCtrl.clear();
    phoneCtrl.clear();

    // Navigate back to the previous page
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    nameCtrl.text = gym?.name ?? '';
    addressCtrl.text = gym?.address ?? '';
    phoneCtrl.text = gym?.phone ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Add Gym')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // TODO: implement form validation
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Gym Name'),
              ),
              TextFormField(
                controller: addressCtrl,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _createOrUpdateGym(context),
                child: gym == null ? Text('Add Gym') : Text('Update Gym'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
