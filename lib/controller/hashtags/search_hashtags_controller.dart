import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/search_hash_tags_model.dart' as search;

import '../../rest/rest_url.dart';

class SearchHashtagsController extends GetxController
    with StateMixin<RxList<search.Data>> {
  RxList<search.Data> searchList = RxList();

  SearchHashtagsController() {
    searchHashtags("");
  }

  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
     ));

  searchHashtags(String searchQuery) async {
        dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
    change(searchList, status: RxStatus.loading());
    if (searchList.isNotEmpty) searchList.clear();
    
    dio.get("/hashtag/search/", queryParameters: {'search': searchQuery})
        .timeout(const Duration(seconds: 10))
        .then((value) {
          change(searchList, status: RxStatus.loading());
          change(searchList, status: RxStatus.success());
          searchList =
              search.SearchHashTagsModel.fromJson(value.data).data!.obs;
        })
        .onError((error, stackTrace) {
          change(searchList, status: RxStatus.error());
        });
    if (searchList.isEmpty) {
      change(searchList, status: RxStatus.empty());
    }
  }
}
