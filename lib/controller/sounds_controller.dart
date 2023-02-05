import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/sound_list_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import '../screens/video/camera_screen.dart';

class SoundsController extends GetxController with StateMixin<RxList<Sounds>> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  var fileSupport = FileSupport();

  var isSoundsLoading = false.obs;
  RxList<Sounds> soundsList = RxList();
  RxList<SongModel> localSoundsList = RxList();
  var selectedSoundPath = "".obs;

  var currentProgress = "0".obs;

  Future<void> getSoundsList() async {
    dio.options.headers["Authorization"] =
        "Bearer ${GetStorage().read("token")}";

    dio.post("/sound/list").then((value) {
      soundsList = SoundListModel.fromJson(value.data).data!.obs;
      change(soundsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  getAlbums() async {
    var storagePermission = await Permission.storage.status;
    if (storagePermission.isGranted) {
      localSoundsList.value = await OnAudioQuery().querySongs();
    } else {
      Permission.storage.request();
    }
  }

  downloadAudio(String soundUrl, String userName, int id, String soundName,
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
        Get.back();
        if (!isFavourites) {
          Get.to(CameraScreen(
            selectedSound: value!.path,
            owner: userName,
            id: id,
            soundName: soundName,
          ));
        } else {
          selectedSoundPath.value = value!.path;
          Get.back();
        }
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }
}
