import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData = null; //se è null l'utente non è loggato -> inseriamo il db?
  String userEmail;

  @override
  void initState() {
    //accedi al db interno userData = db.get('email');
    if (userData == null) logIn();
    getData(userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, backgroundColor: Colors.transparent),
      body: userData == null //se contiene solo un campo (l'email)
          ? Center(child: CircularProgressIndicator()) //attende il fetch
          : Center(
              child: RaisedButton(
                  child: Text("Data"),
                  onPressed: () {
                    print(userData.toString());
                  })), //abbiamo i dati
    );
  }

  Future<void> getData(String userEmail) async {
    //Prendi i dati utente (almeno l'email) dal db in locale?
    //await Future.delayed(Duration(seconds: 3)); //simula il fetching dei dati
    Map usableData = await DatabaseManager.getUserData(userEmail);
    if (usableData != null) {
      setState(() {
        /*this.userData.addAll({
        'name': 'Filippo',
        'cognome': 'Di Lipponia',
        'dataNascita': '20/02/2020'
      });*/
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
    //this.userData = {'email': 'pippolippo@gmail.com'}; //simula un log in
    userEmail = 'pippolippo@gmail.com';
  }
}

//ROBA INUTILE ELIMINABILE CHE SERVE PER TEST
/*class Contents extends StatelessWidget {
  Map values;
  Contents({this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: values.values.map((e) {
      return Text(e.toString());
    }).toList());
  }
}*/
