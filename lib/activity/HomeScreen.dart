import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/activity/DrawerScreen.dart';
import 'package:wheelit/classes/BottomBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  @override
  void initState() {
    getLocation();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mezzi == null || userLocation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      Set markers = Set<Marker>.from(mezzi.entries.map((e) {
        return Marker(
            markerId: MarkerId(e.key),
            position: LatLng(
                e.value['position'].latitude, e.value['position'].longitude));
      }));
      markers.add(Marker(
        markerId: MarkerId("user"),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      return Scaffold(
          drawer: Drawer(child: DrawerScreen(_gmc)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            SearchBar(),
                            FloatingActionButton(
                              child: Icon(Icons.location_searching,
                                  color: Colors.white),
                              onPressed: () {
                                _gmc.moveCamera(CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                        target: userLocation, zoom: 15)));
                              },
                            )
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

  Function filterPerType({TransportType transportType}) {
    return () async {
      setState(() {
        filterType = transportType;
        getData();
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
    Location l = Location();
    l.onLocationChanged().listen((loc) {
      setState(() {
        userLocation = LatLng(loc.latitude, loc.longitude);
      });
    });
  }
}

//custom widgets

class SearchBar extends StatefulWidget {
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
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search",
                  icon: Icon(Icons.search),
                  border: InputBorder.none),
            ),
          ),
          borderRadius: BorderRadius.circular(40.0)),
    );
  }
}
