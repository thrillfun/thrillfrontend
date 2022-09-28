class VideoPostResponse {
  bool? status;
  Data? data;
  String? message;
  bool? error;

  VideoPostResponse({this.status, this.data, this.message, this.error});

  VideoPostResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  String? userId;
  String? video;
  String? sound;
  String? soundName;
  String? filter;
  String? language;
  String? category;
  String? hashtags;
  String? visibility;
  String? isCommentAllowed;
  String? description;
  String? gifImage;
  String? speed;
  String? isDuetable;
  String? soundOwner;
  String? isDuet;
  String? isCommentable;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.userId,
      this.video,
      this.sound,
      this.soundName,
      this.filter,
      this.language,
      this.category,
      this.hashtags,
      this.visibility,
      this.isCommentAllowed,
      this.description,
      this.gifImage,
      this.speed,
      this.isDuetable,
      this.soundOwner,
      this.isDuet,
      this.isCommentable,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']??"";
    video = json['video']??"";
    sound = json['sound']??"";
    soundName = json['sound_name']??"";
    filter = json['filter']??"";
    language = json['language']??"";
    category = json['category']??"";
    hashtags = json['hashtags']??"";
    visibility = json['visibility']??"";
    isCommentAllowed = json['is_comment_allowed']??"";
    description = json['description']??"";
    gifImage = json['gif_image']??"";
    speed = json['speed']??"";
    isDuetable = json['is_duetable']??"";
    soundOwner = json['sound_owner']??"";
    isDuet = json['is_duet']??"";
    isCommentable = json['is_commentable']??"";
    updatedAt = json['updated_at']??"";
    createdAt = json['created_at']??"";
    id = json['id']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['video'] = this.video;
    data['sound'] = this.sound;
    data['sound_name'] = this.soundName;
    data['filter'] = this.filter;
    data['language'] = this.language;
    data['category'] = this.category;
    data['hashtags'] = this.hashtags;
    data['visibility'] = this.visibility;
    data['is_comment_allowed'] = this.isCommentAllowed;
    data['description'] = this.description;
    data['gif_image'] = this.gifImage;
    data['speed'] = this.speed;
    data['is_duetable'] = this.isDuetable;
    data['sound_owner'] = this.soundOwner;
    data['is_duet'] = this.isDuet;
    data['is_commentable'] = this.isCommentable;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
