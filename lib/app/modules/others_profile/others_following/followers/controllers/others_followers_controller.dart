import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../rest/models/followers_model.dart';
import '../../../../../rest/rest_urls.dart';
import '../../../../../utils/utils.dart';

class OtherFollowersController extends GetxController  with StateMixin<RxList<Followers>> {
  //TODO: Implement FollowersController
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  var followersModel = RxList<Followers>();

  @override
  void onInit() {
    super.onInit();
    getUserFollowers();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getUserFollowers() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(followersModel, status: RxStatus.loading());
    if (followersModel.isNotEmpty) followersModel.clear();

    dio.post('user/get-followers', queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((result) {
      followersModel = FollowersModel.fromJson(result.data).data!.obs;
      change(followersModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(followersModel, status: RxStatus.error());
    });
  }
  Future<void> followUnfollowUser(
      int userId,String action
      ) async{

    dio.options.headers={
      "Authorization":"Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user",queryParameters: {"publisher_user_id":userId,"action":"$action"}).then((value) {
      if(value.data["status"]) {
        getUserFollowers();
      }
      else{
        errorToast("sorry an error has occurred");
      }
    }).onError((error, stackTrace) {});
  }
}