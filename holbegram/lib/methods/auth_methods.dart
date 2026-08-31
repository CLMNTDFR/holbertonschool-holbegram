import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import '../models/user.dart';

// Auth helpers for login / signup. Talks to Firebase Auth + Firestore.
// http is here for Cloudinary uploads later.
class AuthMethode {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email + password. Returns "success" or an error string.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Please fill all the fields';
      }
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } catch (error) {
      return error.toString();
    }
  }

  // Creates the Auth user then stores a Users doc in Firestore.
  // file (profile pic) is optional for now.
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return 'Please fill all the fields';
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Map the form data onto our Users model (empty lists for now)
      Users users = Users(
        uid: user!.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: '',
        followers: [],
        following: [],
        posts: [],
        saved: [],
        searchKey: username[0].toLowerCase(),
      );

      // Save the profile under the Auth uid
      await _firestore.collection('users').doc(user.uid).set(users.toJson());
      return 'success';
    } catch (error) {
      return error.toString();
    }
  }
}
