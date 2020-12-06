import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wheelit/classes/Ticket.dart';

class DatabaseManager {
  static Future<Map<String, Map>> getUsersList() async {
    Map<String, Map> users = {};
    await Firebase.initializeApp();
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    try {
      await usersCollection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          users.addAll({element.id: element.data()});
        });
      });
    } catch (error) {
      print(error.toString());
      users = null;
    }
    return users;
  }

  static Future<Map> getUserData(String userEmail) async {
    await Firebase.initializeApp();
    Map data = {};
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    CollectionReference paymentCardsCollection =
        FirebaseFirestore.instance.collection('paymentCards');
    try {
      await usersCollection.doc(userEmail).get().then((value) {
        if (value.exists) data = value.data();
      });
      await paymentCardsCollection
          .where('owner', isEqualTo: '$userEmail')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          data.addAll(element.data());
        });
      });
    } catch (error) {
      print(error.toString());
      data = null;
    }
    return data;
  }

  static Future<Map> getTicketData(String userEmail) async {
    await Firebase.initializeApp();
    Map data = {};

    try {
      int i = 0;
      CollectionReference ticketsCollection =
          FirebaseFirestore.instance.collection('tickets');
      await ticketsCollection
          .where('user', isEqualTo: userEmail)
          .orderBy('buyTimeStamp',
              descending: true) //SE NON FUNZIONA: TOGLIERE DESCENDING
          .get()
          .then((values) {
        if (values != null) {
          values.docs.forEach((ticket) {
            data.addAll({'${i++}': ticket.data()});
          });
        }
      });
    } catch (error) {
      print(error.toString());
      data = null;
    }
    return data;
  }

  static Future<void> setTicketData(Ticket ticket) async {
    await Firebase.initializeApp();
    CollectionReference ticketsCollection =
        FirebaseFirestore.instance.collection('tickets');
    Map ticketMap = ticket.toMap();
    if (ticket.type == TicketType.PASS) {
      ticketsCollection.add({
        'user': ticketMap['email'],
        'public': ticket.mezzi,
        'used': ticketMap['used'],
        'buyTimeStamp':
            DateTime.parse('${ticketMap['buyDate']} ${ticketMap['buyTime']}'),
        'type': "PASS",
        'startDate': DateTime.parse(ticketMap['startDate']),
        'endDate': DateTime.parse(ticketMap['endDate']),
      });
    } else {
      ticketsCollection.add({
        'user': ticketMap['email'],
        'public': ticket.mezzi,
        'used': ticketMap['used'],
        'buyTimeStamp':
            DateTime.parse('${ticketMap['buyDate']} ${ticketMap['buyTime']}'),
        'type': "NORMAL"
      });
    }
  }

  static Future<Map> getTransportData({bool public = false}) async {
    await Firebase.initializeApp();
    Map data = {};
    CollectionReference transportCollection =
        FirebaseFirestore.instance.collection(public ? 'public' : 'electric');
    if (public) {
      await transportCollection.get().then((value) {
        if (value != null) {
          value.docs.forEach((mezzo) {
            data.addAll({mezzo.id: mezzo.data()});
          });
        }
      });
    } else {
      await transportCollection
          .where('state', isEqualTo: "FREE")
          .get()
          .then((value) {
        if (value != null) {
          value.docs.forEach((mezzo) {
            data.addAll({mezzo.id: mezzo.data()});
          });
        }
      });
    }
    return data;
  }
}
