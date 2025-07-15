import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/constants/app_colors.dart';

class AppTextStyle {
  static final TextStyle heading1 = GoogleFonts.raleway(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );

  // Added heading2 as used in HomeScreen for titles like "Attendance History"
  static final TextStyle heading2 = GoogleFonts.raleway(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );

  static final TextStyle body = GoogleFonts.raleway(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkBlue,
  );

  static final TextStyle link = GoogleFonts.raleway(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.teal,
    decoration: TextDecoration.underline,
  );

  static final TextStyle button = GoogleFonts.raleway(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle snackbarSuccess = GoogleFonts.raleway(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle snackbarError = GoogleFonts.raleway(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

class AppInputStyle {
  static InputDecoration textField(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.raleway(
        color: AppColors.darkBlue,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkBlue),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.teal, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }
}


class AppSnackBar {
  static SnackBar success(String message) {
    return SnackBar(
      content: Text(message, style: AppTextStyle.snackbarSuccess),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    );
  }

  static SnackBar error(String message) {
    return SnackBar(
      content: Text(message, style: AppTextStyle.snackbarError),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    );
  }
}