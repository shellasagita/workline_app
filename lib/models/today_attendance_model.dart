// To parse this JSON data, do
//
//     final TodayAttendanceResponse = TodayAttendanceResponseFromJson(jsonString);

import 'dart:convert';

TodayAttendanceResponse TodayAttendanceResponseFromJson(String str) =>
    TodayAttendanceResponse.fromJson(json.decode(str));

String TodayAttendanceResponseToJson(TodayAttendanceResponse data) =>
    json.encode(data.toJson());

class TodayAttendanceResponse {
  String? message;
  TodayAttendanceData? data;

  TodayAttendanceResponse({this.message, this.data});

  factory TodayAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      TodayAttendanceResponse(
        message: json["message"],
        data: json["data"] != null
            ? TodayAttendanceData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class TodayAttendanceData {
  String? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? status;
  String? alasanIzin;

  TodayAttendanceData({
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory TodayAttendanceData.fromJson(Map<String, dynamic> json) => TodayAttendanceData(
    attendanceDate: json["attendance_date"],
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };

  // Tambahkan getter agar kompatibel dengan maps_page.dart
  String get checkIn => checkInTime ?? '';
  String? get checkOut => checkOutTime;

  // Legacy getters for backward compatibility
  String? get tanggal => attendanceDate;
  String? get jamMasuk => checkInTime;
  String? get jamKeluar => checkOutTime;
  String? get alamatMasuk => checkInAddress;
  String? get alamatKeluar => checkOutAddress;
}
