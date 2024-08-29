import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/widgets/notification_banner.dart';

class ForegroundMessageHandler extends StatefulWidget {
  final Widget child;

  const ForegroundMessageHandler({super.key, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _ForegroundMessageHandlerState createState() =>
      _ForegroundMessageHandlerState();
}

class _ForegroundMessageHandlerState extends State<ForegroundMessageHandler> {
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

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
