import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../../rest/models/followers_model.dart';
import '../../../rest/models/search_model.dart' as search;
import '../../../rest/models/user_details_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../other_user_videos/controllers/other_user_videos_controller.dart';

class OthersProfileController extends GetxController with StateMixin<Rx<User>> {
  //TODO: Implement OthersProfileController
  var storage = GetStorage();
  var userProfile = User().obs;
  var otherUserProfile = User().obs;
  var isSimCardAvailable = true.obs;
  var followersModel = RxList<Followers>();
  var followersLoading = false.obs;
  var isFollowingVisible = false.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var profileId = Get.arguments["profileId"];
  var otherUserVideosController = Get.find<OtherUserVideosController>();
  RxList<search.SearchData> searchList = RxList();
  var isSuggestedLoading = false.obs;
  var isUserFollowed = false.obs;

  @override
  void onInit() {
    getUserProfile(Get.arguments["profileId"]);
    followUnfollowStatus(Get.arguments["profileId"]);
    searchHashtags("");
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

  Future<void> followUnfollowUser(int userId, String action) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value)async {
      if(action.toLowerCase()=="follow"){
        sendNotification(userProfile.value.firebaseToken??"",body: "${await GetStorage().read("userName")} started following you",title: "New Follower");
      }
      followUnfollowStatus(userId);
      searchHashtags("");
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
  Future<void> followUnfollowStatus(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-by-userid",
        queryParameters: {"user_id": userId}).then((value) {
      if (value.data["data"]["is_follow"] == 0) {
        isUserFollowed.value = false;
      } else {
        isUserFollowed.value = true;
      }
    }).onError((error, stackTrace) {
      Logger().e(error);
    });
  }

  Future<void> followUnfollowTopUser(int userId, String action) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) async {
      await searchHashtags("");
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> getUserProfile(int id) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    dio.post('/user/get-profile', queryParameters: {"id": id}).then((result) {
      userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
      followUnfollowStatus(userProfile.value.id!);
      change(userProfile, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(userProfile, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getUserProfileWithId(int id) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    if (await storage.read("token") == null ||
        await storage.read("userId") == null) {
      Get.toNamed(Routes.LOGIN);
    } else {
      dio.post('/user/get-profile', queryParameters: {"id": id}).then((result) {
        userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
  }

  Future<void> getFollowings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (followersModel.isNotEmpty) followersModel.clear();
    followersLoading.value = true;
    dio.post('user/get-followings', queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((result) {
      followersModel = FollowersModel.fromJson(result.data).data!.obs;
    }).onError((error, stackTrace) {});
  }

  Future<void> searchHashtags(String searchQuery) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    isSuggestedLoading = true.obs;
    dio.get("hashtag/search?search=$searchQuery").then((value) {
      searchList = search.SearchHashTagsModel.fromJson(value.data).data!.obs;
      searchList.refresh();
      isSuggestedLoading = false.obs;
    }).onError((error, stackTrace) {
      Logger().wtf(error);
      isSuggestedLoading = false.obs;
    });
  }

  Future<String> createDynamicLink(
      String id, String? type, String? name, String? avatar,
      {String? referal}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun?type=$type&id=$id&name=$name&something=$avatar&referal=$referal"),
      androidParameters: const AndroidParameters(
        packageName: 'com.thrill.media',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(parameters);

    return dynamicLink.toString();
  }
}
