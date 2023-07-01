import 'package:device_info_plus/device_info_plus.dart';
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
import '../../../../rest/models/search_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';

class SelectSoundController extends GetxController with StateMixin<dynamic> {
  var storage = GetStorage();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  RxList<Sounds> soundsList = RxList();
  var fileSupport = FileSupport();
  var currentProgress = "0".obs;
  RxList<SongModel> localSoundsList = RxList();
  RxList<SongModel> localFilterList = RxList();
  final OnAudioQuery audioQuery = OnAudioQuery();
  RxList<FavouriteSounds> favouriteSounds = RxList();
  RxList<SearchData> searchList = RxList();

  @override
  void onInit() {
    getSoundsList();
    getFavourites();
    getLocalSounds();
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

  Future<void> getLocalSounds() async {
    List<SongModel> filterList = await audioQuery.querySongs();
    localSoundsList = filterList
        .where((element) => element.fileExtension.contains("mp3"))
        .toList()
        .obs;
    if (filterList.isNotEmpty) {
      localFilterList.value = localSoundsList.toList();
    } else {
      localFilterList = localSoundsList;
    }
    if (!await audioQuery.permissionsStatus()) {
      await audioQuery.permissionsRequest();
    }
  }

  Future<void> getSoundsList() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (soundsList.isEmpty) {
      change(soundsList, status: RxStatus.loading());
    }
    dio.post("sound/list").then((value) {
      if (soundsList.isEmpty) {
        soundsList = SoundsModel.fromJson(value.data).data!.obs;
      } else {
        soundsList.value = SoundsModel.fromJson(value.data).data!.obs;
      }
      change(soundsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      Logger().wtf(error);
      change(soundsList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> addSoundToFavourite(int soundId, String action) async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {"id": "$soundId", "type": "sound", "action": action},
    ).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
        getFavourites();
        getSoundsList();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
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
        Get.toNamed(Routes.CAMERA, arguments: {
          "sound_url": value!.path,
          "sound_name": soundName,
          "sound_owner": userName
        });
      }).onError((error, stackTrace) {
        Logger().wtf(error);
      });
    } on Exception catch (e) {
      Logger().wtf(e);
    }
  }

  Future<void> getFavourites() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.get('/favorite/user-favorites-list').then((value) {
      if (favouriteSounds.isEmpty) {
        favouriteSounds =
            FavouritesModel.fromJson(value.data).data!.sounds!.obs;
      } else {
        favouriteSounds.value =
            FavouritesModel.fromJson(value.data).data!.sounds!.obs;
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
