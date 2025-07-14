import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/models/history_model.dart';
import 'package:workline_app/screens/home/detail_page.dart';
import 'package:workline_app/widgets/bottom_navbar.dart';
// import 'package:workline_app/models/today_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HistoryData>> _futureHistory;
  // late Future<TodayResponse> _futureToday;

  @override
  void initState() {
    super.initState();
    _futureHistory = AttendanceService.fetchAttendanceHistory();
    // _futureToday = AttendanceService.fetchTodayAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning!',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('Your Name', style: GoogleFonts.lexend(fontSize: 16)),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.location_pin, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Your current location address',
                      style: GoogleFonts.lexend(fontSize: 13),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // / CHECK IN / OUT BOX
              // FutureBuilder<TodayResponse>(
              //   future: _futureToday,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     if (!snapshot.hasData || snapshot.hasError) {
              //       return _checkInOutBox('-', '-');
              //     }

              //     final data = snapshot.data!.data;
              //     return _checkInOutBox(
              //       data?.checkInTime ?? '-',
              //       data?.checkOutTime ?? '-',
              //     );
              //   },
              // ),
              const SizedBox(height: 20),

              /// Distance + Map Image
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '250.43m',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Distance from place',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Kehadiran',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailPage()),
                      );
                    },
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.lexend(color: AppColors.darkBlue),
                    ),
                  ),
                ],
              ),

              /// Attendance History
              /// Attendance History
              FutureBuilder<List<HistoryData>>(
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
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkInOutBox(String checkIn, String checkOut) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _attendanceBox('Check In', checkIn),
          const VerticalDivider(color: Colors.grey),
          _attendanceBox('Check Out', checkOut),
        ],
      ),
    );
  }

  Widget _attendanceBox(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 14, color: AppColors.blueGray),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
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
