import 'package:gymme/content/profile/subscription/new_subscription.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FetchSubscription extends StatefulWidget {
  const FetchSubscription({super.key});

  @override
  State<FetchSubscription> createState() => _FetchSubscriptionState();
}

class _FetchSubscriptionState extends State<FetchSubscription> {
  late TextEditingController searchCtrl;
  List<User>? _userList;
  List<User>? _filteredUserList;
  late UserProvider _userProvider;
  bool _useMobileLayout = true;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();

    _userProvider = context.read<UserProvider>();
    _loadUsers();
    searchCtrl.addListener(_filterUserList);
  }

  Future<void> _loadUsers() async {
    _userList = await _userProvider.getUserList();
    setState(() {
      _filteredUserList = _userList;
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _filterUserList() {
    if (searchCtrl.text.isEmpty) {
      setState(() {
        _filteredUserList = _userList;
      });
    } else {
      setState(() {
        _filteredUserList =
            _userList
                ?.where(
                  (user) => user.displayName.toLowerCase().contains(
                    searchCtrl.text.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  void _searchList() {
    final String query = searchCtrl.text.toLowerCase();

    if (query.isNotEmpty) {
      setState(() {
        _filteredUserList =
            _userList
                ?.where(
                  (user) =>
                      user.displayName.toLowerCase().contains(query) ||
                      user.email.toLowerCase().contains(query),
                )
                .toList();
      });
    } else {
      setState(() {
        _filteredUserList = null;
      });
    }
  }

  Widget _buildUserList() {
    if (_userList == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (_userList!.isEmpty) {
      return Center(child: Text('No users found'));
    }

    final displayList = _filteredUserList ?? _userList;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: displayList?.length ?? 0,
      itemBuilder: (context, index) {
        final user = displayList![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
            onTap: () {
              // Navigare alla pagina di creazione abbonamento con l'utente selezionato
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewSubscription(user: user),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: CircleAvatar(
                  radius: 35,
                  child: ClipOval(
                    child: Image.network(
                      user.photoURL,
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
                title: Text(
                  user.displayName.isNotEmpty ? user.displayName : "No Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(user.email, style: TextStyle(fontSize: 14)),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      controller: searchCtrl,
      onChanged: (value) {
        _searchList();
      },
      trailing:
          searchCtrl.text.isNotEmpty
              ? [
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchCtrl.clear();
                    searchCtrl.clear();
                  },
                ),
              ]
              : null,
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16.0),
      ),
      leading: const Icon(Icons.search),
      elevation: WidgetStateProperty.all(0),
      hintText: 'Search for a user by name or email...',
      hintStyle: WidgetStatePropertyAll<TextStyle>(
        TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Members'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16.0),
            Expanded(child: _buildUserList()),
            // If the user if from mobile, add padding to the bottom
            if (_useMobileLayout) SizedBox(height: 65.0),
          ],
        ),
      ),
    );
  }
}
