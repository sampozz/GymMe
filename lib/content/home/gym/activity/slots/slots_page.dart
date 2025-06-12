import 'dart:io';

import 'package:dima_project/models/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/slots/admin_slot_modal.dart';
import 'package:dima_project/content/home/gym/activity/slots/confirm_booking_modal.dart';
import 'package:dima_project/content/home/gym/activity/slots/new_slot.dart';
import 'package:dima_project/content/home/gym/activity/slots/slot_card.dart';
import 'package:dima_project/models/slot_model.dart';
import 'package:dima_project/providers/slot_provider.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/models/gym_model.dart';
import 'package:dima_project/models/instructor_model.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SlotsPage extends StatefulWidget {
  final int gymIndex;
  final int activityIndex;

  const SlotsPage({
    super.key,
    required this.gymIndex,
    required this.activityIndex,
  });

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  Gym? gym;
  Activity? activity;
  List<Slot>? slotList;
  User? user;
  Instructor? instructor;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 31, vsync: this);
    selectedDate = DateTime.now(); // Initialize selected date to today
    _tabController.addListener(() {
      // Update the selected date when the tab changes
      setState(() {
        selectedDate = DateTime.now().add(Duration(days: _tabController.index));
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Deletes the activity from the database
  void _deleteActivity(Gym gym, Activity activity) {
    var gymProvider = Provider.of<GymProvider>(context, listen: false);
    // Show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Activity'),
          content: const Text('Are you sure you want to delete this activity?'),
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
      // If the user confirmed, delete the activity
      if (confirm == true) {
        gymProvider.removeActivity(gym, activity);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  /// Modify the activity
  void _modifyActivity(Gym gym, Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewActivity(gym: gym, activity: activity),
      ),
    );
  }

  /// Navigate to the add slot page
  void _addSlot(Gym gym, Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: context.read<SlotProvider>(),
              child: NewSlot(gymId: gym.id!, activityId: activity.id),
            ),
      ),
    );
  }

  void _showBookingModal(Slot slot) {
    User? user = context.read<UserProvider>().user;
    if (user?.isAdmin ?? false) {
      showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        useRootNavigator: true,
        builder:
            (_) => ChangeNotifierProvider.value(
              value: context.read<SlotProvider>(),
              child: AdminSlotModal(slot: slot),
            ),
      );
      return;
    }

    // Check if the user is already booked for the slot
    if (slot.bookedUsers.contains(user?.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already booked this slot.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if the slot is already full
    if (slot.bookedUsers.length >= slot.maxUsers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This slot is already full.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder:
          (_) => ConfirmBookingModal(
            gym: gym!,
            activity: activity!,
            slot: slot,
            onBookingConfirmed: _onBookingConfirmed,
          ),
    );
  }

  void _onBookingConfirmed(String slotId) {
    Provider.of<SlotProvider>(context, listen: false).addUserToSlot(slotId);
  }

  Widget _buildAdminActions() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _addSlot(gym!, activity!),
            child: Text('Add slot'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _modifyActivity(gym!, activity!),
            child: Text('Modify activity'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteActivity(gym!, activity!),
            child: Text(
              'Delete activity',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotList() {
    return switch (slotList) {
      // Display a loading indicator when the slot list is null
      null => Center(child: CircularProgressIndicator()),
      // Display a message when there are no slots available
      [] => Center(child: Text('No slots available')),
      // Display the slot list - remove Expanded
      _ => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                slotList!.map((slot) {
                  // Check if the slot date matches the selected date
                  if (_tabController.index != 30 &&
                      (slot.startTime.day != selectedDate?.day ||
                          slot.startTime.month != selectedDate?.month ||
                          slot.startTime.year != selectedDate?.year)) {
                    return Container(); // Skip this slot
                  }
                  return GestureDetector(
                    onTap: () => _showBookingModal(slot),
                    child: SlotCard(
                      slot: slot,
                      alreadyBooked: slot.bookedUsers.contains(user?.uid),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    };
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(activity!.description, style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child:
                          !kIsWeb && !Platform.isAndroid && !Platform.isIOS
                              ? Image.asset(
                                'assets/avatar.png',
                                fit: BoxFit.cover,
                              ) // For tests
                              : ClipOval(
                                child: Image.network(
                                  instructor?.photo ?? '',
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
                      children: [
                        Text(
                          instructor?.title ?? 'Instructor info not available',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(instructor?.name ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Price',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('EUR ${activity!.price}', textAlign: TextAlign.end),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _generateTabs() {
    return List.generate(30, (index) {
          // Generate tabs for the next 30 days
          final date = DateTime.now().add(Duration(days: index));
          final day = DateFormat('d').format(date);
          final month = DateFormat('MMMM').format(date);
          final weekdayName = DateFormat('EEE').format(date);
          return Tab(
            height: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(weekdayName, style: TextStyle(fontSize: 12)),
                SizedBox(height: 2),
                Text(
                  day,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(month, style: TextStyle(fontSize: 12)),
                SizedBox(height: 2),
                Icon(
                  Icons.circle,
                  color:
                      (slotList
                                  ?.map((slot) => slot.startTime.day)
                                  .contains(date.day) ??
                              false)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  size: 8,
                ),
                SizedBox(height: 2),
              ],
            ),
          );
        }) +
        [
          Tab(
            height: 84,
            child: Text(
              'Show all',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ];
  }

  @override
  Widget build(BuildContext context) {
    gym = context.watch<GymProvider>().gymList![widget.gymIndex];
    activity = gym!.activities[widget.activityIndex];
    slotList = context.watch<SlotProvider>().nextSlots;
    user = context.watch<UserProvider>().user;
    instructor =
        context.watch<InstructorProvider>().instructorList?.firstWhere(
          (instructor) => instructor.id == activity!.instructorId,
          orElse: () => Instructor(),
        ) ??
        Instructor();

    return Scaffold(
      appBar: AppBar(
        title: Text(activity!.title),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          dividerHeight: 0,
          tabs: _generateTabs(),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildActivityHeader(),
            _buildSlotList(),
            if (slotList != null &&
                slotList!.every(
                  (slot) =>
                      _tabController.index != 30 &&
                      (slot.startTime.day != selectedDate?.day ||
                          slot.startTime.month != selectedDate?.month ||
                          slot.startTime.year != selectedDate?.year),
                ))
              Center(child: Text('No slots available for the selected date')),
            SizedBox(height: 20),
            if (user != null && user!.isAdmin) _buildAdminActions(),
          ],
        ),
      ),
    );
  }
}
