import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/models/sounds_model.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';

class SelectSoundController extends GetxController
    with StateMixin<RxList<Sounds>> {
  var storage = GetStorage();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  RxList<Sounds> soundsList = RxList();
  var fileSupport = FileSupport();
  var currentProgress = "0".obs;

  @override
  void onInit() {
    super.onInit();
    getSoundsList();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getSoundsList() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(soundsList,status: RxStatus.loading());
    dio.post("sound/list").then((value) {
      soundsList = SoundsModel.fromJson(value.data).data!.obs;
      change(soundsList,status: RxStatus.success());

    }).onError((error, stackTrace) {
      errorToast(error.toString());
      change(soundsList,status: RxStatus.error(error.toString()));

    });
  }
  downloadAudio(String soundUrl, String userName, String soundName,
      bool isFavourites) async {
    try {
      Get.defaultDialog(
          title: "Downloading audio",
          content: Obx(() => Text(currentProgress.value)));
      await fileSupport
          .downloadCustomLocation(
        url: "${RestUrl.awsSoundUrl}$soundUrl",
        path: saveCacheDirectory,
        filename: soundName,
        extension: ".mp3",
        progress: (progress) async {
          currentProgress.value = progress;
        },
      )
          .then((value) {
        // GetStorage().write("sound_path", value!.path);
        // GetStorage().write("sound_name", soundName);
        // GetStorage().write("sound_owner", userName);

        Get.toNamed(Routes.CAMERA, arguments: {
          "sound_url": value!.path,
          "sound_name": soundName,
          "sound_owner": userName
        });
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }
}
