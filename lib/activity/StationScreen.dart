import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class StationScreen extends StatefulWidget {
String name;
StationScreen({this.name});
@override
_StationScreenState createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
List<Widget> lines = [Center(child: CircularProgressIndicator())];
Map routes;
Map toShow;

@override
void initState() {
getStationData();
super.initState();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor: Theme.of(context).accentColor,
title: Text(widget.name)),
body: Column(children: [
Flexible(
child: Padding(
padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
child: Container(
height: 50,
child: TextField(
onChanged: search,
decoration: InputDecoration(
hintText: 'Search', icon: Icon(Icons.search)))),
)),
Flexible(
child: ListView(children: lines, physics: BouncingScrollPhysics()))
]),
);
}

void getStationData() async {
this.routes = await DatabaseManager.getLinestoStation(widget.name);
setState(() {
this.routes = routes;
this.toShow = routes;
toWidget(toShow);
});
}

void toWidget(Map map) {
List<Widget> toUse = [];
map.forEach((key, value) {
toUse.add(Card(
child: ListTile(
title: Text(value['public']),
subtitle: Text('${value['day']} on ${value['time']}'),
onTap: () {
print("AcquistaBiglietto");
})));
});
setState(() => this.lines = toUse);
}

void search(String text) {
this.toShow = {};
this.routes.forEach((key, value) {
if (value['public']
    .toString()
    .toLowerCase()
    .contains(text.toLowerCase())) {
toShow.addAll({key: value});
}
});
setState(() {
this.toShow = toShow;
toWidget(toShow);
});
}
}