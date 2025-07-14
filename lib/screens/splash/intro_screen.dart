import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/routes/app_routes.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'WorkLine',
              style: AppTextStyle.heading1.copyWith(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The Modern Way to Manage Work',
              textAlign: TextAlign.center,
              style: AppTextStyle.body.copyWith(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Managing Work from Anywhere',
              textAlign: TextAlign.center,
              style: AppTextStyle.body.copyWith(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Get Started'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
