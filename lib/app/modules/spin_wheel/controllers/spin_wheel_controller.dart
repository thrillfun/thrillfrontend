import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/models/spin_wheel_data_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../../../utils/utils.dart';

class SpinWheelController extends GetxController
    with StateMixin<SpinWheelDataModel> {
  StreamController<int>? streamController;
  RxList<RecentRewards> recentRewardsList = RxList();

  RxList<WheelRewards> wheelRewardsList = RxList();

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  var wheelData = SpinWheelDataModel();

  var rewardMsg = "".obs;

  WheelRewards? random;
  var remainingChance = 0.obs;
  var usedChanceValue = 0.obs;
  var tempToken =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzdkZWQ4Y2VkNDUwZDE1NWQ0NzY5NjFkYmUzOGNlZjJlODk4ZDAxNjk0NzdiNTZmMmIxMGI1MGYxZTI4OTcwYzljYmRlMGFiNzk2OWM2NjIiLCJpYXQiOjE2NjYzNDE0MzkuNjYzOTk0LCJuYmYiOjE2NjYzNDE0MzkuNjYzOTk3LCJleHAiOjE2OTc4Nzc0MzkuNjU5NDExLCJzdWIiOiIxNiIsInNjb3BlcyI6W119.wQrhTRwPK8IeEhAfYiZId3COXKOoQhzTQay9qnsY64JfYUUEAbgwbhJ-t7OAwJ3Xj8An1Fn6r0j4CkPA96Y_gE3cMQkposykW6p5yoB2lk7xgY602JPRTMDC752pP-ePZqP7WOyV-AiC0Obs2kbMtIbsNqd6NufAIVpXTY8HzHdXivXgnHqOazcsJAffo8mkcEW--bQy4gnT6TZuxQ7sxdc4Br-IYbft-MksrfzVsERg91K5lkWSjlmvOY9fqi3rmvitpv1g6TOlQ6WiU5GEdIZAs_kQGWWOVksGYCv2tubOd5VAHbn_reL7u2R1KgJ8UwcvI21NS4CmjYqTNz_C_zCeVjBT6Zvxr4vjn4AjWvKm0HoS2WwbtOBdXTwRnO6riPjjLt06w-Ez3j4tvlp0ZOGfw_wLj8S-VqNO3AvanySEhyusEyYsOSqywy9tiztA0Uxos_VENpCkAcDn5YlU0QUsil1xPaQwwpaqOo3eFKfV_LgSVuvKG1kO0yBGW2vDd8F2F3Xuchls_HAHaJ2ePy8V1w4Mrnychq6mv1BD1uxjp113bR3NSjWPsk2oDbdii-zSp-MwxR3UX3zvNPbU6NeVFqsS6-6Oc84PQqO9VGVlhkTZBRzfZEXnKaO0Rh2XhX6NTgOb6XIv972WkCUijggOUbjKfGKAAyUdm5jKdro";
  var lastReward = "".obs;
  var wheelRewards = RewardModel().obs;
  var isSpinning = false.obs;
  var isRewardWon = false.obs;
  List<WheelRewards> chanceList = [];

  @override
  void onInit() {
    streamController = StreamController<int>();

    getWheelData();

    Random p = Random();
    ever(remainingChance, (callback) {
      if (remainingChance.value == 0) {
        isSpinning.value = true;
      }
    });

    ever(wheelRewardsList, (callback) {
      if (wheelRewardsList.isNotEmpty && wheelRewardsList.length>2 && remainingChance.value < 2) {
      var chance = p.nextInt(20) + 1;
      chanceList = wheelRewardsList.where((p0) =>chance <= p0.probability).toList();
      // for (var rewards in wheelRewardsList) {
      //     if (chance <= rewards.probability) {
      //       chanceList.add(rewards);
      //     }
      //     else{
      //       chance = p.nextInt(100) + 1;
      //     }
      //
      //   }
      random = getRandomElement(chanceList);
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    streamController!.sink.close();
    super.onClose();
  }

  Future<void> getWheelData() async {
    if (wheelRewardsList.isEmpty) {
      change(wheelData, status: RxStatus.loading());
    }
    dio.options.headers['Authorization'] =
        "Bearer ${await GetStorage().read("token")}";
    await dio.get("/spin-wheel/data").then((response) {
      wheelData = SpinWheelDataModel.fromJson(response.data);

      recentRewardsList.value =
          SpinWheelDataModel.fromJson(response.data).data!.recentRewards!;

      wheelRewardsList.value =
          SpinWheelDataModel.fromJson(response.data).data!.wheelRewards!;

      remainingChance.value =
          int.parse(wheelData.data!.availableChance.toString());

      usedChanceValue.value = int.parse(wheelData.data!.usedChance ?? "0");

      lastReward.value = wheelData.data!.lastReward.toString();
      change(wheelData, status: RxStatus.success());
    }).onError((error, stackTrace) {
      getWheelData();
      Logger().wtf(error);
    });
  }

  getRewardUpdate(var rewardId) async {
    dio.options.headers['Authorization'] =
        "Bearer ${await GetStorage().read("token")}";
    await dio.post("/spin-wheel/reward-won",
        data: {"reward_id": rewardId}).then((value) {
      wheelRewards = RewardModel.fromJson(value.data).obs;
      getWheelData();
      isRewardWon = true.obs;
      rewardMsg.value = value.data["message"];
      random = getRandomElement(chanceList);
      Future.delayed(Duration(seconds: 7))
          .then((value) => isRewardWon.value = false);
    }).onError((error, stackTrace) {
      change(wheelData, status: RxStatus.error(error.toString()));
    });
  }
}
