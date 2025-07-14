import 'package:flutter/material.dart';
import 'package:workline_app/screens/auth/forgot_password_screen.dart';
import 'package:workline_app/screens/auth/reset_password_screen.dart';
import 'package:workline_app/screens/splash/splash_screen.dart';
import 'package:workline_app/screens/splash/intro_screen.dart';
import 'package:workline_app/screens/auth/login_screen.dart';
import 'package:workline_app/screens/auth/register_screen.dart';
import 'package:workline_app/screens/home/home_screen.dart';
// import 'package:workline_app/screens/profile/profile_screen.dart';
// import 'package:workline_app/screens/profile/edit_profile_screen.dart';
// import 'package:workline_app/screens/history/history_screen.dart';
// import 'package:workline_app/screens/attendance/check_in_screen.dart';
// import 'package:workline_app/screens/attendance/check_out_screen.dart';
// import 'package:workline_app/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgot = '/forgot-password';
  static const String reset = '/reset-password';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String history = '/history';
  static const String checkIn = '/check-in';
  static const String checkOut = '/check-out';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    intro: (context) => const IntroScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    // home: (context) => const HomeScreen(),
    forgot: (context) => const ForgotPasswordScreen(),

    reset: (context) {
      final email = ModalRoute.of(context)?.settings.arguments as String;
      return NewPasswordScreen(email: email);
    },

    // home: (context) => const HomeScreen(),

    // profile: (context) => const ProfileScreen(),
    // editProfile: (context) => const EditProfileScreen(),
    // history: (context) => const HistoryScreen(),
    // checkIn: (context) => const CheckInScreen(),
    // checkOut: (context) => const CheckOutScreen(),
    // settings: (context) => const SettingsScreen(),
  };
}
