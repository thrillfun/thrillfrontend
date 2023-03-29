import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../rest/models/favourites_model.dart';
import '../../../../../rest/rest_urls.dart';
class FavouriteVideosController extends GetxController
    with StateMixin<RxList<FavouriteVideos>>  {

  RxList<FavouriteVideos> favouriteVideos= RxList();
  var favouritesModel = FavouritesModel().obs;
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));  @override
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
    dio.get('/favorite/user-favorites-list').then((value) {
      favouritesModel = FavouritesModel.fromJson(value.data).obs;
      favouriteVideos = favouritesModel.value.data!.videos!.obs;
      change(favouriteVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouriteVideos, status: RxStatus.error());
    });
  }}
