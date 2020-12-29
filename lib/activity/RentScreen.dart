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
  bool isProfileCompleted;
  bool isOfAge = true;
  User user = FirebaseAuth.instance.currentUser;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            backgroundColor: Theme.of(context).accentColor, elevation: 0),
        backgroundColor: Theme.of(context).accentColor,
        body: !isOfAge
            ? Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You are too young',
                      style: TextStyle(color: Colors.white, fontSize: 24.0)),
                  Text('to rent a vehicle',
                      style: TextStyle(color: Colors.white, fontSize: 24.0))
                ],
              ))
            : isProfileCompleted == null
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ))
                : !isProfileCompleted
                    ? Center(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('You have to complete',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 24.0)),
                          Text('your profile to rent a vehicle',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 24.0))
                        ],
                      ))
                    : isAlreadyRented == null || isRented == null
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        isRented
                                            ? 'You have rented this vehicle'
                                            : 'Tap the button below to rent the vehicle:',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.0)),
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
                                              color:
                                                  Theme.of(context).accentColor,
                                              size: 150)),
                                    ),
                                  ],
                                ),
                              ));
  }

  Future<void> setUp() async {
    Map userData = (await DatabaseManager.getUserData(user.email));
    DateTime userbirthDate =
        userData['birthDate'] == null ? null : userData['birthDate'].toDate();
    double age = userbirthDate == null
        ? 0
        : DateTime.now().difference(userbirthDate).inDays / 356;

    if (userbirthDate != null && userData['paymentCard'] != null && age > 14) {
      setState(() {
        isProfileCompleted = true;
      });
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
    } else if (userbirthDate == null || userData['paymentCard'] == null) {
      //vai all'account screen
      setState(() {
        this.isProfileCompleted = false;
      });
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                  'You need to complete your profile information before continuing'),
              content: FlatButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/account'),
                  icon: Icon(Icons.account_circle_rounded),
                  label: Text('go to Account Screen')),
            );
          });
    } else {
      //l'utente non ha 14 anni
      setState(() {
        this.isOfAge = false;
      });
    }
  }

  void rent() async {
    Function showMessage = (String text) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
    };

    if (!(await DatabaseManager.isRented(widget.codeMezzo))) {
      //se non è affittato
      if(user.emailVerified) {
        await DatabaseManager.setStartRent(
            userEmail: this.user.email, transportCode: widget.codeMezzo);
        setState(() {
          if (mounted) {
            this.elevation = 0;
            this.isRented = true;
          }
        });
      }else{
        print("errore email non verificata");
        user.sendEmailVerification();
        showMessage('A verification email was sent to the email ${user.email}');

      }
    } else {
      await DatabaseManager.setEndRent(user.email, widget.codeMezzo);
      Navigator.pop(context);
    }
  }
}
