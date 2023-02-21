import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/transactions_history_model.dart';
import 'package:thrill/utils/util.dart';

import '../../rest/rest_url.dart';

class TransactionsController extends GetxController
    with StateMixin<RxList<TransactionHistory>> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  RxList<TransactionHistory> transactionsList = RxList();

  @override
  void onInit() {
    super.onInit();
    getTransactionHistory();
  }

  Future<void> getTransactionHistory() async {
    dio.options.headers = {
      "Authorization":
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNjkxMmVjYWZlNDM4MTM1ZjA5N2Q0YTlhZTYzMDg0ODhkNDFkZjA2YTc1YjkzNTQzM2Y3NzQ2ZmU2Zjc4NWY0MzI1NDJiZDA2N2UwM2ViYTMiLCJpYXQiOjE2NzUxNTA4NjAuNDY5ODYwMDc2OTA0Mjk2ODc1LCJuYmYiOjE2NzUxNTA4NjAuNDY5ODYxMDMwNTc4NjEzMjgxMjUsImV4cCI6MTcwNjY4Njg2MC40NjU0MDE4ODc4OTM2NzY3NTc4MTI1LCJzdWIiOiIxMDUiLCJzY29wZXMiOltdfQ.BIORDYkrY0aF25YXrpCM50mC62vxJ-u7K4OQFnfHuGEmRDna_jv2ZFyVaaSkoX2pMqxdF5112HBQytPeQxmImh-cU7GG0kF6wr8x7Y9eBnik9EfQO3wcAjAceLSd-82CqZ0dEtWYYefDibGCxVgtH1R4uFf0tLdnUMTKfu0P9-yzMofB90SucJ1MON0v-DizUFFTwRAzDpVeiT3zyVb6vt4H4toeyJKtjKxEGv9S3tHLfWiiyVTYJ4nFyyvRB759kVETBv8lhiUZkkWy2gCWEDWMe8b-6KQbWpb9ZAOwN6aqqXxZn_3cty9zN_JiOd7BIHdVpdR5J6oDP9rPir7htCsIr9LGVgSmLpn87IzKufichnoEEKVEraQycWRPEeMXQr4gf_g4zwJovVwlSWQrEL64lDuYUh5ZiPfvCOEz4bTH2W50ke-5XHWFfS6ctZlVcpt9EUqE3OYSQHVx713TxhVhoLbgRuc7mJiq5x3TiwGwMlhjLpwYLnsuC1mwn7MuR8MiJQqRyiT7d00WidRj_DWSI8nziHsP965I5wE4H7H8Vx9VoVyKHbMlcFoB4AWJ6xvFnounSxo9R25HNqx_kKSl3A6UrSm4VOwQbn_28VCquCS1oOFFrjZ5TE_fdhcPpeXxkApZ8Ml-Yoo4J_D7_dmA9HNkEuft-d_4-LBU_9s"
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
