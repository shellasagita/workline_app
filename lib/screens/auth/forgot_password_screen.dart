import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';

import 'package:workline_app/api/user_api.dart';
import 'package:workline_app/routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Please enter your email."),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await UserApi.requestReset(email);
Navigator.pop(context);

if (!mounted) return;

if (success) {
  // Show success
  ScaffoldMessenger.of(context).showSnackBar(
    AppSnackBar.success("Reset link sent. You can now set a new password."),
  );

  // Navigate to reset password screen
  Navigator.pushNamed(context, AppRoutes.reset, arguments: email);

} else {
  ScaffoldMessenger.of(context).showSnackBar(
    AppSnackBar.error("Failed to send reset link."),
  );
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Forgot Password", style: AppTextStyle.heading1.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text("Enter your email to get reset link.",
                  style: AppTextStyle.body.copyWith(color: Colors.white70)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: AppInputStyle.textField('Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                        ),
                        child: const Text("Send Reset Link"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
