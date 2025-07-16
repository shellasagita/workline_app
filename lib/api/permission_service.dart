// lib/api/permission_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workline_app/endpoint/endpoint.dart';
import 'package:workline_app/models/permission_model.dart';
import 'package:workline_app/api/user_api.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:workline_app/preferences/preferences_helper.dart'; // Untuk debugPrint

class PermissionService {
  // Helper untuk mendapatkan headers yang diperlukan (termasuk token)
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await PreferencesHelper.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Mengirim pengajuan izin baru ke backend.
  ///
  /// Menerima tanggal dan alasan izin.
  /// Secara opsional bisa menerima data lokasi dan kategori jika diperlukan oleh API.
  static Future<bool> submitPermission({
    required String date,
    required String alasanPermission,
    // Tambahkan parameter berikut jika API membutuhkannya saat submit izin
    String? category, // Misal: "Sakit", "Cuti", "Izin Pribadi"
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/izin'); 
    final headers = await _getAuthHeaders();


    final body = {
      'date': date,
      'alasan_Permission': alasanPermission, // Pastikan ini sesuai dengan field di backend
      if (category != null) 'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
    };

    debugPrint('Submitting permission to: $url with body: $body');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body), // Penting: encode body ke JSON
      );

      final responseData = jsonDecode(response.body);
      debugPrint('Submit Permission Response Status: ${response.statusCode}');
      debugPrint('Submit Permission Response Body: $responseData');

      // Asumsi: API mengembalikan status code 200-299 untuk sukses, dan field 'success: true'
      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['success'] == true) {
        // Kita bisa parse PermissionResponse jika memang ada data detail yang dikembalikan setelah submit
        // final permissionResponse = PermissionResponse.fromJson(responseData);
        // debugPrint('Permission submitted successfully: ${permissionResponse.message}');
        return true;
      } else {
        debugPrint('Failed to submit permission: ${responseData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting permission: $e');
      return false; // Mengembalikan false jika terjadi exception
    }
  }

  /// Mengambil daftar riwayat pengajuan izin dari backend.
  ///
  /// Mengembalikan [List<PermissionData>] yang berisi detail setiap pengajuan izin.
  static Future<List<PermissionData>> fetchAllPermissionRequests() async {
    final url = Uri.parse('${Endpoint.baseUrl}/permissions/history'); // Ganti dengan endpoint riwayat izin 
    final headers = await _getAuthHeaders();

    debugPrint('Fetching permission history from: $url');
    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      debugPrint('Permission History Response Status: ${response.statusCode}');
      debugPrint('Permission History Response Body: $responseData');

      // Asumsi: API mengembalikan status code 200-299 untuk sukses, dan 'data' berupa List
      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['data'] is List) {
        final List<dynamic> rawData = responseData['data'];
        final List<PermissionData> permissions = rawData
            .map((json) => PermissionData.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('Fetched ${permissions.length} permission requests successfully.');
        return permissions;
      } else {
        debugPrint('Failed to fetch permission history: ${responseData['message'] ?? 'Unknown error'}');
        // Mengembalikan list kosong atau throw Exception, tergantung preferensi 
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching permission history: $e');
      return []; // Mengembalikan list kosong jika terjadi exception
    }
  }
}