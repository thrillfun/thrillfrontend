import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/sound_list_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

class SoundsController extends GetxController {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  RxList<Sounds>soundsList = RxList();
  RxList<SongInfo> localSoundsList = RxList();

  SoundsController() {
    getAlbums();
  }

  Future<void> getSoundsList() async {
    dio.options.headers["Authorization"] =
    "Bearer ${GetStorage().read("token")}";
    try {
      var response = await dio.post("/sound/list").timeout(
          Duration(seconds: 60));
      try {
        soundsList = SoundListModel
            .fromJson(response.data)
            .data!
            .obs;
      }
      catch (e) {
        errorToast(e.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  getAlbums() async {
    FlutterAudioQuery flutterAudioQuery = FlutterAudioQuery();
    localSoundsList.value = await flutterAudioQuery.getSongs();
  }
}