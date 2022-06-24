import 'dart:convert';

import 'package:thrill/repository/video/video_base_repository.dart';

import '../../rest/rest_api.dart';

class VideoRepository extends VideoBaseRepository{
  @override
  Future<dynamic> getVideo() async{
    try {
      var result = await RestApi.getAllVideo();
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> likeDislike(int videoId, int isLike)async {
    try {
      var result = await RestApi.likeAndDislike(videoId,isLike);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> followUnfollow(int publisherId, String action)async{
    try {
      var result = await RestApi.followUserAndUnfollow(publisherId,action);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

}