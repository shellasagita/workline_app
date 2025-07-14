import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/api/user_api.dart';
import 'package:workline_app/routes/app_routes.dart';
import 'package:geocoding/geocoding.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _username;
  String? _greeting;
  String _location = '';
  String? _checkInTime;
  String? _checkOutTime;
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setGreeting();
    _getCurrentLocation();
    _fetchTodayAttendance();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = "Good Morning!";
    } else if (hour < 17) {
      _greeting = "Good Afternoon!";
    } else {
      _greeting = "Good Evening!";
    }
  }

  Future<void> _loadUserData() async {
    final user = await PreferencesHelper.getUser();
    setState(() {
      _username = user?.name ?? "User";
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
  position.latitude,
  position.longitude,
);
      final place = placemarks.first;
      setState(() {
        _location =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
      });
    } catch (e) {
      setState(() {
        _location = "Unable to fetch location";
      });
    }
  }

  Future<void> _fetchTodayAttendance() async {
    final attendance = await UserApi.getTodayAttendance();
    setState(() {
      _checkInTime = attendance?.checkIn ?? "--:--";
      _checkOutTime = attendance?.checkOut ?? "--:--";
    });
  }

  Future<void> _checkInOrOut(String type) async {
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      final result = await UserApi.absen(
        type: type,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ? "$type success" : "$type failed")),
      );
      _fetchTodayAttendance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location error or permission denied.")),
      );
    }
    setState(() => _isLoading = false);
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.history);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_greeting ?? '', style: AppTextStyle.heading1),
              const SizedBox(height: 4),
              Text(_username ?? '', style: AppTextStyle.body),
              const SizedBox(height: 4),
              Text(now, style: AppTextStyle.body.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _location,
                            style: AppTextStyle.body,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("Check In"),
                            Text(_checkInTime ?? "--:--")
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Check Out"),
                            Text(_checkOutTime ?? "--:--")
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _checkInOrOut("check-in"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                          ),
                          child: const Text("Check In"),
                        ),
                        ElevatedButton(
                          onPressed: () => _checkInOrOut("check-out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                          ),
                          child: const Text("Check Out"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Recent Attendance", style: AppTextStyle.heading1),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text("Monday, 13-Jun-25"),
                subtitle: const Text("Check In: 07:50 | Check Out: 17:50"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.history),
                  child: const Text("View All"),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: AppColors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
