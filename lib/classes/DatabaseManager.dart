import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseManager {
  Future getUsersList() async {
    List users = [];
    await Firebase.initializeApp();
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('/users');
    try {
      await usersCollection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          users.add(element.data());
        });
        return users;
      });
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
