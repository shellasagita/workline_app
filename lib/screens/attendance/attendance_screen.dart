import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Tambahkan ini
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workline_app/api/attendence_service.dart';
import 'package:workline_app/constants/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Position? _position;
  bool _isLoading = false;
  String? _message;
  bool hasCheckedIn = false;
  final String _status = "Belum Check In";
  String _currentAddress = ""; // Ubah jadi bukan final

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _message = "Location permission denied");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _position = pos;
    });

    _getAddressFromLatLng(pos); // Ambil alamat berdasarkan koordinat
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        _currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Gagal mendapatkan alamat";
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_position == null) {
      setState(() => _message = "Lokasi tidak tersedia");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AttendanceService.checkIn(
        lat: _position!.latitude,
        lng: _position!.longitude,
      );
      setState(() {
        _message = "Berhasil Check In pada ${result.data.checkInTime}";
        hasCheckedIn = true;
      });
    } catch (e) {
      setState(() => _message = "Gagal Check In: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    if (_position == null) {
      setState(() => _message = "Lokasi tidak tersedia");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AttendanceService.checkOut(
        lat: _position!.latitude,
        lng: _position!.longitude,
      );
      setState(() {
        _message = "Berhasil Check Out pada ${result.data.checkOutTime}";
        hasCheckedIn = false;
      });
    } catch (e) {
      setState(() => _message = "Gagal Check Out: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final day = _getWeekDay(today);

    return Scaffold(
      appBar: AppBar(
        title: Text('$day\n${today.day}-${today.month}-${today.year}'),
        centerTitle: true,
        backgroundColor: AppColors.success,
      ),
      backgroundColor: AppColors.softGreen,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _position != null
              ? SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_position!.latitude, _position!.longitude),
                    zoom: 17,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("current"),
                      position: LatLng(
                        _position!.latitude,
                        _position!.longitude,
                      ),
                    ),
                  },
                ),
              )
              : const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
          const SizedBox(height: 20),

          // Alamat lokasi (Geocoding)
          if (_currentAddress.isNotEmpty)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Alamat Lokasi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentAddress,
                      style: GoogleFonts.lexend(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: const [
                        Icon(Icons.gps_fixed, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Titik GPS",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Lat: ${_position?.latitude.toStringAsFixed(6)}\nLng: ${_position?.longitude.toStringAsFixed(6)}",
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text("Waktu Kehadiran", style: GoogleFonts.lexend()),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("Check In"),
                        Text("-", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Check Out"),
                        Text("-", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_message != null)
            Text(
              _message!,
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 24),

          // Satu tombol untuk Check In / Check Out
          ElevatedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : hasCheckedIn
                    ? _handleCheckOut
                    : _handleCheckIn,
            icon: Icon(hasCheckedIn ? Icons.logout : Icons.login),
            label: Text(hasCheckedIn ? "Check Out" : "Check In"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasCheckedIn ? Colors.redAccent : AppColors.success,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
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
