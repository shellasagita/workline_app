import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/api/user_api.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;

  void _submitNewPassword() async {
    final password = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("All fields are required."),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Passwords do not match."),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await UserApi.resetPassword(
      email: widget.email,
      newPassword: password,
      confirmPassword: confirm,
    );

    Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.success("Password updated successfully."),
      );
      Navigator.pop(context); // back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Failed to reset password."),
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
              Text("New Password", style: AppTextStyle.heading1.copyWith(color: Colors.white)),
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
                      controller: _newPasswordController,
                      obscureText: _obscure,
                      decoration: AppInputStyle.textField("New Password"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscure,
                      decoration: AppInputStyle.textField("Confirm Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.darkBlue,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitNewPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                        ),
                        child: const Text("Create Password"),
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
