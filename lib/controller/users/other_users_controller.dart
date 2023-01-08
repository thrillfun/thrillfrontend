import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/user_details_model.dart';

import '../../rest/rest_url.dart';

class OtherUsersController extends GetxController with StateMixin<Rx<User>> {
  var otherUserProfile = User().obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  Future<void> getOtherUserProfile(userId) async {
    change(otherUserProfile, status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post('/user/get-profile', queryParameters: {"id": userId}).then(
        (result) {
          otherUserProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
      change(otherUserProfile, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(otherUserProfile, status: RxStatus.error(error.toString()));
    });
  }


}
