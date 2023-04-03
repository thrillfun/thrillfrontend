import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../rest/models/followers_model.dart';
import '../../../rest/models/user_details_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';

class ProfileController extends GetxController with StateMixin<Rx<User>> {
  var storage = GetStorage();
  var userProfile = User().obs;
  var otherUserProfile = User().obs;
  var isSimCardAvailable = true.obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var qrData = "".obs;
  var followersModel = RxList<Followers>();
  var followersLoading = false.obs;

  @override
  void onInit() {
    getUserProfile();
    getFollowings();
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      // launchUrl(Uri.parse(RestUrl.videoUrl + dynamicLinkData.link.path));
      if (dynamicLinkData.link.queryParameters["type"] == "referal") {
        await GetStorage().write(
            "referal", dynamicLinkData.link.queryParameters["id"].toString());
      }
    }).onError((error) {
      errorToast(error.toString());
    });
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

  Future<void> getUserProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    if (await storage.read("token") == null ||
        await storage.read("userId") == null) {
      Get.toNamed(Routes.LOGIN);
    } else {
      dio.post('/user/get-profile', queryParameters: {
        "id": "${GetStorage().read("userId")}"
      }).then((result) {
        userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
        update();
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
  }

  Future<void> getFollowings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    followersLoading.value = true;
    dio.post('user/get-followings', queryParameters: {
      "user_id": "${await GetStorage().read("userId")}"
    }).then((result) {
      followersLoading.value = false;
      followersModel = FollowersModel.fromJson(result.data).data!.obs;
    }).onError((error, stackTrace) {
      followersLoading.value = false;
    });
    followersLoading.value = false;
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
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }
}
