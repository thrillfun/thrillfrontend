import 'package:thrill/models/video_model.dart';

class DiscoverVideo{
  int hashtag_id,video_count;
  String hashtag_name;
  List<HashVideo> hashVideo;
  List<VideoModel> videoModel;


  DiscoverVideo(this.hashtag_id, this.video_count, this.hashtag_name,
      this.hashVideo,this.videoModel);

  factory DiscoverVideo.fromJson(dynamic json) {
    List<HashVideo> videoList=List<HashVideo>.empty(growable: true);
    List<VideoModel> videoModelList=List<VideoModel>.empty(growable: true);
    List jsonList= json['videos'] as List;
    videoList = jsonList.map((e) => HashVideo.fromJson(e)).toList();
    videoModelList = jsonList.map((e) => VideoModel.fromJson(e)).toList();
    return DiscoverVideo(
        json['hashtag_id']?? 0,
        json['video_count'] ?? 0,
        json['hashtag_name'] ?? '',
        videoList,
        videoModelList
    );
  }
}


class HashVideo{
  int id,user_id;
  int views,likes;
  String video,video_thumbnail,gif_image;

  HashVideo(this.id, this.user_id, this.video, this.video_thumbnail,this.gif_image,this.views,this.likes);

  factory HashVideo.fromJson(dynamic json) {
    return HashVideo(
        json['id']?? 0,
        json['user_id']?? 0,
        json['video'] ?? '',
        json['video_thumbnail'] ?? '',
        json['gif_image'] ?? '',
        json['views'] ?? 0,
        json['likes'] ?? 0
    );
  }

}