import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/widgets/notification_banner.dart';

class ForegroundMessageHandler extends StatefulWidget {
  final Widget child;

  const ForegroundMessageHandler({Key? key, required this.child})
      : super(key: key);

  @override
  _ForegroundMessageHandlerState createState() =>
      _ForegroundMessageHandlerState();
}

class _ForegroundMessageHandlerState extends State<ForegroundMessageHandler> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FirebaseService().saveMessageToFirestore(message);
      _showTopBanner(message);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        FirebaseService().saveMessageToFirestore(message);
      }
    });
  }

  void _showTopBanner(RemoteMessage message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top + 60,
        left: 16,
        right: 16,
        child: NotificationBanner(
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? 'You have a new message.',
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
