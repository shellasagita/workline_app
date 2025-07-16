// lib/widgets/copyright_footer.dart
import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart'; 
import 'package:workline_app/constants/app_style.dart';   

/// Widget footer yang menampilkan teks copyright.
/// Dirancang untuk digunakan di bagian paling bawah setiap halaman.
class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Menggunakan padding simetris untuk ruang di atas dan samping
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      // Warna background yang kontras agar teks copyright terlihat jelas
      // color: AppColors.darkBlue, // Menggunakan warna dari AppColors
      // Memastikan container mengisi lebar penuh
      width: double.infinity,
      // Mengatur teks agar berada di tengah
      alignment: Alignment.center,
      child: Text(
        "© 2025 Shella Sagita Theo Workline App. All Rights Reserved.",
        textAlign: TextAlign.center,
        style: AppTextStyle.body.copyWith( // Menggunakan gaya teks dari AppTextStyle
          fontSize: 10, // Ukuran font yang lebih kecil agar muat dan tidak dominan
          color: Colors.white, // Warna teks putih agar kontras dengan darkBlue
        ),
      ),
    );
  }
}