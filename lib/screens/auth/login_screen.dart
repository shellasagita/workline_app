import 'package:flutter/material.dart';
import 'package:workline_app/api/user_api.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}\$',
    );
    return regex.hasMatch(password);
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Please fill in both email and password."),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackBar.error("Please enter a valid email address."));
      return;
    }

    // if (!_isStrongPassword(password)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     AppSnackBar.error("Password must be at least 8 characters long and include uppercase, lowercase, number, and symbol."),
    //   );
    //   return;
    // }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await UserApi.login(email, password);
    Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Login failed. Please check your credentials."),
      );
    }
  }

  // InputDecoration _inputDecoration(String label) {
  //   return InputDecoration(
  //     labelText: label,
  //     labelStyle: const TextStyle(color: AppColors.darkBlue),
  //     enabledBorder: const OutlineInputBorder(
  //       borderSide: BorderSide(color: AppColors.darkBlue),
  //     ),
  //     focusedBorder: const OutlineInputBorder(
  //       borderSide: BorderSide(color: AppColors.teal, width: 2),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Welcome Back",
                  style: AppTextStyle.heading1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to your account",
                  style: AppTextStyle.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 30),
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppInputStyle.textField('Email'),
                        cursorColor: AppColors.teal,
                        style: const TextStyle(color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: AppInputStyle.textField(
                          'Password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.darkBlue,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                        ),
                        cursorColor: AppColors.teal,
                        style: const TextStyle(color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value!);
                            },
                            checkColor: Colors.white, //warna centangnya
                            activeColor:
                                AppColors.teal, // warna kotak saat dicentang
                          ),
                          Text(
                            "Remember me",
                            style: AppTextStyle.body.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                AppColors.teal.withOpacity(0.1),
                              ), // warna saat diklik
                            ),
                            child: Text(
                              "Forgot Password",
                              style: AppTextStyle.button.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                          ),
                          child: Text("Login", style: AppTextStyle.button),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyle.body.copyWith(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cream,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          AppColors.cream.withOpacity(0.1),
                        ),
                      ),
                      child: Text("Sign Up", style: AppTextStyle.button),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
