import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map userData;
  String userEmail;

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
    );
  }

  Future<void> getData() async {
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
