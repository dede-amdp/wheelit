import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData;
  String userEmail;
  User user = FirebaseAuth.instance.currentUser;
  DateTime birthDate = DateTime.now();
  String userName;
  String email;
  String password;
  String cardCode;
  String cvv;
  String expirationDate;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController cardCodeController = TextEditingController();
  TextEditingController expirationController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black)),
        body: Center(
          child: userData == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(
                          child: Text(user.displayName,
                              style: TextStyle(
                                  fontSize: 48.0,
                                  color: Theme.of(context).accentColor))),
                      Center(
                        child: Text(
                          user.email,
                          style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                      TextFormField(
                        //ignore:missing_return
                        validator: (input) {
                          if (input.length <= 0) {
                            return '\tThe user name must be at least 1 character long';
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'User name',
                            prefixIcon: Icon(Icons.account_box_rounded)),
                        controller: userNameController,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      TextFormField(
                        //ignore:missing_return
                        validator: (input) {
                          if (input.isNotEmpty && input.length < 6)
                            return 'Insert a password';
                        },
                        decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                        controller: passwordController,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      ListTile(
                        onTap: () async {
                          DateTime date = await showDatePicker(
                              context: context,
                              initialDate: birthDate == null
                                  ? DateTime.now()
                                  : birthDate,
                              firstDate: DateTime(DateTime.now().year - 100),
                              lastDate: DateTime(DateTime.now().year + 100));
                          setState(() {
                            if (date != null) {
                              this.birthDate = date;
                            }
                          });
                        },
                        leading: Icon(Icons.calendar_today),
                        title: Text('Birth date: ' +
                            birthDate.toString().split(' ')[0]),
                      ),
                      Divider(color: Colors.grey[850], height: 8),
                      TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          bool validCardCode =
                              RegExp(r'^[1-9]').hasMatch(input);
                          if (input.length != 16 || !validCardCode) {
                            return '  Invalid code';
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Card Code',
                            prefixIcon: Icon(Icons.credit_card_rounded)),
                        controller: cardCodeController,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      TextFormField(
                        //ignore:missing_return
                        validator: (input) {
                          bool validCvc = RegExp(r'^[1-9]').hasMatch(input);
                          if (input.length != 3 || !validCvc) {
                            return '  Invalid code';
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'CVC/CVV', prefixIcon: Icon(Icons.lock)),
                        controller: cvvController,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      TextFormField(
                        //ignore:missing_return
                        validator: (input) {
                          if (input.isNotEmpty || input.length == 5) {
                            bool valid1 = input.contains('/');
                            if (valid1) {
                              bool valid2 = RegExp(r'^[1-9/]').hasMatch(input);
                              if (valid2) {
                                String month = input.split('/')[0];
                                bool valid3 = int.parse(month) <= 12 &&
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
                        decoration: InputDecoration(
                            labelText: 'Expiration Date',
                            prefixIcon: Icon(Icons.calendar_today)),
                        controller: expirationController,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(50.0, 10, 50.0, 0),
                        child: RaisedButton(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          onPressed: () {
                            if (_formKey.currentState.validate()) update();
                          },
                          child: Text('Submit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(50.0, 10, 50.0, 0),
                        child: RaisedButton(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    title: Text(
                                        'Are you sure you want to delete your account?'),
                                    content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              'All your account data will be permanently deleted including tickets and payment informations'),
                                          RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              color: Colors.red,
                                              child: Icon(Icons.delete,
                                                  color: Colors.white),
                                              onPressed: () {
                                                DatabaseManager.deleteUserData(
                                                    userEmail);
                                                Navigator.pushReplacementNamed(
                                                    context, '/welcome');
                                              }),
                                        ]),
                                  );
                                });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                Text('Delete Account',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold))
                              ]),
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ));
  }

  Future<void> getData() async {
    User user = FirebaseAuth.instance.currentUser;
    setState(() {
      this.userEmail = user.email;
    });
    Map usableData = await DatabaseManager.getUserData(user.email);
    if (usableData != null) {
      DateTime data = usableData.containsKey('birthDate')
          ? usableData['birthDate'].toDate()
          : DateTime.now();
      setState(() {
        userData = usableData;
        this.birthDate = data;
        this.userNameController.text =
            (userData['userName'] != null ? userData['userName'] : '');
        if (userData['paymentCard'] != null) {
          this.cvvController.value = userData['paymentCard']['cvc'] != null
              ? userData['paymentCard']['cvc']
              : '';
          this.cardCodeController.text =
              userData['paymentCard']['cardCode'] != null
                  ? userData['paymentCard']['cardCode']
                  : '';
          this.expirationController.text =
              userData['paymentCard']['cardCode'] != null
                  ? userData['paymentCard']['expireDate']
                  : '';
        }
      });
    } else {
      print("NO DATA");
    }
  }

  void update() {
    userName = userNameController.text.toString();
    password = passwordController.text.toString();
    cvv = cvvController.text.toString();
    cardCode = cardCodeController.text.toString();
    expirationDate = expirationController.text.toString();
    DatabaseManager.updateName(userName);
    DatabaseManager.updateBirthDate(birthDate);
    if (password.isNotEmpty) {
      DatabaseManager.updatePassword(password);
    }
    DatabaseManager.updateCardCode(cardCode, cvv, expirationDate);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Update successful'),
                Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 100,
                )
              ]));
        });
  }
}
