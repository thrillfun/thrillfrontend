import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';

import '../../rest/rest_url.dart';

class HashtagVideosController extends GetxController
    with StateMixin<RxList<HashTagsDetails>> {
  RxList<HashTagsDetails> hashTagsDetailsList = RxList();
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> getVideosByHashTags(int hashTagId) async {
    change(hashTagsDetailsList, status: RxStatus.loading());
   
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    dio.post("/hashtag/get-videos-by-hashtag",
        queryParameters: {"hashtag_id": "$hashTagId"}).then((value) {
      hashTagsDetailsList = HashTagVideosModel.fromJson(value.data).data!.obs;
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(hashTagsDetailsList, status: RxStatus.error());
    });
  }
}
