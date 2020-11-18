import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/classes/Transport.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(child: DrawerScreen()),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                //GoogleMaps
                Placeholder(color: Colors.red),
                SafeArea(
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: Colors.tealAccent[700],
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

//---------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------
class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  List<Widget> options;

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
    List<Widget> opts = [];
    //SIMULAZIONE DI FETCHING DEI 3 MEZZI PIù VICINI & ULTIMO BLIGLIETTO
    List nearest = []; //lista di mezzi ELETTRICI
    for (int i = 0; i < 3; i++) {
      nearest.add(Transport(
          code: "A0000${i + 1}",
          type: TransportType.BIKE,
          battery: 52 + i * 10 + (i ~/ 2),
          price: .1));
    }
    Ticket lastTicket = Ticket(
        email: 'pippolippo@gmail.com',
        mezzi: ['AL2BARI'],
        buyDate: '16/11/2020',
        buyTime: '15:13:42',
        type: TicketType.NORMAL,
        used: false);
    //Prendi i dati e mettili in ordine di distanza e carica
    nearest.forEach((mezzo) {
      opts.add(Card(
          child: ListTile(
              //NON CANCELLARE: IMPLEMENTAZIONE DELLA SNACKBAR IN CASO DI TELE-AFFITTO
              /*onTap: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.white,
                    duration: Duration(minutes: 5),
                    action: SnackBarAction(label: "Rent",onPressed: (){

                    }),
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
                            "Type: \t ${mezzo.type.toString()}",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text("Price:\t${mezzo.price}/min",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 24.0)),
                        ])));
                Navigator.pop(context);
              },*/
              //FINE ZONA DA NON CANCELLARE
              isThreeLine: true,
              title: Text('${mezzo.code}'),
              subtitle:
                  Text('${mezzo.transportTypetoString()}\ndistance:\t0.5km'),
              leading: mezzo.type == TransportType.BIKE
                  ? Icon(Icons.electric_bike, color: Colors.black)
                  : Icon(Icons.electric_scooter, color: Colors.black))));
    });
    //inserisci biglietto e abbonamento più recente
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
                "Recentrly made: ${lastTicket.type == TicketType.NORMAL ? '' : 'Pass'} Ticket"),
            leading: Icon(Icons.description, color: Colors.white),
            subtitle: Text(
                lastTicket.buyDate +
                    "\tat\t" +
                    lastTicket.buyTime +
                    "\tfor:\n ${lastTicket.mezzi.toString()}",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pushNamed(context, '/ticket');
            }),
      ),
    ));
    setState(() {
      this.options = opts;
    });
  }
}
