import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/favourites_model.dart';

import '../../rest/rest_url.dart';

class FavouritesController extends GetxController
    with StateMixin<Rx<FavouritesModel>> {
  var favouritesModel = FavouritesModel().obs;
  var selectedSoundPath = "".obs;

  RxList<FavouriteSounds> favouriteSounds = RxList();
  RxList<FavouriteHashTags> favouriteHashtags = RxList();
  RxList<FavouriteVideos> favouriteVideos = RxList();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> getFavourites() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(favouritesModel, status: RxStatus.loading());
    dio.get('/favorite/user-favorites-list').then((value) {
      favouritesModel = FavouritesModel.fromJson(value.data).obs;
      favouriteSounds = favouritesModel.value.data!.sounds!.obs;
      favouriteHashtags = favouritesModel.value.data!.hashTags!.obs;
      favouriteVideos = favouritesModel.value.data!.videos!.obs;
      change(favouritesModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouritesModel, status: RxStatus.error());
    });
    if (favouriteSounds.isEmpty ||
        favouriteHashtags.isEmpty ||
        favouriteVideos.isEmpty) {
      change(favouritesModel, status: RxStatus.empty());
    }
  }
}
