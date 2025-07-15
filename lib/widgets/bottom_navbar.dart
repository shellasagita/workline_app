import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/screens/attendance/attendance_screen.dart';
import 'package:workline_app/screens/home/home_screen.dart';
import 'package:workline_app/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const id = '/bottom-navbar';
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen(); // Ini akan rebuild setiap switch tab
      case 1:
        return const ProfileScreen();
      case 2:
        return const AttendanceScreen();
      default:
        return const Center(child: Text('Halaman tidak ditemukan'));
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(), // Render ulang berdasarkan index
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.softGreen,
        selectedItemColor: AppColors.cream,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Kehadiran',
          ),
        ],
        selectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.lexend(),
      ),
    );
  }
}
