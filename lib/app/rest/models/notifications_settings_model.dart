class NotificationsSettingsModel {
  bool? status;
  Data? data;
  String? message;
  bool? error;

  NotificationsSettingsModel(
      {this.status, this.data, this.message, this.error});

  NotificationsSettingsModel.fromJson(Map<String, dynamic> json) {
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
  String? likes;
  String? comments;
  String? newFollowers;
  String? mentions;
  String? directMessages;
  String? videoFromAccountsYouFollow;
  String? liveNotification;

  Data(
      {this.likes,
        this.comments,
        this.newFollowers,
        this.mentions,
        this.directMessages,
        this.videoFromAccountsYouFollow,
        this.liveNotification});

  Data.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    comments = json['comments'];
    newFollowers = json['new_followers'];
    mentions = json['mentions'];
    directMessages = json['direct_messages'];
    videoFromAccountsYouFollow = json['video_from_accounts_you_follow'];
    liveNotification = json['live_notification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['likes'] = this.likes;
    data['comments'] = this.comments;
    data['new_followers'] = this.newFollowers;
    data['mentions'] = this.mentions;
    data['direct_messages'] = this.directMessages;
    data['video_from_accounts_you_follow'] = this.videoFromAccountsYouFollow;
    data['live_notification'] = this.liveNotification;
    return data;
  }
}