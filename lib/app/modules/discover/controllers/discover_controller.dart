import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../../../rest/models/top_hashtags_videos_model.dart';

class DiscoverController extends GetxController with StateMixin<dynamic> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  final count = 0.obs;
  RxList<Tophashtagvideos> tophashtagvideosList = RxList();

  @override
  void onInit() {
    getTopHashTagVideos();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getTopHashTagVideos() async {
    change(tophashtagvideosList, status: RxStatus.loading());
    await dio.get("hashtag/top-hashtags-videos").then((value) {
      tophashtagvideosList =
          TopHashtagVideosModel.fromJson(value.data).data!.obs;
      change(tophashtagvideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(tophashtagvideosList, status: RxStatus.error(error.toString()));
    });
  }
}
