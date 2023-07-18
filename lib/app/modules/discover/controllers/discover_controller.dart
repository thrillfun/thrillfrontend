import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../../../rest/models/all_hashtags_model.dart';
import '../../../rest/models/top_hashtags_videos_model.dart';

class DiscoverController extends GetxController
    with StateMixin<RxList<Tophashtagvideos>> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  final count = 0.obs;
  RxList<Tophashtagvideos> tophashtagvideosList = RxList();
  RxList<AllHashtags> allHashtagsList = RxList();
  var callApi = false.obs;
  var nextPageUrl =
      "https://thrill.fun/api/hashtag/top-hashtags-videos?page=1".obs;

  @override
  void onInit() {
    //getTopHashTagVideos();
    getAllHashtags();
    ever(callApi, (callback) {
      if (callApi.isTrue) {
        getPaginationTopHashTagVideos();
      }
    });

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

  Future<void> getTopHashTagVideos() async {
    change(tophashtagvideosList, status: RxStatus.loading());

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    await dio.get("hashtag/top-hashtags-videos").then((value) {
      tophashtagvideosList =
          TopHashtagVideosModel.fromJson(value.data).data!.obs;
      nextPageUrl.value =
          TopHashtagVideosModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      change(tophashtagvideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(tophashtagvideosList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getPaginationTopHashTagVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (tophashtagvideosList.isEmpty) {
      change(tophashtagvideosList, status: RxStatus.loading());
    }
    dio.get(nextPageUrl.value).then((value) {
      nextPageUrl.value =
          TopHashtagVideosModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      if (nextPageUrl.isNotEmpty) {
        tophashtagvideosList
            .addAll(TopHashtagVideosModel.fromJson(value.data).data!);
      }
      tophashtagvideosList.refresh();

      change(tophashtagvideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }

  Future<void> getAllHashtags() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.get("hashtag/list").then((value) {
      allHashtagsList = AllHashtagsModel.fromJson(value.data).data!.obs;
      change(tophashtagvideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(tophashtagvideosList, status: RxStatus.error(error.toString()));
    });
  }
}
