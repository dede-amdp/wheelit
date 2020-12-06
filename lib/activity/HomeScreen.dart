import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:wheelit/activity/DrawerScreen.dart';
import 'package:wheelit/classes/BottomBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map mezzi;
  Ticket recent;
  String userEmail = 'pippolippo@gmail.com';

  @override
  void initState() {
    getData(userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(child: DrawerScreen()),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      zoom: 15, target: LatLng(41.092724, 16.852686)),
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
                        alignment: Alignment.bottomCenter, child: BottomBar()))
              ],
            );
          },
        ));
  }

  Future<void> getData(String userEmail) async {
    Ticket lastTicket = (await DatabaseManager.getTicketData(userEmail))['0'];
    setState(() {
      this.recent = lastTicket;
      this.mezzi = {};
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
