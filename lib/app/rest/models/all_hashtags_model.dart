class AllHashtagsModel {
  bool? status;
  List<AllHashtags>? data;
  String? message;
  bool? error;

  AllHashtagsModel({this.status, this.data, this.message, this.error});

  AllHashtagsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <AllHashtags>[];
      json['data'].forEach((v) {
        data!.add(new AllHashtags.fromJson(v));
      });
    }
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class AllHashtags {
  int? id;
  int? userId;
  String? name;
  int? isActive;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? isFavouriteHashtagCount;

  AllHashtags(
      {this.id,
      this.userId,
      this.name,
      this.isActive,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.isFavouriteHashtagCount});

  AllHashtags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    isActive = json['is_active'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isFavouriteHashtagCount = json['is_favourite_hashtag_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['is_active'] = this.isActive;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_favourite_hashtag_count'] = this.isFavouriteHashtagCount;
    return data;
  }
}
