import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workline_app/endpoint/endpoint.dart';
import 'package:workline_app/models/profile_model.dart';
import 'package:workline_app/preferences/preferences_helper.dart';

class ProfileService {
  /// Get Profile Data
  static Future<ProfileData> fetchProfile() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.profile);

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('Debug Profile Data: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final profileResponse = ProfileResponse.fromJson(json);
      return profileResponse.data;
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Update Profile Name
  static Future<ProfileData> updateProfileName({
    required String token,
    required String name,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/profile');

    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"name": name}),
      );
      print("Data Update name${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ProfileData.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile name');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload Profile Photo in Base64 format
  static Future<ProfileData> uploadProfilePhotoBase64({
    required String token,
    required String base64Image,
  }) async {
    final url = Uri.parse('${Endpoint.baseUrl}/profile/photo');

    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'profile_photo': base64Image}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return ProfileData.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      rethrow;
    }
  }
}
