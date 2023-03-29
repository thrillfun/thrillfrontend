import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../rest/models/favourites_model.dart';
import '../../../../../rest/rest_urls.dart';

class FavouriteSoundsController extends  GetxController
    with StateMixin<RxList<FavouriteSounds>>
{

  RxList<FavouriteSounds> favouriteSounds = RxList();
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
    change(favouriteSounds, status: RxStatus.loading());
    dio.get('/favorite/user-favorites-list').then((value) {
      favouritesModel = FavouritesModel.fromJson(value.data).obs;

      favouriteSounds = favouritesModel.value.data!.sounds!.obs;
      change(favouriteSounds, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(favouriteSounds, status: RxStatus.error());
    });

  }
}
