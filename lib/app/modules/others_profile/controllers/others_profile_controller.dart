import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../../rest/models/followers_model.dart';
import '../../../rest/models/user_details_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/utils.dart';
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

  @override
  void onInit() {
    getUserProfile();
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

  Future<void> followUnfollowUser(int userId, String action) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      getUserProfile();
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
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
      dio.post('/user/get-profile', queryParameters: {"id": "$profileId"}).then(
          (result) {
        userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
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
