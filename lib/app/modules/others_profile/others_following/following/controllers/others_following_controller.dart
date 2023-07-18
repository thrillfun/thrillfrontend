import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../rest/models/followers_model.dart';
import '../../../../../rest/models/following_model.dart';
import '../../../../../rest/rest_urls.dart';
import '../../../../../utils/utils.dart';

class OthersFollowingController extends GetxController
    with StateMixin<RxList<Following>> {
//TODO: Implement FollowersController
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));
  var nextPageUrl = "https://thrill.fun/api/user/get-followings?page=1".obs;

  var followersModel = RxList<Following>();

  @override
  void onInit() {
    getFollowings();
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

  Future<void> getFollowings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(followersModel, status: RxStatus.loading());
    if (followersModel.isNotEmpty) followersModel.clear();

    dio.post('user/get-followings', queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((result) {
      followersModel = FollowingModel.fromJson(result.data).data!.obs;
      nextPageUrl.value =
          FollowingModel.fromJson(result.data).pagination!.nextPageUrl ?? "";

      change(followersModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(followersModel, status: RxStatus.error());
    });
  }

  Future<void> getPaginationFollowing(int page) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (followersModel.isEmpty) {
      change(followersModel, status: RxStatus.loading());
    }
    dio.post(nextPageUrl.value, queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((value) {
      if (nextPageUrl.isNotEmpty) {
        FollowingModel.fromJson(value.data).data!.forEach((element) {
          followersModel.add(element);
        });
        followersModel.refresh();
      }
      nextPageUrl.value =
          FollowingModel.fromJson(value.data).pagination!.nextPageUrl ?? "";

      change(followersModel, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }

  Future<void> followUnfollowUser(int userId, String action) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      if (value.data["status"]) {
        getFollowings();
      } else {
        errorToast("sorry an error has occurred");
      }
    }).onError((error, stackTrace) {});
  }
}
