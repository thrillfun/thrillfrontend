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
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(balance, status: RxStatus.loading());
    dio.get("/wallet/balance").then((value) {
      balance.value = WalletBalanceModel.fromJson(value.data).data!;
      change(balance, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(balance, status: RxStatus.error());
    });
    if (balance.isEmpty) {
      change(balance, status: RxStatus.empty());
    }
  }
}
