import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class DrawerScreen extends StatefulWidget {
  Map mezzi;
  DrawerScreen({this.mezzi});

  @override
  _DrawerScreenState createState() => _DrawerScreenState(this.mezzi);
}

class _DrawerScreenState extends State<DrawerScreen> {
  List<Widget> options = [Center(child: CircularProgressIndicator())];
  String userEmail = 'pippolippo@gmail.com';
  Map mezzi;

  _DrawerScreenState(Map mezzi) {
    this.mezzi = mezzi;
  }

  @override
  void initState() {
    super.initState();
    getOptions(context);
  }

  @override
  Widget build(BuildContext context) {
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

  Future<void> getOptions(BuildContext context) async {
    LatLng userLocation;
    List<Widget> opts = [];
    Location l = Location();
    await l.onLocationChanged().first.then(
        (value) => userLocation = LatLng(value.latitude, value.longitude));
    //SIMULAZIONE DI FETCHING DEI 3 MEZZI PIù VICINI & ULTIMO BLIGLIETTO
    Map mezziMap = await DatabaseManager.getTransportData();
    print("DEBUG: $mezziMap");
    //lista di mezzi ELETTRICI
    //Prendi i dati e mettili in ordine di distanza e carica
    mezziMap = sortByDistance(mezziMap, userLocation);
    mezziMap = removeTooFar(mezziMap, userLocation);
    //prendi i primi 3
    for (int i = 0; i < 3 && i < mezziMap.entries.length; i++) {
      Map value = mezziMap;
      Transport mezzo = Transport.parseString(
          value.entries.toList()[i].key, value.entries.toList()[i].value);
      opts.add(Card(
          child: ListTile(
              //NON CANCELLARE: IMPLEMENTAZIONE DELLA SNACKBAR IN CASO DI TELE-AFFITTO
              onTap: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.white,
                    duration: Duration(minutes: 5),
                    action: SnackBarAction(label: "Rent", onPressed: () {}),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Do you want to rent?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 24.0)),
                          Text(
                            "Type: \t ${mezzo.type == TransportType.BIKE ? 'Bike' : 'Scooter'}",
                            style:
                                TextStyle(color: Colors.black, fontSize: 24.0),
                          ),
                          Text("Price:\t${mezzo.price}/min",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 24.0)),
                        ])));
                Navigator.pop(context);
              },
              //FINE ZONA DA NON CANCELLARE
              isThreeLine: true,
              title: Text('${mezzo.code}'),
              subtitle: Text(
                  '${mezzo.transportTypetoString()}\ndistance:\t${((getDistance(LatLng(value.entries.toList()[i].value['position'].latitude, value.entries.toList()[i].value['position'].longitude), LatLng(userLocation.latitude, userLocation.longitude)))).ceil() / 1000} km'),
              leading: mezzo.type == TransportType.BIKE
                  ? Icon(Icons.electric_bike, color: Colors.black)
                  : Icon(Icons.electric_scooter, color: Colors.black))));
    }
    //inserisci biglietto e abbonamento più recente
    await DatabaseManager.getTicketData(userEmail).then((value) {
      Ticket recent = Ticket.parseString(value['0'].toString());

      opts.add(Card(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.tealAccent[700], Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)),
          child: ListTile(
              isThreeLine: true,
              title: Text(
                  "Recentrly made: ${recent.type == TicketType.NORMAL ? '' : 'Pass'} Ticket"),
              leading: Icon(Icons.description, color: Colors.white),
              subtitle: Text(
                  recent.buyDate +
                      "\tat\t" +
                      recent.buyTime +
                      "\tfor:\n ${recent.mezzi.toString()}",
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pushNamed(context, '/ticket');
              }),
        ),
      ));
      setState(() {
        this.options = opts;
      });
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
