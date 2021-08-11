import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

// ignore: camel_case_types
String name = 'Log In';

class giveUser {
  giveUser({@required this.uid});
  final String uid;
}

abstract class AuthBase {
  Stream<giveUser> get onAuthStateChanged;
  Future<giveUser> currentUser();
  Future<giveUser> signInWithGoogle();
  Future<giveUser> signInAnonymously();
  Future<giveUser> SignInWithEmailandPassword(String email, String password);
  Future<giveUser> CreateUserWithEmailandPassword(
      String email, String password);
  Future<void> signOut();
}

class Auth implements AuthBase {
  giveUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return giveUser(uid: user.uid);
  }

  @override
  Stream<giveUser> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  final _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<giveUser> currentUser() async {

    final user = _firebaseAuth.currentUser;

    return _userFromFirebase(user);
  }

  @override
  Future<giveUser> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        name = googleAccount.displayName.toString();
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  @override
  Future<giveUser> SignInWithEmailandPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<giveUser> CreateUserWithEmailandPassword(
      String email, String password) async {



    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(authResult.user);
  }

  @override
  Future<giveUser> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }
}
