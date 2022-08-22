import 'package:thrill/models/video_model.dart';

class NotificationModel{
  int id, userId;
  String title, body, createDate, updateDate, redirectType;
  VideoModel? videoModel;

  NotificationModel(
      this.id,
      this.userId,
      this.title,
      this.body,
      this.createDate,
      this.updateDate,
      this.redirectType,
      this.videoModel,
      );

  factory NotificationModel.fromJson(dynamic json) {
    VideoModel? vModel = json['redirect_type'].toString()=="video"
        || json['redirect_type'].toString()=="comment"?
    json['video_details']!=null?VideoModel.fromJson(json['video_details']):null:null;
    int _id = json['other_user_details']!=null?json['other_user_details']['id']:0;
    return NotificationModel(
        json['id'] ?? 0,
        _id,
        json['title'] ?? '',
        json['body'] ?? '',
        json['created_at'] ?? '',
        json['updated_at'] ?? '',
        json['redirect_type'] ?? '',
        vModel
    );
  }

}