import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests

// Project-specific imports
import 'package:workline_app/endpoint/endpoint.dart'; // Contains your API base URL and specific paths
import 'package:workline_app/models/check_in_model.dart'; // Model for check-in API response
import 'package:workline_app/models/check_out_model.dart'; // Model for check-out API response
import 'package:workline_app/models/history_model.dart'; // Model for attendance history
import 'package:workline_app/models/today_attendance_model.dart'; // Model for today's attendance
import 'package:workline_app/preferences/preferences_helper.dart'; // Utility for managing user preferences/token
import 'package:intl/intl.dart'; // Required for date formatting

class AttendanceService {

  // Helper to get the authentication token, ensuring it's available
  static Future<String> _getAuthToken() async {
    final token = await PreferencesHelper.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in again.');
    }
    return token;
  }

  /// Fetches today's attendance record for a specific date.
  ///
  /// Requires [attendanceDate] in 'YYYY-MM-DD' format.
  static Future<TodayAttendanceResponse> fetchTodayAttendance(String attendanceDate) async {
    try {
      final token = await _getAuthToken(); // Get token for authenticated request
      final uri = Uri.parse('${Endpoint.baseUrl}/absen/today?attendance_date=$attendanceDate');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token', // Include token in headers
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return TodayAttendanceResponse.fromJson(json.decode(response.body));
      } else {
        // More descriptive error message from API if available
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load today attendance.';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('Error fetching today attendance for $attendanceDate: $e'); // Use debugPrint in actual app
      // Re-throw the specific exception or a more generic one for UI handling
      throw Exception('Failed to connect to the server or process today\'s attendance. $e');
    }
  }

  /// Fetches the full attendance history for the authenticated user.
  static Future<List<HistoryData>> fetchAttendanceHistory() async {
    try {
      final token = await _getAuthToken(); // Get token for authenticated request
      final response = await http.get(
        Uri.parse(Endpoint.history), // Uses the predefined history endpoint
        headers: {
          'Authorization': 'Bearer $token', // Include token in headers
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> jsonList;

        // --- FIXED HISTORY PARSING LOGIC ---
        if (decodedResponse is List) {
          // Case 1: The root response is directly a JSON array (e.g., [...])
          jsonList = decodedResponse;
        } else if (decodedResponse is Map && decodedResponse.containsKey('data')) {
          // Case 2: The response is an object with a 'data' key
          final dynamic dataContent = decodedResponse['data'];
          if (dataContent is List) {
            // Case 2a: 'data' key directly contains the array (e.g., {"data": [...]})
            jsonList = dataContent;
          } else if (dataContent is Map && dataContent.containsKey('data') && dataContent['data'] is List) {
            // Case 2b: 'data' key contains another object with a 'data' key that is the array (e.g., {"data": {"data": [...]}})
            jsonList = dataContent['data'];
          } else {
            throw Exception('Unexpected history data format under "data" key. Expected a list.');
          }
        } else {
          throw Exception('Unexpected history data format. Expected a list or an object with a "data" key.');
        }
        // --- END FIXED HISTORY PARSING LOGIC ---

        return jsonList.map((json) => HistoryData.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load attendance history.';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('Error fetching attendance history: $e'); // Use debugPrint in actual app
      throw Exception('Failed to connect to the server or process attendance history. $e');
    }
  }

  /// Sends a check-in request to the API.
  ///
  /// Requires [lat] (latitude), [lng] (longitude), and optionally [address].
  static Future<CheckInResponse> checkIn({
    required double lat,
    required double lng,
    String? address, // Optional, depending on your API needs
  }) async {
    try {
      DateTime now = DateTime.now();
      String attendanceDate = DateFormat('yyyy-MM-dd').format(now);
      String checkInTime = DateFormat('HH:mm').format(now); // Renamed to checkInTime for clarity

      print('attendance_date: $attendanceDate'); // Use debugPrint
      print('check_in: $checkInTime'); // Use debugPrint

      final token = await _getAuthToken();
      final url = Uri.parse(Endpoint.checkIn);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "attendance_date": attendanceDate,
          "check_in": checkInTime, // Corrected variable name
          "check_in_lat": lat,
          "check_in_lng": lng,
          "check_in_address": address, // --- FIXED: Use the actual address parameter ---
          "status": "masuk", // Ensure this status is correct for check-in
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckInResponse.fromJson(responseData);
      } else {
        final errorMessage = responseData['message'] ?? 'Check In failed: Unknown error.';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('Error during check-in: $e'); // Use debugPrint
      throw Exception('Failed to perform check-in. $e');
    }
  }

  /// Sends a check-out request to the API.
  ///
  /// Requires [lat] (latitude), [lng] (longitude), and optionally [address].
  static Future<CheckOutResponse> checkOut({
    required double lat,
    required double lng,
    String? address, // Optional, depending on your API needs
  }) async {
    try {
      DateTime now = DateTime.now();
      String attendanceDate = DateFormat('yyyy-MM-dd').format(now);
      String checkOutTime = DateFormat('HH:mm').format(now); // Renamed to checkOutTime for clarity

      final token = await _getAuthToken();
      final url = Uri.parse(Endpoint.checkOut);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "attendance_date": attendanceDate,
          "check_out": checkOutTime, // Corrected variable name
          "check_out_lat": lat,
          "check_out_lng": lng,
          "check_out_location": '$lat,$lng', // Keep if API expects combined string
          "check_out_address": address, // --- FIXED: Use the actual address parameter ---
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckOutResponse.fromJson(responseData);
      } else {
        final errorMessage = responseData['message'] ?? 'Check Out failed: Unknown error.';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('Error during check-out: $e'); // Use debugPrint
      throw Exception('Failed to perform check-out. $e');
    }
  }
}