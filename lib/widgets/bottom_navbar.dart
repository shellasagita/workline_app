import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/profile/profile_page.dart';
import 'package:workline_app/screens/attendance/attendance_screen.dart';
import 'package:workline_app/screens/home/home_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.softGreen,
      selectedItemColor: AppColors.cream,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
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
    );
  }
}
