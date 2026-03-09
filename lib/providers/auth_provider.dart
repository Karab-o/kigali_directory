import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, emailUnverified, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  AuthStatus _status = AuthStatus.loading;
  String? _error;
  Map<String, dynamic>? _profile;

  AuthStatus get status => _status;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;
  User? get user => _service.currentUser;

  AuthProvider() {
    _service.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    try {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _profile = null;
      } else if (!user.emailVerified) {
        _status = AuthStatus.emailUnverified;
        _profile = null;
      } else {
        try {
          _profile = await _service.getUserProfile(user.uid);
        } catch (_) {
          // Fallback if Firestore read fails so user isn't stuck loading
          _profile = {
            'displayName': user.displayName ?? user.email?.split('@').first ?? 'User',
            'email': user.email ?? '',
          };
        }
        if (_profile == null || _profile!.isEmpty) {
          _profile = {
            'displayName': user.displayName ?? user.email?.split('@').first ?? 'User',
            'email': user.email ?? '',
          };
        }
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading();
    _error = await _service.signUp(email, password, name);
    if (_error != null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } else {
      // Success: sign out so user is led to Sign in screen, then they sign in to reach home
      await _service.logOut();
    }
  }

  Future<void> logIn(String email, String password) async {
    _setLoading();
    _error = await _service.logIn(email, password);
    if (_error != null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> logOut() => _service.logOut();

  /// Resend verification email. Returns error message or null on success.
  Future<String?> resendVerificationEmail() async => _service.sendVerificationEmail();

  Future<void> reloadUser() async {
    await _service.reloadUser();
    final u = _service.currentUser;
    if (u != null && u.emailVerified) {
      try {
        _profile = await _service.getUserProfile(u.uid);
      } catch (_) {
        _profile = {
          'displayName': u.displayName ?? u.email?.split('@').first ?? 'User',
          'email': u.email ?? '',
        };
      }
      if (_profile == null || _profile!.isEmpty) {
        _profile = {
          'displayName': u.displayName ?? u.email?.split('@').first ?? 'User',
          'email': u.email ?? '',
        };
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading() {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }
}
