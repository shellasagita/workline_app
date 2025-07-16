import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/screens/attendance/attendance_screen.dart';
import 'package:workline_app/screens/home/home_screen.dart';
import 'package:workline_app/screens/profile/profile_screen.dart';

/// MainScreen adalah widget utama yang mengelola navigasi BottomNavigationBar.
/// Ini berfungsi sebagai wadah untuk berbagai layar utama aplikasi.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const id = '/bottom-navbar'; // ID rute statis untuk navigasi

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Mengontrol indeks tab yang sedang aktif

  /// Membangun body/konten layar berdasarkan indeks tab yang dipilih.
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen(); // Menampilkan HomeScreen untuk tab pertama
      case 1:
        return const AttendanceScreen(); // Menampilkan AttendanceScreen untuk tab kedua
      case 2:
        return const ProfileScreen(); // Menampilkan ProfileScreen untuk tab ketiga
      default:
        return const Center(
            child: Text('Page not found')); // Pesan default jika indeks tidak valid
    }
  }

  /// Fungsi yang dipanggil ketika sebuah tab di BottomNavigationBar ditekan.
  void _onTabTapped(int index) {
    // Mencegah rebuild jika tab yang sama ditekan lagi
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index; // Memperbarui indeks tab yang aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(), // Konten layar yang berubah sesuai tab
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.softGreen, // Warna latar belakang BottomNav
        selectedItemColor: AppColors.red, // Warna ikon/label item yang dipilih
        unselectedItemColor: AppColors.paleYellow, // Warna ikon/label item yang tidak dipilih
        currentIndex: _currentIndex, // Indeks tab yang sedang aktif
        onTap: _onTabTapped, // Fungsi yang dipanggil saat tab ditekan
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home', // Label tab Home
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Attendance', // Label tab Attendance (sebelumnya 'Kehadiran')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile', // Label tab Profile
          ),
        ],
        selectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600), // Gaya teks label yang dipilih
        unselectedLabelStyle: GoogleFonts.lexend(), // Gaya teks label yang tidak dipilih
      ),
    );
  }
}