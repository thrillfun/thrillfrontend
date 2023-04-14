class SoundDetailsModel {
  bool? status;
  SoundDetails? data;
  String? message;
  bool? error;

  SoundDetailsModel({this.status, this.data, this.message, this.error});

  SoundDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new SoundDetails.fromJson(json['data']) : null;
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class SoundDetails {
  int? id;
  String? sound;
  int? userId;
  String? category;
  String? name;
  String? thumbnail;
  String? createdAt;
  String? updatedAt;
  int? soundUsedCount;
  SoundOwner? soundOwner;

  SoundDetails(
      {this.id,
        this.sound,
        this.userId,
        this.category,
        this.name,
        this.thumbnail,
        this.createdAt,
        this.updatedAt,
        this.soundUsedCount,
        this.soundOwner});

  SoundDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sound = json['sound']??"";
    userId = json['user_id']??0;
    category = json['category']??"";
    name = json['name']??"";
    thumbnail = json['thumbnail']??"";
    createdAt = json['created_at']??0;
    updatedAt = json['updated_at']??0;
    soundUsedCount = json['sound_used_count']??0;
    soundOwner = json['sound_owner'] != null
        ? new SoundOwner.fromJson(json['sound_owner'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sound'] = this.sound;
    data['user_id'] = this.userId;
    data['category'] = this.category;
    data['name'] = this.name;
    data['thumbnail'] = this.thumbnail;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['sound_used_count'] = this.soundUsedCount;
    if (this.soundOwner != null) {
      data['sound_owner'] = this.soundOwner!.toJson();
    }
    return data;
  }
}

class SoundOwner {
  int? id;
  String? name;
  String? username;
  String? email;
  String? dob;
  String? emailVerifiedAt;
  String? phone;
  String? avtars;
  String? location;
  String? coverImage;
  String? rating;
  String? notification;
  String? twoFAToggle;
  String? status;
  int? deactivationRequest;
  int? role;
  String? socialLoginId;
  String? socialLoginType;
  String? referralCode;
  String? firebaseToken;
  int? systemActive;
  String? activeDate;
  int? spinWallet;
  String? createdAt;
  String? updatedAt;
  int? isVerified;
  int? followingCount;
  int? followersCount;

  SoundOwner(
      {this.id,
        this.name,
        this.username,
        this.email,
        this.dob,
        this.emailVerifiedAt,
        this.phone,
        this.avtars,
        this.location,
        this.coverImage,
        this.rating,
        this.notification,
        this.twoFAToggle,
        this.status,
        this.deactivationRequest,
        this.role,
        this.socialLoginId,
        this.socialLoginType,
        this.referralCode,
        this.firebaseToken,
        this.systemActive,
        this.activeDate,
        this.spinWallet,
        this.createdAt,
        this.updatedAt,
        this.isVerified,
        this.followingCount,
        this.followersCount});

  SoundOwner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    dob = json['dob'];
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    avtars = json['avtars'];
    location = json['location'];
    coverImage = json['cover_image'];
    rating = json['rating'];
    notification = json['notification'];
    twoFAToggle = json['two_FA_toggle'];
    status = json['status'];
    deactivationRequest = json['deactivation_request'];
    role = json['role'];
    socialLoginId = json['social_login_id'];
    socialLoginType = json['social_login_type'];
    referralCode = json['referral_code'];
    firebaseToken = json['firebase_token'];
    systemActive = json['system_active'];
    activeDate = json['active_date'];
    spinWallet = json['spin_wallet'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isVerified = json['is_verified'];
    followingCount = json['following_count'];
    followersCount = json['followers_count'];
  }

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
    data['location'] = this.location;
    data['cover_image'] = this.coverImage;
    data['rating'] = this.rating;
    data['notification'] = this.notification;
    data['two_FA_toggle'] = this.twoFAToggle;
    data['status'] = this.status;
    data['deactivation_request'] = this.deactivationRequest;
    data['role'] = this.role;
    data['social_login_id'] = this.socialLoginId;
    data['social_login_type'] = this.socialLoginType;
    data['referral_code'] = this.referralCode;
    data['firebase_token'] = this.firebaseToken;
    data['system_active'] = this.systemActive;
    data['active_date'] = this.activeDate;
    data['spin_wallet'] = this.spinWallet;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_verified'] = this.isVerified;
    data['following_count'] = this.followingCount;
    data['followers_count'] = this.followersCount;
    return data;
  }
}
