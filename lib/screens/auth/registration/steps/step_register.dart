import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/app_spacing.dart';
import 'package:notify/utils/showSnackbar.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:notify/widgets/textfield.dart';

class RegistrationStep extends StatefulWidget {
  final VoidCallback onNext;

  const RegistrationStep({super.key, required this.onNext});

  @override
  State<RegistrationStep> createState() => _RegistrationStepState();
}

class _RegistrationStepState extends State<RegistrationStep> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> firebaseFCMToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? fcmToken = await messaging.getToken();
    FirebaseService().saveFCMToken(fcmToken ?? "");
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  Future<void> _registerUser() async {
    print("Registering user");
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      User? user = await _firebaseService.signUpWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        try {
          print("Storing user data");
          await _firebaseService.storeUserEmailAndName(
            user.uid,
            emailController.text,
            nameController.text,
          );
          firebaseFCMToken();
          widget.onNext();
        } catch (e) {
          // ignore: use_build_context_synchronously
          showSnackBar(context, "Error storing user data");
        }
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "Error signing up");
      }
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        return isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ))
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalTextField(
                      controller: nameController,
                      hintText: "Name",
                      validator: _validateName,
                    ),
                    AppSpacing.height(20),
                    GlobalTextField(
                      controller: emailController,
                      hintText: "Email",
                      validator: _validateEmail,
                    ),
                    AppSpacing.height(20),
                    GlobalTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    AppSpacing.height(40),
                    Center(
                      child: PrimaryButton(
                        text: "Next",
                        bgColor: AppColors.primaryColor,
                        onTap: _registerUser,
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
