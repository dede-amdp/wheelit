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

  void checkAuthentication() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {

        await DatabaseManager.setPaymentCard(email, cvc, carCode, expirationDate);
        await DatabaseManager.setUser(email, birthDate, userName);

        User user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password)) as FirebaseUser;
        if (user != null) {
          await FirebaseAuth.instance.currentUser
              .updateProfile(displayName: user.displayName);
        }
        await Future.delayed(Duration(seconds: 3));
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
                          decoration: InputDecoration(
                              labelText: 'User name',
                              prefixIcon: Icon(Icons.account_box_rounded)),
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
                          decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email)),
                          onSaved: (input) => email = input),
                    ),
                    ListTile(
                      title: Text(
                          "Birth date: ${birthDate.day}/"
                          "${birthDate.month}/ ${birthDate.year}  ",
                          style: TextStyle(fontSize: 25.0, color: Colors.grey)),
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
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          onSaved: (input) => password = input),
                    ),
                    Container(
                      child: TextFormField(
                          // ignore: missing_return
                          validator: (input) {
                            if (input.length < 16 || input.length > 16) {
                              return '  Invalid code';
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Credit card code',
                            prefixIcon: Icon(Icons.credit_card_rounded),
                          ),
                          onSaved: (input) => carCode = input),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                              validator: (input) {
                                if (input.length < 3 || input.length > 3) {
                                  return '  Invalid code';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: ' CVC/CVV',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onSaved: (input) => cvc = input),
                          TextFormField(
                              validator: (input) {
                                if (input.length < 5 || input.length > 5) {
                                  return '  Invalid date';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: '  Expiration date',
                                prefixIcon: Icon(Icons.calendar_today_rounded),
                              ),
                              onSaved: (input) => expirationDate = input)
                        ],
                      ),
                    ),
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
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
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
