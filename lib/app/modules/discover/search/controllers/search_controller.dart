import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
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

  Future<void> followUnfollowUser(
    int userId,
    String action, {
    String? searchQuery,
    String fcmToken = "",
    String image = "",
    String name = "",
  }) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      if (value.data["status"]) {
        if (action == "follow") {
          sendNotification(fcmToken,
              body: "$name started following you!",
              title: "New follower!",
              image: image);
        }
        searchHashtags(searchQuery ?? "");
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
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
        "url": image,
        "body": body,
        "title": title,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image": image
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> addSoundToFavourite(int id, String action) async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {"id": id, "type": "sound", "action": action},
    ).then((value) {
      if (value.data["status"]) {
        searchHashtags("");
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
