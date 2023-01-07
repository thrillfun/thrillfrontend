import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:on_audio_query/on_audio_query.dart';
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

  SoundsController() {
    getAlbums();
  }

  getSoundsList() async {
    change(soundsList, status: RxStatus.loading());
    dio.options.headers["Authorization"] =
        "Bearer ${GetStorage().read("token")}";
    try {
      var response = await dio.post("/sound/list");
      try {
        soundsList = SoundListModel.fromJson(response.data).data!.obs;
        change(soundsList, status: RxStatus.success());
      } catch (e) {
        change(soundsList, status: RxStatus.error());

        errorToast(e.toString());
      }
    } on Exception catch (e) {
      change(soundsList, status: RxStatus.error());
      isSoundsLoading.value = false;
      log(e.toString());
    }
  }

  getAlbums() async {
    localSoundsList.value = await OnAudioQuery().querySongs();
  }

  downloadAudio(String soundName, String userName, int id) async {
    try {
      var path = await getTemporaryDirectory();
      await fileSupport
          .downloadCustomLocation(
        url: "${RestUrl.awsSoundUrl}$soundName",
        path: path.path,
        filename: soundName.split('.').first,
        extension: ".${soundName.split('.').last}",
        progress: (progress) async {
          currentProgress.value = progress;
          Get.defaultDialog(
              title: "Downloading audio",
              content: Obx(() => Text(currentProgress.value)));
        },
      )
          .then((value) {
        Get.back();
        Get.to(CameraScreen(
          selectedSound: value!.path,
          owner: userName,
          id: id,
        ));
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }
}
