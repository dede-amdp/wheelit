import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/activity/TicketScreen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData;
  String userEmail;

  @override
  void initState() {
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
            : /*Align(
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
              )), //abbiamo i dati*/
            Center(
                child: RaisedButton(
                    onPressed: () {
                      DatabaseManager.setTicketData(Ticket(
                          email: "pippolippo@gmail.com",
                          used: false,
                          mezzi: {"A": "B"},
                          buyTime:
                              TicketScreen.toLocalDateTime(DateTime.now())[1],
                          buyDate:
                              TicketScreen.toLocalDateTime(DateTime.now())[0]));
                    },
                    child: Text("DO NOT TOUCH PLS"))));
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
}
