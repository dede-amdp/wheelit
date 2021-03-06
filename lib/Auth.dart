import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken);
  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  final User currentuser = _auth.currentUser;
  assert(currentuser.uid == user.uid);
  DatabaseManager.setGoogleUser(user.email, user.displayName);
  return user;
}
