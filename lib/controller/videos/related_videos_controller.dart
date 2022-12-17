import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/rest/rest_url.dart';

class RelatedVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {
  RxList<PublicVideos> publicVideosList = RxList();
  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
     
      responseType: ResponseType.json));

  RelatedVideosController() {
    getAllVideos();
  }
  Future<void> getAllVideos() async {
        dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
    change(publicVideosList, status: RxStatus.loading());
    dio.get("/video/list").then((value) {
      if (publicVideosList.isEmpty) {
        publicVideosList = PublicVideosModel.fromJson(value.data).data!.obs;
      } else {
        publicVideosList.value =
            PublicVideosModel.fromJson(value.data).data!.obs;
      }
      change(publicVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(publicVideosList, status: RxStatus.error());
      change(publicVideosList, status: RxStatus.empty());
    });
    if (publicVideosList.isEmpty)change(publicVideosList, status: RxStatus.empty());
  }
}
