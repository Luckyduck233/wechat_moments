import 'dart:convert';

/// 将json转为实体类
Result resultEntityFromJson(String str) => Result.fromJson(json.decode(str));

///将实体类转为json
String resultEntityToJson(Result data) => json.encode(data.toJson());


class Result {
  double id;
  Video video;
  String content;
  User user;
  String publishDate;
  String location;
  bool isLike;
  List<String> images;

  Result({
    required this.id,
    required this.video,
    required this.content,
    required this.user,
    required this.publishDate,
    required this.location,
    required this.isLike,
    required this.images,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"]?.toDouble(),
    video: Video.fromJson(json["video"]),
    content: json["content"],
    user: User.fromJson(json["user"]),
    publishDate: json["publishDate"],
    location: json["location"],
    isLike: json["is_like"],
    images: List<String>.from(json["images"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "video": video.toJson(),
    "content": content,
    "user": user.toJson(),
    "publishDate": publishDate,
    "location": location,
    "is_like": isLike,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}
class User {
  String uid;
  String nickname;
  String avator;

  User({
    required this.uid,
    required this.nickname,
    required this.avator,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json["uid"],
    nickname: json["nickname"],
    avator: json["avator"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "nickname": nickname,
    "avator": avator,
  };
}

class Video {
  String cover;
  String url;

  Video({
    required this.cover,
    required this.url,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    cover: json["cover"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "cover": cover,
    "url": url,
  };
}