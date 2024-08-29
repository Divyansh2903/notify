import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notify/models/user_prefs_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isPreferencesCompleted = false;
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  NotificationPreferences? _userPreferences;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user != null) {
        await _loadUserData();
        _isPreferencesCompleted = await _checkIfPreferencesCompleted();
        if (_isPreferencesCompleted) {
          _userPreferences = await loadUserPreferences();
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isPreferencesCompleted => _isPreferencesCompleted;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  NotificationPreferences? get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> _checkIfPreferencesCompleted() async {
    if (_user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      return doc.exists &&
          doc.data() != null &&
          (doc.data() as Map<String, dynamic>).containsKey('frequency');
    }
    return false;
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        _userName = data['name'] as String?;
        _userEmail = data['email'] as String?;
      }
    }
  }

  Future<NotificationPreferences?> loadUserPreferences() async {
    if (_user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return NotificationPreferences.fromMap(
            doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<void> updateUserPreferences(
      NotificationPreferences preferences) async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set(preferences.toMap(), SetOptions(merge: true));
        _userPreferences = preferences;
        _isPreferencesCompleted = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  void setPreferencesCompleted() {
    _isPreferencesCompleted = true;
    notifyListeners();
  }
}
