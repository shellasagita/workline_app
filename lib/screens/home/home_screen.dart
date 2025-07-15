import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Required for address from coordinates
import 'package:geolocator/geolocator.dart'; // Required for location
import 'package:intl/intl.dart';
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/api/profile_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/models/history_model.dart';
import 'package:workline_app/models/login_response.dart';
import 'package:workline_app/models/profile_model.dart';
import 'package:workline_app/models/statatistic_attendance_model.dart';
import 'package:workline_app/models/today_attendance_model.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/screens/home/detail_page.dart'; // Assuming DetailPage is your DetailScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HistoryData>> _futureHistory;
  late Future<TodayAttendanceResponse> _futureToday;
  late Future<StatisticAttendanceResponse> _futureStats;
  User? _currentUser;
  String _currentLocationAddress = 'Fetching location...';
  double? _currentLatitude; // Changed to double?
  double? _currentLongitude; // Changed to double?
  bool _isLoadingLocation = false;
  bool _isChecking = false;
  DateTime? _selectedDate;
  final TextEditingController _alasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _futureHistory = AttendanceService.fetchAttendanceHistory();
    _futureToday = AttendanceService.fetchTodayAttendance(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _futureStats = AttendanceService.fetchStats();
    _fetchCurrentLocation();
  }

  Future<void> _loadUserData() async {
    final user = await PreferencesHelper.getUser();
    if (mounted) {
      // Check if widget is still mounted before calling setState
      setState(() {
        _currentUser = user;
      });
    }
  }

  /// Location Fetching and Distance Calculation
  Future<void> _fetchCurrentLocation() async {
    if (!mounted) return; // Important: Check mounted status early

    setState(() {
      _isLoadingLocation = true;
      _currentLocationAddress = 'Getting your location...';
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentLocationAddress = 'Location permissions are denied.';
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentLocationAddress =
                'Location permissions are permanently denied.';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        // Check mounted before setState
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _currentLatitude = position.latitude; // Assign double directly
            _currentLongitude = position.longitude; // Assign double directly
            _currentLocationAddress =
                "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
            _isLoadingLocation = false;
          });
        } else {
          setState(() {
            _currentLocationAddress = 'Could not get address from coordinates.';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      // Avoid print in production, use a logging framework
      debugPrint(
        "Error fetching location: $e",
      ); // Use debugPrint for development
      if (mounted) {
        // Check mounted before setState
        setState(() {
          _currentLocationAddress = 'Error fetching location: $e';
          _isLoadingLocation = false;
        });
      }
    }
  }

  String _getDistanceToOffice() {
    // You would implement actual distance calculation here
    // using _currentLatitude, _currentLongitude and office coordinates.
    // For now, it's a placeholder.
    return '250.43m';
  }

  Future<void> _handleCheckIn() async {
    if (_isChecking) return;
    // Check if location data is available before attempting check-in
    if (_currentLatitude == null || _currentLongitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait, fetching location...')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isChecking = true;
      });
    }

    try {
      await AttendanceService.checkIn(
        // FIX: Use 'lat' and 'lng' named parameters
        lat: _currentLatitude!,
        lng: _currentLongitude!,
        address: _currentLocationAddress, // Optional, depending on your API
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in successful!')));
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _handleCheckOut() async {
    if (_isChecking) return;
    if (_currentLatitude == null || _currentLongitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait, fetching location...')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isChecking = true;
      });
    }

    try {
      await AttendanceService.checkOut(
        // FIX: Use 'lat' and 'lng' named parameters
        lat: _currentLatitude!,
        lng: _currentLongitude!,
        address: _currentLocationAddress, // Optional, depending on your API
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-out successful!')));
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-out failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return; // Check mounted status early

    setState(() {
      _futureHistory = AttendanceService.fetchAttendanceHistory();
      _futureToday = AttendanceService.fetchTodayAttendance(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      _futureStats = AttendanceService.fetchStats();
      _loadUserData();
      _fetchCurrentLocation(); // Re-fetch location on refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      // bottomNavigationBar: const BottomNavBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildLocationInfo(),
                const SizedBox(height: 20),
                _buildCheckInOutBox(),
                const SizedBox(height: 20),
                _buildStatisticBox(),
                const SizedBox(height: 20),
                _buildIzinForm(),
                // const SizedBox(height: 20),
                // _buildActionButtons(),
                // const SizedBox(height: 20),
                // _buildDistanceAndMap(),
                const SizedBox(height: 24),
                _buildHistoryHeader(),
                _buildAttendanceHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAjukanIzin() async {
    if (_selectedDate == null || _alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi tanggal dan alasan izin.')),
      );
      return;
    }

    try {
      await AttendanceService.ajukanIzin(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        alasan: _alasanController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Izin berhasil diajukan.')));

      // Reset form
      setState(() {
        _selectedDate = null;
        _alasanController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan izin: ${e.toString()}')),
      );
    }
  }

  Widget _buildIzinForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.greyShadow, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Form Izin Tidak Hadir",
            style: AppTextStyle.heading2.copyWith(
              fontSize: 16,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            icon: const Icon(Icons.date_range, color: AppColors.teal),
            label: Text(
              _selectedDate == null
                  ? "Pilih Tanggal"
                  : DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate!),
              style: AppTextStyle.body.copyWith(
                color: AppColors.blueGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _alasanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tuliskan alasan izin...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleAjukanIzin,
              icon: const Icon(Icons.send),
              label: const Text("Ajukan Izin"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticBox() {
    return FutureBuilder<StatisticAttendanceResponse>(
      future: _futureStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Gagal memuat statistik.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final data = snapshot.data!.data;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.greyShadow, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistik Absensi",
                style: AppTextStyle.heading2.copyWith(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Total Absen", data.totalAbsen.toString()),
                  _statItem("Masuk", data.totalMasuk.toString()),
                  _statItem("Izin", data.totalIzin.toString()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.today, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.sudahAbsenHariIni
                          ? "Anda sudah absen hari ini."
                          : "Anda belum absen hari ini.",
                      style: AppTextStyle.body.copyWith(
                        color:
                            data.sudahAbsenHariIni
                                ? AppColors.teal
                                : AppColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.heading2.copyWith(
            fontSize: 20,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
        ),
      ],
    );
  }

  /// Builds the greeting and user name section at the top of the screen.
  Widget _buildHeader() {
    String greeting;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning!';
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyle.heading1.copyWith(
            fontSize: 22,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        FutureBuilder<ProfileData>(
          future: ProfileService.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!.name ?? 'User',
                style: AppTextStyle.body.copyWith(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
              );
            } else {
              return SizedBox(
                height: 16,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  /// Builds the current location display row.
  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(
          _isLoadingLocation ? Icons.location_searching : Icons.location_on,
          color: _isLoadingLocation ? AppColors.blueGray : AppColors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _currentLocationAddress,
            style: AppTextStyle.body.copyWith(
              fontSize: 13,
              color: AppColors.blueGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the FutureBuilder for today's check-in/out box.
  Widget _buildCheckInOutBox() {
    return FutureBuilder<TodayAttendanceResponse>(
      future: _futureToday,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.greyShadow, blurRadius: 4),
              ],
            ),
            height: 100,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data == null) {
          return _renderCheckInOutBox('-', '-');
        }

        final data = snapshot.data!.data!;
        return _renderCheckInOutBox(
          data.checkInTime ?? '-',
          data.checkOutTime ?? '-',
        );
      },
    );
  }

  /// Renders the actual check-in/out box UI.
  Widget _renderCheckInOutBox(String checkIn, String checkOut) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.greyShadow, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _attendanceBox('Check In', checkIn),
          const VerticalDivider(
            color: AppColors.blueGray,
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          _attendanceBox('Check Out', checkOut),
        ],
      ),
    );
  }

  /// Helper widget for displaying single attendance time (e.g., Check In or Check Out).
  Widget _attendanceBox(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyle.body.copyWith(
            fontSize: 14,
            color: AppColors.blueGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: AppTextStyle.heading2.copyWith(
            fontSize: 18,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  /// NEW: Check In/Check Out Buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                _isChecking || _isLoadingLocation || _currentLatitude == null
                    ? null
                    : _handleCheckIn, // Disable if location not ready
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Check In',
                      style: AppTextStyle.button.copyWith(color: Colors.white),
                    ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed:
                _isChecking || _isLoadingLocation || _currentLatitude == null
                    ? null
                    : _handleCheckOut, // Disable if location not ready
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, // Or another appropriate color
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Check Out',
                      style: AppTextStyle.button.copyWith(color: Colors.white),
                    ),
          ),
        ),
      ],
    );
  }

  /// Builds the distance to office and map view section.
  Widget _buildDistanceAndMap() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.greyShadow, blurRadius: 4),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_walk, color: AppColors.orange),
                  const SizedBox(height: 8),
                  Text(
                    _getDistanceToOffice(),
                    style: AppTextStyle.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  Text(
                    'Distance from office',
                    style: AppTextStyle.body.copyWith(
                      fontSize: 12,
                      color: AppColors.blueGray,
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
              color: AppColors.lightGrey,
              boxShadow: [
                BoxShadow(color: AppColors.greyShadow, blurRadius: 4),
              ], // FIX: Corrected typo 'box boxShadow'
              image: const DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/200x100?text=Map+View',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Office Location',
                style: AppTextStyle.body.copyWith(
                  color: Colors.white.withAlpha((255 * 0.9).round()),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha((255 * 0.5).round()),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the header for the attendance history section.
  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance History',
          style: AppTextStyle.heading2.copyWith(
            fontSize: 16,
            color: AppColors.darkBlue,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailScreen(),
              ), // Navigating to DetailScreen
            );
          },
          child: Text(
            'See All',
            style: AppTextStyle.button.copyWith(color: AppColors.darkBlue),
          ),
        ),
      ],
    );
  }

  /// Builds the FutureBuilder for the list of attendance history.
  Widget _buildAttendanceHistory() {
    return FutureBuilder<List<HistoryData>>(
      future: _futureHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.teal),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading history: ${snapshot.error}",
              style: AppTextStyle.body.copyWith(color: AppColors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No attendance records found.",
              style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
            ),
          );
        }

        final list = snapshot.data!;

        // Limit to, say, 3 recent history items for HomeScreen preview
        final displayedList = list.take(3).toList();

        return ListView.separated(
          itemCount: displayedList.length, // Use displayedList count
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = displayedList[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                _getWeekDay(data.attendanceDate),
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(data.attendanceDate),
                style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Check In: ${data.checkInTime ?? '-'}',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Check Out: ${data.checkOutTime ?? '-'}',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getWeekDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
}
