import 'dart:convert';

import '../timeline_likesAndcomments/result.dart';

TimeLineLikesCommentsEntity timeLineLikesCommentsEntityFromJson(String str) => TimeLineLikesCommentsEntity.fromJson(json.decode(str));

String timeLineLikesCommentsEntityToJson(TimeLineLikesCommentsEntity data) => json.encode(data.toJson());

class TimeLineLikesCommentsEntity {
  int code;
  String message;
  List<Result> result;

  TimeLineLikesCommentsEntity({
    required this.code,
    required this.message,
    required this.result,
  });

  factory TimeLineLikesCommentsEntity.fromJson(Map<String, dynamic> json) => TimeLineLikesCommentsEntity(
    code: json["code"],
    message: json["message"],
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}