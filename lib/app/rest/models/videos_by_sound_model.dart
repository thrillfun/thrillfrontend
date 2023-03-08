class VideosBySoundModel {
  bool? status;
  bool? error;
  String? message;
  List<VideosBySound>? data;

  VideosBySoundModel({this.status, this.error, this.message, this.data});

  VideosBySoundModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VideosBySound>[];
      json['data'].forEach((v) {
        data!.add(new VideosBySound.fromJson(v));
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

class VideosBySound {
  int? id;
  String? video;
  String? description;
  String? sound;
  String? soundName;
  String? soundCategoryName;
  Null? filter;
  int? likes;
  int? views;
  String? gifImage;
  String? speed;
  int? comments;
  List<String>? hashtags;
  String? isDuet;
  Null? duetFrom;
  String? isDuetable;
  String? isCommentable;
  String? soundOwner;
  User? user;

  VideosBySound(
      {this.id,
        this.video,
        this.description,
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
        this.user});

  VideosBySound.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    video = json['video'];
    description = json['description'];
    sound = json['sound'];
    soundName = json['sound_name'];
    soundCategoryName = json['sound_category_name'];
    filter = json['filter'];
    likes = json['likes'];
    views = json['views'];
    gifImage = json['gif_image'];
    speed = json['speed'];
    comments = json['comments'];
    hashtags = json['hashtags'].cast<String>();
    isDuet = json['is_duet'];
    duetFrom = json['duet_from'];
    isDuetable = json['is_duetable'];
    isCommentable = json['is_commentable'];
    soundOwner = json['sound_owner'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['video'] = this.video;
    data['description'] = this.description;
    data['sound'] = this.sound;
    data['sound_name'] = this.soundName;
    data['sound_category_name'] = this.soundCategoryName;
    data['filter'] = this.filter;
    data['likes'] = this.likes;
    data['views'] = this.views;
    data['gif_image'] = this.gifImage;
    data['speed'] = this.speed;
    data['comments'] = this.comments;
    data['hashtags'] = this.hashtags;
    data['is_duet'] = this.isDuet;
    data['duet_from'] = this.duetFrom;
    data['is_duetable'] = this.isDuetable;
    data['is_commentable'] = this.isCommentable;
    data['sound_owner'] = this.soundOwner;
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
  String? email;
  Null? dob;
  String? phone;
  Null? avatar;
  String? socialLoginId;
  String? socialLoginType;
  Null? firstName;
  Null? lastName;
  Null? gender;
  Null? websiteUrl;
  Null? bio;
  Null? youtube;
  Null? facebook;
  Null? instagram;
  Null? twitter;
  Null? firebaseToken;
  String? referralCount;
  String? following;
  String? followers;
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
        this.likes,
        this.levels,
        this.totalVideos,
        this.boxTwo,
        this.boxThree});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    dob = json['dob'];
    phone = json['phone'];
    avatar = json['avatar'];
    socialLoginId = json['social_login_id'];
    socialLoginType = json['social_login_type'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    websiteUrl = json['website_url'];
    bio = json['bio'];
    youtube = json['youtube'];
    facebook = json['facebook'];
    instagram = json['instagram'];
    twitter = json['twitter'];
    firebaseToken = json['firebase_token'];
    referralCount = json['referral_count'];
    following = json['following'];
    followers = json['followers'];
    likes = json['likes'];
    levels =
    json['levels'] != null ? new Levels.fromJson(json['levels']) : null;
    totalVideos = json['total_videos'];
    boxTwo = json['box_two'];
    boxThree = json['box_three'];
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

