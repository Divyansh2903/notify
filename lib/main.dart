import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/firebase_options.dart';
import 'package:notify/providers/auth_provider.dart';
import 'package:notify/screens/auth/registration/registration_screen.dart';
import 'package:notify/screens/home/home_screen.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/message_handler.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FirebaseService().saveMessageToFirestore(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.secondaryColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ForegroundMessageHandler(
            child: authProvider.isAuthenticated
                ? authProvider.isPreferencesCompleted
                    ? const HomeScreen()
                    : const RegistrationScreen(
                        step: 1,
                      )
                : const RegistrationScreen(),
          ),
          theme: ThemeData(fontFamily: 'Poppins'),
        );
      }),
    );
  }
}
