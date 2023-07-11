class RelatedVideosModel {
  bool? status;
  String? message;
  List<RelatedVideos>? data;
  bool? error;
  Pagination? pagination;
  RelatedVideosModel({this.status, this.message, this.data, this.error, this.pagination});

  RelatedVideosModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <RelatedVideos>[];
      json['data'].forEach((v) {
        data!.add(new RelatedVideos.fromJson(v));
      });
    }
    error = json['error'];
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class RelatedVideos {
  int? id;
  String? video;
  String? description;
  int? soundId;
  String? sound;
  String? soundName;
  String? soundCategoryName;
  String? filter;
  int? likes;
  int? views;
  String? gifImage;
  String? speed;
  int? comments;
  List<Hashtags>? hashtags;
  String? isDuet;
  String? duetFrom;
  String? isDuetable;
  String? isCommentable;
  String? soundOwner;
  int? videoLikeStatus;
  User? user;

  RelatedVideos(
      {this.id,
      this.video,
      this.description,
      this.soundId,
      this.sound,
      this.soundName,
      this.soundCategoryName,
      this.filter,
      this.likes,
      this.views,
      this.gifImage,
      this.speed,
      this.comments,
      this.hashtags,
      this.isDuet,
      this.duetFrom,
      this.isDuetable,
      this.isCommentable,
      this.soundOwner,
      this.videoLikeStatus,
      this.user});

  RelatedVideos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    video = json['video'] ?? "";
    description = json['description'] ?? "";
    soundId = json['sound_id'];
    sound = json['sound'] ?? "";
    soundName = json['sound_name'] ?? "";
    soundCategoryName = json['sound_category_name'] ?? "";
    filter = json['filter'] ?? "";
    likes = json['likes'] ?? 0;
    views = json['views'] ?? 0;
    gifImage = json['gif_image'] ?? "";
    speed = json['speed'];
    comments = json['comments'] ?? 0;
    if (json['hashtags'] != null) {
      hashtags = <Hashtags>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(new Hashtags.fromJson(v));
      });
    }
    isDuet = json['is_duet'] ?? "";
    duetFrom = json['duet_from'] ?? "";
    isDuetable = json['is_duetable'] ?? "";
    isCommentable = json['is_commentable'] ?? "yes";
    soundOwner = json['sound_owner'] ?? "";
    videoLikeStatus = json['video_like_status'] ?? 0;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['video'] = this.video;
    data['description'] = this.description;
    data['sound_id'] = this.soundId;
    data['sound'] = this.sound;
    data['sound_name'] = this.soundName;
    data['sound_category_name'] = this.soundCategoryName;
    data['filter'] = this.filter;
    data['likes'] = this.likes;
    data['views'] = this.views;
    data['gif_image'] = this.gifImage;
    data['speed'] = this.speed;
    data['comments'] = this.comments;
    if (this.hashtags != null) {
      data['hashtags'] = this.hashtags!.map((v) => v.toJson()).toList();
    }
    data['is_duet'] = this.isDuet;
    data['duet_from'] = this.duetFrom;
    data['is_duetable'] = this.isDuetable;
    data['is_commentable'] = this.isCommentable;
    data['sound_owner'] = this.soundOwner;
    data['video_like_status'] = this.videoLikeStatus;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
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
  int? following;
  int? followers;
  int? isfollow;
  String? likes;
  Levels? levels;
  String? totalVideos;
  String? boxTwo;
  String? boxThree;

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
      this.isfollow,
      this.likes,
      this.levels,
      this.totalVideos,
      this.boxTwo,
      this.boxThree});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
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
    isfollow = json['isfollow'] ?? 0;
    likes = json['likes'] ?? "0";
    levels =
        json['levels'] != null ? new Levels.fromJson(json['levels']) : null;
    totalVideos = json['total_videos'] ?? "";
    boxTwo = json['box_two'] ?? "";
    boxThree = json['box_three'] ?? "";
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
    data['isfollow'] = this.isfollow;
    data['likes'] = this.likes;
    if (this.levels != null) {
      data['levels'] = this.levels!.toJson();
    }
    data['total_videos'] = this.totalVideos;
    data['box_two'] = this.boxTwo;
    data['box_three'] = this.boxThree;
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