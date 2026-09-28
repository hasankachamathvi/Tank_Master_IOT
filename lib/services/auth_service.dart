import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  FirebaseAuth? _auth;
  bool _firebaseAvailable = false;

  final StreamController<AppUser?> _authController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  /// Lazily initialize Firebase Auth (safe if Firebase isn't ready)
  FirebaseAuth? _safeAuth() {
    if (_auth != null) return _auth;
    try {
      _auth = FirebaseAuth.instance;
      _firebaseAvailable = true;
      return _auth;
    } catch (e) {
      debugPrint('Firebase Auth not available: $e');
      _firebaseAvailable = false;
      return null;
    }
  }

  bool get isFirebaseAvailable => _firebaseAvailable;

  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  /// Register a new user with Firebase Authentication.
  Future<String?> register({required String name, required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Try Firebase first
    final auth = _safeAuth();
    if (auth != null) {
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        await userCredential.user?.updateDisplayName(name.trim());

        _currentUser = AppUser(name: name.trim(), email: normalizedEmail);
        _authController.add(_currentUser);
        return null;
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase register error: ${e.code} - ${e.message}');
        return _mapAuthError(e);
      } catch (e, stackTrace) {
        debugPrint('Register error: $e');
        debugPrintStack(stackTrace: stackTrace);
        return 'Registration failed. Please try again.';
      }
    }

    return 'Authentication is unavailable. Please check your connection.';
  }

  /// Log in an existing user with Firebase Authentication.
  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Try Firebase first
    final auth = _safeAuth();
    if (auth != null) {
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final user = userCredential.user;
        _currentUser = AppUser(
          name: user?.displayName ?? 'User',
          email: user?.email ?? normalizedEmail,
        );
        _authController.add(_currentUser);
        return null;
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase login error: ${e.code} - ${e.message}');
        return _mapAuthError(e);
      } catch (e, stackTrace) {
        debugPrint('Login error: $e');
        debugPrintStack(stackTrace: stackTrace);
        return 'Login failed. Please try again.';
      }
    }

    return 'Authentication is unavailable. Please check your connection.';
  }

  /// Log out the current user
  Future<void> logout() async {
    final auth = _safeAuth();
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (e) {
        debugPrint('Logout error: $e');
      }
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
