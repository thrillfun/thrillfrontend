import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/models/hash_tag_details_model.dart';
import '../../../../rest/rest_urls.dart';

class HashTagsDetailsController extends GetxController
    with StateMixin<RxList<HashtagRelatedVideos>> {
  RxList<HashtagRelatedVideos> hashTagsDetailsList = RxList();
  final _bannerAdId = "ca-app-pub-3566466065033894/8796726228";
  BannerAd? bannerAd;
  var isFavouriteHastag = false.obs;
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));
  var currentPage = 1.obs;
  var nextPageUrl =
      "https://thrill.fun/api/hashtag/top-hashtags-videos?page=2".obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getVideosByHashTags();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getVideosByHashTags() async {
    change(hashTagsDetailsList, status: RxStatus.loading());

    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    dio.post("hashtag/get-videos-by-hashtag", queryParameters: {
      "hashtag_id": "${Get.arguments["hashtagId"]}"
    }).then((value) {
      hashTagsDetailsList = HashtagDetailsModel.fromJson(value.data).data!.obs;
      hashTagsDetailsList.removeWhere((element) => element.id == null);
      hashTagsDetailsList.refresh();

      if (hashTagsDetailsList.isNotEmpty) {
        isFavouriteHastag.value =
            hashTagsDetailsList[0].is_favorite_hasttag == 0 ? false : true;

        nextPageUrl.value =
            HashtagDetailsModel.fromJson(value.data).pagination!.nextPageUrl ??
                "";
      } else {
        change(hashTagsDetailsList, status: RxStatus.empty());
      }
      currentPage.value =
          HashtagDetailsModel.fromJson(value.data).pagination!.currentPage!;
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(hashTagsDetailsList, status: RxStatus.error());
    });
  }

  Future<void> getPaginationVideosByHashTags() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    dio.post(nextPageUrl.value, queryParameters: {
      "hashtag_id": "${Get.arguments["hashtagId"]}"
    }).then((value) {
      if (nextPageUrl.isNotEmpty) {
        hashTagsDetailsList
            .addAll(HashtagDetailsModel.fromJson(value.data).data!);
        hashTagsDetailsList.refresh();
      }

      hashTagsDetailsList.removeWhere((element) => element.id == null);

      nextPageUrl.value =
          HashtagDetailsModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      currentPage.value =
          HashtagDetailsModel.fromJson(value.data).pagination!.currentPage!;
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }

  Future<void> addHashtagToFavourite() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {
        "id": "${await GetStorage().read("hashtagId")}",
        "type": "hashtag",
        "action": isFavouriteHastag.value == true ? "0" : "1"
      },
    ).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
      getVideosByHashTags();
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: _bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Logger().wtf(ad);
        },
        onAdFailedToLoad: (ad, err) {
          Logger().e(err);
          ad.dispose();
        },
      ),
    )..load();
  }
}
