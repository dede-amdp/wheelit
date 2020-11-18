import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData; //se è null l'utente non è loggato -> inseriamo il db?

  @override
  void initState() {
    super.initState();
    //accedi al db interno userData = db.get('email');
    if (userData == null) logIn();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, backgroundColor: Colors.transparent),
      body: userData.length <= 1 //se contiene solo un campo (l'email)
          ? Center(child: CircularProgressIndicator()) //attende il fetch
          : Center(child: Contents(values: userData)), //abbiamo i dati
    );
  }

  Future<void> getData() async {
    //Prendi i dati utente (almeno l'email) dal db in locale?
    await Future.delayed(Duration(seconds: 3)); //simula il fetching dei dati
    setState(() {
      this.userData.addAll({
        'name': 'Filippo',
        'cognome': 'Di Lipponia',
        'dataNascita': '20/02/2020'
      });
    });
  }

  void logIn() {
    //ESEGUI IL LOG IN CON GOOGLE AUTH, PER ORA INIZIALIZZA userData
    //il log in fatto con google (e apple?) salva la mail dell'utente nel dispositivo
    //e poi assegnamo il valore a userData :)
    this.userData = {'email': 'pippolippo@gmail.com'}; //simula un log in
  }
}

class Contents extends StatelessWidget {
  Map values;
  Contents({this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: values.values.map((e) {
      return Text(e.toString());
    }).toList());
  }
}
