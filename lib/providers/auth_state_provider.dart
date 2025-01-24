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
  bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;

  Future<void> _initialize() async {
    try {
      await _authProvider.initialize();
      await reloadUser();
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logIn(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authProvider.logIn(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createUser(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authProvider.createUser(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authProvider.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    _setLoading(true);
    try {
      await _authProvider.logOut();
      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authProvider.sendPasswordReset(toEmail: email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadUser() async {
    try {
      final firebaseUser = firebase.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        await firebaseUser.reload();
        final updatedFirebaseUser = firebase.FirebaseAuth.instance.currentUser;
        _currentUser = updatedFirebaseUser != null
            ? AuthUser.fromFirebase(updatedFirebaseUser)
            : null;
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      notifyListeners();
    }
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}