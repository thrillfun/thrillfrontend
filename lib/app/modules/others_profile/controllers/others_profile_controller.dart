import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../rest/models/user_details_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';

class OthersProfileController extends GetxController with StateMixin<Rx<User>> {
  //TODO: Implement OthersProfileController
  var storage = GetStorage();
  var userProfile = User().obs;
  var otherUserProfile = User().obs;
  var isSimCardAvailable = true.obs;

  var dio =Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  @override
  void onInit() {
    getUserProfile();
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
        "id": "${GetStorage().read("profileId")}"
      }).then((result) {
        userProfile =
            UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
  }
}
