import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/modules/profile/user_videos/controllers/user_videos_controller.dart';

import '../../../../rest/models/user_private_video_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/utils.dart';

class UserPrivateVideosController extends GetxController with StateMixin<RxList<PrivateVideos>> {
  RxList<PrivateVideos> privateVideosList = RxList();
  var storage = GetStorage();
  var userProfile = User().obs;

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    getUserPrivateVideos();
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

  getUserPrivateVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(privateVideosList, status: RxStatus.loading());
    dio.get('/video/private').then((value) {
      privateVideosList.value =
          UserPrivateVideosModel.fromJson(value.data).data!.obs;
      change(privateVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(privateVideosList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> deleteUserVideo(int videoId)async{
    dio.options.headers={"Authorization":"Bearer ${await GetStorage().read("token")}"};
    dio.post("video/delete",queryParameters: {
      "video_id":videoId
    }).then((value) {

      if(value.data["status"]){
        successToast(value.data["message"]);
        getUserPrivateVideos();
      }
      else{
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });

  }

  Future<void> makeVideoPrivateOrPublic(int videoId,String visibility)async{
    dio.options.headers={"Authorization":"Bearer ${await GetStorage().read("token")}"};
    dio.post("video/change-visibility",queryParameters: {
      "video_id":videoId,
      "visibility":visibility
    }).then((value) {

      if(value.data["status"]){
        Get.find<UserVideosController>().getUserVideos();
        getUserPrivateVideos();
      }
      else{
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }
}
