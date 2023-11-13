import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project/User.dart' as demo;
import 'package:firebase_auth/firebase_auth.dart';

class DataStorage {

  Future<void> createUserWithProfile(demo.User user) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final UserCredential userCredential;
    String password = user.roll_no.toString()+user.batch.toString();
    try {
      // Attempt to create the user in Firebase Authentication
      userCredential = await auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle different Firebase Auth errors here
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception('Failed to create user: ${e.message}');
      }
    } catch (e) {
      // Handle any other errors that might occur
      throw Exception('Failed to create user: $e');
    }

    // If the user creation was successful, proceed to create the Firestore document
    try {
      await FirebaseFirestore.instance.collection('events').add(
        user.toJson(),
      );
    } on FirebaseException catch (e) {
      // If Firestore write fails, delete the Firebase Authentication user
      await userCredential.user!.delete();
      throw Exception('Failed to create user profile in Firestore. The Firebase Authentication user has been deleted: ${e.message}');
    }
  }
}