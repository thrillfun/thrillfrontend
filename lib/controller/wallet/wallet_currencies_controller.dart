import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';
import "package:get_storage/get_storage.dart";
import 'package:dio/dio.dart';

import '../../rest/rest_url.dart';
import '../model/currencies_model.dart';

class WalletCurrenciesController extends GetxController
    with StateMixin<RxList<Currencies>> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var currenciesList = RxList<Currencies>();

  getCurrencies() async {
    change(currenciesList, status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get("/currencies/data").then((response) {
      currenciesList.value = CurrenciesModel.fromJson(response.data).data!;
      change(currenciesList, status: RxStatus.success());
      if (currenciesList.isEmpty) {
        change(currenciesList, status: RxStatus.empty());
      }
    }).onError((error, stackTrace) {
      change(currenciesList, status: RxStatus.error());
    });
    if (currenciesList.isEmpty) {
      change(currenciesList, status: RxStatus.empty());
    }
  }
}
