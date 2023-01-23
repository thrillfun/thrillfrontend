import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/search_hash_tags_model.dart' as search;

import '../../rest/rest_url.dart';

class SearchHashtagsController extends GetxController
    with StateMixin<RxList<search.Data>> {
  RxList<search.Data> searchList = RxList();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> searchHashtags(String searchQuery) async {
    change(searchList, status: RxStatus.loading());

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get("/hashtag/search?search=$searchQuery").then(
        (value) {
      searchList = search.SearchHashTagsModel.fromJson(value.data).data!.obs;
      change(searchList, status: RxStatus.success());

        }).onError((error, stackTrace) {
      change(searchList, status: RxStatus.error(error.toString()));
    });
  }
}
