import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:thrill/app/rest/models/currencies_model.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../rest/rest_urls.dart';

class WithdrawController extends GetxController with StateMixin<dynamic> {
  //TODO: Implement WithdrawController
  bool isLoading = true;
  int adminCommission = 0;
  var selectedCurrencyController = TextEditingController().obs;
  var selectedNetworkController = TextEditingController().obs;
  var feeCtr = TextEditingController().obs;
  var upiCtr = TextEditingController().obs;
  var amtCtr = TextEditingController().obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  RxList<Currencies> currenciesList = RxList();
  RxList<Networks>? netList;
  Networks? networks;
  Currencies? model;
  var selectedCurrency = "".obs;
  var walletController =Get.find<WalletController>();
  var minAmount = "".obs;
  var maxAmount = "0.0".obs;

  var networkFee = "0.0".obs;
  var availableBalance = "".obs;
  var currencyName = "".obs;
  var withdrawAmount="0.0".obs;
  var isAmountOverLimit = false.obs;
  var isAmountUnderLimit = false.obs;

  @override
  void onInit() {
    amtCtr.value.text = "0";
    getCurrenciesData();
    if(amtCtr.value.text =="0"){
      withdrawAmount.value = "0";
    }

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

  Future<void> sendWithdrawRequest(String currencyCode, String upiAddress,
      String networkName, String amount, String networkFee) async {
    dio.options.headers = {
      "Authorization": "Bearer ${GetStorage().read("token")}"
    };

    dio.post("wallet/withdraw", queryParameters: {
      "currency": currencyCode,
      "address_upi": upiAddress,
      "network_name": networkName,
      "amount": amount,
      "network_fee": networkFee
    }).then((value) {
      if (value.data["status"]) {

        successToast(value.data["message"]);
        amtCtr.value.text = "";
        upiCtr.value.text = "";
        selectedCurrencyController.value.text = "";
        walletController.getBalance();
        Get.close(1);
      }
      else{
        errorToast(value.data["message"]);
      }



    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> getCurrenciesData() async {
    dio.options.headers = {
      "Authorization": "Bearer ${GetStorage().read("token")}"
    };
    change(currenciesList, status: RxStatus.loading());
    dio.get("currencies/data").then((value) {
      currenciesList = CurrenciesModel.fromJson(value.data).data!.obs;
      currenciesList.removeWhere((element) => element.networks!.isEmpty);
      currencyName.value = currenciesList[0].symbol.toString();
      availableBalance.value = currenciesList[0].balance.toString();
      model = currenciesList[0];
      netList = currenciesList[0].networks?.obs;
      networks = currenciesList[0].networks![0];
      feeCtr.value.text = currenciesList[0].networks![0].feeDigit.toString().formatCrypto();
      selectedCurrencyController.value.text = currenciesList[0].symbol.toString();
      selectedNetworkController.value.text = currenciesList[0].networks![0].networkName.toString();
      networkFee.value = currenciesList[0].networks![0].feeDigit.toString().formatCrypto();
      minAmount.value = currenciesList[0].networks![0].minAmount.toString().formatCrypto() ;
      maxAmount.value = currenciesList[0].networks![0].maxAmount!.formatCrypto() ;

      change(currenciesList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(currenciesList, status: RxStatus.error());
    });
  }
}
