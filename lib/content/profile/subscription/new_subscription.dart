import 'package:dima_project/content/profile/subscription/subscription_model.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewSubscription extends StatefulWidget {
  User? user;
  NewSubscription({super.key, required this.user});

  @override
  _NewSubscriptionState createState() => _NewSubscriptionState(user: user);
}

class _NewSubscriptionState extends State<NewSubscription>
    with SingleTickerProviderStateMixin {
  User? user;
  final _formKey = GlobalKey<FormState>();
  _NewSubscriptionState({this.user});

  // Aggiungi TabController
  late TabController _tabController;
  late int selectedDuration;

  late TextEditingController titleCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController priceCtrl;

  // Aggiungi variabile per la data del certificato medico
  DateTime? medicalCertDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inizializza TabController
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Quando l'utente passa alla tab del certificato medico (index 1)
        if (_tabController.index == 1) {
          // Aggiorna la data con quella dell'utente
          setState(() {
            medicalCertDate = null;
          });
        }
        setState(() {}); // Aggiorna l'interfaccia per il bottone
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
    // Rimuovi il listener quando il widget viene distrutto
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

  // Implementa il selettore di data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: medicalCertDate ?? DateTime.now(),
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

  // Formatta la data per la visualizzazione
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Modifica il metodo _saveChanges per gestire entrambe le tab
  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
          expiryDate: addMonths(DateTime.now(), selectedDuration),
          price: double.tryParse(priceCtrl.text) ?? 0.0,
          paymentDate: DateTime.now(),
          duration: selectedDuration,
        );

        // Update user data in provider and Firestore
        await userProvider.addSubscription(user!, subscription);

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

        // Salva il certificato medico
        await userProvider.updateMedicalCertificate(
          user!.uid,
          medicalCertDate!,
        );

        // Aggiorna anche l'oggetto user locale con il nuovo valore
        user!.certificateExpDate = medicalCertDate;
      }

      setState(() {
        _isSaving = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
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
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      // Handle potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There\'s been an issue during the update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New subscription or medical certification'),
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
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: Icon(
              _tabController.index == 0 ? Icons.save : Icons.medical_services,
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
                  // User info card - sempre visibile, sopra i tab content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                user!.photoURL.isEmpty
                                    ? AssetImage('assets/avatar.png')
                                    : NetworkImage(user!.photoURL),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user != null
                                      ? user!.displayName
                                      : 'No User Selected',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user != null ? user!.email : '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TabBarView content - scrollabile
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // TAB 1: Subscription form
                        SingleChildScrollView(
                          padding: EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subscription Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Subscription details card
                                Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Plan Information',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Title field
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: TextFormField(
                                            controller: titleCtrl,
                                            decoration: InputDecoration(
                                              labelText: 'Title',
                                              icon: Icon(Icons.title),
                                              border: InputBorder.none,
                                            ),
                                            validator:
                                                (value) =>
                                                    _validateMandatory(value),
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Description field
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: TextFormField(
                                            controller: descriptionCtrl,
                                            decoration: InputDecoration(
                                              labelText: 'Description',
                                              icon: Icon(Icons.description),
                                              border: InputBorder.none,
                                            ),
                                            maxLines: 2,
                                            validator:
                                                (value) =>
                                                    _validateMandatory(value),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Duration card
                                Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Duration',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),

                                        // Duration options
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Price card
                                Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Payment Details',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Price field
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: TextFormField(
                                            controller: priceCtrl,
                                            decoration: InputDecoration(
                                              labelText: 'Price (€)',
                                              icon: Icon(Icons.euro),
                                              border: InputBorder.none,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator:
                                                (value) =>
                                                    _validateMandatory(value),
                                          ),
                                        ),
                                        SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue[300],
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Full payment required at signup',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // TAB 2: Medical Certificate form
                        SingleChildScrollView(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical Certificate Expiry Date',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Date selection card
                              Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Expiry Date:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed:
                                                () => _selectDate(context),
                                            icon: Icon(Icons.calendar_today),
                                            label: Text('Select Date'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                medicalCertDate != null
                                                    ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                    : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  medicalCertDate != null
                                                      ? Icons.event_available
                                                      : Icons.event_busy,
                                                  color:
                                                      medicalCertDate != null
                                                          ? Colors.green
                                                          : Colors.red,
                                                  size: 28,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  medicalCertDate != null
                                                      ? _formatDate(
                                                        medicalCertDate!,
                                                      )
                                                      : 'No date selected',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        medicalCertDate != null
                                                            ? Colors.black
                                                            : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
