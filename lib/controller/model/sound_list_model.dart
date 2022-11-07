class SoundListModel {
  bool? status;
  bool? error;
  String? message;
  List<Sounds>? data;

  SoundListModel({this.status, this.error, this.message, this.data});

  SoundListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Sounds>[];
      json['data'].forEach((v) {
        data!.add(new Sounds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sounds {
  int? id;
  String? sound;
  int? userId;
  String? category;
  String? name;
  String? createdAt;
  String? updatedAt;
  int? isFavorite;

  Sounds(
      {this.id,
        this.sound,
        this.userId,
        this.category,
        this.name,
        this.createdAt,
        this.updatedAt,
        this.isFavorite});

  Sounds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sound = json['sound'];
    userId = json['user_id'];
    category = json['category'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isFavorite = json['is_favorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sound'] = this.sound;
    data['user_id'] = this.userId;
    data['category'] = this.category;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_favorite'] = this.isFavorite;
    return data;
  }
}
