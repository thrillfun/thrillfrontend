class FavouritesModel {
  bool? status;
  Favourites? data;
  String? message;
  bool? error;

  FavouritesModel({this.status, this.data, this.message, this.error});

  FavouritesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Favourites.fromJson(json['data']) : null;
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

class Favourites {
  List<FavouriteVideos>? videos;
  List<FavouriteSounds>? sounds;
  List<FavouriteHashTags>? hashTags;

  Favourites({this.videos, this.sounds, this.hashTags});

  Favourites.fromJson(Map<String, dynamic> json) {
    if (json['videos'] != null) {
      videos = <FavouriteVideos>[];
      json['videos'].forEach((v) {
        videos!.add(new FavouriteVideos.fromJson(v));
      });
    }
    if (json['sounds'] != null) {
      sounds = <FavouriteSounds>[];
      json['sounds'].forEach((v) {
        sounds!.add(new FavouriteSounds.fromJson(v));
      });
    }
    if (json['hash_tags'] != null) {
      hashTags = <FavouriteHashTags>[];
      json['hash_tags'].forEach((v) {
        hashTags!.add(new FavouriteHashTags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.videos != null) {
      data['videos'] = this.videos!.map((v) => v.toJson()).toList();
    }
    if (this.sounds != null) {
      data['sounds'] = this.sounds!.map((v) => v.toJson()).toList();
    }
    if (this.hashTags != null) {
      data['hash_tags'] = this.hashTags!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FavouriteVideos {
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
  List<dynamic>? hashtags;
  FavouriteUser? user;

  FavouriteVideos(
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
        this.user});

  FavouriteVideos.fromJson(Map<String, dynamic> json) {
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
    hashtags = json['hashtags']??[];
    user = json['user'] != null ? new FavouriteUser.fromJson(json['user']) : null;
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
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class FavouriteUser {
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

  FavouriteUser(
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

  FavouriteUser.fromJson(Map<String, dynamic> json) {
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

class FavouriteSounds {
  int? id;
  String? sound;
  int? userId;
  String? category;
  String? name;
  String? thumbnail;
  String? createdAt;
  String? updatedAt;
  User? user;


  FavouriteSounds(
      {this.id,
        this.sound,
        this.userId,
        this.category,
        this.name,
        this.thumbnail,
        this.createdAt,
        this.updatedAt,
        this.user});

  FavouriteSounds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sound = json['sound'];
    userId = json['user_id'];
    category = json['category'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
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
  String? dob;
  String? phone;
  String? avatar;
  String? socialLoginId;
  String? socialLoginType;
  String? firebaseToken;
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


class FavouriteHashTags {
  int? id;
  int? userId;
  String? name;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  FavouriteHashTags(
      {this.id,
        this.userId,
        this.name,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  FavouriteHashTags.fromJson(Map<String, dynamic> json) {
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