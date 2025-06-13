import 'package:gymme/content/profile/new_my_data.dart';
import 'package:flutter/material.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyData extends StatelessWidget {
  final User? user;
  const MyData({super.key, this.user});

  Widget buildListTile(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 22,
          ),
          title: Text(title, style: TextStyle(fontSize: 16)),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget buildProfilePicture(String photoURL, bool isMobile) {
    return CircleAvatar(
      radius: isMobile ? 50 : 80,
      child: ClipOval(
        child: Image.network(
          photoURL,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Image.asset('assets/avatar.png', fit: BoxFit.cover);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;
    // Controlla se è un dispositivo mobile basandosi sulla larghezza dello schermo
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('My data'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                // Usa un layout diverso in base alla dimensione dello schermo
                child:
                    isMobile
                        ? _buildMobileLayout(
                          user,
                          context,
                        ) // Layout mobile con foto sopra
                        : _buildDesktopLayout(
                          user,
                          context,
                        ), // Layout desktop con foto a sinistra (attuale)
              ),
      bottomNavigationBar:
          (user != null && !user.isAdmin)
              ? Container(
                decoration: BoxDecoration(color: Colors.transparent),
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewMyData(user: user),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_outlined),
                    label: Text('Modify', style: TextStyle(fontSize: 16)),
                  ),
                ),
              )
              : null,
    );
  }

  // Layout mobile con foto sopra
  Widget _buildMobileLayout(User user, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Immagine del profilo centrata in alto
        // solo se non è un admin
        if (!(user.isAdmin)) ...[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [buildProfilePicture(user.photoURL, true)]),
          ),
        ],
        // Lista dei dettagli utente
        Expanded(
          child: ListView(children: _buildUserDetailsList(user, context)),
        ),
      ],
    );
  }

  // Layout desktop con foto a sinistra (layout attuale)
  Widget _buildDesktopLayout(User user, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonna sinistra con l'immagine del profilo
        // solo se non è un admin
        if (!(user.isAdmin)) ...[
          SizedBox(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [buildProfilePicture(user.photoURL, false)],
            ),
          ),
        ],
        SizedBox(width: 16),
        // Colonna destra con l'elenco delle ListTile
        Expanded(
          child: ListView(children: _buildUserDetailsList(user, context)),
        ),
      ],
    );
  }

  List<Widget> _buildUserDetailsList(User user, BuildContext context) {
    return [
      buildListTile(
        Icons.person_outlined,
        'Name',
        user.displayName.isNotEmpty ? user.displayName : 'Unspecified',
        context,
      ),
      buildListTile(Icons.email_outlined, 'Email', user.email, context),
      if (!(user.isAdmin)) ...[
        buildListTile(
          Icons.phone_outlined,
          'Phone number',
          user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Unspecified',
          context,
        ),
        buildListTile(
          Icons.home_outlined,
          'Address',
          user.address.isNotEmpty ? user.address : 'Unspecified',
          context,
        ),
        buildListTile(
          Icons.badge_outlined,
          'Tax code',
          user.taxCode.isNotEmpty ? user.taxCode : 'Unspecified',
          context,
        ),
        buildListTile(
          Icons.calendar_today_outlined,
          'Birth date',
          user.birthDate != null
              ? '${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}'
              : 'Unspecified',
          context,
        ),
        buildListTile(
          Icons.location_on_outlined,
          'Birth place',
          user.birthPlace.isNotEmpty ? user.birthPlace : 'Unspecified',
          context,
        ),
      ],
    ];
  }
}
