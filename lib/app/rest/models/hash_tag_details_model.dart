class HashtagDetailsModel {
  bool? status;
  bool? error;
  String? message;
  List<HashtagRelatedVideos>? data;
  Pagination? pagination;

  HashtagDetailsModel(
      {this.status, this.error, this.message, this.data, this.pagination});

  HashtagDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <HashtagRelatedVideos>[];
      json['data'].forEach((v) {
        data!.add(new HashtagRelatedVideos.fromJson(v));
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

class HashtagRelatedVideos {
  int? id;
  String? video;
  String? description;
  String? sound;
  String? soundName;
  String? soundCategoryName;
  int? is_favorite_hasttag;
  String? filter;
  int? likes;
  int? views;
  String? gifImage;
  String? speed;
  int? comments;
  String? isCommentable;
  List<Hashtags>? hashtags;
  String? soundOwner;
  int? videoLikeStatus;
  int? soundId;
  User? user;

  HashtagRelatedVideos(
      {this.id,
      this.video,
      this.description,
      this.sound,
      this.soundName,
      this.soundCategoryName,
      this.is_favorite_hasttag,
      this.filter,
      this.likes,
      this.views,
      this.gifImage,
      this.isCommentable,
      this.speed,
      this.comments,
      this.hashtags,
      this.soundOwner,
      this.videoLikeStatus,
      this.user,
      this.soundId});

  HashtagRelatedVideos.fromJson(Map<String, dynamic> json) {
    id = json['id'] ;
    video = json['video'] ?? "";
    description = json['description'] ?? "";
    sound = json['sound'] ?? "";
    soundName = json['sound_name'] ?? "";
    soundCategoryName = json['sound_category_name'] ?? "";
    is_favorite_hasttag = json["is_favorite_hasttag"] ?? 0;
    filter = json['filter'] ?? "";
    likes = json['likes'] ?? 0;
    views = json['views'] ?? 0;
    gifImage = json['gif_image'] ?? "";
    speed = json['speed'] ?? "";
    comments = json['comments'] ?? 0;
    if (json['hashtags'] != null) {
      hashtags = <Hashtags>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(new Hashtags.fromJson(v));
      });
    }
    soundOwner = json['sound_owner'] ?? "";
    videoLikeStatus = json['video_like_status'] ?? 0;
    isCommentable = json['is_commentable'];

    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    soundId = json["sound_id"] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['video'] = this.video;
    data['description'] = this.description;
    data['sound'] = this.sound;
    data['sound_name'] = this.soundName;
    data['sound_category_name'] = this.soundCategoryName;
    data['is_favorite_hasttag'] = this.is_favorite_hasttag;
    data['filter'] = this.filter;
    data['likes'] = this.likes;
    data['views'] = this.views;
    data['gif_image'] = this.gifImage;
    data['speed'] = this.speed;
    data['comments'] = this.comments;
    data['is_commentable'] = this.isCommentable;

    if (this.hashtags != null) {
      data['hashtags'] = this.hashtags!.map((v) => v.toJson()).toList();
    }
    data['sound_owner'] = this.soundOwner;
    data['video_like_status'] = this.videoLikeStatus;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data["sound_id"] = this.soundId;
    return data;
  }
}

class Hashtags {
  int? id;
  String? name;

  Hashtags({this.id, this.name});

  Hashtags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? dob;
  String? phone;
  String? avatar;
  String? socialLoginId;
  String? socialLoginType;
  String? firstName;
  String? lastName;
  String? gender;
  String? websiteUrl;
  String? bio;
  String? youtube;
  String? facebook;
  String? instagram;
  String? twitter;
  String? firebaseToken;
  String? referralCount;
  String? following;
  String? followers;
  String? likes;
  Levels? levels;
  String? totalVideos;
  String? boxTwo;
  String? boxThree;
  int? isfollow;

  User(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.dob,
      this.phone,
      this.avatar,
      this.socialLoginId,
      this.socialLoginType,
      this.firstName,
      this.lastName,
      this.gender,
      this.websiteUrl,
      this.bio,
      this.youtube,
      this.facebook,
      this.instagram,
      this.twitter,
      this.firebaseToken,
      this.referralCount,
      this.following,
      this.followers,
      this.likes,
      this.levels,
      this.totalVideos,
      this.boxTwo,
      this.boxThree,
      this.isfollow});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? "";
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    dob = json['dob'] ?? "";
    phone = json['phone'] ?? "";
    avatar = json['avatar'] ?? "";
    socialLoginId = json['social_login_id'] ?? "";
    socialLoginType = json['social_login_type'] ?? "";
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    gender = json['gender'] ?? "";
    websiteUrl = json['website_url'] ?? "";
    bio = json['bio'] ?? "";
    youtube = json['youtube'] ?? "";
    facebook = json['facebook'] ?? "";
    instagram = json['instagram'] ?? "";
    twitter = json['twitter'] ?? "";
    firebaseToken = json['firebase_token'] ?? "";
    referralCount = json['referral_count'] ?? "";
    following = json['following'] ?? "";
    followers = json['followers'] ?? "";
    likes = json['likes'] ?? "";
    levels =
        json['levels'] != null ? new Levels.fromJson(json['levels']) : null;
    totalVideos = json['total_videos'] ?? 0;
    boxTwo = json['box_two'];
    boxThree = json['box_three'];
    isfollow = json["isfollow"] ?? 0;
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
    if (this.levels != null) {
      data['levels'] = this.levels!.toJson();
    }
    data['total_videos'] = this.totalVideos;
    data['box_two'] = this.boxTwo;
    data['box_three'] = this.boxThree;
    data["isfollow"] = this.isfollow;
    return data;
  }
}

class Levels {
  String? current;
  String? next;
  String? progress;

  Levels({this.current, this.next, this.progress});

  Levels.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    next = json['next'];
    progress = json['progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current'] = this.current;
    data['next'] = this.next;
    data['progress'] = this.progress;
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
