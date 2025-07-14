// To parse this JSON data, do:
// final attendanceHistory = attendanceHistoryFromJson(jsonString);

import 'dart:convert';

AttendanceHistoryResponse attendanceHistoryFromJson(String str) =>
    AttendanceHistoryResponse.fromJson(json.decode(str));

String attendanceHistoryToJson(AttendanceHistoryResponse data) =>
    json.encode(data.toJson());

class AttendanceHistoryResponse {
  String message;
  List<AttendanceRecord> data;

  AttendanceHistoryResponse({
    required this.message,
    required this.data,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceHistoryResponse(
        message: json["message"],
        data: List<AttendanceRecord>.from(
          json["data"].map((x) => AttendanceRecord.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AttendanceRecord {
  int id;
  DateTime date;
  String? checkInTime;
  String? checkOutTime;
  double? checkInLat;
  double? checkInLng;
  double? checkOutLat;
  double? checkOutLng;
  String? checkInAddress;
  String? checkOutAddress;
  String? checkInLocation;
  String? checkOutLocation;
  AttendanceStatus status;
  String? permissionReason;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
    required this.permissionReason,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json["id"],
        date: DateTime.parse(json["attendance_date"]),
        checkInTime: json["check_in_time"],
        checkOutTime: json["check_out_time"],
        checkInLat: json["check_in_lat"]?.toDouble(),
        checkInLng: json["check_in_lng"]?.toDouble(),
        checkOutLat: json["check_out_lat"]?.toDouble(),
        checkOutLng: json["check_out_lng"]?.toDouble(),
        checkInAddress: json["check_in_address"],
        checkOutAddress: json["check_out_address"],
        checkInLocation: json["check_in_location"],
        checkOutLocation: json["check_out_location"],
        status: attendanceStatusValues.map[json["status"]] ?? AttendanceStatus.PRESENT,
        permissionReason: json["alasan_izin"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "attendance_date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "check_in_time": checkInTime,
        "check_out_time": checkOutTime,
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_in_address": checkInAddress,
        "check_out_address": checkOutAddress,
        "check_in_location": checkInLocation,
        "check_out_location": checkOutLocation,
        "status": attendanceStatusValues.reverse[status],
        "alasan_izin": permissionReason,
      };
}

enum AttendanceStatus { PERMISSION, PRESENT }

final attendanceStatusValues = EnumValues({
  "izin": AttendanceStatus.PERMISSION,
  "masuk": AttendanceStatus.PRESENT,
  "permission": AttendanceStatus.PERMISSION, // compatibility
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
