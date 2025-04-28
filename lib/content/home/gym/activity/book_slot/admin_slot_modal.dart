import 'package:dima_project/content/home/gym/activity/book_slot/new_slot.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSlotModal extends StatefulWidget {
  final Slot slot;

  const AdminSlotModal({required this.slot, super.key});

  @override
  State<AdminSlotModal> createState() => _AdminSlotModalState();
}

class _AdminSlotModalState extends State<AdminSlotModal> {
  bool _isFetchingUsers = true;
  List<User> _bookedUsers = [];

  @override
  void initState() {
    super.initState();
    _isFetchingUsers = true;
    context.read<UserProvider>().getUsersByIds(widget.slot.bookedUsers).then((
      users,
    ) {
      setState(() {
        _bookedUsers = users;
        _isFetchingUsers = false;
      });
    });
  }

  void _navigateToModifySlot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: context.read<SlotProvider>(),
              child: NewSlot(
                gymId: widget.slot.gymId,
                activityId: widget.slot.activityId,
                oldSlot: widget.slot,
              ),
            ),
      ),
    ).then((_) => Navigator.pop(context));
  }

  void _deleteSlot() {
    // Show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Slot'),
          content: const Text('Are you sure you want to delete this slot?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((confirm) {
      // If the user confirmed, delete the slot
      if (confirm == true) {
        context.read<SlotProvider>().deleteSlot(widget.slot.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  Widget _buildAdminView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isFetchingUsers) CircularProgressIndicator(),
        if (!_isFetchingUsers && _bookedUsers.isNotEmpty)
          Text(
            'Users booked this slot:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        if (!_isFetchingUsers && _bookedUsers.isEmpty)
          Center(child: Text('No users booked this slot')),
        Expanded(
          child: ListView.builder(
            itemCount: _bookedUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      _bookedUsers[index].photoURL,
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
                title: Text(_bookedUsers[index].displayName),
                subtitle: Text(_bookedUsers[index].email),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () => _navigateToModifySlot(),
            child: Text('Modify slot'),
          ),
        ),
        SizedBox(height: 10, width: double.infinity),
        Center(
          child: ElevatedButton(
            onPressed: () => _deleteSlot(),
            child: Text('Delete slot'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle at the top for better UX
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content that determines the height
          SizedBox(height: 500, child: _buildAdminView()),
        ],
      ),
    );
  }
}
