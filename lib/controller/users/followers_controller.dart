import 'package:get/state_manager.dart';
import "package:dio/dio.dart";
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';

import '../../rest/rest_url.dart';
import '../model/followers_model.dart';

class FollowersController extends GetxController
    with StateMixin<RxList<Followers>> {
  var followersModel = RxList<Followers>();
  var followingModel = RxList<Followers>();
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> getUserFollowers(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(followersModel, status: RxStatus.loading());
    if (followersModel.isNotEmpty) followersModel.clear();

    dio
        .post('${RestUrl.baseUrl}/user/get-followers',
            queryParameters: {"user_id": "$userId"})
        .then((result) {
          followersModel = FollowersModel.fromJson(result.data).data!.obs;
          change(followersModel, status: RxStatus.success());
        })
        .onError((error, stackTrace) {
          change(followersModel, status: RxStatus.error());
        });
  }

  getUserFollowing(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(followingModel, status: RxStatus.loading());
    if (followingModel.isNotEmpty) followersModel.clear();

    dio
        .post('/user/get-followings', queryParameters: {"user_id": "$userId"})
        .then((result) {
          if (followingModel.isNotEmpty) {
            followingModel.value =
                FollowersModel.fromJson(result.data).data!.obs;
          } else {
            followingModel = FollowersModel.fromJson(result.data).data!.obs;
          }
          change(followersModel, status: RxStatus.success());
        })
        .onError((error, stackTrace) {
          change(followersModel, status: RxStatus.error());
        });
  }
}
