import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class DrawerScreen extends StatefulWidget {
  GoogleMapController gmc;
  DrawerScreen(this.gmc);
  @override
  _DrawerScreenState createState() => _DrawerScreenState(this.gmc);
}

class _DrawerScreenState extends State<DrawerScreen> {
  //List<Widget> options = [Center(child: CircularProgressIndicator())];
  Ticket lastTicket;
  List<Transport> nearest = [];
  String userEmail = 'pippolippo@gmail.com';
  GoogleMapController gmc;
  LatLng userLocation;

  _DrawerScreenState(GoogleMapController gmc) {
    this.gmc = gmc;
  }

  @override
  void initState() {
    getTicketButton();
    getLocation();
    super.initState();
    //getOptions(context);
  }

  @override
  Widget build(BuildContext context) {
    List options = <Widget>[];
    if (nearest != null) {
      nearest.forEach((element) {
        LatLng target = LatLng(double.parse(element.position.split(',')[0]),
            double.parse(element.position.split(',')[1]));
        options.add(Card(
            child: ListTile(
                leading: Icon(element.type == TransportType.BIKE
                    ? Icons.electric_bike
                    : Icons.electric_scooter),
                title: Row(children: [
                  Icon(Icons.battery_full, color: Colors.green),
                  Text('${element.battery.toString()}%'),
                  Text(
                      '\t${getDistance(target, userLocation).floor()} m from you')
                ]),
                onTap: () {
                  gmc.moveCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: target, zoom: 17)));
                  Navigator.pop(context);
                })));
      });
    }
    if (lastTicket != null) {
      List datelist = this.lastTicket.buyDate.split("-");
      String data = "${datelist[2]}/${datelist[1]}/${datelist[0]}";
      options.add(Card(
          color: Theme.of(context).accentColor,
          child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/ticket');
              },
              leading: Icon(Icons.description, color: Colors.white),
              title: Text(
                  "Ticket bought on $data at ${this.lastTicket.buyTime.substring(0, 5)}",
                  style: TextStyle(color: Colors.white)))));
    }
    if (options.isEmpty) {
      options.add(Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 9,
            child: ListView(
              children: options,
            ),
          ),
          Flexible(
              flex: 1,
              child: SafeArea(
                child: FlatButton.icon(
                    minWidth: double.infinity,
                    onPressed: () {
                      Navigator.pushNamed(context, '/account');
                    },
                    label: Text(
                      "Account",
                      style: TextStyle(color: Colors.black),
                    ),
                    icon: Icon(Icons.account_circle, color: Colors.black)),
              )),
        ],
      ),
    );
  }

  Future<void> getTicketButton() async {
    Ticket recent = Ticket.parseString(
        (await DatabaseManager.getTicketData(userEmail))['0'].toString());
    setState(() {
      this.lastTicket = recent;
    });
  }

  Future<void> getLocation() async {
    Location().getLocation().then((value) async {
      setState(() {
        userLocation = LatLng(value.latitude, value.longitude);
        getNearest();
      });
    });
  }

  Future<void> getNearest() async {
    List<Transport> nearestM = [];
    Map mezzi = await DatabaseManager.getTransportData(public: false);
    mezzi = removeTooFar(mezzi, this.userLocation);
    mezzi = sortByDistance(mezzi, this.userLocation);
    List l = mezzi.entries.toList();
    for (int i = 0; i < 3 && i < l.length; i++) {
      nearestM.add(Transport.parseString(l[i].key, l[i].value));
    }
    setState(() {
      this.nearest = nearestM;
    });
  }

  double getDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
            from.latitude, from.longitude, to.latitude, to.longitude)
        .abs();
  }

  Map removeTooFar(Map toRemove, LatLng target) {
    Map toReturn = {};
    toRemove.forEach((key, value) {
      if (getDistance(
              LatLng(value['position'].latitude, value['position'].longitude),
              target) <=
          2000) {
        toReturn.addAll({key: value});
      }
    });
    return toReturn;
  }

  Map sortByDistance(Map toOrder, LatLng target) {
    List toOrderList = toOrder.entries.toList();
    toOrderList.sort((a, b) => (Geolocator.distanceBetween(
            a.value['position'].latitude,
            a.value['position'].longitude,
            target.latitude,
            target.longitude))
        .compareTo(Geolocator.distanceBetween(b.value['position'].latitude,
            b.value['position'].longitude, target.latitude, target.longitude)));
    Map ordered = {};
    toOrderList.forEach((element) {
      ordered.addAll({element.key: element.value});
    });
    return ordered;
  }
}
