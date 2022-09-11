import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/discover_model.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/utils/util.dart';

class DiscoverController extends GetxController {
  var isLoading = false.obs;
  var isHashTagsLoading = false.obs;
  RxList<DiscoverModel> discoverBanners = RxList();
  RxList<HashTags> hasTagsList = RxList();
  RxList<HashTagVideos> hashTagsVideos = RxList();
  RxList<HashTagsDetails> hashTagsDetailsList = RxList();
  DiscoverController() {
    getBanners();
    getTopHashTags();
  }

  getBanners() async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var response = await http.get(
      Uri.parse('http://3.129.172.46/dev/api/banners'),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);

    try {
      discoverBanners = (json.decode(response.body) as List)
          .map((i) => DiscoverModel.fromJson(i))
          .toList()
          .obs;
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();
      errorToast('Something went wrong');
    }
  }

  getTopHashTags() async {
    isHashTagsLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var response = await http.get(
      Uri.parse('http://3.129.172.46/dev/api/hashtag/top-hashtags-videos'),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 60));
    var result = jsonDecode(response.body);
    try {
      hasTagsList = TopHastagVideosModel.fromJson(result).data!.obs;

      if (hasTagsList.isNotEmpty) {
        hasTagsList.forEach((element) {
          element.videos!.forEach((element) {
            hashTagsVideos.add(element);
          });
        });
      }

      isHashTagsLoading.value = false;
      update();
    } catch (e) {
      isHashTagsLoading.value = false;
      update();
      errorToast(TopHastagVideosModel.fromJson(result).message.toString());
    }
  }

  getVideosByHashTags(int hashTagId) async {
    isHashTagsLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var response = await http.post(
      Uri.parse('http://3.129.172.46/dev/api/hashtag/get-videos-by-hashtag'),
      body: {"hashtag_id": "$hashTagId"},
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try {

        hashTagsDetailsList = HashTagVideosModel.fromJson(result).data!.obs;

        isHashTagsLoading.value = false;
        update();
      } catch (e) {
        isHashTagsLoading.value = false;
        update();
        errorToast(HashTagVideosModel.fromJson(result).message.toString());
      }
    } else {
      hashTagsVideos.clear();
    }
  }
}
