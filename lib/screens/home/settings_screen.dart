import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/models/user_prefs_model.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:notify/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool receivePromotions;
  late bool receiveUpdates;
  late bool receiveReminders;
  late String frequency;
  final TextStyle style = const TextStyle(
    color: Colors.white,
  );
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final preferences = authProvider.userPreferences;

    if (preferences != null) {
      receivePromotions = preferences.receivePromotions;
      receiveUpdates = preferences.receiveUpdates;
      receiveReminders = preferences.receiveReminders;
      frequency = preferences.frequency;
    } else {
      receivePromotions = false;
      receiveUpdates = false;
      receiveReminders = false;
      frequency = 'daily';
    }
  }

  Future<void> _savePreferences() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return;
    }

    _isSaving.value = true;
    NotificationPreferences preferences = NotificationPreferences(
      receivePromotions: receivePromotions,
      receiveUpdates: receiveUpdates,
      receiveReminders: receiveReminders,
      frequency: frequency,
    );
    await FirebaseService().subscribeToTopics(preferences);

    await authProvider.updateUserPreferences(preferences);
    await authProvider.loadUserPreferences();

    _isSaving.value = false;
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isSaving,
        builder: (context, isSaving, child) {
          return isSaving
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Spacer(
                      flex: 5,
                    ),
                    Center(
                      child: PrimaryButton(
                        text: "Save Preferences",
                        onTap: _savePreferences,
                        bgColor: AppColors.primaryColor,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                );
        },
      ),
    );
  }
}
