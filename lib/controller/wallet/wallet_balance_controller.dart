import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:thrill/controller/model/wallet_balance_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/utils/util.dart';

var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
    ));

class WalletBalanceController extends GetxController
    with StateMixin<RxList<Balance>> {
  var balance = RxList<Balance>();

  Future<void> getBalance() async {
        dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
    try {
      change(balance, status: RxStatus.loading());
     
      var response =
          await dio.get("/wallet/balance").timeout(const Duration(seconds: 10));
      try {
        balance.value = WalletBalanceModel.fromJson(response.data).data!;
        change(balance, status: RxStatus.success());
      } on HttpException catch (e) {
        change(balance, status: RxStatus.error());

        errorToast(e.toString());
      } on Exception catch (e) {
        change(balance, status: RxStatus.error());

        errorToast(
            WalletBalanceModel.fromJson(response.data).message.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
