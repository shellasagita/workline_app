import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Dibutuhkan untuk mendapatkan alamat dari koordinat
import 'package:geolocator/geolocator.dart'; // Dibutuhkan untuk mendapatkan lokasi
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'package:workline_app/api/attendence_service.dart'; // Layanan untuk API Absensi
import 'package:workline_app/api/profile_service.dart'; // Layanan untuk API Profil
import 'package:workline_app/constants/app_colors.dart'; // Konstanta warna aplikasi
import 'package:workline_app/constants/app_style.dart'; // Konstanta gaya teks aplikasi
import 'package:workline_app/models/history_model.dart'; // Model data riwayat absensi
import 'package:workline_app/models/login_response.dart'; // Model data respons login (untuk user)
import 'package:workline_app/models/profile_model.dart'; // Model data profil pengguna
import 'package:workline_app/models/statatistic_attendance_model.dart'; // Model data statistik absensi
import 'package:workline_app/models/today_attendance_model.dart'; // Model data absensi hari ini
import 'package:workline_app/preferences/preferences_helper.dart'; // Helper untuk Shared Preferences
import 'package:workline_app/screens/home/detail_page.dart';
import 'package:workline_app/widgets/%20copyright_footer.dart.dart'; // Halaman Detail Riwayat Absensi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Variabel State ---
  late Future<List<HistoryData>> _futureHistory; // Future untuk riwayat absensi
  late Future<TodayAttendanceResponse> _futureToday; // Future untuk absensi hari ini
  late Future<StatisticAttendanceResponse> _futureStats; // Future untuk statistik absensi
  User? _currentUser; // Data pengguna yang sedang login
  String _currentLocationAddress =
      'Fetching location...'; // Alamat lokasi terkini pengguna
  double? _currentLatitude; // Latitude lokasi terkini
  double? _currentLongitude; // Longitude lokasi terkini
  bool _isLoadingLocation = false; // Status loading saat mengambil lokasi
  bool _isChecking = false; // Status saat proses check-in/out
  DateTime? _selectedDate; // Tanggal yang dipilih untuk form izin
  final TextEditingController _alasanController =
      TextEditingController(); // Controller untuk input alasan izin

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Memuat data pengguna saat inisialisasi
    _futureHistory = AttendanceService.fetchAttendanceHistory(); // Ambil riwayat absensi
    _futureToday = AttendanceService.fetchTodayAttendance(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    ); // Ambil absensi hari ini
    _futureStats = AttendanceService.fetchStats(); // Ambil statistik absensi
    _fetchCurrentLocation(); // Ambil lokasi terkini pengguna
  }

  // Memuat data pengguna dari PreferencesHelper
  Future<void> _loadUserData() async {
    final user = await PreferencesHelper.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  /// Mengambil lokasi terkini pengguna dan mengonversinya menjadi alamat.
  Future<void> _fetchCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true; // Set status loading lokasi
      _currentLocationAddress = 'Getting your location...';
    });
    try {
      // Cek dan minta izin lokasi
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

      // Ambil posisi GPS terkini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Konversi koordinat menjadi alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _currentLatitude = position.latitude;
            _currentLongitude = position.longitude;
            _currentLocationAddress =
                "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
            _isLoadingLocation = false; // Selesai loading
          });
        } else {
          setState(() {
            _currentLocationAddress = 'Could not get address from coordinates.';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      debugPrint(
          "Error fetching location: $e"); // Log error untuk debugging
      if (mounted) {
        setState(() {
          _currentLocationAddress = 'Error fetching location: $e';
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Placeholder untuk menghitung jarak ke kantor (perlu implementasi nyata)
  String _getDistanceToOffice() {
    return '250.43m';
  }

  /// Menangani proses Check-in.
  Future<void> _handleCheckIn() async {
    if (_isChecking) return; // Mencegah double klik
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
        _isChecking = true; // Set status sedang proses check-in/out
      });
    }

    try {
      await AttendanceService.checkIn(
        lat: _currentLatitude!, // Kirim latitude
        lng: _currentLongitude!, // Kirim longitude
        address: _currentLocationAddress, // Kirim alamat
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in successful!')));
      }
      _refreshData(); // Refresh data setelah berhasil
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackBar.error('Check-in failed: ${e.toString()}'))
        ;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false; // Selesai proses
        });
      }
    }
  }

  /// Menangani proses Check-out.
  Future<void> _handleCheckOut() async {
    if (_isChecking) return; // Mencegah double klik
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
        _isChecking = true; // Set status sedang proses check-in/out
      });
    }

    try {
      await AttendanceService.checkOut(
        lat: _currentLatitude!, // Kirim latitude
        lng: _currentLongitude!, // Kirim longitude
        address: _currentLocationAddress, // Kirim alamat
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-out successful!')));
      }
      _refreshData(); // Refresh data setelah berhasil
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackBar.error('Check-out failed: ${e.toString()}'))
        ;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false; // Selesai proses
        });
      }
    }
  }

  /// Memuat ulang semua data (riwayat, absensi hari ini, statistik, profil, lokasi).
  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      _futureHistory = AttendanceService.fetchAttendanceHistory();
      _futureToday = AttendanceService.fetchTodayAttendance(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      _futureStats = AttendanceService.fetchStats();
      _loadUserData();
      _fetchCurrentLocation(); // Ambil ulang lokasi saat refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      body: RefreshIndicator(
        onRefresh: _refreshData, // Fungsi untuk refresh data saat pull down
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(), // Bagian header (salam dan nama user)
                const SizedBox(height: 16),
                _buildLocationInfo(), // Informasi lokasi terkini
                const SizedBox(height: 20),
                _buildCheckInOutBox(), // Kotak informasi check-in/out hari ini
                const SizedBox(height: 20),
                _buildStatisticBox(), // Kotak statistik absensi
                const SizedBox(height: 20),
                _buildIzinForm(), // Form pengajuan izin
                // Bagian-bagian yang di-comment out (tombol aksi, jarak, peta)
                // const SizedBox(height: 20),
                // _buildActionButtons(),
                // const SizedBox(height: 20),
                // _buildDistanceAndMap(),
                const SizedBox(height: 24),
                _buildHistoryHeader(), // Header untuk riwayat absensi
                _buildAttendanceHistory(), // Daftar riwayat absensi
              
               const CopyrightFooter(),
              
              ],
            ),
            
          ),
        ))

        )
        ;
  }

  /// Menangani pengajuan izin tidak hadir.
  Future<void> _handleAjukanIzin() async {
    if (_selectedDate == null || _alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error('Please fill date and reason for leave.')) // Teks Snack Bar
      ;
      return;
    }

    try {
      await AttendanceService.ajukanIzin(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!), // Tanggal izin
        alasan: _alasanController.text.trim(), // Alasan izin
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Leave request submitted successfully.'))); // Teks Snack Bar

      // Reset form setelah berhasil
      setState(() {
        _selectedDate = null;
        _alasanController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error('Failed to submit leave request: ${e.toString()}')) // Teks Snack Bar
      ;
    }
  }

  /// Membangun widget form untuk pengajuan izin.
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
            "Leave Request Form", // Judul form
            style: AppTextStyle.heading2.copyWith(
              fontSize: 16,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              // Buka date picker untuk memilih tanggal
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
                  ? "Select Date" // Teks jika belum ada tanggal dipilih
                  : DateFormat(
                      'EEEE, dd MMMM yyyy',
                      'en_US', // Format tanggal dengan nama hari dalam Bahasa Inggris
                    ).format(_selectedDate!),
              style: AppTextStyle.body.copyWith(
                color: AppColors.blueGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _alasanController, // Input alasan izin
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter your reason...", // Placeholder teks
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
              onPressed: _handleAjukanIzin, // Tombol untuk mengajukan izin
              icon: Icon(Icons.send, color:  AppColors.yellow,),
              label:  Text("Submit Leave",style: AppTextStyle.button.copyWith(
                fontSize: 16,
                color: AppColors.yellow)), // Teks tombol
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

  /// Membangun widget kotak statistik absensi.
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
              child: CircularProgressIndicator(color: AppColors.teal), // Indikator loading
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
                "Failed to load statistics.", // Pesan error jika gagal
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
                "Attendance Statistics", // Judul statistik
                style: AppTextStyle.heading2.copyWith(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Total Absences", data.totalAbsen.toString()), // Item statistik Total Absen
                  _statItem("Present", data.totalMasuk.toString()), // Item statistik Masuk
                  _statItem("Leave", data.totalIzin.toString()), // Item statistik Izin
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
                          ? "You have checked in today" // Status sudah absen
                          : "You haven't checked in today.", // Status belum absen
                      style: AppTextStyle.body.copyWith(
                        color:
                            data.sudahAbsenHariIni ? AppColors.teal : AppColors.red,
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

  /// Helper untuk menampilkan satu item statistik (label & nilai).
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
      greeting = 'Good Morning!'; // Sapaan pagi
    } else if (hour < 17) {
      greeting = 'Good Afternoon!'; // Sapaan siang/sore
    } else {
      greeting = 'Good Evening!'; // Sapaan malam
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting, // Teks sapaan
          style: AppTextStyle.heading1.copyWith(
            fontSize: 22,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        FutureBuilder<ProfileData>(
          future: ProfileService.fetchProfile(), // Ambil data profil
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!.name ?? 'User', // Nama pengguna
                style: AppTextStyle.heading2.copyWith(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
              );
            } else {
              return SizedBox(
                height: 16,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal), // Loading nama
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
          _isLoadingLocation
              ? Icons.location_searching
              : Icons.location_on, // Ikon lokasi (loading/on)
          color: _isLoadingLocation ? AppColors.blueGray : AppColors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _currentLocationAddress, // Teks alamat lokasi
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
              child: CircularProgressIndicator(color: AppColors.teal), // Loading box
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data == null) {
          return _renderCheckInOutBox('-', '-'); // Tampilan default jika error/data kosong
        }

        final data = snapshot.data!.data!;
        return _renderCheckInOutBox(
          data.checkInTime ?? '-', // Waktu check-in
          data.checkOutTime ?? '-', // Waktu check-out
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
          _attendanceBox('Check In', checkIn), // Kotak Check In
          const VerticalDivider(
            color: AppColors.blueGray,
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          _attendanceBox('Check Out', checkOut), // Kotak Check Out
        ],
      ),
    );
  }

  /// Helper widget for displaying single attendance time (e.g., Check In or Check Out).
  Widget _attendanceBox(String label, String time) {
    return Column(
      children: [
        Text(
          label, // Label (Check In/Check Out)
          style: AppTextStyle.heading2.copyWith(
            fontSize: 14,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time, // Waktu (HH:mm)
          style: AppTextStyle.heading2.copyWith(
            fontSize: 18,
            color: AppColors.red,
          ),
        ),
      ],
    );
  }

  /// Tombol Check In/Check Out (saat ini tidak dipakai di build utama).
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

  /// Membangun bagian jarak ke kantor dan tampilan peta (saat ini tidak dipakai di build utama).
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
                    _getDistanceToOffice(), // Menampilkan jarak ke kantor
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
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/200x100?text=Map+View',
                ), // Placeholder gambar peta
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Office Location', // Teks lokasi kantor di atas peta
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

  /// Membangun header untuk bagian riwayat absensi.
  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance History', // Judul riwayat absensi
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
                builder: (context) => const DetailScreen(), // Tombol "See All" menuju DetailScreen
              ),
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

  /// Membangun FutureBuilder untuk daftar riwayat absensi.
  Widget _buildAttendanceHistory() {
    return FutureBuilder<List<HistoryData>>(
      future: _futureHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.teal), // Indikator loading riwayat
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading history: ${snapshot.error}", // Pesan error riwayat
              style: AppTextStyle.body.copyWith(color: AppColors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No attendance records found.", // Pesan jika tidak ada riwayat
              style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
            ),
          );
        }

        final list = snapshot.data!;

        // Batasi tampilan hanya 3 item riwayat terbaru untuk preview di HomeScreen
        final displayedList = list.take(3).toList();

        return ListView.separated(
          itemCount: displayedList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Non-scrollable agar tidak konflik dengan SingleChildScrollView
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = displayedList[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                _getWeekDay(data.attendanceDate), // Nama hari (misal: Monday)
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(data.attendanceDate), // Tanggal absensi
                style: AppTextStyle.body.copyWith(color: AppColors.blueGray),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Check In: ${data.checkInTime ?? '-'}', // Waktu Check In
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Check Out: ${data.checkOutTime ?? '-'}', // Waktu Check Out
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

  // Mengambil nama hari dari objek DateTime.
  String _getWeekDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
}