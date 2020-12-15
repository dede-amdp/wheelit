import 'package:flutter/material.dart';
import 'package:wheelit/activity/HomeScreen.dart';
import 'package:wheelit/activity/AccountScreen.dart';
import 'package:wheelit/activity/TicketScreen.dart';
import 'package:wheelit/activity/LogInScreen.dart';
import 'package:wheelit/activity/StationScreen.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(accentColor: Color.fromARGB(255, 14, 191, 181)),
      routes: {
        '/home': (context) => HomeScreen(),
        '/account': (context) => AccountScreen(),
        '/ticket': (context) => TicketScreen(),
        '/login': (context) => LogInScreen(),
        '/station': (context) => StationScreen(),
      },
      initialRoute: '/home',
    ));
