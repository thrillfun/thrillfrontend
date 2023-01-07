import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_url.dart';

import '../model/following_video_model.dart';
import '../model/public_videosModel.dart';

class FollowingVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {

  var dio = Dio(
      BaseOptions(baseUrl: RestUrl.baseUrl, responseType: ResponseType.json));
  var isLoading = false.obs;

  FollowingVideosController() {
  }

  
}
