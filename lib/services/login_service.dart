import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginService extends ChangeNotifier {
  // singleton
  factory LoginService() => _instance;

  LoginService.internal();
  static final LoginService _instance = LoginService.internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Future<String?> login(String email, String senha) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "Email inválido";
        case "wrong-password":
          return "Senha inválida";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> signIn(String email, String senha, String nome) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);

      await userCredential.user!.updateDisplayName(nome);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "Email já usado.";
        case "weak-password":
          return "Senha fraca.";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}

