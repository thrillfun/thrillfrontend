import 'package:thrill/app/rest/models/favourites_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../rest/models/favourites_model.dart';
import '../../../../../rest/rest_urls.dart';
class FavouriteHashtagsController extends GetxController
    with StateMixin<RxList<FavouriteHashTags>> {
  RxList<FavouriteHashTags> favouriteHastags = RxList();
  var favouritesModel = FavouritesModel().obs;
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
    change(favouriteHastags, status: RxStatus.loading());
    dio.get('/favorite/user-favorites-list').then((value) {
      favouritesModel = FavouritesModel.fromJson(value.data).obs;
      favouriteHastags = favouritesModel.value.data!.hashTags!.obs;
      change(favouriteHastags, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouriteHastags, status: RxStatus.error());
    });
  }}
