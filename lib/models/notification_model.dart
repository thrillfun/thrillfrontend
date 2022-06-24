class NotificationModel{
  String likes,comments,new_followers,mentions,direct_messages,video_from_accounts_you_follow,live_notification;

  NotificationModel(
      this.likes,
      this.comments,
      this.new_followers,
      this.mentions,
      this.direct_messages,
      this.video_from_accounts_you_follow,
      this.live_notification);

  factory NotificationModel.fromJson(dynamic json) {
    return NotificationModel(
        json['likes'] ?? '',
        json['comments'] ?? '',
        json['new_followers'] ?? '',
        json['mentions'] ?? '',
        json['direct_messages'] ?? '',
        json['video_from_accounts_you_follow'] ?? '',
        json['live_notification'] ?? ''
    );
  }

}