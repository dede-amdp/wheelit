import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime birthDate = DateTime.now();
  String userName;
  String email;
  String password;
  String carCode;
  String cvc;
  String expirationDate;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void checkAuthentication() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void initState() {
    this.checkAuthentication();
    super.initState();
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await DatabaseManager.setPaymentCard(
            email, cvc, carCode, expirationDate);
        User user = (await _auth.createUserWithEmailAndPassword(
                email: email, password: password))
            .user;
        await DatabaseManager.setUser(email, birthDate, userName);
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
        if (user != null) {
          await FirebaseAuth.instance.currentUser
              .updateProfile(displayName: user.displayName);
        }
      } catch (error) {
        showError(error.message);
        print(error);
      }
    }
  }

  void showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Image(
                    image: AssetImage("assets/images/DrawerHeaderImage.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TextFormField(
                              // ignore: missing_return
                              validator: (input) {
                                if (input.isEmpty) {
                                  return '  Enter user name';
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              decoration: InputDecoration(
                                  labelText: 'User name',
                                  prefixIcon: Icon(Icons.account_box_rounded,
                                      color: Theme.of(context).accentColor)),
                              onSaved: (input) => userName = input),
                        ),
                        Container(
                          child: TextFormField(
                              // ignore: missing_return
                              validator: (input) {
                                bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(input);
                                if (input.isEmpty) {
                                  return '  Enter Email';
                                } else if (emailValid == false) {
                                  return '  invalid email format';
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email,
                                      color: Theme.of(context).accentColor)),
                              onSaved: (input) => email = input),
                        ),
                        ListTile(
                          title: Text(
                              "Birth date: ${birthDate.day}/"
                              "${birthDate.month}/ ${birthDate.year}  ",
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Theme.of(context).accentColor)),
                          onTap: pickDate,
                        ),
                        Container(
                          child: TextFormField(
                              // ignore:, missing_return
                              validator: (input) {
                                if (input.length < 6) {
                                  return 'Provide Minimum 6 Character';
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock,
                                    color: Theme.of(context).accentColor),
                              ),
                              obscureText: true,
                              onSaved: (input) => password = input),
                        ),
                        Container(
                          child: TextFormField(
                              // ignore: missing_return
                              validator: (input) {
                                bool validCardCode =
                                    RegExp(r'^[0-9]').hasMatch(input);
                                if (input.length != 16 || !validCardCode) {
                                  return '  Invalid code';
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              decoration: InputDecoration(
                                labelText: 'Credit card code',
                                prefixIcon: Icon(Icons.credit_card_rounded,
                                    color: Theme.of(context).accentColor),
                              ),
                              onSaved: (input) => carCode = input),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                  //ignore:missing_return
                                  validator: (input) {
                                    bool validCvc =
                                        RegExp(r'^[0-9]').hasMatch(input);
                                    if (input.length != 3 || !validCvc) {
                                      return '  Invalid code';
                                    }
                                  },
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                  decoration: InputDecoration(
                                    labelText: ' CVC/CVV',
                                    prefixIcon: Icon(Icons.lock,
                                        color: Theme.of(context).accentColor),
                                  ),
                                  obscureText: true,
                                  onSaved: (input) => cvc = input),
                              TextFormField(
                                  //ignore:missing_return
                                  validator: (input) {
                                    if (input.isNotEmpty && input.length == 5) {
                                      bool valid1 = input.contains('/');
                                      if (valid1) {
                                        bool valid2 =
                                            RegExp(r'^[0-9/]').hasMatch(input);
                                        bool notvalid = RegExp(r'^[A-Z a-z]')
                                            .hasMatch(input);
                                        if (valid2 && !notvalid) {
                                          String month = input.split('/')[0];
                                          bool valid3 =
                                              int.parse(month) <= 12 &&
                                                  int.parse(month) > 0;
                                          if (!valid3) return '\tInvalid month';
                                        } else {
                                          return 'it must contains only numbers and /';
                                        }
                                      } else {
                                        return '\tInsert a valid expiration date';
                                      }
                                    } else {
                                      return '\tInsert a valid expiration date';
                                    }
                                  },
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                  decoration: InputDecoration(
                                    labelText: '  Expiration date',
                                    prefixIcon: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Theme.of(context).accentColor),
                                  ),
                                  onSaved: (input) => expirationDate = input)
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        RichText(
                            text: TextSpan(
                                text:
                                    "An account verification email will be sent to your email ",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ))),
                        SizedBox(height: 10),
                        RaisedButton(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          onPressed: signUp,
                          child: Text('SignUp',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RichText(
                                text: TextSpan(
                                    text: "Alredy signed? ",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ))),
                            GestureDetector(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void pickDate() async {
    DateTime now = DateTime.now();
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
      initialDate: now,
    );
    if (date != null) {
      setState(() {
        birthDate = date;
      });
    }
  }
}
