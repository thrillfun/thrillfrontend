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
      dio.options.headers['Authorization'] =
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMGIxYWQwYmEyZjkzZjAzNWYwM2ZlMjlkOTgxMGQ1YWYzNmYyY2VkZjExYzNiYzA0MmIwNTBlNzFhYTkyNjVjYTUxOGQ5YjZmNzM1ZTVkNGMiLCJpYXQiOjE2NTk5NTI5MjguNjc2NzI2LCJuYmYiOjE2NTk5NTI5MjguNjc2NzMxLCJleHAiOjE2OTE0ODg5MjguNjY5NjE4LCJzdWIiOiIxMSIsInNjb3BlcyI6W119.pIsyYBLFg6m6yOthNUmQtRo3HJx0vdcIY7nDdlpxs7N-zqgvNyKMrkelPsv0mwW3BLRTydgxYxng7aoxA2L6DE-R0Pu15MU1WbkPFjNnCtbEocLXcMQq_s6s8lk045U47vI-5XneeZHsnOk0Pb_pfyQBEMhFmZFbmVVq14aBROGVgzBOGS3k5TxaGwluLzdxbdNTvFmOiJR4J_V2hrir3nqxEXcJ44sdrAIVsZWM1nEqA9TV-3V8E2C4BM4X9ynxZwTjezcnPwWuyPDSkfEvlyowxgNpuJLHMaJrBxC82gUpgTMHxtQVvT8SUG8bNxSeaHVSoYJ09Tos0ie6YyMA8O_rzjfIdihaKMnCm9jsjprvrhklCf6ycsJPBBYWgj9tuNmwpqQmLTRllfk0_4dPwFDuxnaSATh5dsYNK2WTU20gJ3Eqbbtkd4IQSx8uM93M0Jqe4Jm8_4qa_jXfnvpe6FRZU3YxBtDcHo5gUAlpL-S6WsacEqK2SVQW5hycG6Rfh1q5oj0M9rlGqs39wMpqySEMOK4GRVzNo3vHYWA7sqLV3reJNtLfF-7xMlwB36pSQF2AvuKx-A0iBdyTAesFaYBYIoavTv7t0xRllmdE7dWmlg3OkolYvUU9ePDJb8w7RkfmGUEiem4DfgOz4JPGCMK64zPSSjtqiHLp0nrMXsw";

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
