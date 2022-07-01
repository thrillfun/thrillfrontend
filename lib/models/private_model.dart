import 'package:thrill/models/user.dart';

class PrivateModel {
  int id;
  List comments;
  String video, description, filter, gif_image, sound_name, sound_category_name;
  int likes,views;
  UserModel user;

  PrivateModel(
      this.id,
      this.comments,
      this.video,
      this.description,
      this.likes,
      this.user,
      this.filter,
      this.gif_image,
      this.sound_name,
      this.sound_category_name,this.views);

  factory PrivateModel.fromJson(dynamic json) {
    UserModel users;
    users = UserModel.fromJson(json['user'] ?? {});
    return PrivateModel(
        json['id'],
        json['comments'] ?? [],
        json['video'] ?? '',
        json['description'] ?? '',
        json['likes'] ?? 0,
        users,
        json['filter'] ?? '',
        json['gif_image'] ?? '',
        json['sound_name'] ?? '',
        json['sound_category_name'] ?? '',json['views'] ?? 0);
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
    data['sound_name'] = sound_name;
    data['sound_category_name'] = sound_category_name;
    data['views'] = views;
    return data;
  }
}
