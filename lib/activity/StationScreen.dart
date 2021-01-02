import 'package:flutter/material.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:wheelit/activity/TicketScreen.dart';

//ignore: must_be_immutable
class StationScreen extends StatefulWidget {
  String name;
  StationScreen({this.name});
  @override
  _StationScreenState createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen>
    with TickerProviderStateMixin {
  List<Widget> lines = [Center(child: CircularProgressIndicator())];
  Map routes;
  Map toShow;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User user = FirebaseAuth.instance.currentUser;
  Widget popUp;

  @override
  void initState() {
    getStationData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              subtitle: Text(toSchedule(value['days'], value['times'])),
              onTap: () {
                buyTicket(user.email, value['public']);
              })));
    });
    setState(() => this.lines = toUse);
  }

  String toSchedule(List days, List times) {
    String toReturn = '';
    if (days == null && times == null) return 'No data found';
    if (days.length != times.length) return 'No schedule found';
    for (int i = 0; i < days.length; i++) {
      toReturn += days[i] + "\ton " + times[i] + '\n';
    }
    return toReturn;
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

  void buyTicket(String email, String line) async {
    Map lineData = await DatabaseManager.getLineInfo(line);
    Map userData = await DatabaseManager.getUserData(user.email);
    buildSnackBar(userData, lineData);
  }

  void buildSnackBar(Map userData, Map lineData,
      {DateTime chosenDate, int initialIndex = 0}) async {
    TabController _controller = TabController(
        length: lineData.values.toList()[0]['prices'].length,
        vsync: this,
        initialIndex: initialIndex);
    SnackBar snb = SnackBar(
        onVisible: () => _scaffoldKey.currentState.showBodyScrim(true, 0.5),
        backgroundColor: Theme.of(context).accentColor,
        duration: Duration(days: 365),
        content: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: TabBar(
                          isScrollable: true,
                          controller: _controller,
                          tabs: createTabBar(
                              lineData.values.toList()[0]['prices']))),
                  Container(
                      height: 200,
                      child: TabBarView(
                        controller: _controller,
                        physics: BouncingScrollPhysics(),
                        children: await createTabs(
                            lineData.values.toList()[0]['prices'],
                            userData: userData,
                            lineData: lineData,
                            chosenDate: chosenDate,
                            initialIndex: initialIndex,
                            controller: _controller),
                      ))
                ]),
            color: Colors.transparent),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)));
    _scaffoldKey.currentState.showSnackBar(snb).closed.whenComplete(() {
      _scaffoldKey.currentState.showBodyScrim(false, 0.5);
    });
  }

  List<Tab> createTabBar(Map prices) {
    List<Tab> toReturn = [];
    prices.keys.forEach((key) {
      toReturn.add(Tab(
          child: Text(key.toString().toUpperCase(),
              style: TextStyle(fontSize: 18.0))));
    });
    return toReturn;
  }

  Future<List<Widget>> createTabs(Map ticketPrices,
      {Map userData,
      Map lineData,
      DateTime chosenDate,
      int initialIndex = 0,
      TabController controller}) async {
    Function showMessage = (String text) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
    };
    if (chosenDate == null) chosenDate = DateTime.now();
    List<Widget> tabs = [];
    ticketPrices.forEach((key, value) {
      tabs.add(Container(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text("PRICE: ${value.toString().toUpperCase()}€",
                style: TextStyle(fontSize: 24.0)),
            key.toString().toLowerCase() == 'singleuse'
                ? Text("Single use ticket", style: TextStyle(fontSize: 24.0))
                : FlatButton.icon(
                    label: Text(
                        'Chose a start Date\n${chosenDate.day.toString()}/${chosenDate.month.toString()}/${chosenDate.year.toString()}',
                        style: TextStyle(fontSize: 24.0)),
                    icon: Icon(Icons.calendar_today, size: 32.0),
                    onPressed: () => showDate(
                        userData: userData,
                        lineData: lineData,
                        initialIndex: controller.index)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  color: Colors.white,
                  onPressed: () async {
                    await user.reload();
                    this.user = FirebaseAuth.instance.currentUser;
                    if (user.emailVerified) {
                      if (userData['paymentCard'] == null ||
                          userData['birthDate'] == null) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  title: Text(
                                      'Add a payments card and your birth date to buy a ticket'),
                                  content: FlatButton.icon(
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/account'),
                                      icon: Icon(Icons.account_circle_rounded),
                                      label: Text('Go to Account Screen')));
                            });
                      } else {
                        DatabaseManager.setTicketData(Ticket(
                            used: false,
                            mezzi: {
                              lineData.keys.toList()[0]:
                                  lineData.values.toList()[0]['type']
                            },
                            email: user.email,
                            buyTime: TicketScreen.toLocalDateTime(
                                DateTime.now(),
                                local: true)[1],
                            buyDate: TicketScreen.toLocalDateTime(
                                DateTime.now(),
                                local: true)[0],
                            type: key.toString().toLowerCase() == 'singleuse'
                                ? TicketType.NORMAL
                                : TicketType.PASS,
                            startDate: key.toString().toLowerCase() !=
                                    'singleuse'
                                ? TicketScreen.toLocalDateTime(chosenDate)[0]
                                : '',
                            endDate: key.toString().toLowerCase() == 'weekly'
                                ? TicketScreen.toLocalDateTime(
                                    chosenDate.add(Duration(days: 7)))[0]
                                : key.toString().toLowerCase() == 'monthly'
                                    ? TicketScreen.toLocalDateTime(
                                        chosenDate.add(Duration(days: 29)))[0]
                                    : key.toString().toLowerCase() == 'biweekly'
                                        ? TicketScreen.toLocalDateTime(
                                            chosenDate
                                                .add(Duration(days: 15)))[0]
                                        : ''));
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Ticket bought successfully'),
                                        Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 100,
                                        )
                                      ]));
                            });
                      }
                    } else {
                      showMessage(
                          'A verification email was sent to the email ${user.email}');
                      user.sendEmailVerification();
                    }
                    _scaffoldKey.currentState.showBodyScrim(false, 0.5);
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                  child: Icon(Icons.check_rounded,
                      color: Theme.of(context).accentColor)),
              FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  color: Colors.white,
                  onPressed: () {
                    _scaffoldKey.currentState.showBodyScrim(false, 0.5);
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                  child: Icon(Icons.cancel_outlined, color: Colors.red))
            ])
          ])));
    });
    return tabs;
  }

  void showDate({Map userData, Map lineData, int initialIndex = 0}) async {
    DateTime chosenDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 100));
    if (chosenDate != null) {
      setState(() {
        _scaffoldKey.currentState.hideCurrentSnackBar();
        buildSnackBar(userData, lineData,
            chosenDate: chosenDate, initialIndex: initialIndex);
      });
    }
  }
}
