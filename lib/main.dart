import 'package:flutter/material.dart';
import 'package:wheelit/activity/ForgotPasswordScreen.dart';
import 'package:wheelit/activity/HomeScreen.dart';
import 'package:wheelit/activity/AccountScreen.dart';
import 'package:wheelit/activity/SignUpScreen.dart';
import 'package:wheelit/activity/TicketScreen.dart';
import 'package:wheelit/activity/LoginScreen.dart';
import 'package:wheelit/activity/WelcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wheelit/activity/StationScreen.dart';
import 'package:wheelit/activity/RentScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(accentColor: Color.fromARGB(255, 14, 191, 181)),
    routes: {
      '/home': (context) => HomeScreen(),
      '/account': (context) => AccountScreen(),
      '/ticket': (context) => TicketScreen(),
      '/welcome': (context) => WelcomeScreen(),
      '/login': (context) => LoginScreen(),
      '/station': (context) => StationScreen(),
      '/signUp': (context) => SignUpScreen(),
      '/reset': (context) => ForgotPasswordScreen(),
      '/rent': (context) => RentScreen(),
    },
    initialRoute: '/rent',
  ));
}
