import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text('Notification History',
            style: TextStyle(color: AppColors.primaryColor)),
        backgroundColor: AppColors.secondaryColor,
      ),
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: NotificationHistoryList(),
      ),
    );
  }
}

class NotificationHistoryList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notifications = snapshot.data?.docs ?? [];

        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications found.'));
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification =
                notifications[index].data() as Map<String, dynamic>;
            final title = notification['title'] ?? 'No Title';
            final body = notification['body'] ?? 'No Body';
            final timestamp =
                notification['timestamp']?.toDate() ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.primaryColor,
              child: ListTile(
                // contentPadding: const EdgeInsets.all(8),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(body),
                trailing: Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
