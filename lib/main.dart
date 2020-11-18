import 'package:flutter/material.dart';
import 'package:wheelit/activity/HomeScreen.dart';
import 'package:wheelit/activity/AccountScreen.dart';
import 'package:wheelit/activity/TicketScreen.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(accentColor: Colors.tealAccent[700]),
      routes: {
        '/home': (context) => HomeScreen(),
        '/account': (context) => AccountScreen(),
        '/ticket': (context) => TicketScreen(),
      },
      initialRoute: '/home',
    ));
