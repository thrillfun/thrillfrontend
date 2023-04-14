import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/rest/models/sounds_model.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/models/favourites_model.dart';
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
  RxList<SongModel> localSoundsList = RxList();
  final OnAudioQuery audioQuery = OnAudioQuery();
  RxList<FavouriteSounds> favouriteSounds = RxList();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getLocalSounds();
    getSoundsList();
    getFavourites();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getLocalSounds() async {
    await audioQuery.permissionsRequest();
    localSoundsList.value = await audioQuery.querySongs();
  }

  Future<void> getSoundsList() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(soundsList, status: RxStatus.loading());
    dio.post("sound/list").then((value) {
      soundsList = SoundsModel.fromJson(value.data).data!.obs;
      change(soundsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      change(soundsList, status: RxStatus.error(error.toString()));
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

  Future<void> getFavourites() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.get('/favorite/user-favorites-list').then((value) {
      favouriteSounds = FavouritesModel.fromJson(value.data).data!.sounds!.obs;
    }).onError((error, stackTrace) {});
  }
}
