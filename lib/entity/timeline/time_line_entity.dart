import 'dart:convert';

import 'package:wechat_moments/entity/timeline/result.dart';

/// 将json转为实体类
TimeLineEntity timeLineEntityFromJson(String str) => TimeLineEntity.fromJson(json.decode(str));

///将实体类转为json
String timeLineEntityToJson(TimeLineEntity data) => json.encode(data.toJson());


class TimeLineEntity {
  int code;
  String message;
  List<Result> result;

  TimeLineEntity({
    required this.code,
    required this.message,
    required this.result,
  });

  factory TimeLineEntity.fromJson(Map<String, dynamic> json) => TimeLineEntity(
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