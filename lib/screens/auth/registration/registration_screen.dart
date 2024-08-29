import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/screens/auth/login_screen.dart';
import 'package:notify/screens/auth/registration/steps/step_register.dart';
import 'package:notify/screens/auth/registration/steps/step_user_prefs.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/app_spacing.dart';
import 'package:notify/utils/navigation.dart';

class RegistrationScreen extends StatefulWidget {
  final int step;
  const RegistrationScreen({super.key, this.step = 0});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late int _currentStep;

  @override
  void initState() {
    _currentStep = widget.step;
    super.initState();
  }

  void _nextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.height(10),
              const Text(
                "N O T I F Y",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const Spacer(),
              _currentStep == 0
                  ? RegistrationStep(onNext: _nextStep)
                  : UserPrefsStep(),
              const Spacer(),
              _currentStep == 1
                  ? Container()
                  : Center(
                      child: RichText(
                          text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                navigate(context, const LoginScreen());
                              },
                          ),
                        ],
                      )),
                    ),
              AppSpacing.height(20),
            ],
          ),
        ),
      ),
    );
  }
}
