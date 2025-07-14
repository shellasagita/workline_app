import 'package:flutter/material.dart';
import 'package:workline_app/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool hasCheckedIn = false;
  String checkInTime = "-";
  String checkOutTime = "-";

  void _checkIn() {
    final now = DateTime.now();
    setState(() {
      hasCheckedIn = true;
      checkInTime = "${now.hour}:${now.minute}:${now.second}";
    });
  }

  void _checkOut() {
    final now = DateTime.now();
    setState(() {
      checkOutTime = "${now.hour}:${now.minute}:${now.second}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBlue,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            hasCheckedIn ? "You've Checked In Today" : "Welcome to Workline",
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 24),
          if (!hasCheckedIn)
            ElevatedButton.icon(
              onPressed: _checkIn,
              icon: const Icon(Icons.login),
              label: const Text("Check In"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          if (hasCheckedIn) ...[
            Text(
              "Check-In Time: $checkInTime",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _checkOut,
              icon: const Icon(Icons.logout),
              label: const Text("Check Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Check-Out Time: $checkOutTime",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}
