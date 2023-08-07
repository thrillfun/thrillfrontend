import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/models/favourite_videos_model.dart' as fav;

import '../../../../../rest/rest_urls.dart';

class FavouriteVideosController extends GetxController
    with StateMixin<RxList<fav.Data>> {
  RxList<fav.Data> favouriteVideos = RxList();
  var favouritesModel = fav.FavouriteVideosModel().obs;
  var nextPageUrl = "https://thrill.fun/api/video/favorite-videos?page=2".obs;

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    super.onInit();
    getFavourites();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getFavourites() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(favouriteVideos, status: RxStatus.loading());
    dio.get('video/favorite-videos').then((value) {
      favouritesModel = fav.FavouriteVideosModel.fromJson(value.data).obs;
      favouriteVideos = favouritesModel.value.data!.obs;
      favouriteVideos.removeWhere((element) => element.id == null);
      favouriteVideos.refresh();
      change(favouriteVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouriteVideos, status: RxStatus.error());
    });
  }

  Future<void> getPaginationAllVideos(int page) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get(nextPageUrl.value).then((value) {
      if (nextPageUrl.isNotEmpty) {
        favouritesModel = fav.FavouriteVideosModel.fromJson(value.data).obs;
        favouriteVideos.addAll(favouritesModel.value.data!.obs);
      }
      favouriteVideos.removeWhere((element) => element.id == null);
      favouriteVideos.refresh();

      nextPageUrl.value = fav.FavouriteVideosModel.fromJson(value.data)
              .pagination!
              .nextPageUrl ??
          "";
      change(favouriteVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
