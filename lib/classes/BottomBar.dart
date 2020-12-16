import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

//ignore: must_be_immutable
class BottomBar extends StatelessWidget {
  List<Function> functions = [];
  BottomBar({@required this.functions});

  @override
  Widget build(BuildContext context) {
    List<Map> _buttons = [
      {
        'child': Text("ALL", style: TextStyle(color: Colors.white)),
        'f': this.functions[0]
      },
      {
        'child': Icon(Icons.electric_bike, color: Colors.white),
        'f': this.functions[1]
      },
      {
        'child': Icon(Icons.electric_scooter, color: Colors.white),
        'f': this.functions[2]
      },
      {
        'child': Row(children: [
          Icon(Icons.directions_bus, color: Colors.white),
          Icon(Icons.directions_train, color: Colors.white)
        ]),
        'f': this.functions[3]
      },
    ];
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
