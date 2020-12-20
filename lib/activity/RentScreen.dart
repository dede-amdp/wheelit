import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:firebase_auth/firebase_auth.dart';

//ignore:must_be_immutable
class RentScreen extends StatefulWidget {
  String codeMezzo;
  bool fromDrawer;
  RentScreen({this.codeMezzo, this.fromDrawer = false});
  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  Map infoMezzo;
  bool isRented;
  bool isAlreadyRented;
  double elevation = 10;
  User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).accentColor, elevation: 0),
        backgroundColor: Theme.of(context).accentColor,
        body: isAlreadyRented == null || isRented == null
            ? Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ))
            : isAlreadyRented
                ? Center(
                    child: Text(
                        'This Vehicle was already rented by someone else...'))
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            isRented
                                ? 'You have rented this vehicle'
                                : 'Tap the button below to rent the vehicle:',
                            style:
                                TextStyle(color: Colors.white, fontSize: 24.0)),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: RaisedButton(
                              elevation: elevation,
                              color: Colors.white,
                              onPressed: () {
                                rent();
                              },
                              shape: CircleBorder(),
                              child: Icon(Icons.power_settings_new,
                                  color: Theme.of(context).accentColor,
                                  size: 150)),
                        ),
                      ],
                    ),
                  ));
  }

  Future<void> setUp() async {
    this.isRented = true;
    String idMezzo = widget.codeMezzo;
    if (!widget.fromDrawer) {
      //Scannerizza il qr
      if (await DatabaseManager.isRented(idMezzo)) {
        setState(() {
          if (mounted) {
            this.isRented = true;
            this.elevation = 0;
          }
        });
        bool isSameUser =
            await DatabaseManager.isSameUser(this.user.email, idMezzo);
        setState(() {
          if (mounted) this.isAlreadyRented = !isSameUser;
        });
      } else {
        setState(() {
          if (mounted) {
            this.isAlreadyRented = false;
            this.isRented = false;
            this.elevation = 10;
          }
        });
      }
    } else {
      setState(() {
        if (mounted) {
          this.isAlreadyRented = false;
          this.isRented = true;
          this.elevation = 0;
        }
      });
    }
  }

  void rent() async {
    if (!(await DatabaseManager.isRented(widget.codeMezzo))) {
      //se non è affittato
      await DatabaseManager.setStartRent(
          userEmail: this.user.email, transportCode: widget.codeMezzo);
      setState(() {
        if (mounted) {
          this.elevation = 0;
          this.isRented = true;
        }
      });
    } else {
      await DatabaseManager.setEndRent(user.email, widget.codeMezzo);
      Navigator.pop(context);
    }
  }
}
