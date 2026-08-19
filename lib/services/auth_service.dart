import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<AppUser?> _authController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  /// Register a new user with Firebase Authentication
  Future<String?> register({required String name, required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Store the display name
      await userCredential.user?.updateDisplayName(name.trim());

      _currentUser = AppUser(name: name.trim(), email: email.trim().toLowerCase());
      _authController.add(_currentUser);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase register error: ${e.code} - ${e.message}');
      return _mapAuthError(e);
    } catch (e) {
      debugPrint('Register error: $e');
      return 'Registration failed. Please try again.';
    }
  }

  /// Log in an existing user with Firebase Authentication
  Future<String?> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      _currentUser = AppUser(
        name: user?.displayName ?? 'User',
        email: user?.email ?? email.trim().toLowerCase(),
      );
      _authController.add(_currentUser);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.code} - ${e.message}');
      return _mapAuthError(e);
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Login failed. Please try again.';
    }
  }

  /// Log out the current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    _currentUser = null;
    _authController.add(null);
  }

  /// Map Firebase Auth exceptions to user-friendly messages
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}