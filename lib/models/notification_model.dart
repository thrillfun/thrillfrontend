class NotificationModel{
  int id, userId;
  String title, body, createDate, updateDate;

  NotificationModel(
      this.id,
      this.userId,
      this.title,
      this.body,
      this.createDate,
      this.updateDate,
      );

  factory NotificationModel.fromJson(dynamic json) {
    return NotificationModel(
        json['id'] ?? 0,
        json['user_id'] ?? 0,
        json['title'] ?? '',
        json['body'] ?? '',
        json['created_at'] ?? '',
        json['updated_at'] ?? '',
    );
  }

}