import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/models/history_model.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Future<List<HistoryData>>? _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = AttendanceService.fetchAttendanceHistory();
    // _futureToday = AttendanceService.fetchTodayAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueGray,
      appBar: AppBar(
        title: Text('Detail History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: FutureBuilder<List<HistoryData>>(
          future: _futureHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Failed to load history");
            }

            final list = snapshot.data!;
            if (list.isEmpty) {
              return const Text("No attendance records yet.");
            }

            return ListView.separated(
              itemCount: list.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = list[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    _getWeekDay(data.attendanceDate),
                    style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${data.attendanceDate.day}-${data.attendanceDate.month}-${data.attendanceDate.year}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Check In: ${data.checkInTime ?? '-'}'),
                      Text('Check Out: ${data.checkOutTime ?? '-'}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getWeekDay(DateTime date) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[date.weekday % 7];
  }
}
