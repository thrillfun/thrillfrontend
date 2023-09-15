import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/user_videos_model.dart';
import '../../../../rest/rest_urls.dart';

class OtherUserVideosController extends GetxController
    with StateMixin<RxList<Videos>> {
  //TODO: Implement OtherUserVideosController

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var userVideos = RxList<Videos>();
  var scrollController = ScrollController();
  var currentPage = 1.obs;
  var nextPage = 2.obs;
  var nextPageUrl = "https://thrill.fun/api/video/user-videos?page=2".obs;
  @override
  void onInit() {
    getUserVideos();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getPaginationAllVideos(nextPage.value);
        // Bottom poistion
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

  Future<void> getUserVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userVideos, status: RxStatus.loading());
    dio.post('/video/user-videos', queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((response) {
      userVideos.clear();
      userVideos = UserVideosModel.fromJson(response.data).data!.obs;
      userVideos.removeWhere((element) => element.id == null);
      userVideos.refresh();

      change(userVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(userVideos, status: RxStatus.error());
    });
  }

  Future<void> getPaginationAllVideos(int page) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (userVideos.isEmpty) {
      change(userVideos, status: RxStatus.loading());
    }
    dio.post(nextPageUrl.value, queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((value) {
      if (nextPageUrl.isNotEmpty) {
        UserVideosModel.fromJson(value.data).data!.forEach((element) {
          userVideos.addIf(element.id != null, element);
        });
        userVideos.refresh();
      }
      nextPageUrl.value =
          UserVideosModel.fromJson(value.data).pagination!.nextPageUrl ?? "";
      currentPage.value =
          UserVideosModel.fromJson(value.data).pagination!.currentPage!;
      change(userVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }
}
