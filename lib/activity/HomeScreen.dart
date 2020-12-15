import 'dart:math';
import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/classes/BottomBar.dart';
import 'package:wheelit/activity/StationScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map mezzi;
  Ticket recent;
  String userEmail = 'pippolippo@gmail.com';
  LatLng userLocation;
  GoogleMapController _gmc;
  TransportType filterType;
  Ticket lastTicket;
  List toShowInDrawer;
  List searchResults;
  List<String> searchOptionList = [];
  String qr = "";
  String getQr = "";

  Future<void> scanQrCode() async {
    getQr = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff", "INDIETRO", true, ScanMode.QR);
    setState(() {
      floatingRent(getQr);
    });
  }

  @override
  void initState() {
    getLocation();
    getData();
    getTicketButton();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map toShow = {};
    if (mezzi == null || userLocation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      sortNearestforDrawer();
      if (filterType != null) {
        String typeString = filterType == TransportType.BIKE
            ? 'BIKE'
            : filterType == TransportType.SCOOTER
                ? 'SCOOTER'
                : filterType == TransportType.BUS_STATION ||
                        filterType == TransportType.TRAIN_STATION
                    ? 'STATION'
                    : '';
        this.mezzi.forEach((key, value) {
          if (value['type'] == typeString) {
            toShow.addAll({key: value});
          }
        });
      } else {
        toShow = this.mezzi;
      }
      Set markers = Set<Marker>.from(toShow.entries.map((e) {
        return Marker(
            onTap: () => {
                  if (e.value['type'] == 'STATION')
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StationScreen(name: e.value['name'])))
                    }
                },
            markerId: MarkerId(e.key),
            position: LatLng(
                e.value['position'].latitude, e.value['position'].longitude));
      }));
      markers.add(Marker(
        markerId: MarkerId("user"),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      List options = <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              image: DecorationImage(
                  image: AssetImage('assets/images/DrawerHeaderImage.jpg'))),
          child: FlatButton(
              child: Align(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userEmail,
                            overflow: TextOverflow.fade,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.logout, color: Colors.white))
                      ]),
                  alignment: Alignment.bottomLeft),
              onPressed: () {
                Navigator.pushNamed(context, '/account');
              }),
        ),
        Card(
            child: ListTile(
                leading: Icon(Icons.description, color: Colors.white),
                title: Text(
                    "Last Ticket bought on ${lastTicket.buyDate.split('-')[2]}/${lastTicket.buyDate.split('-')[1]}/${lastTicket.buyDate.split('-')[0]}",
                    style: TextStyle(color: Colors.white)),
                tileColor: Theme.of(context).accentColor,
                onTap: () => Navigator.pushNamed(context, '/ticket'))),
      ];
      if (this.toShowInDrawer != null) {
        this.toShowInDrawer.forEach((mezzo) {
          Map value = mezzo.value;
          //dynamic key = mezzo.key;
          options.add(Card(
              child: ListTile(
                  leading: Icon(value['type'] == 'BIKE'
                      ? Icons.electric_bike
                      : Icons.electric_scooter),
                  title: Row(children: <Widget>[
                    Icon(Icons.battery_full, color: Colors.green),
                    Text("${value['battery']}%\t"),
                    Text(
                        "distance: ${Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, value['position'].latitude, value['position'].longitude).ceil()}")
                  ]),
                  onTap: () {
                    _gmc.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(value['position'].latitude,
                                value['position'].longitude),
                            zoom: 18)));
                    Navigator.pop(context);
                    setState(() {
                      this.filterType = null;
                    });
                  })));
        });
      }
      return Scaffold(
          drawer: Drawer(child: ListView(children: options)),
          //endDrawer: Drawer(),
          body: Builder(
            builder: (context) {
              return Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (gmc) {
                      _gmc = gmc;
                    },
                    markers: markers,
                    initialCameraPosition:
                        CameraPosition(zoom: 15, target: userLocation),
                  ),
                  SafeArea(
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                                iconSize: 32.0,
                                icon: Icon(
                                  Icons.menu,
                                  color: Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                }),
                            SearchBar(onSearch: search, onSubmit: find),
                            SizedBox(
                              width: 55.0,
                              height: 55.0,
                              child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Icon(Icons.location_searching,
                                    color: Colors.white),
                                onPressed: () {
                                  _gmc.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: userLocation, zoom: 15)));
                                },
                              ),
                            ),
                            SizedBox(
                              width: 55.0,
                              height: 55.0,
                              child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Icon(Icons.qr_code_scanner_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  scanQrCode();
                                },
                              ),
                            ),
                          ],
                        )),
                  ),
                  SafeArea(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: BottomBar(functions: [
                            filterPerType(),
                            filterPerType(transportType: TransportType.BIKE),
                            filterPerType(transportType: TransportType.SCOOTER),
                            filterPerType(
                                transportType: TransportType.BUS_STATION),
                          ])))
                ],
              );
            },
          ));
    }
  }

  void floatingRent(String qr) async {
    if (qr != "" && qr != "-1") {
      Map m = (await DatabaseManager.getTransportInfo(qr))[qr];
      String toShow = qr.toString() +
          '\nType: ' +
          m['type'].toString() +
          "\nBattery:" +
          m['battery'].toString();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(toShow),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  child: Text("RENT"),
                  onPressed: () {
                    DatabaseManager.setStartRent(
                        userEmail: this.userEmail, transportCode: qr);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  Future<void> getTicketButton() async {
    Ticket recent = Ticket.parseString(
        (await DatabaseManager.getTicketData(userEmail))['0'].toString());
    setState(() {
      this.lastTicket = recent;
    });
  }

  Function filterPerType({TransportType transportType}) {
    return () async {
      setState(() {
        filterType = transportType;
      });
    };
  }

  Future<void> getData() async {
    Function updateMap = (Map toAdd) {
      setState(() {
        this.mezzi = toAdd;
      });
    };
    DatabaseManager.getRealTimeTransportData(
        onChange: updateMap, toChange: this.mezzi);
  }

  Future<void> getLocation() async {
    //await Permission.location.request();
    Location l = Location();
    l.onLocationChanged().listen((loc) {
      setState(() {
        userLocation = LatLng(loc.latitude, loc.longitude);
      });
    });
  }

  Future<void> sortNearestforDrawer() async {
    Map temp = {};
    this.mezzi.forEach((key, value) {
      if (value['type'] == 'BIKE' || value['type'] == 'SCOOTER')
        temp.addAll({key: value});
    });
    List sortedMezzi = temp.entries.toList();
    sortedMezzi.sort((a, b) => Geolocator.distanceBetween(
            a.value['position'].latitude,
            a.value['position'].longitude,
            this.userLocation.latitude,
            this.userLocation.longitude)
        .compareTo(Geolocator.distanceBetween(
            b.value['position'].latitude,
            b.value['position'].longitude,
            this.userLocation.latitude,
            this.userLocation.longitude)));
    setState(() {
      this.toShowInDrawer =
          sortedMezzi.getRange(0, min(sortedMezzi.length - 1, 2) + 1).toList();
    });
  }

  void search(String text) {
    List newSearch = [];
    List newSearchOptionsList = [];
    mezzi.forEach((key, value) {
      if (value['type'] == 'STATION') {
        if (value['name']
            .toString()
            .toLowerCase()
            .contains(text.toString().toLowerCase())) {
          newSearch.add(value);
          newSearchOptionsList.add(value['name']);
        }
      }
    });
    setState(() {
      this.searchResults = newSearch;
      this.searchOptionList = newSearchOptionsList;
    });
  }

  void find(String text) {
    if (searchResults != null) {
      setState(() {
        _gmc.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(this.searchResults[0]['position'].latitude,
                this.searchResults[0]['position'].longitude),
            zoom: 18)));
      });
    }
  }
}

//custom widgets

class SearchBar extends StatefulWidget {
  Function onSearch, onSubmit;

  SearchBar({this.onSearch, this.onSubmit});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: ClipRRect(
          child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: widget.onSearch,
                    onSubmitted: widget.onSubmit,
                    decoration: InputDecoration(
                        hintText: "Search",
                        icon: Icon(Icons.search),
                        border: InputBorder.none),
                  ),
                ],
              )),
          borderRadius: BorderRadius.circular(40.0)),
    );
  }
}
