class ProfileModelPojo {
  bool? status;
  bool? error;
  String? message;
  ProfileData? data;

  ProfileModelPojo({this.status, this.error, this.message, this.data});

  ProfileModelPojo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? new ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  User? user;

  ProfileData({this.user});

  ProfileData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? username;
  String email = "null";
  String? dob;
  String? phone;
  String avatar = "null";
  String socialLoginId = "null";
  String socialLoginType = "null";
  String firstName = "null";
  String lastName = "";
  String gender = "";
  String websiteUrl = "";
  String? bio;
  String youtube = "";
  String facebook = "";
  String instagram = "";
  String twitter = "";
  String? firebaseToken;
  String? referralCount;
  String? following;
  String? followers;
  String? likes;
  String? isVerified;
  Levels? levels;
  String? totalVideos;
  String? boxTwo;
  String? boxThree;
  String? referralCode;

  User(
      {this.id,
      this.name,
      this.username,
      required this.email,
      this.dob,
      this.phone,
      required this.avatar,
      required this.socialLoginId,
      required this.socialLoginType,
      required this.firstName,
      required this.lastName,
      required this.gender,
      required this.websiteUrl,
      this.bio,
      required this.youtube,
      required this.facebook,
      required this.instagram,
      required this.twitter,
      this.firebaseToken,
      this.referralCount,
      this.following,
      this.followers,
      this.likes,
      this.isVerified,
      this.levels,
      this.totalVideos,
      this.boxTwo,
      this.boxThree,
      this.referralCode});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    dob = json['dob'] ?? "";
    phone = json['phone'];
    avatar = json['avatar'] ?? "";
    socialLoginId = json['social_login_id'] ?? "";
    socialLoginType = json['social_login_type'] ?? "";
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    gender = json['gender'] ?? "";
    websiteUrl = json['website_url'] ?? "";
    bio = json['bio'] ?? '';
    youtube = json['youtube'] ?? "";
    facebook = json['facebook'] ?? "";
    instagram = json['instagram'] ?? "";
    twitter = json['twitter'] ?? "";
    firebaseToken = json['firebase_token'] ?? "";
    referralCount = json['referral_count'] ?? "0";
    following = json['following'] ?? "0";
    followers = json['followers'] ?? "0";
    likes = json['likes'] ?? "0";
    isVerified = json['is_verified'] ?? '';
    levels =
        json['levels'] != null ? new Levels.fromJson(json['levels']) : null;
    totalVideos = json['total_videos'] ?? "0";
    boxTwo = json['box_two'] ?? '';
    boxThree = json['box_three'] ?? '';
    referralCode = json['referral_code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['dob'] = this.dob;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    data['social_login_id'] = this.socialLoginId;
    data['social_login_type'] = this.socialLoginType;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['website_url'] = this.websiteUrl;
    data['bio'] = this.bio;
    data['youtube'] = this.youtube;
    data['facebook'] = this.facebook;
    data['instagram'] = this.instagram;
    data['twitter'] = this.twitter;
    data['firebase_token'] = this.firebaseToken;
    data['referral_count'] = this.referralCount;
    data['following'] = this.following;
    data['followers'] = this.followers;
    data['likes'] = this.likes;
    data['is_verified'] = this.isVerified;
    if (this.levels != null) {
      data['levels'] = this.levels!.toJson();
    }
    data['total_videos'] = this.totalVideos;
    data['box_two'] = this.boxTwo;
    data['box_three'] = this.boxThree;
    data['referral_code'] = this.referralCode;
    return data;
  }
}

class Levels {
  String? current;
  String? next;
  String? progress;
  String? maxLevel;

  Levels({this.current, this.next, this.progress, this.maxLevel});

  Levels.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    next = json['next'];
    progress = json['progress'];
    maxLevel = json['max_level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current'] = this.current;
    data['next'] = this.next;
    data['progress'] = this.progress;
    data['max_level'] = this.maxLevel;
    return data;
  }
}