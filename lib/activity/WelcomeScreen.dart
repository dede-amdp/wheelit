import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelit/Auth.dart';
import 'package:location/location.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<WelcomeScreen> {
  User user;

  @override
  initState() {
    getLocationPermission();
    super.initState();
  }

  navigateToLogin() async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  navigateToRegister() async {
    Navigator.pushReplacementNamed(context, '/signUp');
  }

  navigateToHomeScreen() async {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Image(
                    image: AssetImage("assets/images/DrawerHeaderImage.jpg")),
              ),
              SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                      text: 'Welcome to ',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                        text: 'Wheelit',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor))
                  ])),
              SizedBox(height: 10.0),
              Text(
                "The app for smart mobility",
                style: TextStyle(fontSize: 20.0, color: Colors.black),
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      onPressed: navigateToLogin,
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Theme.of(context).accentColor),
                  SizedBox(width: 20.0),
                  RaisedButton(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      onPressed: navigateToRegister,
                      child: Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Theme.of(context).accentColor),
                ],
              ),
              SizedBox(height: 20.0),
              SignInButton(Buttons.Google,
                  text: "Sign up with Google",
                  onPressed: ()  {
                        signInWithGoogle()
                            .then((user) => navigateToHomeScreen())
                            .whenComplete(() => showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Please complete your profile"),
                                actions: <Widget>[
                                  MaterialButton(
                                    elevation: 5.0,
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/account');
                                    },
                                  )
                                ],
                              );
                            }),
                        );
                      }),
            ],
          ),
        ),
      ),
    );
  }

  void getLocationPermission() {
    Location().getLocation().then((value) => {});
  }

}

Future<AlertDialog> completeProfile() async {

}