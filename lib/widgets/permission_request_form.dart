// lib/widgets/permission_request_form.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:workline_app/api/permission_service.dart'; // Pastikan path ini benar
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';

class PermissionRequestForm extends StatefulWidget {
  final Function onPermissionSubmitted;
  final Position? currentPosition;
  final String currentAddress;

  const PermissionRequestForm({
    super.key,
    required this.onPermissionSubmitted,
    this.currentPosition,
    required this.currentAddress,
  });

  @override
  State<PermissionRequestForm> createState() => _PermissionRequestFormState();
}

class _PermissionRequestFormState extends State<PermissionRequestForm> {
  final List<String> _permissionCategories = [
    'Sakit',
    'Cuti',
    'Izin Pribadi',
    'Kedukaan (Meninggal)',
    'Acara Keluarga',
    'Lain-lain',
  ];
  String? _selectedCategory;
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitPermissionRequest() async {
    if (!mounted) return;

    if (_selectedCategory == null || _reasonController.text.trim().isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih tanggal, kategori, dan isi alasan.')),
      );
      return;
    }

    if (widget.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum tersedia. Mohon tunggu.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil PermissionService.submitPermission dengan parameter yang sesuai.
      // Sesuaikan `alasanPermission` di sini.
      // Dan sertakan `category`, `latitude`, `longitude`, `address` jika API membutuhkannya.
      await PermissionService.submitPermission(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        alasanPermission: _reasonController.text.trim(), // Sesuai dengan model PermissionRequest
        category: _selectedCategory, // Kirim kategori
        latitude: widget.currentPosition?.latitude, // Kirim latitude jika ada
        longitude: widget.currentPosition?.longitude, // Kirim longitude jika ada
        address: widget.currentAddress, // Kirim address jika ada
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengajuan izin berhasil dikirim!")),
        );
        widget.onPermissionSubmitted(); // Panggil callback untuk refresh riwayat
        Navigator.pop(context); // Tutup form
      }
    } catch (e) {
      debugPrint("Error submitting permission: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pengajuan izin gagal: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Ajukan Izin/Cuti',
              style: AppTextStyle.heading1.copyWith(color: AppColors.darkBlue, fontSize: 20),
            ),
          ),
          const Divider(height: 30, thickness: 1, color: AppColors.lightGrey),
          Text(
            'Tanggal Izin:',
            style: AppTextStyle.body.copyWith(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            icon: const Icon(Icons.calendar_today, color: AppColors.teal),
            label: Text(
              _selectedDate == null
                  ? "Pilih Tanggal Izin"
                  : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!),
              style: AppTextStyle.body.copyWith(
                color: AppColors.blueGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kategori Izin:',
            style: AppTextStyle.body.copyWith(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Pilih Kategori', style: AppTextStyle.body.copyWith(color: AppColors.blueGray)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.lightGrey,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _permissionCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: AppTextStyle.body),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Alasan / Keterangan Tambahan:',
            style: AppTextStyle.body.copyWith(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Misal: Demam tinggi, izin keperluan keluarga...',
              hintStyle: AppTextStyle.body.copyWith(color: AppColors.blueGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.lightGrey,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPermissionRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Kirim Pengajuan Izin',
                      style: AppTextStyle.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}