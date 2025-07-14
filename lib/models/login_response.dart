// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';



LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String message;
    Data data;

    LoginResponse({
        required this.message,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String token;
    User user;

    Data({
        required this.token,
        required this.user,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    int id;
    String name;
    String email;
    dynamic emailVerifiedAt;
    DateTime createdAt;
    DateTime updatedAt;
    String batchId;
    String trainingId;
    String jenisKelamin;
    String profilePhoto;
    String onesignalPlayerId;
    Batch batch;
    Training training;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.emailVerifiedAt,
        required this.createdAt,
        required this.updatedAt,
        required this.batchId,
        required this.trainingId,
        required this.jenisKelamin,
        required this.profilePhoto,
        required this.onesignalPlayerId,
        required this.batch,
        required this.training,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        batchId: json["batch_id"],
        trainingId: json["training_id"],
        jenisKelamin: json["jenis_kelamin"],
        profilePhoto: json["profile_photo"],
        onesignalPlayerId: json["onesignal_player_id"],
        batch: Batch.fromJson(json["batch"]),
        training: Training.fromJson(json["training"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "batch_id": batchId,
        "training_id": trainingId,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "onesignal_player_id": onesignalPlayerId,
        "batch": batch.toJson(),
        "training": training.toJson(),
    };
}

class Batch {
    int id;
    String batchKe;
    DateTime startDate;
    DateTime endDate;
    DateTime createdAt;
    DateTime updatedAt;

    Batch({
        required this.id,
        required this.batchKe,
        required this.startDate,
        required this.endDate,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json["id"],
        batchKe: json["batch_ke"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}

class Training {
    int id;
    String title;
    dynamic description;
    dynamic participantCount;
    dynamic standard;
    dynamic duration;
    DateTime createdAt;
    DateTime updatedAt;

    Training({
        required this.id,
        required this.title,
        required this.description,
        required this.participantCount,
        required this.standard,
        required this.duration,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        participantCount: json["participant_count"],
        standard: json["standard"],
        duration: json["duration"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "participant_count": participantCount,
        "standard": standard,
        "duration": duration,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
