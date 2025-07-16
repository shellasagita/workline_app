import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed, use AppTextStyle for consistency
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart'; // Import AppStyle for consistent typography
import 'package:workline_app/models/history_model.dart';
import 'package:intl/intl.dart';
import 'package:workline_app/widgets/%20copyright_footer.dart.dart'; // Required for advanced date formatting

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<HistoryData>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = AttendanceService.fetchAttendanceHistory();
  }

  // Function to refresh data on pull-to-refresh
  Future<void> _refreshHistory() async {
    setState(() {
      _futureHistory = AttendanceService.fetchAttendanceHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen, // Consistent background color
      appBar: AppBar(
        title: Text(
          'Attendance Details', // More descriptive title
          style: AppTextStyle.heading1.copyWith(
            color: AppColors.darkBlue, // Use app colors
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.softGreen, // Use app colors
        elevation: 0, // No shadow for a cleaner look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkBlue), // Use app colors
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator( // Allows pull-to-refresh
        onRefresh: _refreshHistory,
        child: Column(
          children: [
            FutureBuilder<List<HistoryData>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal)); // Use app colors
                }
            
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Failed to load attendance history: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.body.copyWith(color: AppColors.red), // Error text in red
                      ),
                    ),
                  );
                }
            
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No detailed attendance records found.",
                      style: AppTextStyle.body.copyWith(color: const Color.fromARGB(255, 5, 12, 14)),
                    ),
                  );
                }
            
                final historyList = snapshot.data!;
            
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16.0), // Padding for the entire list
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final data = historyList[index];
                    return _buildAttendanceCard(data); // Using the new detailed card widget
                  },
                );
              },
            ),
            const CopyrightFooter()
          ],
        ),
      ),
    );
  }

  // --- New Widget to Build a Detailed Attendance Card ---
  Widget _buildAttendanceCard(HistoryData data) {
    // Format date and time for display
    final String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(data.attendanceDate);
    final String checkInTime = data.checkInTime ?? 'N/A';
    final String checkOutTime = data.checkOutTime ?? 'N/A';
    final String checkInAddress = data.checkInAddress ?? 'No address recorded';
    final String checkOutAddress = data.checkOutAddress ?? 'No address recorded';
    final String status = data.status ?? 'Unknown';
    final String alasanIzin = data.alasanIzin ?? ''; // Empty if no reason

    Color statusColor = AppColors.blueGray; // Default
    String statusText = status;

    // Apply specific styles based on attendance status
    switch (status.toLowerCase()) {
      case 'hadir':
        statusColor = AppColors.teal;
        break;
      case 'izin':
        statusColor = AppColors.orange;
        statusText = 'Izin: $alasanIzin'; // Show reason for Izin
        break;
      case 'alpha':
        statusColor = AppColors.red;
        break;
      case 'terlambat':
        statusColor = AppColors.darkBlue;
        break;
      default:
        statusColor = AppColors.blueGray;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyle.heading2.copyWith(
                    fontSize: 16,
                    color: AppColors.darkBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15), // Light background for status
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyle.body.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check In Section
            _buildDetailRow(
              icon: Icons.login,
              label: 'Check In',
              time: checkInTime,
              address: checkInAddress,
              iconColor: AppColors.teal,
            ),
            const SizedBox(height: 12),

            // Check Out Section
            _buildDetailRow(
              icon: Icons.logout,
              label: 'Check Out',
              time: checkOutTime,
              address: checkOutAddress,
              iconColor: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a row for check-in/out details
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String time,
    required String address,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: AppTextStyle.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
                fontSize: 14,
              ),
            ),
            Text(
              time,
              style: AppTextStyle.body.copyWith(
                color: AppColors.darkBlue,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0), // Align with icon
          child: Text(
            address,
            style: AppTextStyle.body.copyWith(
              color: AppColors.blueGray,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}