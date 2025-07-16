import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_images.dart'; // Pastikan ini ada dan berisi path ke logoGif
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/routes/app_routes.dart'; // Untuk navigasi ke login atau intro
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/widgets/%20copyright_footer.dart.dart'; // Untuk cek status login (jika diperlukan)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Durasi splash screen
    await Future.delayed(const Duration(seconds: 3)); // Durasi 3 detik

    if (!mounted) return; // Pastikan widget masih mounted sebelum navigasi

    // Contoh logika navigasi berdasarkan status login
    //  bisa mengaktifkan PreferenceHelper.init() di main.dart jika ingin menggunakan ini
    // bool isLogin = await PreferencesHelper.getLogin();
    // if (isLogin) {
    //   Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard); // Contoh rute ke dashboard utama
    // } else {
    //   Navigator.pushReplacementNamed(context, AppRoutes.intro); // Contoh rute ke intro screen
    // }

    // Jika tidak ada logika login/intro yang kompleks, langsung navigasi ke IntroScreen
    Navigator.pushReplacementNamed(context, AppRoutes.intro); // Navigasi ke IntroScreen (yang  sebut IntroScreenGetStarted)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue, // Warna latar belakang yang konsisten
      body: Center( // Menggunakan Center untuk menengahkan seluruh konten Column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal
          crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan konten secara horizontal
          children: [
            // Gambar Logo (AppImage.logoGif)
            Image.asset(
              AppImage.logoGif, // Pastikan path ini benar di app_images.dart
              width: 500, // Sesuaikan ukuran lebar gambar
              height: 500, // Sesuaikan ukuran tinggi gambar
              //  juga bisa menggunakan fit: BoxFit.contain atau BoxFit.cover
              // agar gambar menyesuaikan dengan ukuran yang diberikan
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30), // Jarak antara gambar dan teks
            Text(
              'WorkLine',
              style: AppTextStyle.heading1.copyWith(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold, // Tambahkan fontWeight jika belum ada di AppTextStyle
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
            // const SizedBox(height: 8), // Jarak antar subtitle
            // Text(
            //   'Managing Work from Anywhere',
            //   textAlign: TextAlign.center,
            //   style: AppTextStyle.body.copyWith(
            //     fontSize: 16,
            //     color: Colors.white70,
            //   ),
            // ),
            //  bisa menambahkan CircularProgressIndicator di sini jika ada proses loading
            // const SizedBox(height: 40),
            // const CircularProgressIndicator(color: Colors.white),
                    const CopyrightFooter()
                    ],
          
        ),
      ),
    );
  }
}