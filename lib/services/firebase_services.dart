// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notify/models/user_prefs_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> saveMessageToFirestore(RemoteMessage message) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .add({
          'title': message.notification?.title ?? 'No Title',
          'body': message.notification?.body ?? 'No Body',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving message to Firestore: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveFCMToken(String token) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      }).catchError((e) {
        print('Error saving FCM token: $e');
      });
    }
  }

  Future<void> storeUserEmailAndName(
      String uid, String email, String name) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
      });
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  Future<void> savePreferences(
      String userId, NotificationPreferences preferences) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(preferences.toMap(), SetOptions(merge: true));
  }

  Future<void> subscribeToTopics(NotificationPreferences preferences) async {
    if (preferences.receivePromotions) {
      await _firebaseMessaging.subscribeToTopic('promotions');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('promotions');
    }

    if (preferences.receiveUpdates) {
      await _firebaseMessaging.subscribeToTopic('updates');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('updates');
    }

    if (preferences.receiveReminders) {
      await _firebaseMessaging.subscribeToTopic('reminders');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('reminders');
    }
  }

  Future<NotificationPreferences?> getPreferences(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists && doc.data() != null) {
      return NotificationPreferences.fromMap(
          doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
