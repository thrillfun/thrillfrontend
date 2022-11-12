import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/discover_model.dart';
import 'package:thrill/controller/model/hash_tags_list_model.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/search_hashtag_model.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/utils/util.dart';

class DiscoverController extends GetxController {
  var isLoading = false.obs;
  var isHashTagsLoading = false.obs;
  var isHashTagsListLoading = false.obs;
  var isSearchingHashtags = false.obs;
  RxList<HashTagsList> hashTagsList = RxList();
  RxList<DiscoverModel> discoverBanners = RxList();
  RxList<HashTags> hasTagsList = RxList();
  RxList<HashTagVideos> hashTagsVideos = RxList();
  RxList<HashTagsDetails> hashTagsDetailsList = RxList();
  RxList<SearchList> searchList = RxList();

  var token = GetStorage().read('token');

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  DiscoverController() {
    getBanners();
    getTopHashTags();
    getHashTagsList();
  }

  getBanners() async {
    isLoading.value = true;

    try {
      var response = await http.get(
        Uri.parse('${RestUrl.baseUrl}/banners'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));

      try {
        discoverBanners.value = (json.decode(response.body) as List)
            .map((i) => DiscoverModel.fromJson(i))
            .toList();
      } catch (e) {
        errorToast('Something went wrong');
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    isLoading.value = false;
    discoverBanners.refresh();
    update();
  }

  getTopHashTags() async {
    isHashTagsLoading.value = true;
    try {
      var response = await http.get(
        Uri.parse('${RestUrl.baseUrl}/hashtag/top-hashtags-videos'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          hasTagsList = TopHastagVideosModel.fromJson(result).data!.obs;
          if (hashTagsVideos.isNotEmpty) {
            hashTagsVideos.clear();
          }
          if (hasTagsList.isNotEmpty) {
            for (HashTags tags in hasTagsList.value) {
              hashTagsVideos.value = tags.videos!;
            }
          }
        } on HttpException catch (e) {
          errorToast(TopHastagVideosModel.fromJson(result).message.toString());
        } on Exception catch (e) {
          e.printError();
        }
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    hashTagsVideos.refresh();
    hashTagsList.refresh();

    isHashTagsLoading.value = false;
    update();
  }

  Future<void> getVideosByHashTags(int hashTagId) async {
    isHashTagsLoading.value = true;
    Get.defaultDialog(content: loader(),title: "");

    if (hashTagsDetailsList.isNotEmpty) {
      hashTagsDetailsList.clear();
    }
    try {
      var response = await http.post(
        Uri.parse('${RestUrl.baseUrl}/hashtag/get-videos-by-hashtag'),
        body: {"hashtag_id": "$hashTagId"},
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          hashTagsDetailsList = HashTagVideosModel.fromJson(result).data!.obs;

        } catch (e) {
          errorToast(HashTagVideosModel.fromJson(result).message.toString());
        }
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    Get.back();
    isHashTagsLoading.value = false;
    hashTagsDetailsList.refresh();
    update();
  }

  getHashTagsList() async {
    isHashTagsListLoading.value = true;
    if(hashTagsList.isNotEmpty)hashTagsList.clear();

    try {
      var response = await http.get(
        Uri.parse('${RestUrl.baseUrl}/hashtag/list'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          hashTagsList = HashTagsListModel.fromJson(result).data!.obs;
        } catch (e) {
          errorToast(HashTagsListModel.fromJson(result).message.toString());
        }
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    isHashTagsListLoading.value = false;
    hashTagsList.refresh();
    update();
  }

  searchHashtags(String searchQuery) async {
    isSearchingHashtags.value = true;
    searchList.clear();

    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      var response = await dio.get("/hashtag/search/", queryParameters: {
        'search': searchQuery
      }).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        searchList.value = SearchHashtagModel.fromJson(response.data).data!;
        successToast(
            SearchHashtagModel.fromJson(response.data).message.toString());
      } else {
        isSearchingHashtags.value = false;
        searchList.value = SearchHashtagModel.fromJson(response.data).data!;
        errorToast(response.statusCode.toString());
        update();
      }
    } on HttpException catch (e) {
      errorToast(e.toString());
    } catch (e) {
      log.printInfo(info: e.toString());
    }

    searchList.refresh();
    isSearchingHashtags.value = false;
  }
}
