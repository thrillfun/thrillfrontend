class HashTagsListModel {
  bool? status;
  List<HashTagsList>? data;
  String? message;
  bool? error;

  HashTagsListModel({this.status, this.data, this.message, this.error});

  HashTagsListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <HashTagsList>[];
      json['data'].forEach((v) {
        data!.add( HashTagsList.fromJson(v));
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

class HashTagsList {
  int? id;
  int? userId;
  String? name;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  HashTagsList(
      {this.id,
        this.userId,
        this.name,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  HashTagsList.fromJson(Map<String, dynamic> json) {
    id = json['id']??"";
    userId = json['user_id']??"";
    name = json['name']??"";
    isActive = json['is_active']??"";
    createdAt = json['created_at']??"";
    updatedAt = json['updated_at']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
