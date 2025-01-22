import 'package:flutter/material.dart';
import '../service/auth/auth_provider.dart';
import '../service/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AuthStateProvider extends ChangeNotifier {
  final AuthProvider _authProvider;

  AuthUser? _currentUser;
  bool _isLoading = true;

  AuthStateProvider(this._authProvider) {
    _initialize();
  }

  AuthUser? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await _authProvider.initialize();
    await reloadUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logIn(String email, String password) async {
    try {
      _currentUser =
          await _authProvider.logIn(email: email, password: password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(String email, String password) async {
    try {
      _currentUser =
          await _authProvider.createUser(email: email, password: password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    await _authProvider.sendEmailVerification();
  }

  Future<void> logOut() async {
    await _authProvider.logOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authProvider.sendPasswordReset(toEmail: email);
  }

  Future<void> reloadUser() async {
    try {
      final firebaseUser = firebase.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        await firebaseUser.reload();

        final updatedFirebaseUser = firebase.FirebaseAuth.instance.currentUser;

        if (updatedFirebaseUser != null) {
          _currentUser = AuthUser.fromFirebase(updatedFirebaseUser);
        } else {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    }
    notifyListeners();
  }

  bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;
}
