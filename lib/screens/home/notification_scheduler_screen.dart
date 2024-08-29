import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ScheduleNotificationScreen extends StatefulWidget {
  const ScheduleNotificationScreen({super.key});

  @override
  _ScheduleNotificationScreenState createState() =>
      _ScheduleNotificationScreenState();
}

class _ScheduleNotificationScreenState
    extends State<ScheduleNotificationScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      DateTime scheduledTime,
      String title,
      String body) async {
    final tz.TZDateTime tzDateTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tzDateTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'Schedule Notification',
          style: TextStyle(color: AppColors.primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _selectTime,
                child: Text('Select Time: ${_selectedTime.format(context)}'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: PrimaryButton(
                  onTap: _scheduleNotification,
                  text: "Schedule Notification",
                  bgColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null && time != _selectedTime) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _scheduleNotification() async {
    final DateTime now = DateTime.now();
    final DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime.add(const Duration(days: 1));
    }

    const title = 'Notify';
    const body = 'This is your scheduled notification!!';

    await scheduleNotification(
      flutterLocalNotificationsPlugin,
      scheduledDateTime,
      title,
      body,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification Scheduled')),
    );
  }
}
