import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData; //se è null l'utente non è loggato -> inseriamo il db?
  String userEmail;

  @override
  void initState() {
    //accedi al db interno userEmail = db.get('email');
    if (userData == null) logIn();
    getData(userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black)),
      body: userData == null //se contiene solo un campo (l'email)
          ? Center(child: CircularProgressIndicator()) //attende il fetch
          : Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 0),
                child: Card(
                  color: Theme.of(context).accentColor,
                  child: ListTile(
                    onTap: () {
                      print('${userData.toString()}');
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${userData['name']} ${userData['surname']}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$userEmail',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
              )), //abbiamo i dati
    );
  }

  Future<void> getData(String userEmail) async {
    //Prendi i dati utente (almeno l'email) dal db in locale?
    Map usableData = await DatabaseManager.getUserData(userEmail);
    if (usableData != null) {
      setState(() {
        userData = usableData;
      });
    } else {
      print("NO DATA");
    }
  }

  void logIn() {
    //ESEGUI IL LOG IN CON GOOGLE AUTH, PER ORA INIZIALIZZA userData
    //il log in fatto con google (e apple?) salva la mail dell'utente nel dispositivo
    //e poi assegnamo il valore a userData :)
    //simula un log in
    userEmail = 'pippolippo@gmail.com';
  }
}
