import 'package:thrill/models/level_model.dart';

class UserModel {
  int id;
  String name, facebook, firebase_token;
  String phone, youtube, instagram;
  String dob, bio, twitter;
  String social_login_type;
  String social_login_id;
  String avatar, website_url;
  String email, gender;
  String username, first_name, last_name;
  String referral_count,
      following,
      followers,
      likes,
      total_videos,
      box_two,
      box_three;
  LevelModel levels;
  String is_verified;
  String referral_code;

  UserModel(
      this.id,
      this.name,
      this.phone,
      this.avatar,
      this.dob,
      this.social_login_type,
      this.social_login_id,
      this.email,
      this.facebook,
      this.firebase_token,
      this.youtube,
      this.instagram,
      this.bio,
      this.twitter,
      this.website_url,
      this.gender,
      this.first_name,
      this.last_name,
      this.username,
      this.referral_count,
      this.following,
      this.followers,
      this.likes,
      this.total_videos,
      this.box_two,
      this.box_three,
      this.levels,
      this.is_verified,
      this.referral_code,
      );

  factory UserModel.fromJson(dynamic json) {
    LevelModel levels;
    levels = LevelModel.fromJson(json['levels'] ?? {});
    return UserModel(
        json['id'] ?? 0,
        json['name'] ?? '',
        json['phone'] ?? '',
        json['avatar'] ?? '',
        json['dob'] ?? '',
        json['social_login_type']?? '',
        json['social_login_id'] ?? '',
        json['email'] ?? '',
        json['facebook'] ?? '',
        json['firebase_token'] ?? '',
        json['youtube'] ?? '',
        json['instagram'] ?? '',
        json['bio'] ?? '',
        json['twitter'] ?? '',
        json['website_url'] ?? '',
        json['gender'] ?? '',
        json['first_name'] ?? '',
        json['last_name'] ?? '',
        json['username'] ?? '',
        json['referral_count'] ?? '',
        json['following'] ?? '0',
        json['followers'] ?? '0',
        json['likes'] ?? '0',
        json['total_videos'] ?? '',
        json['box_two'] ?? '',
        json['box_three'] ?? '',
        levels,
        json['is_verified'] ?? '0',
        json['referral_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['dob'] = dob;
    data['social_login_type'] = social_login_type;
    data['social_login_id'] = social_login_id;
    data['email'] = email;
    data['facebook'] = facebook;
    data['firebase_token'] = firebase_token;
    data['youtube'] = youtube;
    data['instagram'] = instagram;
    data['bio'] = bio;
    data['twitter'] = twitter;
    data['website_url'] = website_url;
    data['gender'] = gender;
    data['first_name'] = first_name;
    data['last_name'] = last_name;
    data['username'] = username;
    data['referral_count'] = referral_count;
    data['following'] = following;
    data['followers'] = followers;
    data['likes'] = likes;
    data['total_videos'] = total_videos;
    data['box_two'] = box_two;
    data['box_three'] = box_three;
    data['levels'] = levels.toJson();
    data['is_verified'] = is_verified;
    data['referral_code'] = referral_code;
    return data;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? facebook,
    String? firebase_token,
    String? phone,
    String? youtube,
    String? instagram,
    String? dob,
    String? bio,
    String? twitter,
    String? social_login_type,
    String? social_login_id,
    String? avatar,
    String? website_url,
    String? email,
    String? gender,
    String? username,
    String? first_name,
    String? last_name,
    String? referral_count,
    String? following,
    String? followers,
    String? likes,
    String? total_videos,
    String? box_two,
    String? box_three,
    LevelModel? levels,
    String? is_verified,
    String? referral_code,
  }) {
    return UserModel(
      id ?? this.id,
      name ?? this.name,
      facebook ?? this.facebook,
      firebase_token ?? this.firebase_token,
      phone ?? this.phone,
      youtube ?? this.youtube,
      instagram ?? this.instagram,
      dob ?? this.dob,
      bio ?? this.bio,
      twitter ?? this.twitter,
      social_login_type ?? this.social_login_type,
      social_login_id ?? this.social_login_id,
      avatar ?? this.avatar,
      website_url ?? this.website_url,
      email ?? this.email,
      gender ?? this.gender,
      username ?? this.username,
      first_name ?? this.first_name,
      last_name ?? this.last_name,
      referral_count ?? this.referral_count,
      following ?? this.following,
      followers ?? this.followers,
      likes ?? this.likes,
      total_videos ?? this.total_videos,
      box_two ?? this.box_two,
      box_three ?? this.box_three,
      levels ?? this.levels,
      is_verified ?? this.is_verified,
      referral_code ?? this.referral_code,
    );
  }
}
