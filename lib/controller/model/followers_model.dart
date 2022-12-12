class FollowersModel {
  bool? status;
  bool? error;
  String? message;
  List<Followers>? data;

  FollowersModel({this.status, this.error, this.message, this.data});

  FollowersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Followers>[];
      json['data'].forEach((v) {
        data!.add(new Followers.fromJson(v));
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

class Followers {
  int? id;
  String? name;
  String? username;
  String? email;
  String? dob;
  String? emailVerifiedAt;
  String? phone;
  String? avtars;
  String? coverImage;
  String? rating;
  String? notification;
  String? twoFAToggle;
  String? status;
  int? deactivationRequest;
  int? role;
  String? socialLoginId;
  String? socialLoginType;
  String? createdAt;
  String? updatedAt;
  int? isVerified;
  int? isfollowing;

  Followers(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.dob,
      this.emailVerifiedAt,
      this.phone,
      this.avtars,
      this.coverImage,
      this.rating,
      this.notification,
      this.twoFAToggle,
      this.status,
      this.deactivationRequest,
      this.role,
      this.socialLoginId,
      this.socialLoginType,
      this.createdAt,
      this.updatedAt,
      this.isVerified,this.isfollowing});

  Followers.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    dob = json['dob'] ?? "";
    emailVerifiedAt = json['email_verified_at'] ?? "";
    phone = json['phone'] ?? "";
    avtars = json['avtars'] ?? "";
    coverImage = json['cover_image'] ?? "";
    rating = json['rating'] ?? "";
    notification = json['notification'] ?? "";
    twoFAToggle = json['two_FA_toggle'] ?? "";
    status = json['status'] ?? "";
    deactivationRequest = json['deactivation_request'] ?? "";
    role = json['role'] ?? "";
    socialLoginId = json['social_login_id'] ?? "";
    socialLoginType = json['social_login_type'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    isVerified = json['is_verified'] ?? "";
    isfollowing = json["isfollowing"]??0;}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['dob'] = this.dob;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['phone'] = this.phone;
    data['avtars'] = this.avtars;
    data['cover_image'] = this.coverImage;
    data['rating'] = this.rating;
    data['notification'] = this.notification;
    data['two_FA_toggle'] = this.twoFAToggle;
    data['status'] = this.status;
    data['deactivation_request'] = this.deactivationRequest;
    data['role'] = this.role;
    data['social_login_id'] = this.socialLoginId;
    data['social_login_type'] = this.socialLoginType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_verified'] = this.isVerified;
    data['isfollowing'] = this.isfollowing;
    return data;
  }
}
