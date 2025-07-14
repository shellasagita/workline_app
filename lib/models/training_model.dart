// To parse this JSON data:
//
//     final trainingListResponse = trainingListResponseFromJson(jsonString);

import 'dart:convert';

TrainingListResponse trainingListResponseFromJson(String str) =>
    TrainingListResponse.fromJson(json.decode(str));

String trainingListResponseToJson(TrainingListResponse data) =>
    json.encode(data.toJson());

class TrainingListResponse {
  String message;
  List<Training> data;

  TrainingListResponse({
    required this.message,
    required this.data,
  });

  factory TrainingListResponse.fromJson(Map<String, dynamic> json) =>
      TrainingListResponse(
        message: json["message"],
        data:
            List<Training>.from(json["data"].map((x) => Training.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Training {
  int id;
  String title;

  Training({
    required this.id,
    required this.title,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
