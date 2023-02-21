import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/RewardModel.dart';
import 'package:thrill/controller/model/counter_data_model.dart';
import 'package:thrill/controller/model/earned_spin_model.dart';
import 'package:thrill/controller/model/wheel_data_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/spin/spin_the_wheel_getx.dart';
import 'package:thrill/utils/util.dart';

class WheelController extends GetxController with StateMixin<dynamic> {
  var isCounterDataLoading = false.obs;
  var isWheelDataLoading = false.obs;
  var isRewardUpdating = false.obs;
  late final StreamController<int> streamController;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  String token = GetStorage().read("token");

  RxList<CounterData> probabilityCounter = RxList();

  RxList<RecentRewards> recentRewardsList = RxList();

  RxList<WheelRewards> wheelRewardsList = RxList();

  RxList<Activities> activityList = RxList();

  var wheelData = WheelDataModel().obs;

  var wheelRewards = RewardModel().obs;
  var remainingChance = 0.obs;
  var usedChanceValue = 0.obs;
  var tempToken =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzdkZWQ4Y2VkNDUwZDE1NWQ0NzY5NjFkYmUzOGNlZjJlODk4ZDAxNjk0NzdiNTZmMmIxMGI1MGYxZTI4OTcwYzljYmRlMGFiNzk2OWM2NjIiLCJpYXQiOjE2NjYzNDE0MzkuNjYzOTk0LCJuYmYiOjE2NjYzNDE0MzkuNjYzOTk3LCJleHAiOjE2OTc4Nzc0MzkuNjU5NDExLCJzdWIiOiIxNiIsInNjb3BlcyI6W119.wQrhTRwPK8IeEhAfYiZId3COXKOoQhzTQay9qnsY64JfYUUEAbgwbhJ-t7OAwJ3Xj8An1Fn6r0j4CkPA96Y_gE3cMQkposykW6p5yoB2lk7xgY602JPRTMDC752pP-ePZqP7WOyV-AiC0Obs2kbMtIbsNqd6NufAIVpXTY8HzHdXivXgnHqOazcsJAffo8mkcEW--bQy4gnT6TZuxQ7sxdc4Br-IYbft-MksrfzVsERg91K5lkWSjlmvOY9fqi3rmvitpv1g6TOlQ6WiU5GEdIZAs_kQGWWOVksGYCv2tubOd5VAHbn_reL7u2R1KgJ8UwcvI21NS4CmjYqTNz_C_zCeVjBT6Zvxr4vjn4AjWvKm0HoS2WwbtOBdXTwRnO6riPjjLt06w-Ez3j4tvlp0ZOGfw_wLj8S-VqNO3AvanySEhyusEyYsOSqywy9tiztA0Uxos_VENpCkAcDn5YlU0QUsil1xPaQwwpaqOo3eFKfV_LgSVuvKG1kO0yBGW2vDd8F2F3Xuchls_HAHaJ2ePy8V1w4Mrnychq6mv1BD1uxjp113bR3NSjWPsk2oDbdii-zSp-MwxR3UX3zvNPbU6NeVFqsS6-6Oc84PQqO9VGVlhkTZBRzfZEXnKaO0Rh2XhX6NTgOb6XIv972WkCUijggOUbjKfGKAAyUdm5jKdro";
  var lastReward = "".obs;

  @override
  void onInit() {
    super.onInit();

    streamController = StreamController<int>();
    getCounterData();
    getWheelData();
    getEarnedSpinData();
  }

  @override
  void dispose() {
    streamController.sink.close();
    super.dispose();
  }

  getCounterData() async {
    isCounterDataLoading.value = true;
    try {
      change(probabilityCounter, status: RxStatus.loading());

      dio.options.headers = {
        "'Authorization'": "Bearer ${await GetStorage().read("token")}"
      };
      var response = await dio.get("/spin-wheel/counter-data");

      print(response.data);

      if (response.statusCode == 200) {
        try {
          probabilityCounter.value =
              CounterDataModel.fromJson(response.data).data!;
          change(probabilityCounter, status: RxStatus.success());
        } on HttpException catch (e) {
          change(probabilityCounter,
              status: RxStatus.error(response.data['message']));

          errorToast(response.data['message']);
        } on Exception catch (e) {
          change(probabilityCounter, status: RxStatus.error(e.toString()));

          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isCounterDataLoading.value = false;
  }

  getWheelData() async {
    isWheelDataLoading.value = true;
    change(RxStatus.loading());
    dio.options.headers['Authorization'] =
        "Bearer ${await GetStorage().read("token")}";
    var response = await dio.get("/spin-wheel/data");

    print(response.data);

    try {
      if (response.statusCode == 200) {
        try {
          wheelData = WheelDataModel.fromJson(response.data).obs;
          change(RxStatus.success());

          recentRewardsList.value =
              WheelDataModel.fromJson(response.data).data!.recentRewards!;

          wheelRewardsList.value =
              WheelDataModel.fromJson(response.data).data!.wheelRewards!;

          remainingChance.value =
              int.parse(wheelData.value.data!.availableChance ?? "0");
          usedChanceValue.value =
              int.parse(wheelData.value.data!.usedChance ?? "0");

          lastReward.value =
              wheelController.wheelData.value.data!.lastReward.toString();
        } on HttpException catch (e) {
          change(RxStatus.error(e.toString()));

          errorToast(response.data['message']);
        } on Exception catch (e) {
          change(RxStatus.error(e.toString()));

          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isWheelDataLoading.value = false;
  }

  getRewardUpdate(var rewardId) async {
    isRewardUpdating.value = true;
    change(wheelData, status: RxStatus.loading());

    try {
      dio.options.headers['Authorization'] =
          "Bearer ${await GetStorage().read("token")}";
      var response = await dio
          .post("/spin-wheel/reward-won", data: {"reward_id": rewardId});

      print(response.data);

      if (response.statusCode == 200) {
        try {
          wheelRewards = RewardModel.fromJson(response.data).obs;
          change(wheelRewards.value, status: RxStatus.success());
        } on HttpException catch (e) {
          errorToast(response.data['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        change(wheelData,
            status: RxStatus.error(response.statusCode.toString()));

        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      change(wheelData, status: RxStatus.error(e.toString()));

      log(e.toString());
    }
    isRewardUpdating.value = false;
  }

  getEarnedSpinData() async {
    change(activityList, status: RxStatus.loading());

    try {
      dio.options.headers['Authorization'] =
          "Bearer ${await GetStorage().read("token")}";
      await dio.get("/spin-wheel/earned-spin").then((response) {
        if (response.data["status"] == true) {
          activityList =
              EarnedSpinModel.fromJson(response.data).data!.activities!.obs;
          change(wheelData, status: RxStatus.success());
        } else {
          errorToast(response.data["message"]);
        }
      }).onError((error, stackTrace) {
        change(wheelData, status: RxStatus.error(error.toString()));
      });
    } on Exception catch (e) {
      change(wheelData, status: RxStatus.error(e.toString()));

      log(e.toString());
    }
  }
}
