// To parse this JSON data, do
//
//     final deviceToken = deviceTokenFromJson(jsonString);

import 'dart:convert';

DeviceToken deviceTokenFromJson(String str) =>
    DeviceToken.fromJson(json.decode(str));

String deviceTokenToJson(DeviceToken data) => json.encode(data.toJson());

class DeviceToken {
  String? message;
  Data? data;

  DeviceToken({this.message, this.data});

  factory DeviceToken.fromJson(Map<String, dynamic> json) => DeviceToken(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int? userId;
  String? playerId;

  Data({this.userId, this.playerId});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(userId: json["user_id"], playerId: json["player_id"]);

  Map<String, dynamic> toJson() => {"user_id": userId, "player_id": playerId};
}
