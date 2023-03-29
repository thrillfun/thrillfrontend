import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../rest/models/wallet_balance_model.dart';
import '../../../rest/rest_urls.dart';

class WalletController extends GetxController with StateMixin<RxList<Balance>> {
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));
  var textEditingController = TextEditingController().obs;
  var textDollarController = TextEditingController().obs;

  var balance = RxList<Balance>();
  var webSocketData = ''.obs;
  var cryptoData = RxList<CryptoModel>();
  var thrillPrice = "".obs;
  var btcPrice = "".obs;
  var bnbPrice = "".obs;
  var ethPrice = "".obs;
  var shibPrice = "".obs;
  var dogePrice = "".obs;
  var luncPrice = "".obs;

  var thrillPer = "".obs;
  var btcPer = "".obs;
  var bnbPer = "".obs;
  var ethPer = "".obs;
  var shibPer = "".obs;
  var dogePer = "".obs;
  var luncPer = "".obs;

  var totalbalance = ''.obs;

  final IOWebSocketChannel ethusdChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/ethusdt@ticker");

  final IOWebSocketChannel btcusdtChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/btcusdt@ticker");

  final IOWebSocketChannel bnbusdtChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/bnbusdt@ticker");

  final IOWebSocketChannel dogeusdChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/dogeusdt@ticker");

  final IOWebSocketChannel luncusdChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/luncusdt@ticker");

  final IOWebSocketChannel shibusdChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/shibusdt@ticker");

  final IOWebSocketChannel thrillusdChannel = IOWebSocketChannel.connect(
      "wss://stream.binance.com:9443/ws/xrpusdt@ticker");

  @override
  void onInit() {
    super.onInit();
    getBalance();
  }

  @override
  void onReady() {
    super.onReady();
    ethusdChannel.stream.listen((event) {
      ethPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      ethPrice.value =
          (double.parse(jsonDecode(event)['c']).toStringAsFixed(6));
    });
    btcusdtChannel.stream.listen((event) {
      btcPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      btcPrice = double.parse(jsonDecode(event)['c']).toStringAsFixed(6).obs;
      getDatafromBinance();

    });
    bnbusdtChannel.stream.listen((event) {
      bnbPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      bnbPrice.value = double.parse(jsonDecode(event)['c']).toStringAsFixed(6);
    });
    shibusdChannel.stream.listen((event) {
      shibPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      shibPrice.value = double.parse(jsonDecode(event)['c']).toStringAsFixed(6);
    });
    luncusdChannel.stream.listen((event) {
      luncPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      luncPrice.value = double.parse(jsonDecode(event)['c']).toStringAsFixed(6);
    });
    dogeusdChannel.stream.listen((event) {
      dogePer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      dogePrice.value = double.parse(jsonDecode(event)['c']).toStringAsFixed(6);
    });
    thrillusdChannel.stream.listen((event) {
      thrillPer.value = double.parse(jsonDecode(event)['P']).toStringAsFixed(2);
      thrillPrice.value =
          double.parse(jsonDecode(event)['c']).toStringAsFixed(6);
    });
  }

  @override
  void onClose() {
    ethusdChannel.sink.close();
    btcusdtChannel.sink.close();
    bnbusdtChannel.sink.close();
    shibusdChannel.sink.close();
    luncusdChannel.sink.close();
    dogeusdChannel.sink.close();
    thrillusdChannel.sink.close();
    super.onClose();
  }

  Future<void> getBalance() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(balance, status: RxStatus.loading());
   await dio.get("/wallet/balance").then((value) async{
      balance = WalletBalanceModel.fromJson(value.data).data!.obs;
      //  textEditingController.text = balance.first.amount.toString();
      change(balance, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(balance, status: RxStatus.error());
    });
  }

  Future<void> getDatafromBinance() async {
    var dio = Dio(BaseOptions(
      baseUrl: "https://api.binance.com/api/v3",
    ));
    dio.get("/ticker", queryParameters: {
      "symbols": jsonEncode([
        "BTCUSDT",
        "ETHUSDT",
        "BNBUSDT",
        "SHIBUSDT",
        "DOGEUSDT",
        "LUNCUSDT",
      ])
    }).then((value) {
      cryptoData.value =
          (value.data as List).map((x) => CryptoModel.fromJson(x)).toList();

      var totalAmount = ((double.parse(balance.value[1].amount.toString()) *
              double.parse(cryptoData[0].lastPrice.toString())) +
          (double.parse(balance.value[2].amount.toString()) *
                  double.parse(cryptoData[1].lastPrice.toString()) +
              double.parse(balance.value[3].amount.toString()) *
                  double.parse(cryptoData[2].lastPrice.toString()) +
              double.parse(balance.value[4].amount.toString()) *
                  double.parse(cryptoData[3].lastPrice.toString()) +
              double.parse(balance.value[5].amount.toString()) *
                  double.parse(cryptoData[4].lastPrice.toString()) +
              double.parse(balance.value[6].amount.toString()) *
                  double.parse(cryptoData[5].lastPrice.toString())));

      if (btcPrice.value.isEmpty) {
        textEditingController.value.text = "0.0";
      } else {
        textEditingController.value.text =
            (totalAmount / double.parse(btcPrice.toString()))
                .toStringAsFixed(6);
      }

      totalbalance.value = "= \$" + totalAmount.toStringAsFixed(2);

      textDollarController.value.text = totalbalance.value;

      Logger().wtf(cryptoData);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
