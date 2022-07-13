import 'package:thrill/models/user.dart';

class VideoModel {
  int id, comments;
  String video, description, filter, gif_image, sound, sound_name, sound_category_name;
  int likes,views;
  UserModel user;
  String speed;

  VideoModel(
      this.id,
      this.comments,
      this.video,
      this.description,
      this.likes,
      this.user,
      this.filter,
      this.gif_image,
      this.sound,
      this.sound_name,
      this.sound_category_name,this.views,this.speed);

  factory VideoModel.fromJson(dynamic json) {
    UserModel users;
    users = UserModel.fromJson(json['user'] ?? {});
    return VideoModel(
        json['id'],
        json['comments'] ?? 0,
        json['video'] ?? '',
        json['description'] ?? '',
        json['likes'] ?? 0,
        users,
        json['filter'] ?? '',
        json['gif_image'] ?? '',
        json['sound'] ?? '',
        json['sound_name'] ?? '',
        json['sound_category_name'] ?? '',json['views'] ?? 0,
        json['speed'] ?? '1');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['comments'] = id;
    data['video'] = video;
    data['description'] = description;
    data['likes'] = likes;
    data['user'] = user.toJson();
    data['filter'] = filter;
    data['gif_image'] = gif_image;
    data['sound'] = sound;
    data['sound_name'] = sound_name;
    data['sound_category_name'] = sound_category_name;
    data['views'] = views;
    data['speed'] = speed;
    return data;
  }

  VideoModel copyWith(
      {int? id,
      int? comments,
      String? video,
      String? description,
      int? likes,
      UserModel? user,
      String? filter,
      String? gif_image,
        String? sound,
        String? sound_name,
        String? sound_category_name,
        int? views,
        String? speed
      }) {
    return VideoModel(
        id ?? this.id,
        comments ?? this.comments,
        video ?? this.video,
        description ?? this.description,
        likes ?? this.likes,
        this.user,
        this.filter,
        this.gif_image,
        this.sound_name,
        this.sound,
        this.sound_category_name,
      views ?? this.views,
        this.speed
    );
  }
}
