import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:thrill/controller/model/wallet_balance_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/utils/util.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var dio = Dio(BaseOptions(
  baseUrl: RestUrl.baseUrl,
));

TextEditingController textEditingController = TextEditingController();

class WalletBalanceController extends GetxController
    with StateMixin<RxList<Balance>> {
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
    ethusdChannel.stream.listen((event) {
      ethPer.value = jsonDecode(event)['P'];
      ethPrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    btcusdtChannel.stream.listen((event) {
      btcPer.value = jsonDecode(event)['P'];
      btcPrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    bnbusdtChannel.stream.listen((event) {
      bnbPer.value = jsonDecode(event)['P'];
      bnbPrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    shibusdChannel.stream.listen((event) {
      shibPer.value = jsonDecode(event)['P'];
      shibPrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    luncusdChannel.stream.listen((event) {
      luncPer.value = jsonDecode(event)['P'];
      luncPrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    dogeusdChannel.stream.listen((event) {
      dogePer.value = jsonDecode(event)['P'];
      dogePrice.value = double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
    thrillusdChannel.stream.listen((event) {
      thrillPer.value = jsonDecode(event)['P'];
      thrillPrice.value =
          double.parse(jsonDecode(event)['l']).toStringAsFixed(4);
    });
  }

  @override
  void dispose() {
    ethusdChannel.sink.close();
    btcusdtChannel.sink.close();
    bnbusdtChannel.sink.close();
    shibusdChannel.sink.close();
    luncusdChannel.sink.close();
    dogeusdChannel.sink.close();
    thrillusdChannel.sink.close();
    super.dispose();
  }

  Future<void> getBalance() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(balance, status: RxStatus.loading());
    dio.get("/wallet/balance").then((value) {
      balance.value = WalletBalanceModel.fromJson(value.data).data!;
      textEditingController.text = balance[0].amount.toString();

      update();
      change(balance, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(balance, status: RxStatus.error());
    });
    if (balance.isEmpty) {
      change(balance, status: RxStatus.empty());
    }
  }

  Future<void> getDatafromBinance() async {
    var dio = Dio(BaseOptions(
      baseUrl: "https://api.binance.com/api/v3",
    ));
    dio.get("/ticker", queryParameters: {
      "symbols": jsonEncode([
        "BTCUSDT",
        "BNBUSDT",
        "DOGEUSDT",
        "SHIBUSDT",
        "LUNCUSDT",
        "ETHUSDT",
        "XRPUSDT"
      ])
    }).then((value) {
      cryptoData.value =
          (value.data as List).map((x) => CryptoModel.fromJson(x)).toList();
      Logger().wtf(cryptoData);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
