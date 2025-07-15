import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 👈 call this
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Optional splash delay
    final isLoggedIn = await PreferencesHelper.isLoggedIn(); // ✅ await needed
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? AppRoutes.main : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Text(
          'Workline',
          style: AppTextStyle.heading1.copyWith(
            color: Colors.white,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
