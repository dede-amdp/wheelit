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

  @override
  void initState() {
    getData();
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mezzi == null || userLocation == null
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            drawer: Drawer(child: DrawerScreen()),
            body: Builder(
              builder: (context) {
                return Stack(
                  children: [
                    GoogleMap(
                      myLocationEnabled: true,
                      markers: Set.from(mezzi.entries.map((e) {
                        return e.value['state'] != "FREE"
                            ? null
                            : Marker(
                                markerId: MarkerId(e.key),
                                position: LatLng(e.value['position'].latitude,
                                    e.value['position'].longitude));
                      })),
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
                            ],
                          )),
                    ),
                    SafeArea(
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: BottomBar()))
                  ],
                );
              },
            ));
  }

  Future<void> getData() async {
    Map mezziMap = await DatabaseManager.getTransportData(public: false);
    setState(() {
      this.mezzi = mezziMap;
    });
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
