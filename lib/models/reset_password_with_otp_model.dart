// To parse this JSON data, do
//
//     final resetPasswordwithOtp = resetPasswordwithOtpFromJson(jsonString);

import 'dart:convert';

ResetPasswordwithOtp resetPasswordwithOtpFromJson(String str) =>
    ResetPasswordwithOtp.fromJson(json.decode(str));

String resetPasswordwithOtpToJson(ResetPasswordwithOtp data) =>
    json.encode(data.toJson());

class ResetPasswordwithOtp {
  String? message;

  ResetPasswordwithOtp({this.message});

  factory ResetPasswordwithOtp.fromJson(Map<String, dynamic> json) =>
      ResetPasswordwithOtp(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
