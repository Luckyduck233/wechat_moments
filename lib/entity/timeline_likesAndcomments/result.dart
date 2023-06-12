class Result {
  double id;
  Video video;
  String content;
  User user;
  String publishDate;
  String location;
  bool isLike;
  List<String> images;
  List<User> likes;
  List<Comment> comments;

  Result({
    required this.id,
    required this.video,
    required this.content,
    required this.user,
    required this.publishDate,
    required this.location,
    required this.isLike,
    required this.images,
    required this.likes,
    required this.comments,
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
    likes: List<User>.from(json["likes"].map((x) => User.fromJson(x))),
    comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
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
    "likes": List<dynamic>.from(likes.map((x) => x.toJson())),
    "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
  };
}

class Comment {
  User user;
  String content;
  DateTime publishDate;

  Comment({
    required this.user,
    required this.content,
    required this.publishDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    user: User.fromJson(json["user"]),
    content: json["content"],
    publishDate: DateTime.parse(json["publishDate"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "content": content,
    "publishDate": publishDate.toIso8601String(),
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