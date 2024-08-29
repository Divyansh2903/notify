import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/models/user_prefs_model.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/app_spacing.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:notify/providers/auth_provider.dart';

class UserPrefsStep extends StatefulWidget {
  const UserPrefsStep({super.key});

  @override
  _UserPrefsStepState createState() => _UserPrefsStepState();
}

class _UserPrefsStepState extends State<UserPrefsStep> {
  bool receivePromotions = false;
  bool receiveUpdates = false;
  bool receiveReminders = false;
  String frequency = 'daily';
  final TextStyle style = const TextStyle(
    color: Colors.white,
  );
  final FirebaseService _firebaseService = FirebaseService();
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  Future<void> _savePreferences(String userId) async {
    _isSaving.value = true;
    NotificationPreferences preferences = NotificationPreferences(
      receivePromotions: receivePromotions,
      receiveUpdates: receiveUpdates,
      receiveReminders: receiveReminders,
      frequency: frequency,
    );

    await _firebaseService.savePreferences(userId, preferences);

    await _firebaseService.subscribeToTopics(preferences);
    // ignore: use_build_context_synchronously
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setPreferencesCompleted();
    await authProvider.loadUserPreferences();

    _isSaving.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    return ValueListenableBuilder<bool>(
      valueListenable: _isSaving,
      builder: (context, isSaving, child) {
        return isSaving
            ? const Center(
                child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Customize your experience:",
                      style: style.copyWith(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  AppSpacing.height(30),
                  SwitchListTile(
                    activeColor: Colors.grey,
                    activeTrackColor: AppColors.primaryColor,
                    title: Text(
                      'Receive Promotions',
                      style: style,
                    ),
                    value: receivePromotions,
                    onChanged: (val) {
                      setState(() {
                        receivePromotions = val;
                      });
                    },
                  ),
                  SwitchListTile(
                    activeColor: Colors.grey,
                    activeTrackColor: AppColors.primaryColor,
                    title: Text(
                      'Receive Updates',
                      style: style,
                    ),
                    value: receiveUpdates,
                    onChanged: (val) {
                      setState(() {
                        receiveUpdates = val;
                      });
                    },
                  ),
                  SwitchListTile(
                    activeColor: Colors.grey,
                    activeTrackColor: AppColors.primaryColor,
                    title: Text(
                      'Receive Reminders',
                      style: style,
                    ),
                    value: receiveReminders,
                    onChanged: (val) {
                      setState(() {
                        receiveReminders = val;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frequency',
                          style: style,
                        ),
                        DropdownButton<String>(
                          value: frequency,
                          dropdownColor:
                              AppColors.secondaryColor.withOpacity(0.8),
                          onChanged: (String? newValue) {
                            setState(() {
                              frequency = newValue!;
                            });
                          },
                          items: <String>['daily', 'weekly', 'monthly']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: style.copyWith(
                                    color: AppColors.primaryColor),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.height(40),
                  Center(
                    child: PrimaryButton(
                      text: "Save Preferences",
                      onTap: () => _savePreferences(userId!),
                      bgColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              );
      },
    );
  }
}
