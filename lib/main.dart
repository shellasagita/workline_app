import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workline_app/routes/app_routes.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
    'id',
    null,
  ); // Or simply initializeDateFormatting('id');

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
