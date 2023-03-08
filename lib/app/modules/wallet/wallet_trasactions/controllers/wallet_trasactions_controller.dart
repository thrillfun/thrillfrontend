import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/transactions_history_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/utils.dart';

class WalletTrasactionsController extends GetxController  with StateMixin<RxList<TransactionHistory>>{
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  RxList<TransactionHistory> transactionsList = RxList();
  @override
  void onInit() {
    getTransactionHistory();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getTransactionHistory() async {
    dio.options.headers = {
      "Authorization":
      "Bearer ${await GetStorage().read("token")}"
    };
    change(transactionsList, status: RxStatus.loading());
    dio.get("/wallet/withdraw-history").then((value) {
      transactionsList = TransactionsHistoryModel.fromJson(value.data)
          .data!
          .obs;

      change(transactionsList, status: RxStatus.success());
      if (transactionsList.isEmpty) {
        change(transactionsList, status: RxStatus.empty());
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      change(transactionsList, status: RxStatus.error());
    });
  }

}
