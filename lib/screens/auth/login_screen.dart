import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';
import 'package:notify/services/firebase_services.dart';
import 'package:notify/utils/app_spacing.dart';
import 'package:notify/utils/showSnackbar.dart';
import 'package:notify/widgets/primary_button.dart';
import 'package:notify/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> displayPassword = ValueNotifier(false);
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _isLoading.value = true;
      User? user = await _firebaseService.signInWithEmailPassword(
          emailController.text.trim(), passwordController.text.trim());

      if (user == null) {
        showSnackBar(
          // ignore: use_build_context_synchronously
          context,
          "Please enter correct email and password",
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Builder(builder: (context) {
          return ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, isloading, child) {
                return isloading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      GlobalTextField(
                                        controller: emailController,
                                        hintText: "Email",
                                        validator: _validateEmail,
                                      ),
                                      AppSpacing.height(20),
                                      ValueListenableBuilder<bool>(
                                          valueListenable: displayPassword,
                                          builder: (context, value, child) {
                                            return Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                GlobalTextField(
                                                  controller:
                                                      passwordController,
                                                  hintText: "Password",
                                                  obscureText: !value,
                                                  validator: _validatePassword,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    displayPassword.value =
                                                        !displayPassword.value;
                                                  },
                                                  icon: !value
                                                      ? const Icon(
                                                          Icons.visibility_off)
                                                      : const Icon(
                                                          Icons.visibility),
                                                ),
                                              ],
                                            );
                                          }),
                                      const Spacer(),
                                      Center(
                                          child: PrimaryButton(
                                        text: "Login",
                                        onTap: _login,
                                        bgColor: AppColors.primaryColor,
                                      )),
                                      AppSpacing.height(20),
                                      Center(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: "New here? ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              TextSpan(
                                                text: "Signup",
                                                style: const TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Navigator.pop(context);
                                                      },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AppSpacing.height(50),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              });
        }),
      ),
    );
  }
}
