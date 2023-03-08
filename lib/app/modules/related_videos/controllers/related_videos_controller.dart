import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/models/related_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RelatedVideosController extends GetxController {
  //TODO: Implement RelatedVideosController

  late VideoPlayerController videoPlayerController;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  RxList<RelatedVideos> relatedVideosList = RxList();
  var isLoading = false.obs;

  var isInitialised = false.obs;
  @override
  void onInit() {
    super.onInit();
    getAllVideos();

  }
  Future<void> getAllVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    //change(publicVideosList, status: RxStatus.loading());

    dio.get("/video/list").then((value) {
      if (relatedVideosList.isEmpty) {
        // change(relatedVideosList, status: RxStatus.loading());

        isLoading.value = true;
        relatedVideosList = RelatedVideosModel.fromJson(value.data).data!.obs;
        // change(relatedVideosList, status: RxStatus.success());
      } else {
        relatedVideosList.value =
            RelatedVideosModel.fromJson(value.data).data!.obs;
        // change(publicVideosList, status: RxStatus.success());
      }

      //  change(publicVideosList, status: RxStatus.success());
      isLoading.value = false;
    }).onError((error, stackTrace) {
      isLoading.value = false;
      //   change(publicVideosList, status: RxStatus.error());
    });
    isLoading.value = false;
  }

  Future<void> postVideoView(int videoId) async{
    dio.options.headers = {"Authorization":"Bearer ${await GetStorage().read("token")}"};
    
    dio.post("video/view",queryParameters: {
      "video_id": videoId
    }).then((value) {

      if(value.data["status"]){
        Logger().wtf("View posted successfully");

      }

    }).onError((error, stackTrace) {});

  }
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {

    super.onClose();
  }
}
