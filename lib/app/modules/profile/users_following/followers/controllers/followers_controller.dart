import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../../../../rest/models/followers_model.dart';
import '../../../../../rest/rest_urls.dart';
import '../../../../../utils/utils.dart';

class FollowersController extends GetxController
    with StateMixin<RxList<Followers>> {
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
      "user_id": "${await GetStorage().read("userId")}"
    }).then((result) {
      followersModel = FollowersModel.fromJson(result.data).data!.obs;
      change(followersModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(followersModel, status: RxStatus.error());
    });
  }

  Future<void> followUnfollowUser(
      int userId,String action,{
        String fcmToken="",
        String image="",
        String name="",
  }
      ) async{

    dio.options.headers={
      "Authorization":"Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user",queryParameters: {"publisher_user_id":userId,"action":"$action"}).then((value) {
      if(value.data["status"]) {
        if(action=="follow"){
          sendNotification(fcmToken,body: "$name started following you!",title: "New follower!",image: image);
        }
        else{
          sendNotification(fcmToken,body: "$name stopped following you!",title: "Follower lost",image: image);

        }
        getUserFollowers();
      }
      else{
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
  Future<void> sendNotification(String fcmToken,
      {String? body = "", String? title = "", String? image = ""}) async {
    var dio = Dio(BaseOptions(baseUrl: "https://fcm.googleapis.com/fcm"));
    dio.options.headers = {
      "Authorization":
      "key= AAAAzWymZ2o:APA91bGABMolgt7oiBiFeTU7aCEj_hL-HSLlwiCxNGaxkRl385anrsMMNLjuuqmYnV7atq8vZ5LCNBPt3lPNA1-0ZDKuCJHezvoRBpL9VGvixJ-HHqPScZlwhjeQJPhbsiLDSTtZK-MN"
    };
    final data = {
      "to": fcmToken,
      "notification": {"body": body, "title": title, "image": image},
      "priority": "high",
      "image": image,
      "data": {
        "url":image,
        "body":body,
        "title":title,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image":
        image
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
