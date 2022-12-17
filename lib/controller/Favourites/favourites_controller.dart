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

  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
      ));

  getFavourites() async {
        dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
    change(favouritesModel, status: RxStatus.loading());
    dio.get('/favorite/user-favorites-list').then((value) {
      favouritesModel = FavouritesModel.fromJson(value.data).obs;
      favouriteSounds = favouritesModel.value.data!.sounds!.obs;
      favouriteHashtags = favouritesModel.value.data!.hashTags!.obs;
      change(favouritesModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouritesModel, status: RxStatus.error());
    });
  }
}
