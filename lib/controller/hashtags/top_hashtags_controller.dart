import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';

class TopHashtagsController extends GetxController
    with StateMixin<RxList<HashTags>> {
  RxList<HashTags> topHashtagsList = RxList();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));


  @override
  void onInit() {
    super.onInit();
    change(topHashtagsList,status: RxStatus.loading());

  }

  getTopHashTags() async {

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    try {
      dio.get("/hashtag/top-hashtags-videos").then((value) {
        topHashtagsList = TopHastagVideosModel.fromJson(value.data).data!.obs;
        change(topHashtagsList, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(topHashtagsList, status: RxStatus.error());
      });
    } on Exception catch (e) {
      change(topHashtagsList, status: RxStatus.empty());
    }
    if (topHashtagsList.isEmpty) {
      change(topHashtagsList, status: RxStatus.empty());
    }
  }
}
