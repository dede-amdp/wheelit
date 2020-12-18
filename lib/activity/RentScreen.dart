import 'package:flutter/material.dart';

class RentScreen extends StatefulWidget {
  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).accentColor, elevation: 0),
        backgroundColor: Theme.of(context).accentColor,
        body: Center(
          child: RaisedButton(
              elevation: 0,
              color: Colors.white,
              onPressed: () {},
              shape: CircleBorder(),
              child: Icon(Icons.power_settings_new,
                  color: Theme.of(context).accentColor, size: 150)),
        ));
  }
}
