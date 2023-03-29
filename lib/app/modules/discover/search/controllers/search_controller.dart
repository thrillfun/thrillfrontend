import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/models/search_model.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/rest_urls.dart';

class SearchController extends GetxController
    with StateMixin<RxList<SearchData>> {
  RxList<SearchData> searchList = RxList();
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    super.onInit();
    searchHashtags("");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> searchHashtags(String searchQuery) async {
    change(searchList, status: RxStatus.loading());

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get("hashtag/search?search=$searchQuery").then((value) {
      searchList = SearchHashTagsModel.fromJson(value.data).data!.obs;
      change(searchList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(searchList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> followUnfollowUser(int userId, String action,
      {String? searchQuery}) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      if (value.data["status"]) {
        searchHashtags(searchQuery ?? "");
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }
}
