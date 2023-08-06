// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../login/authentication.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    firebase_auth.FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        // Add from here
        // to here.
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(firebase_auth.FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods = await firebase_auth.FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }

      _email = email;
      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(firebase_auth.FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(firebase_auth.FirebaseAuthException e)
          errorCallback) async {
    try {
      var credential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    firebase_auth.FirebaseAuth.instance.signOut();
  }

  Future<void> pushData2Cloud(Map<String, dynamic> formData) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Tu dois etre connecté pour ca');
    }

    print("pushData2Cloud");
    print(formData);

    return cloud_firestore.FirebaseFirestore.instance
        .collection('formdata')
        .doc(formData["id"])
        .set(formData);
  }
}
