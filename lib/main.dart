import 'package:flutter/material.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/routes/app_routes.dart';
import 'package:workline_app/screens/auth/login_screen.dart';
import 'package:workline_app/screens/auth/register_screen.dart';
import 'package:workline_app/screens/home/home_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workline App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Optional override via settings
      initialRoute: AppRoutes.splash,
      // home: RegisterScreen(),
      routes: AppRoutes.routes,
    );
  }
}