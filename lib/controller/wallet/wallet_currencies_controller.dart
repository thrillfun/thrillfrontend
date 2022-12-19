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
     dio.options.headers = {
        "Authorization": "Bearer ${await GetStorage().read("token")}"
      };

    await dio.get("/currencies/data").then((response) {
        currenciesList.value = CurrenciesModel.fromJson(response.data).data!;
                change(currenciesList, status: RxStatus.success());

      }).onError((error, stackTrace) {
        change(currenciesList, status: RxStatus.error());
      });
  }
}
