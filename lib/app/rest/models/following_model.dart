class FollowingModel {
  bool? status;
  bool? error;
  String? message;
  List<Following>? data;
  Pagination? pagination;

  FollowingModel(
      {this.status, this.error, this.message, this.data, this.pagination});

  FollowingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Following>[];
      json['data'].forEach((v) {
        data!.add(new Following.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Following {
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
  String? createdAt;
  String? updatedAt;
  int? isVerified;
  int? isFolling;
  int? isFollowing;

  Following(
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
      this.createdAt,
      this.updatedAt,
      this.isVerified,
      this.isFolling,
      this.isFollowing});

  Following.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'];
    username = json['username'];
    email = json['email'] ?? "";
    dob = json['dob'] ?? "";
    emailVerifiedAt = json['email_verified_at'] ?? "";
    phone = json['phone'] ?? "";
    avtars = json['avtars'] ?? "";
    location = json['location'] ?? "";
    coverImage = json['cover_image'] ?? "";
    rating = json['rating'] ?? "";
    notification = json['notification'] ?? "";
    twoFAToggle = json['two_FA_toggle'] ?? "";
    status = json['status'] ?? "";
    deactivationRequest = json['deactivation_request'] ?? 0;
    role = json['role'] ?? 0;
    socialLoginId = json['social_login_id'] ?? "";
    socialLoginType = json['social_login_type'] ?? "";
    referralCode = json['referral_code'] ?? "";
    firebaseToken = json['firebase_token'] ?? "";
    systemActive = json['system_active'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    isVerified = json['is_verified'] ?? 0;
    isFolling = json['isfollow_count'] ?? 0;
    // isFollowing = json['isFolling'] ?? 0;
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_verified'] = this.isVerified;
    data['isfollow_count'] = this.isFolling;
    //   data["isFolling"] = this.isFollowing;

    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  String? firstPageUrl;
  String? nextPageUrl;

  Pagination(
      {this.currentPage,
      this.lastPage,
      this.perPage,
      this.total,
      this.firstPageUrl,
      this.nextPageUrl});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
    firstPageUrl = json['first_page_url'];
    nextPageUrl = json['next_page_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    data['first_page_url'] = this.firstPageUrl;
    data['next_page_url'] = this.nextPageUrl;
    return data;
  }
}
