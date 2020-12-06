import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List<Map> _buttons = [
    {'child': Text("ALL", style: TextStyle(color: Colors.white)), 'f': () {}},
    {'child': Icon(Icons.electric_bike, color: Colors.white), 'f': () {}},
    {'child': Icon(Icons.electric_scooter, color: Colors.white), 'f': () {}},
    {'child': Icon(Icons.directions_bus, color: Colors.white), 'f': () {}},
    {'child': Icon(Icons.train, color: Colors.white), 'f': () {}},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: _buttons.map((button) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0, 5.0, 8.0),
              child: FlatButton(
                  onPressed: button['f'],
                  child: button['child'],
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
            );
          }).toList()),
    );
  }
}
