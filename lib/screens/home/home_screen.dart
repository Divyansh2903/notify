import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/providers/auth_provider.dart';
import 'package:notify/screens/home/notif_history.dart';
import 'package:notify/screens/home/notification_scheduler_screen.dart';
import 'package:notify/screens/home/settings_screen.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/app_spacing.dart';
import 'package:notify/utils/navigation.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> firebaseFCMToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? fcmToken = await messaging.getToken();
    FirebaseService().saveFCMToken(fcmToken ?? "");
  }

  Future<void> loadPrefs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserPreferences();
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
    firebaseFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Welcome ${authProvider.userName ?? 'User'}',
          style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: authProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : Consumer<AuthProvider>(builder: (context, auth, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppColors.surfaceColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                          children: [
                            const TextSpan(
                              text: "You're logged in as ",
                            ),
                            TextSpan(
                              text: "${auth.userEmail}",
                              style: const TextStyle(
                                  color: AppColors.primaryColor),
                            ),
                            const TextSpan(
                              text: " and you want to receive ",
                            ),
                            TextSpan(
                              text: auth.userPreferences?.frequency ?? 'daily',
                              style: const TextStyle(
                                  color: AppColors.primaryColor),
                            ),
                            const TextSpan(
                              text: " for the following:",
                            ),
                            if (auth.userPreferences?.receivePromotions ??
                                false)
                              const TextSpan(
                                text: " Promotions, ",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            if (auth.userPreferences?.receiveUpdates ?? false)
                              const TextSpan(
                                text: " Updates, ",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            if (auth.userPreferences?.receiveReminders ?? false)
                              const TextSpan(
                                text: " Reminders.",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                          ],
                        ),
                      ),
                      AppSpacing.height(40),
                      PrimaryButton(
                        text: 'Notification Preferences',
                        bgColor: AppColors.primaryColor,
                        onTap: () {
                          navigate(context, const SettingsScreen());
                        },
                      ),
                      AppSpacing.height(20),
                      PrimaryButton(
                        text: 'Schedule Notifications',
                        bgColor: AppColors.primaryColor,
                        onTap: () {
                          navigate(context, const ScheduleNotificationScreen());
                        },
                      ),
                      AppSpacing.height(20),
                      PrimaryButton(
                        text: 'Notifications History',
                        bgColor: AppColors.primaryColor,
                        onTap: () {
                          navigate(context, const NotificationHistoryScreen());
                        },
                      ),
                      AppSpacing.height(20),
                      PrimaryButton(
                        text: 'Sign Out',
                        bgColor: AppColors.primaryColor,
                        onTap: () async {
                          await FirebaseService().signOut();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
    );
  }
}
