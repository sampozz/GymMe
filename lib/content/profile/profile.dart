import 'package:dima_project/content/bookings/widgets/booking_page.dart';
import 'package:dima_project/content/bookings/widgets/bookings.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void _signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  /*    
 Chip utente con dati (dati da definire)
 Nome e cognome
 Pagina “i miei dati” anagrafica
 Pagina delle prenotazioni attive (sempre la solita)
 Pagina per visualizzare tessere e abbonamenti
 Pagina per visualizzare il certificato medico
 pagina gestione accessi notifiche e calendario
 [?] tema chiaro/scuro
 Logout (→ ritorna alla schermata di login/signup)
 Eliminare l’account */

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;
    final List<String> fields = <String>[
      "Chip",
      "I miei dati",
      "Prenotazioni",
      "Tessere e abbonamenti",
      "Certificato medico",
      "Notifiche e calendario",
      "Tema chiaro/scuro",
      "Logout",
    ];

    return user == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    switch (i) {
                      case 0: // "Chip"
                        break;
                      // TODO: gestire gli altri casi
                      case 2: // "Prenotazioni"
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Bookings()),
                        );
                        break;
                      case 7: // "Logout"
                        _signOut(context);
                        break;
                      // Altri casi...
                    }
                  },
                  child:
                      i == 0
                          ? Container(
                            height: 100,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      user.photoURL.isEmpty
                                          ? AssetImage('assets/avatar.png')
                                          : NetworkImage(user.photoURL),
                                  radius: 40,
                                ),
                                SizedBox(
                                  width: 16,
                                ), // Spazio tra l'immagine e il testo
                                // Colonna con nome, email e numero di telefono
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Container(
                            height: 40,
                            width:
                                double
                                    .infinity, // Questa riga assicura che il container occupi tutta la larghezza
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fields[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color:
                                        i == fields.length - 1
                                            ? Colors.red
                                            : null,
                                  ),
                                ),
                                if (i > 0 && i < fields.length - 1)
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                          ),
                ),
                if (i < fields.length - 1)
                  Divider(
                    color: Color.fromARGB(255, 172, 172, 172),
                    thickness: 1.0,
                  ),
              ],
              SizedBox(height: 100),
            ],
          ),
        );
  }
}
