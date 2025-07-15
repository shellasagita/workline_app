import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workline_app/endpoint/endpoint.dart';
import 'package:workline_app/models/batch_model.dart' as batch_model;
import 'package:workline_app/models/login_response.dart';
import 'package:workline_app/models/register_response.dart';
import 'package:workline_app/models/training_model.dart' as training_model;
import 'package:workline_app/preferences/preferences_helper.dart';

class UserApi {
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('${Endpoint.baseUrl}/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      debugPrint("Login Response: $data");

      if (response.statusCode == 200 && data['data'] != null) {
        final loginResponse = LoginResponse.fromJson(data);
        await PreferencesHelper.saveToken(loginResponse.data.token);
        await PreferencesHelper.setLoginStatus(true);
        // await PreferencesHelper.saveUser(loginResponse.data.user);
        return true;
      } else {
        debugPrint('Login failed: ${data['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String gender,
    required int batchId,
    required int trainingId,
    File? profilePhoto,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/register'); // without `/api`

    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      String? base64Photo;
      if (profilePhoto != null) {
        final bytes = await profilePhoto.readAsBytes();
        base64Photo = base64Encode(bytes);
      }

      final body = {
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': gender,
        'batch_id': batchId,
        'training_id': trainingId,
        if (base64Photo != null) 'profile_photo': base64Photo,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      debugPrint("Register Response: $data");

      if (response.statusCode == 200 && data['data'] != null) {
        final registerResponse = RegisterResponse.fromJson(data);
        await PreferencesHelper.saveToken(registerResponse.data.token);
        await PreferencesHelper.setLoginStatus(true);
        await PreferencesHelper.saveUser(registerResponse.data.user);
        return true;
      } else {
        debugPrint('Register failed: ${data['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  static Future<bool> requestReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/forgot-password'),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return false;
    }
  }

  static Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/reset-password'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  static Future<List<batch_model.Batch>> getBatchList() async {
    final url = Uri.parse('${Endpoint.baseUrl}/batches');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<batch_model.Batch>.from(
          data['data'].map((x) => batch_model.Batch.fromJson(x)),
        );
      }
    } catch (e) {
      debugPrint('getBatchList error: $e');
    }
    return [];
  }

  static Future<List<training_model.Training>> getTrainingList() async {
    final url = Uri.parse('${Endpoint.baseUrl}/trainings');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<training_model.Training>.from(
          data['data'].map((x) => training_model.Training.fromJson(x)),
        );
      }
    } catch (e) {
      debugPrint('getTrainingList error: $e');
    }
    return [];
  }

  // static Future<TodayAttendance?> getTodayAttendance() async {
  //   final token = await PreferencesHelper.getToken();
  //   final url = Uri.parse('${Endpoint.baseUrl}/today-attendance');

  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return TodayAttendance.fromJson(data['data']);
  //   } else {
  //     return null;
  //   }
  // }

  static Future<bool> absen({
    required String type,
    required String latitude,
    required String longitude,
  }) async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen-$type');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'latitude': latitude, 'longitude': longitude},
    );

    return response.statusCode == 200;
  }
}
