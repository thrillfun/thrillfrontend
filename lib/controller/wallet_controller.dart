import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/currencies_model.dart';
import 'package:thrill/controller/model/wallet_balance_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

class WalletController extends GetxController {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var token = GetStorage().read('token');
  var isCurrenciesLoading = false.obs;
  var currenciesList = RxList<Currencies>();
  var balance = RxList<Balance>();

  WalletController() {
    if(token!=null){
      getBalance();
    }
  }

  getCurrencies() async {
    isCurrenciesLoading.value = true;
    try {
             dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};

      var response =
          await dio.get("/currencies/data").timeout(const Duration(seconds: 10));
      try {
        currenciesList.value = CurrenciesModel.fromJson(response.data).data!;
      } on HttpException catch (e) {
        errorToast(e.toString());
      } on Exception catch (e) {
        errorToast(CurrenciesModel.fromJson(response.data).message.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isCurrenciesLoading.value = false;
    update();
  }

  getBalance() async {
    isCurrenciesLoading.value = true;
    try {
            dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};

      var response =
          await dio.get("/wallet/balance").timeout(const Duration(seconds: 10));
      try {
        balance.value = WalletBalanceModel.fromJson(response.data).data!;
      } on HttpException catch (e) {
        errorToast(e.toString());
      } on Exception catch (e) {
        errorToast(WalletBalanceModel.fromJson(response.data).message.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isCurrenciesLoading.value = false;
    update();
  }
}
