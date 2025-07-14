import 'dart:convert';

PermissionRequest PermissionRequestFromJson(String str) =>
    PermissionRequest.fromJson(json.decode(str));

String PermissionRequestToJson(PermissionRequest data) => json.encode(data.toJson());

class PermissionRequest {
  final String date;
  final String alasanPermission;

  PermissionRequest({required this.date, required this.alasanPermission});

  factory PermissionRequest.fromJson(Map<String, dynamic> json) =>
      PermissionRequest(date: json["date"], alasanPermission: json["alasan_Permission"]);

  Map<String, dynamic> toJson() => {"date": date, "alasan_Permission": alasanPermission};
}

PermissionResponse PermissionResponseFromJson(String str) =>
    PermissionResponse.fromJson(json.decode(str));

String PermissionResponseToJson(PermissionResponse data) => json.encode(data.toJson());

class PermissionResponse {
  final String message;
  final PermissionData data;

  PermissionResponse({required this.message, required this.data});

  factory PermissionResponse.fromJson(Map<String, dynamic> json) => PermissionResponse(
    message: json["message"],
    data: PermissionData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class PermissionData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkInLat;
  final String? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;
  final String status;
  final String alasanPermission;

  PermissionData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    required this.status,
    required this.alasanPermission,
  });

  factory PermissionData.fromJson(Map<String, dynamic> json) => PermissionData(
    id: json["id"],
    attendanceDate: json["attendance_date"],
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"],
    checkInLng: json["check_in_lng"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanPermission: json["alasan_Permission"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate,
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_Permission": alasanPermission,
  };
}
