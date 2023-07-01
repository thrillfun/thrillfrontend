import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/models/hash_tag_details_model.dart';
import '../../../../rest/rest_urls.dart';

class HashTagsDetailsController extends GetxController
    with StateMixin<RxList<HashtagRelatedVideos>> {
  RxList<HashtagRelatedVideos> hashTagsDetailsList = RxList();

  var isFavouriteHastag = false.obs;
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getVideosByHashTags();

    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getVideosByHashTags() async {
    change(hashTagsDetailsList, status: RxStatus.loading());

    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    dio.post("hashtag/get-videos-by-hashtag", queryParameters: {
      "hashtag_id": "${await GetStorage().read("hashtagId")}"
    }).then((value) {
      hashTagsDetailsList = HashtagDetailsModel.fromJson(value.data).data!.obs;
      isFavouriteHastag.value =
          hashTagsDetailsList[0].is_favorite_hasttag == 0 ? false : true;
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(hashTagsDetailsList, status: RxStatus.error());
    });
  }

  Future<void> addHashtagToFavourite() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {
        "id": "${await GetStorage().read("hashtagId")}",
        "type": "hashtag",
        "action": isFavouriteHastag.value == true ? "0" : "1"
      },
    ).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
      getVideosByHashTags();
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
