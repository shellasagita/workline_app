import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workline_app/endpoint/endpoint.dart';
import 'package:workline_app/models/check_in_model.dart';
import 'package:workline_app/models/check_out_model.dart';
import 'package:workline_app/models/history_model.dart';
// import 'package:workline_app/models/today_model.dart';
import 'package:workline_app/preferences/preferences_helper.dart';

class AttendanceService {
  static Future<List<HistoryData>> fetchAttendanceHistory() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.history);

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print('Debug History Data:${response.body}');
    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<HistoryData>.from(
        data['data'].map((x) => HistoryData.fromJson(x)),
      );
    } else {
      throw Exception('Failed to load attendance history');
    }
  }

  // final base64Image =
  //       _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : null;

  static Future<dynamic> fetchTodayAttendance() async {}

  // static Future<TodayResponse> fetchTodayAttendance() async {
  //   final token = await PreferencesHelper.getToken();
  //   final url = Uri.parse('${Endpoint.baseUrl}/today-attendance');

  //   final response = await http.get(
  //     url,
  //     headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return TodayResponse.fromJson(data);
  //   } else {
  //     throw Exception('Failed to fetch today attendance');
  //   }
  // }

  static Future<CheckInResponse> checkIn({
    required double lat,
    required double lng,
  }) async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen-check-in');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );

    if (response.statusCode == 200) {
      return checkInResponseFromJson(response.body);
    } else {
      throw Exception('Check In gagal');
    }
  }

  static Future<CheckOutResponse> checkOut({
    required double lat,
    required double lng,
  }) async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen-check-out');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );

    if (response.statusCode == 200) {
      return checkOutResponseFromJson(response.body);
    } else {
      throw Exception('Check Out gagal');
    }
  }
}
