import 'package:dima_project/models/subscription_model.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewSubscription extends StatefulWidget {
  final User? user;
  const NewSubscription({super.key, required this.user});

  @override
  State<NewSubscription> createState() => _NewSubscriptionState();
}

class _NewSubscriptionState extends State<NewSubscription>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  late int selectedDuration;

  late TextEditingController titleCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController priceCtrl;

  DateTime? medicalCertDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 1) {
          setState(() {
            medicalCertDate = widget.user?.certificateExpDate;
          });
        }
        setState(() {});
      }
    });

    // Controllers initialization
    titleCtrl = TextEditingController();
    descriptionCtrl = TextEditingController();
    priceCtrl = TextEditingController();
    selectedDuration = 1;
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Function to validate add duration to the current date
  DateTime addMonths(DateTime date, int months) {
    var newMonth = date.month + months;
    var newYear = date.year + (newMonth - 1) ~/ 12;
    newMonth = (newMonth - 1) % 12 + 1;

    var lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
    var day = date.day <= lastDayOfMonth ? date.day : lastDayOfMonth;

    return DateTime(newYear, newMonth, day);
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
      helpText: 'Select certificate expiration date',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != medicalCertDate) {
      setState(() {
        medicalCertDate = pickedDate;
      });
    }
  }

  // Date formatting function
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var snackBar = ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      if (_tabController.index == 0) {
        // Subscription tab
        if (!_formKey.currentState!.validate()) {
          setState(() {
            _isSaving = false;
          });
          return;
        }

        final Subscription subscription = Subscription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleCtrl.text,
          description: descriptionCtrl.text,
          startTime: DateTime.now(),
          paymentDate: DateTime.now(),
          expiryDate: addMonths(DateTime.now(), selectedDuration),
          price: double.tryParse(priceCtrl.text) ?? 0.0,
          duration: selectedDuration,
        );

        // Update user data in provider and Firestore
        await userProvider.addSubscription(widget.user!, subscription);

        titleCtrl.clear();
        descriptionCtrl.clear();
        priceCtrl.clear();
      } else {
        // Medical certificate tab
        if (medicalCertDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select an expiry date'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }

        // Update the medical certificate date in Firestore
        await userProvider.updateMedicalCertificate(
          widget.user!.uid,
          medicalCertDate!,
        );

        // Uodate the user object in the provider
        widget.user!.certificateExpDate = medicalCertDate;
      }

      setState(() {
        _isSaving = false;
      });

      // Show success message
      snackBar.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _tabController.index == 0
                      ? 'Subscription added successfully!'
                      : 'Medical certificate updated successfully!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Return to previous page
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      // Handle potential errors
      snackBar.showSnackBar(
        SnackBar(
          content: Text('There\'s been an issue during the update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget biuldDurationOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          RadioListTile<int>(
            title: Text('1 month'),
            value: 1,
            groupValue: selectedDuration,
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  selectedDuration = value;
                });
              }
            },
          ),
          Divider(height: 1),
          RadioListTile<int>(
            title: Text('3 months'),
            value: 3,
            groupValue: selectedDuration,
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  selectedDuration = value;
                });
              }
            },
          ),
          Divider(height: 1),
          RadioListTile<int>(
            title: Text('6 months'),
            value: 6,
            groupValue: selectedDuration,
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  selectedDuration = value;
                });
              }
            },
          ),
          Divider(height: 1),
          RadioListTile<int>(
            title: Text('12 months'),
            value: 12,
            groupValue: selectedDuration,
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  selectedDuration = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildSubscriptionCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),

            // Title field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  icon: Icon(Icons.title_outlined),
                  border: InputBorder.none,
                ),
                validator: (value) => _validateMandatory(value),
              ),
            ),
            SizedBox(height: 16),

            // Description field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                controller: descriptionCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  icon: Icon(Icons.description_outlined),
                  border: InputBorder.none,
                ),
                maxLines: 2,
                validator: (value) => _validateMandatory(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriceCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),

            // Price field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText: 'Price (€)',
                  icon: Icon(Icons.euro_symbol_outlined),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _validateMandatory(value),
              ),
            ),
            SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.yellow,
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Full payment required at the time of subscription.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDurationCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            biuldDurationOptions(),
          ],
        ),
      ),
    );
  }

  Widget buildSubscriptionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            buildSubscriptionCard(),
            SizedBox(height: 16),
            buildDurationCard(),
            SizedBox(height: 16),
            buildPriceCard(),
          ],
        ),
      ),
    );
  }

  Widget buildDateSelectionBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              medicalCertDate != null &&
                      medicalCertDate!.isAfter(
                        DateTime.now().subtract(Duration(days: 1)),
                      )
                  ? Icons.event_available_outlined
                  : Icons.event_busy_outlined,
              color:
                  medicalCertDate != null &&
                          medicalCertDate!.isAfter(
                            DateTime.now().subtract(Duration(days: 1)),
                          )
                      ? Colors.green
                      : Colors.red,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              medicalCertDate != null
                  ? _formatDate(medicalCertDate!)
                  : 'No date selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: medicalCertDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDateSelectionCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expiry Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text('Select date', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 36),
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      medicalCertDate != null
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                ),
              ),
              child: buildDateSelectionBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicalCertificateTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical Certificate Expiry Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Date selection card
          buildDateSelectionCard(),

          SizedBox(height: 24),

          // Info text
          Text(
            'The medical certificate must be valid to participate in gym activities.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserInfoBox() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          child: ClipOval(
            child: Image.network(
              widget.user?.photoURL ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Image.asset('assets/avatar.png', fit: BoxFit.cover);
              },
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user != null
                    ? widget.user!.displayName
                    : 'No User Selected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.user != null ? widget.user!.email : '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User documents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Subscription"),
            Tab(text: "Medical Certificate"),
          ],
        ),
      ),
      // Mantieni il bottomNavigationBar per il pulsante fisso
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: Icon(
              _tabController.index == 0
                  ? Icons.save_outlined
                  : Icons.medical_services_outlined,
            ),
            label: Text(
              _tabController.index == 0
                  ? "Save Subscription"
                  : "Update Medical Certificate",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
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
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: buildUserInfoBox(),
                    ),
                  ),

                  // TabBarView content - scrollabile
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // TAB 1: Subscription form
                        buildSubscriptionTab(),
                        // TAB 2: Medical Certificate form
                        buildMedicalCertificateTab(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
