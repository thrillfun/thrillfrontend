class SearchHashTagsModel {
  bool? status;
  String? message;
  List<Data>? data;

  SearchHashTagsModel({this.status, this.message, this.data});

  SearchHashTagsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  List<VideosList>? videos;
  List<HashtagsList>? hashtags;
  List<UsersList>? users;
  List<SoundsList>? sounds;
  int? videoCount;

  Data(
      {this.id,
        this.name,
        this.videos,
        this.hashtags,
        this.users,
        this.sounds,
        this.videoCount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['videos'] != null) {
      videos = <VideosList>[];
      json['videos'].forEach((v) {
        videos!.add(new VideosList.fromJson(v));
      });
    }
    if (json['hashtags'] != null) {
      hashtags = <HashtagsList>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(new HashtagsList.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <UsersList>[];
      json['users'].forEach((v) {
        users!.add(new UsersList.fromJson(v));
      });
    }
    if (json['sounds'] != null) {
      sounds = <SoundsList>[];
      json['sounds'].forEach((v) {
        sounds!.add(new SoundsList.fromJson(v));
      });
    }
    videoCount = json['video_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.videos != null) {
      data['videos'] = this.videos!.map((v) => v.toJson()).toList();
    }
    if (this.hashtags != null) {
      data['hashtags'] = this.hashtags!.map((v) => v.toJson()).toList();
    }
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.sounds != null) {
      data['sounds'] = this.sounds!.map((v) => v.toJson()).toList();
    }
    data['video_count'] = this.videoCount;
    return data;
  }
}

class VideosList {
  int? id;
  String? video;
  String? description;
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
  int? totalview;
  int? soundId;
  UsersList? user;

  VideosList(
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
        this.videoLikeStatus,
        this.totalview,
        this.user,
      this.soundId});

  VideosList.fromJson(Map<String, dynamic> json) {
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
    if (json['hashtags'] != null) {
      hashtags = <Hashtags>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(new Hashtags.fromJson(v));
      });
    }
    isDuet = json['is_duet'];
    duetFrom = json['duet_from'];
    isDuetable = json['is_duetable'];
    isCommentable = json['is_commentable'];
    soundOwner = json['sound_owner'];
    videoLikeStatus = json['video_like_status'];
    totalview = json['totalview'];
    user = json['user'] != null ? new UsersList.fromJson(json['user']) : null;
    soundId = json["sound_id"];
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
    if (this.hashtags != null) {
      data['hashtags'] = this.hashtags!.map((v) => v.toJson()).toList();
    }
    data['is_duet'] = this.isDuet;
    data['duet_from'] = this.duetFrom;
    data['is_duetable'] = this.isDuetable;
    data['is_commentable'] = this.isCommentable;
    data['sound_owner'] = this.soundOwner;
    data['video_like_status'] = this.videoLikeStatus;
    data['totalview'] = this.totalview;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data["sound_id"] = this.soundId;
    return data;
  }
}

class HashtagsList {
  int? id;
  String? name;
  int? total;

  HashtagsList({this.id, this.name});

  HashtagsList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['hashtag'];
    total = json["total"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hashtag'] = this.name;
    data['total'] =this.total;
    return data;
  }
}

class UsersList {
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

  UsersList(
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

  UsersList.fromJson(Map<String, dynamic> json) {
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
    isfollow = json['isfollow'];
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

class Hashtags{
  int? id;
  int? userId;
  String? name;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  Hashtags(
      {this.id,
        this.userId,
        this.name,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  Hashtags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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

class User {
  int? id;
  String? name;
  String? username;

  User({this.id, this.name, this.username});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    return data;
  }
}

class SoundsList {
  int? id;
  String? sound;
  String? category;
  int? userId;
  SoundOwner? soundOwner;

  SoundsList({this.id, this.sound, this.category, this.userId, this.soundOwner});

  SoundsList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sound = json['sound'];
    category = json['category'];
    userId = json['user_id'];
    soundOwner = json['sound_owner'] != null
        ? new SoundOwner.fromJson(json['sound_owner'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sound'] = this.sound;
    data['category'] = this.category;
    data['user_id'] = this.userId;
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
    coverImage = json['cover_image'];
    rating = json['rating'];
    notification = json['notification'];
    twoFAToggle = json['two_FA_toggle'];
    status = json['status'];
    deactivationRequest = json['deactivation_request'];
    role = json['role'];
    socialLoginId = json['social_login_id'];
    socialLoginType = json['social_login_type'];
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
    data['following_count'] = this.followingCount;
    data['followers_count'] = this.followersCount;
    return data;
  }
}
