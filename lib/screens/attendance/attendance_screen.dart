import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart'; // Import AppTextStyle
import 'package:workline_app/models/today_attendance_model.dart'; // Import today attendance model

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Position? _currentPosition; // Renamed to _currentPosition for clarity
  bool _isLoadingLocation = true; // Separate loading state for location
  bool _isProcessingAttendance = false; // Loading state for check-in/out
  String _message = ""; // Message for user feedback
  String _currentAddress = "Mencari lokasi..."; // Initial message for address

  TodayAttendanceData? _todayAttendanceData; // Holds today's attendance data

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Load location and today's attendance
  }

  Future<void> _loadInitialData() async {
    await _getCurrentLocation();
    await _fetchTodayAttendance();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return; // Check mounted before any async operation

    setState(() {
      _isLoadingLocation = true;
      _currentAddress = "Mendapatkan lokasi Anda...";
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) {
            setState(() {
              _message = "Izin lokasi ditolak.";
              _currentAddress = "Izin lokasi tidak diberikan.";
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10) // Add a timeout for better UX
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      await _getAddressFromLatLng(position); // Get address after position is obtained
    } catch (e) {
      debugPrint("Error fetching location: $e"); // Use debugPrint
      if (mounted) {
        setState(() {
          _message = "Gagal mendapatkan lokasi: ${e.toString()}";
          _currentAddress = "Gagal mendapatkan alamat.";
          _isLoadingLocation = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: "id_ID" // Request Indonesian locale for address
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, " // Street name & number
              "${place.subLocality ?? ''}, ${place.locality ?? ''}, " // Sub-district, City
              "${place.administrativeArea ?? ''}, ${place.country ?? ''}"; // Province, Country

          // Clean up multiple commas if some parts are null
          _currentAddress = _currentAddress.replaceAll(RegExp(r',(\s*,)+'), ',').trim();
          _currentAddress = _currentAddress.replaceAll(RegExp(r'^\s*,+'), '').trim();
          _currentAddress = _currentAddress.replaceAll(RegExp(r',+\s*$'), '').trim();
        });
      } else if (mounted) {
        setState(() {
          _currentAddress = "Alamat tidak ditemukan untuk koordinat ini.";
        });
      }
    } catch (e) {
      debugPrint("Error getting address from coordinates: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Gagal mendapatkan alamat.";
        });
      }
    }
  }

  Future<void> _fetchTodayAttendance() async {
    if (!mounted) return;
    try {
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await AttendanceService.fetchTodayAttendance(todayDate);
      if (mounted) {
        setState(() {
          _todayAttendanceData = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching today's attendance: $e");
      if (mounted) {
        setState(() {
          _message = "Gagal memuat data kehadiran hari ini.";
        });
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) {
      if (mounted) {
        setState(() => _message = "Lokasi tidak tersedia.");
      }
      return;
    }
    if (_currentAddress.isEmpty || _currentAddress == "Mencari lokasi...") {
      if (mounted) {
        setState(() => _message = "Mohon tunggu, alamat belum ditemukan.");
      }
      return;
    }

    if (mounted) {
      setState(() => _isProcessingAttendance = true);
    }

    try {
      final result = await AttendanceService.checkIn(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _currentAddress, // Pass the actual address
      );
      if (mounted) {
        setState(() {
          _message = "Berhasil Check In pada ${result.data.checkInTime}";
          // Refresh today's attendance data to reflect the new check-in time
          _fetchTodayAttendance();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-in berhasil!")),
        );
      }
    } catch (e) {
      debugPrint("Error during check-in: $e");
      if (mounted) {
        setState(() => _message = "Gagal Check In: ${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-in gagal: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAttendance = false);
      }
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentPosition == null) {
      if (mounted) {
        setState(() => _message = "Lokasi tidak tersedia.");
      }
      return;
    }
    if (_currentAddress.isEmpty || _currentAddress == "Mencari lokasi...") {
      if (mounted) {
        setState(() => _message = "Mohon tunggu, alamat belum ditemukan.");
      }
      return;
    }

    if (mounted) {
      setState(() => _isProcessingAttendance = true);
    }

    try {
      final result = await AttendanceService.checkOut(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _currentAddress, // Pass the actual address
      );
      if (mounted) {
        setState(() {
          _message = "Berhasil Check Out pada ${result.data.checkOutTime}";
          // Refresh today's attendance data to reflect the new check-out time
          _fetchTodayAttendance();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-out berhasil!")),
        );
      }
    } catch (e) {
      debugPrint("Error during check-out: $e");
      if (mounted) {
        setState(() => _message = "Gagal Check Out: ${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-out gagal: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAttendance = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayName = DateFormat('EEEE', 'id_ID').format(today); // Day name in Indonesian
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(today); // Date in Indonesian

    final bool hasCheckedIn = _todayAttendanceData?.checkInTime != null && _todayAttendanceData!.checkInTime!.isNotEmpty;
    final bool hasCheckedOut = _todayAttendanceData?.checkOutTime != null && _todayAttendanceData!.checkOutTime!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkBlue), // Use app colors
          onPressed: () => Navigator.of(context).pop(),
                  ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dayName, style: AppTextStyle.heading2.copyWith(fontSize: 16, color: AppColors.darkBlue)),
            Text(formattedDate, style: AppTextStyle.body.copyWith(fontSize: 14, color: AppColors.blueGray)),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.softGreen, // Consistent with HomeScreen
        elevation: 0,
      ),
      backgroundColor: AppColors.softGreen,
      body: RefreshIndicator( // Added for pull-to-refresh
        onRefresh: _loadInitialData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Map Section ---
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.lightGrey,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoadingLocation || _currentPosition == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.teal),
                          const SizedBox(height: 10),
                          Text(
                            _isLoadingLocation ? "Mencari lokasi..." : "Lokasi tidak tersedia.",
                            style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
                          ),
                        ],
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 17,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("current_location"),
                          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          infoWindow: InfoWindow(title: "Lokasi Anda", snippet: _currentAddress),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false, // You might want to enable this
                      myLocationEnabled: true,
                    ),
            ),
            const SizedBox(height: 20),

            // --- Address and GPS Info Card ---
            _buildLocationInfoCard(),
            const SizedBox(height: 20),

            // --- Attendance Time & Status Card ---
            _buildAttendanceStatusCard(hasCheckedIn, hasCheckedOut),
            const SizedBox(height: 20),

            // --- Feedback Message ---
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _message,
                  style: AppTextStyle.body.copyWith(color: AppColors.darkBlue),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- Check In / Check Out Button ---
            ElevatedButton.icon(
              onPressed: _isProcessingAttendance || _isLoadingLocation || _currentPosition == null || _currentAddress.isEmpty || _currentAddress == "Mencari lokasi..."
                  ? null // Disable if loading location or processing attendance or no location
                  : hasCheckedOut // If already checked out, button is disabled
                      ? null
                      : hasCheckedIn
                          ? _handleCheckOut
                          : _handleCheckIn,
              icon: _isProcessingAttendance
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(hasCheckedIn ? Icons.logout : Icons.login),
              label: Text(
                _isProcessingAttendance
                    ? "Memproses..."
                    : hasCheckedOut
                        ? "Sudah Check Out"
                        : hasCheckedIn
                            ? "Check Out"
                            : "Check In",
                style: AppTextStyle.button.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasCheckedOut
                    ? AppColors.blueGray // Grey out if already checked out
                    : hasCheckedIn
                        ? AppColors.red // Red for Check Out
                        : AppColors.teal, // Teal for Check In
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets to build sections ---

  Widget _buildLocationInfoCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Alamat Lokasi Anda",
                  style: AppTextStyle.heading2.copyWith(color: AppColors.darkBlue, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentAddress,
              style: AppTextStyle.body.copyWith(fontSize: 14, color: AppColors.blueGray),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.blueGray),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: AppColors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Titik Koordinat GPS",
                  style: AppTextStyle.heading2.copyWith(color: AppColors.darkBlue, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Latitude: ${_currentPosition?.latitude.toStringAsFixed(6) ?? 'N/A'}",
              style: AppTextStyle.body.copyWith(fontSize: 14, color: AppColors.blueGray),
            ),
            Text(
              "Longitude: ${_currentPosition?.longitude.toStringAsFixed(6) ?? 'N/A'}",
              style: AppTextStyle.body.copyWith(fontSize: 14, color: AppColors.blueGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatusCard(bool hasCheckedIn, bool hasCheckedOut) {
    String statusText;
    Color statusColor;

    if (hasCheckedOut) {
      statusText = "Sudah Check Out";
      statusColor = AppColors.blueGray; // Grey or a neutral color
    } else if (hasCheckedIn) {
      statusText = "Sudah Check In";
      statusColor = AppColors.teal; // Green for checked in
    } else {
      statusText = "Belum Check In";
      statusColor = AppColors.orange; // Orange for pending check-in
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status Kehadiran Hari Ini",
              style: AppTextStyle.heading2.copyWith(color: AppColors.darkBlue, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Check In Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Check In", style: AppTextStyle.body.copyWith(color: AppColors.blueGray)),
                    const SizedBox(height: 4),
                    Text(
                      _todayAttendanceData?.checkInTime ?? '-',
                      style: AppTextStyle.heading1.copyWith(color: AppColors.teal, fontSize: 20),
                    ),
                  ],
                ),
                // Check Out Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Check Out", style: AppTextStyle.body.copyWith(color: AppColors.blueGray)),
                    const SizedBox(height: 4),
                    Text(
                      _todayAttendanceData?.checkOutTime ?? '-',
                      style: AppTextStyle.heading1.copyWith(color: AppColors.red, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyle.body.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}