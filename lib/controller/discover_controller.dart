import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/discover_model.dart';
import 'package:thrill/controller/model/hash_tags_list_model.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/search_hash_tags_model.dart'
    as hashTagsModel;
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';

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
  RxList<hashTagsModel.Data> searchList = RxList();
  RxList<bool> audioSelectedList = RxList();
  RxList<hashTagsModel.Data> allDataList = RxList();

  var token = GetStorage().read('token');

  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
      headers: {"Authorization": "Bearer ${GetStorage().read("token")}"}));

  DiscoverController() {
    getBanners();
    getTopHashTags();
    getHashTagsList();
    searchHashtags("");
  }

  getBanners() async {
    isLoading.value = true;
    try {
      var response = await http
          .get(
            Uri.parse('${RestUrl.baseUrl}/banners'),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 10))
          .then((value) {
            discoverBanners.value = (json.decode(value.body) as List)
                .map((i) => DiscoverModel.fromJson(i))
                .toList();
            isLoading.value = false;
      })
          .onError((error, stackTrace) {
        isLoading.value = false;

      });
    } on Exception catch (e) {
      isLoading.value = false;

      log.printError(info: e.toString(

      ));
    }
  }

  getTopHashTags() async {
    isHashTagsLoading.value = true;

    try {
      var response = await http
          .get(
            Uri.parse('${RestUrl.baseUrl}/hashtag/top-hashtags-videos'),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 10))
          .then((value) {
        isHashTagsLoading.value = false;

        hasTagsList =
                TopHastagVideosModel.fromJson(jsonDecode(value.body)).data!.obs;
            if (hashTagsVideos.isNotEmpty) {
              hashTagsVideos.clear();
            }
            if (hasTagsList.isNotEmpty) {
              for (HashTags tags in hasTagsList.value) {
                hashTagsVideos.value = tags.videos!;
              }
            }
          })
          .onError((error, stackTrace) {
        isHashTagsLoading.value = false;

      });
    } on Exception catch (e) {
      isLoading.value = false;
      log.printError(info: e.toString());
    }
    hashTagsVideos.refresh();
    hashTagsList.refresh();
  }

  Future<void> getVideosByHashTags(int hashTagId) async {
    isLoading.value = true;

    if (hashTagsDetailsList.isNotEmpty) {
      hashTagsDetailsList.clear();
    }

    var response = await http
        .post(
          Uri.parse('${RestUrl.baseUrl}/hashtag/get-videos-by-hashtag'),
          body: {"hashtag_id": "$hashTagId"},
          headers: {"Authorization": "Bearer $token"},
        )
        .timeout(const Duration(seconds: 10))
        .then((value) {
          hashTagsDetailsList =
              HashTagVideosModel.fromJson(jsonDecode(value.body)).data!.obs;
          isLoading.value = false;

    })
        .onError((error, stackTrace) {
      isLoading.value = false;

    });
  }

  getHashTagsList() async {
    isHashTagsListLoading.value = true;
    if (hashTagsList.isNotEmpty) hashTagsList.clear();

    try {
      var response = await http
          .get(
            Uri.parse('${RestUrl.baseUrl}/hashtag/list'),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 10))
          .then((value) {
            hashTagsList =
                HashTagsListModel.fromJson(jsonDecode(value.body)).data!.obs;
            isHashTagsListLoading.value = false;

      })
          .onError((error, stackTrace) {
        isHashTagsListLoading.value = false;

      });
    } on Exception catch (e) {
      log.printError(info: e.toString());
      isHashTagsListLoading.value = false;

    }
  }

  searchHashtags(String searchQuery) async {
    isSearchingHashtags.value = true;
    if (searchList.isNotEmpty) searchList.clear();
    dio.options.headers["Authorization"] = "Bearer $token";

    var response = await dio
        .get("/hashtag/search/", queryParameters: {'search': searchQuery})
        .timeout(const Duration(seconds: 10))
        .then((value) {
          searchList =
              hashTagsModel.SearchHashTagsModel.fromJson(value.data).data!.obs;
          isSearchingHashtags.value = false;

    })
        .onError((error, stackTrace) {
          false;

    });
  }
}
