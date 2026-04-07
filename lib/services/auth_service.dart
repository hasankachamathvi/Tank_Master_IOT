import 'dart:async';

import '../models/app_user.dart';

class AuthService {
  AuthService._internal() {
    _credentials['demo@tankmaster.com'] = 'demo1234';
    _names['demo@tankmaster.com'] = 'Demo User';
  }

  static final AuthService instance = AuthService._internal();

  final Map<String, String> _credentials = <String, String>{};
  final Map<String, String> _names = <String, String>{};

  final StreamController<AppUser?> _authController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  Future<String?> register({required String name, required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_credentials.containsKey(normalizedEmail)) {
      return 'Account already exists for this email';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    _credentials[normalizedEmail] = password;
    _names[normalizedEmail] = name.trim();

    _currentUser = AppUser(name: name.trim(), email: normalizedEmail);
    _authController.add(_currentUser);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = _credentials[normalizedEmail];

    if (storedPassword == null || storedPassword != password) {
      return 'Invalid email or password';
    }

    _currentUser = AppUser(
      name: _names[normalizedEmail] ?? 'User',
      email: normalizedEmail,
    );

    _authController.add(_currentUser);
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    _authController.add(null);
  }
}
