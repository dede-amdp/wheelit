import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:wheelit/classes/LocationProvider.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wheelit/classes/Transport.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    Map<String, dynamic> data = <String, dynamic>{};
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
          data.addAll({'paymentCard': element.data()});
        });
      });
    } catch (error) {
      print('ERROR: ${error.toString()}');
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
          .where('used', isEqualTo: false)
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
      print('ERROR ${error.toString()}');
      data = null;
    }
    return data;
  }

  static Future<void> setTicketData(Ticket ticket) async {
    await Firebase.initializeApp();
    try {
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
    } catch (error) {
      print(error.toString());
    }
  }

  static Future<Map> getTransportData({bool public = false}) async {
    await Firebase.initializeApp();
    Map data = {};
    try {
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
    } catch (error) {
      print(error.toString());
      return null;
    }
    return data;
  }

  static Future<Map> getNearestTransport(LatLng userPosition,
      {TransportType transportType}) async {
    Map data = {};
    int distance = 2000;
    await Firebase.initializeApp();
    try {
      CollectionReference eleCollection =
          FirebaseFirestore.instance.collection('electric');
      CollectionReference pubCollection =
          FirebaseFirestore.instance.collection('stations');
      if (userPosition != null) {
        await eleCollection
            .where('state', isEqualTo: "FREE")
            .get()
            .then((value) {
          if (value != null) {
            value.docs.forEach((electric) {
              if (Geolocator.distanceBetween(
                          userPosition.latitude,
                          userPosition.longitude,
                          electric.data()['position'].latitude,
                          electric.data()['position'].longitude)
                      .abs() <=
                  distance) {
                data.addAll({electric.id: electric.data()});
              }
            });
          }
        });
      }
      await pubCollection.get().then((stations) {
        if (stations != null) {
          stations.docs.forEach((station) {
            data.addAll({station.id: station.data()});
          });
        }
      });
    } catch (error) {
      print(error.toString());
      return null;
    }
    if (transportType != null) {
      Map filtered = {};
      switch (transportType) {
        case TransportType.BIKE:
          data.entries.forEach((e) {
            if (e.value['type'] == 'BIKE') filtered.addAll({e.key: e.value});
          });
          break;
        case TransportType.SCOOTER:
          data.entries.forEach((e) {
            if (e.value['type'] == 'SCOOTER') filtered.addAll({e.key: e.value});
          });
          break;
        case TransportType.BUS_STATION:
        case TransportType.TRAIN_STATION:
          data.entries.forEach((e) {
            if (e.value['type'] == 'STATION') filtered.addAll({e.key: e.value});
          });
          break;
        default:
          filtered = data;
        //CASO ALL
      }
      data = filtered;
    }
    return data;
  }

  static Future<void> getRealTimeTransportData(
      {@required Function onChange,
      @required Map toChange,
      LatLng userLoc}) async {
    LatLng userLocation = userLoc;
    final Permission _permissionHandler = Permission.location;
    var result = await _permissionHandler.request();
    if (result.isGranted) {
      toChange = await getNearestTransport(userLocation);
      await Firebase.initializeApp();
      //Setto i listener:
      CollectionReference eleCollection =
          FirebaseFirestore.instance.collection('electric');
      try {
        eleCollection.snapshots().listen((changes) async {
          userLocation = await LocationProvider.getCurrentLocation();
          changes.docChanges.forEach((changedDoc) {
            double distance = userLocation != null
                ? Geolocator.distanceBetween(
                        changedDoc.doc.data()['position'].latitude,
                        changedDoc.doc.data()['position'].longitude,
                        userLocation.latitude,
                        userLocation.longitude)
                    .abs()
                : double.infinity;
            if (distance <= 2000) {
              if (changedDoc.doc.data()['state'] != 'FREE') {
                toChange.remove(changedDoc.doc.id);
              } else {
                toChange.update(
                    changedDoc.doc.id, (value) => changedDoc.doc.data(),
                    ifAbsent: () => changedDoc.doc.data());
              }
            } else {
              toChange.remove(changedDoc.doc.id);
            }
            onChange(toChange);
          });
        });
      } catch (error) {
        print(error.toString());
      }
    }
  }

  static Future<void> setStartRent(
      {@required String userEmail, @required String transportCode}) async {
    await Firebase.initializeApp();
    CollectionReference rentCollection =
        FirebaseFirestore.instance.collection('rented');
    CollectionReference eleCollection =
        FirebaseFirestore.instance.collection('electric');
    try {
      rentCollection.add({
        'electric': transportCode,
        'user': userEmail,
        'startRent': DateTime.now(),
      });
      eleCollection.doc(transportCode).update({'state': 'RENTED'});
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<Map> getTransportInfo(String transportCode) async {
    await Firebase.initializeApp();
    CollectionReference eleCollection =
        FirebaseFirestore.instance.collection('electric');
    try {
      return await eleCollection
          .doc(transportCode)
          .get()
          .then((value) => {value.id: value.data()});
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
    return null;
  }

  static Future<Map> getLineInfo(String line) async {
    await Firebase.initializeApp();
    CollectionReference publicCollection =
        FirebaseFirestore.instance.collection('public');
    try {
      return await publicCollection
          .doc(line)
          .get()
          .then((value) => {value.id: value.data()});
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
    return null;
  }

  static Future<Map> getLinestoStation(String stationName) async {
    Map data = {};
    await Firebase.initializeApp();
    try {
      CollectionReference routesCollection =
          FirebaseFirestore.instance.collection('routes');
      await routesCollection
          .where('station', isEqualTo: stationName)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          data.addAll({element.id: element.data()});
        });
      });
    } catch (error) {
      print("ERROR: ${error.toString()}");
      data = null;
    }
    return data;
  }

  static Future<void> setUser(
      String email, DateTime birthDate, String userName) async {
    await Firebase.initializeApp();
    final firestoreInstance = FirebaseFirestore.instance;
    try {
      firestoreInstance.collection("users").doc(email).set({
        "userName": userName,
        "birthDate": birthDate,
      }, SetOptions(merge: true));
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> setGoogleUser(String email, String userName) async {
    await Firebase.initializeApp();
    final firestoreInstance = FirebaseFirestore.instance;
    try {
      firestoreInstance.collection("users").doc(email).set({
        "userName": userName,
      }, SetOptions(merge: true));
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> setPaymentCard(
      String email, String cvc, String carCode, String expirationDate) async {
    await Firebase.initializeApp();
    final firestoreInstance = FirebaseFirestore.instance;
    try {
      firestoreInstance.collection("paymentCards").add(
        {
          "owner": email,
          "cvc": cvc,
          "cardcode": carCode,
          "expireDate": expirationDate,
        },
      );
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> updateTickets(String email) async {
    await Firebase.initializeApp();
    CollectionReference ticketsCollection =
        FirebaseFirestore.instance.collection('tickets');
    try {
      await ticketsCollection
          .where('user', isEqualTo: email)
          .where('type', isEqualTo: "PASS")
          .where('endDate', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((document) {
          ticketsCollection.doc(document.id).update({'used': true});
        });
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> updatePassword(String password) async {
    await Firebase.initializeApp();
    User user = FirebaseAuth.instance.currentUser;
    try {
      user
          .updatePassword(password)
          .then((value) => Text("Successful changed password"));
    } catch (error) {
      print("ERROR: ${error.toString()}");
    }
  }

  static Future<void> updateCardCode(
      String cardCode, String cvc, String expireDate) async {
    await Firebase.initializeApp();
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference cardCodeCollection =
        FirebaseFirestore.instance.collection('paymentCards');
    try {
      await cardCodeCollection
          .where('owner', isEqualTo: user.email)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((document) {
          cardCodeCollection.doc(document.id).update({'cardCode': cardCode});
          cardCodeCollection.doc(document.id).update({'cvc': cvc});
          cardCodeCollection
              .doc(document.id)
              .update({'expireDate': expireDate});
        });
      });
    } catch (error) {
      print("ERROR: ${error.toString()}");
    }
  }

  static Future<void> getRented(String userEmail,
      {Function onChanged, Map toChange}) async {
    toChange = {};
    await Firebase.initializeApp();
    CollectionReference rentedCollection =
        FirebaseFirestore.instance.collection('rented');
    try {
      rentedCollection
          .where('user', isEqualTo: userEmail)
          .snapshots()
          .listen((event) {
        if (event != null) {
          event.docChanges.forEach((document) {
            if (document.doc.data()['endRent'] == null) {
              toChange.addAll({document.doc.id: document.doc.data()});
            } else {
              toChange.remove(document.doc.id);
            }
            onChanged(toChange);
          });
        }
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> getRealTimeRecentTicket(String userEmail,
      {Function onChanged, Ticket toChange}) async {
    await Firebase.initializeApp();
    CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');
    try {
      ticketCollection
          .where('user', isEqualTo: userEmail)
          .orderBy('buyTimeStamp', descending: true)
          .snapshots()
          .listen((docChanges) {
        if (docChanges != null) {
          Map lastTicketMap = {
            docChanges.docChanges[0].doc.id: docChanges.docChanges[0].doc.data()
          };
          if (lastTicketMap != null) {
            if (lastTicketMap.isNotEmpty) {
              toChange = Ticket.parseString(lastTicketMap.toString());
              onChanged(toChange);
            }
          }
        }
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<bool> isRented(String code) async {
    await Firebase.initializeApp();
    CollectionReference rentRef =
        FirebaseFirestore.instance.collection('rented');
    try {
      await rentRef.where('electric', isEqualTo: code).get().then((docs) {
        if (docs == null) {
          return false;
        } else {
          docs.docs.forEach((document) {
            if (document.data()['endRent'] == null) return true;
          });
          return false;
        }
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
      return false;
    }
    return false;
  }

  static Future<bool> isSameUser(String email, String code) async {
    await Firebase.initializeApp();
    CollectionReference rentRef =
        FirebaseFirestore.instance.collection('rented');
    try {
      await rentRef.where('electric', isEqualTo: code).get().then((docs) {
        docs.docs.forEach((document) {
          if (document.data()['endRent'] == null) {
            return document.data()['user'] == email;
          }
        });
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
      return false;
    }
    return false;
  }

  static Future<void> setEndRent(String userEmail, String code) async {
    await Firebase.initializeApp();
    CollectionReference rentRef =
        FirebaseFirestore.instance.collection('rented');
    try {
      await rentRef
          .where('user', isEqualTo: userEmail)
          .where('electric', isEqualTo: code)
          .orderBy('startRent', descending: true)
          .get()
          .then((document) {
        if (document != null) {
          rentRef.doc(document.docs[0].id).update({'endRent': DateTime.now()});
        }
      });
    } catch (error) {
      print('ERROR ${error.toString()}');
    }
  }

  static Future<void> updateName(String userName) async {
    await Firebase.initializeApp();
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
    try {
      await userCollection.doc(user.email).get().then((snapshot) {
        userCollection.doc(user.email).update({'userName': userName});
      });
    } catch (error) {
      print("ERROR: ${error.toString()}");
    }
  }
}
