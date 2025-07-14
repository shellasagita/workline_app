// To parse this JSON StatDataAbsen, do
//
//     final StatisticAttendanceResponse = StatisticAttendanceResponseFromJson(jsonString);

import 'dart:convert';

StatisticAttendanceResponse StatisticAttendanceResponseFromJson(String str) =>
    StatisticAttendanceResponse.fromJson(json.decode(str));

String StatisticAttendanceResponseToJson(StatisticAttendanceResponse data) =>
    json.encode(data.toJson());

class StatisticAttendanceResponse {
  String message;
  StatDataAbsen data;

  StatisticAttendanceResponse({required this.message, required this.data});

  factory StatisticAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      StatisticAttendanceResponse(
        message: json["message"],
        data: StatDataAbsen.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class StatDataAbsen {
  int totalAbsen;
  int totalMasuk;
  int totalIzin;
  bool sudahAbsenHariIni;

  StatDataAbsen({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory StatDataAbsen.fromJson(Map<String, dynamic> json) => StatDataAbsen(
    totalAbsen: json["total_absen"],
    totalMasuk: json["total_masuk"],
    totalIzin: json["total_izin"],
    sudahAbsenHariIni: json["sudah_absen_hari_ini"],
  );

  Map<String, dynamic> toJson() => {
    "total_absen": totalAbsen,
    "total_masuk": totalMasuk,
    "total_izin": totalIzin,
    "sudah_absen_hari_ini": sudahAbsenHariIni,
  };
}
