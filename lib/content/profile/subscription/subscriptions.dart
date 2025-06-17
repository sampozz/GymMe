import 'package:gymme/models/subscription_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  // Set to track which subscriptions are expanded
  final Set<String> _expandedSubscriptions = {};

  // Toggle the expanded state of a subscription
  void _toggleExpansion(String subscriptionId) {
    setState(() {
      if (_expandedSubscriptions.contains(subscriptionId)) {
        _expandedSubscriptions.remove(subscriptionId);
      } else {
        _expandedSubscriptions.add(subscriptionId);
      }
    });
  }

  Future<void> _refreshSubscriptions(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final snackBar = ScaffoldMessenger.of(context);
    try {
      await userProvider.fetchUser();

      // Optional: show success message
      snackBar.showSnackBar(
        const SnackBar(
          content: Text('Subscriptions updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      snackBar.showSnackBar(
        SnackBar(
          content: Text('Error refreshing subscriptions: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildSubscriptionsList(
    BuildContext context,
    List<Subscription>? subscriptions,
  ) {
    if (subscriptions == null) {
      return const CircularProgressIndicator();
    }

    if (subscriptions.isEmpty) {
      return const Text(
        'No subscriptions found',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshSubscriptions(context),
      child: ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          final isExpanded = _expandedSubscriptions.contains(subscription.id);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Card(
              elevation: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icona centrata verticalmente
                            Container(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.fitness_center,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                size: 36,
                              ),
                            ),
                            // Contenuto principale
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titolo
                                  Text(
                                    subscription.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Indicatore di validità
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color:
                                              subscription.expiryDate != null &&
                                                      subscription.expiryDate!
                                                          .isAfter(
                                                            DateTime.now(),
                                                          )
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 14,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          subscription.expiryDate != null &&
                                                  subscription.expiryDate!
                                                      .isAfter(DateTime.now())
                                              ? "Expiring on ${_formatDate(subscription.expiryDate!)}"
                                              : "Expired on ${_formatDate(subscription.expiryDate!)}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Down arrow
                        InkWell(
                          onTap: () => _toggleExpansion(subscription.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  isExpanded ? "Hide details" : "Show details",
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedCrossFade(
                    firstChild: SizedBox(height: 0, width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        // Cambia questo da CrossAxisAlignment.start a CrossAxisAlignment.center
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${subscription.duration}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  subscription.duration == 1
                                      ? 'month'
                                      : 'months',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(height: 8, thickness: 1),
                                SizedBox(height: 16),
                                // Description
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(subscription.description),
                                SizedBox(height: 8),
                                // Start date
                                Text(
                                  "Start date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  subscription.startTime != null
                                      ? _formatDate(subscription.startTime!)
                                      : "N/A",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),

                                SizedBox(height: 24),

                                // Prezzo
                                Text(
                                  "Payment details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "€${subscription.price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),

                                // Data di pagamento
                                if (subscription.paymentDate != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    "Paid on ${_formatDate(subscription.paymentDate!)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],

                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    firstCurve: Curves.easeOut,
                    secondCurve: Curves.easeIn,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    List<Subscription>? subscriptions =
        context.watch<UserProvider>().user?.subscriptions;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Subscriptions'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: "Valid"), Tab(text: "Expired")],
            dividerHeight: 0,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: TabBarView(
            children: <Widget>[
              Center(
                child: _buildSubscriptionsList(
                  context,
                  subscriptions
                      ?.where(
                        (b) =>
                            b.expiryDate != null &&
                            b.expiryDate!.isAfter(startOfDay),
                      )
                      .toList(),
                ),
              ),
              Center(
                child: _buildSubscriptionsList(
                  context,
                  subscriptions
                      ?.where(
                        (b) =>
                            b.expiryDate != null &&
                            b.expiryDate!.isBefore(startOfDay),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
