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

class WheelController extends GetxController {
  var isCounterDataLoading = false.obs;
  var isWheelDataLoading = false.obs;
  var isRewardUpdating = false.obs;

  var dio = Dio(BaseOptions(baseUrl:RestUrl.baseUrl));
  String token = GetStorage().read("token");

  RxList<CounterData> probabilityCounter = RxList();

  RxList<RecentRewards> recentRewardsList = RxList();

  RxList<WheelRewards> wheelRewardsList = RxList();

  RxList<Activities> activityList = RxList();

  var wheelData = WheelDataModel().obs;

  var wheelRewards = RewardModel().obs;
  var remainingChance =0.obs;
  var usedChanceValue = 0.obs;
  var tempToken =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzdkZWQ4Y2VkNDUwZDE1NWQ0NzY5NjFkYmUzOGNlZjJlODk4ZDAxNjk0NzdiNTZmMmIxMGI1MGYxZTI4OTcwYzljYmRlMGFiNzk2OWM2NjIiLCJpYXQiOjE2NjYzNDE0MzkuNjYzOTk0LCJuYmYiOjE2NjYzNDE0MzkuNjYzOTk3LCJleHAiOjE2OTc4Nzc0MzkuNjU5NDExLCJzdWIiOiIxNiIsInNjb3BlcyI6W119.wQrhTRwPK8IeEhAfYiZId3COXKOoQhzTQay9qnsY64JfYUUEAbgwbhJ-t7OAwJ3Xj8An1Fn6r0j4CkPA96Y_gE3cMQkposykW6p5yoB2lk7xgY602JPRTMDC752pP-ePZqP7WOyV-AiC0Obs2kbMtIbsNqd6NufAIVpXTY8HzHdXivXgnHqOazcsJAffo8mkcEW--bQy4gnT6TZuxQ7sxdc4Br-IYbft-MksrfzVsERg91K5lkWSjlmvOY9fqi3rmvitpv1g6TOlQ6WiU5GEdIZAs_kQGWWOVksGYCv2tubOd5VAHbn_reL7u2R1KgJ8UwcvI21NS4CmjYqTNz_C_zCeVjBT6Zvxr4vjn4AjWvKm0HoS2WwbtOBdXTwRnO6riPjjLt06w-Ez3j4tvlp0ZOGfw_wLj8S-VqNO3AvanySEhyusEyYsOSqywy9tiztA0Uxos_VENpCkAcDn5YlU0QUsil1xPaQwwpaqOo3eFKfV_LgSVuvKG1kO0yBGW2vDd8F2F3Xuchls_HAHaJ2ePy8V1w4Mrnychq6mv1BD1uxjp113bR3NSjWPsk2oDbdii-zSp-MwxR3UX3zvNPbU6NeVFqsS6-6Oc84PQqO9VGVlhkTZBRzfZEXnKaO0Rh2XhX6NTgOb6XIv972WkCUijggOUbjKfGKAAyUdm5jKdro";
  var lastReward = "".obs;

  WheelController() {
    getCounterData();
  }

  getCounterData() async {
    isCounterDataLoading.value = true;

    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      var response = await dio
          .get("/spin-wheel/counter-data")
          .timeout(const Duration(seconds: 60));

      print(response.data);

      if (response.statusCode == 200) {
        try {
          probabilityCounter.value =
          CounterDataModel.fromJson(response.data).data!;
        } on HttpException catch (e) {
          errorToast(response.data['message']);
        } on Exception catch (e) {
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

    dio.options.headers['Authorization'] = "Bearer $token";
    var response =
    await dio.get("/spin-wheel/data").timeout(const Duration(seconds: 60));

    print(response.data);

    try {
      if (response.statusCode == 200) {
        try {
          wheelData = WheelDataModel.fromJson(response.data).obs;

          recentRewardsList.value =
          WheelDataModel.fromJson(response.data).data!.recentRewards!;

          wheelRewardsList.value =
          WheelDataModel.fromJson(response.data).data!.wheelRewards!;

          remainingChance.value  =
              int.parse(wheelData!.value.data!.availableChance??"0");
          usedChanceValue.value =
              int.parse(wheelData!.value.data!.usedChance??"0");

          lastReward.value = wheelController.wheelData.value.data!.lastReward.toString();


        } on HttpException catch (e) {
          errorToast(response.data['message']);
        } on Exception catch (e) {
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

    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      var response = await dio.post("/spin-wheel/reward-won",
          data: {"reward_id": rewardId}).timeout(const Duration(seconds: 60));

      print(response.data);

      if (response.statusCode == 200) {
        try {
          wheelRewards = RewardModel.fromJson(response.data).obs;
        } on HttpException catch (e) {
          errorToast(response.data['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isRewardUpdating.value = false;
  }

  getEarnedSpinData() async {
    try {
      dio.options.headers['Authorization'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzJmZTcwZTEyOWEyNzllZGM3YWExZGY3ZjBiYzE1ZGJhNWUzOWZkYWRmY2RjNTQ5YTEzZjljNDU0MDcxYTIxNDA5M2FiYmUzMjcwMTZjMWYiLCJpYXQiOjE2Njc2MTkzNzYuMzU4NzE2OTY0NzIxNjc5Njg3NSwibmJmIjoxNjY3NjE5Mzc2LjM1ODcxOTExMDQ4ODg5MTYwMTU2MjUsImV4cCI6MTY5OTE1NTM3Ni4zNTU2MDc5ODY0NTAxOTUzMTI1LCJzdWIiOiIxNCIsInNjb3BlcyI6W119.BwWq7kdEXpYiI3Hw0nGGdPlBtMabw7KwW0sxe3DA8klhMBVGjccUsQCy8BQt-4WZM0A7D3JT-xwWC8hqEPBJLL3nhpmRO6g6wVbq0NF74TjfvgNE3DRPrFwarTY8NDWaTEr4eIl4OHyv8B-NtOSGcLpm9IXospafg3rbGk4-YvCaG9ySs4fgH_p_BRBDlYvBmzKjLkQo2hrJBhEtFMlzRPeZBJ4z8bp0KpAUhsLkNXz6l39uGJkG4aw4hIxYbPFOeqIvgzkCRYok0EzNPefblrt_5PevpnOYdMvXlAVIf2_MhEIYzt3ZLwSjhMfr51Y1QI_o1E51kqzJsBhdny6WMVdyzySb7YoCN-ioeuGFUuD9RE_V8TqjE_Ndp2Q26sVcIqTBaq0_dujXyLvsP7yFNVnH-e8FqOyOXTMT7wAbEn5_diURZk4LaWjrWfGq3kJ033R-XtuIKMRO9AmE2ush3M87jJ8ZYL1y0hYCl4S8QBIP-afkpz45EZ31ypzXbb7kqh8VwRnOpv51sNpbOILJ8j52avfrO_sAxGLStwE-WDYWGR5ySo5VqqY0ZQMN3y4eXOZrX-hlv_SxTORwi-iLGAKpswNdNDEp4cHTkdz-JeX_Dsubsk7_CBVCaDYCC8bBwq3oxAph0_8pgd2AEqbcO658Bm_RvnPUua_lY8_w3SM';
      var response = await dio
          .get("/spin-wheel/earned-spin")
          .timeout(const Duration(seconds: 60));

      try {
        activityList = EarnedSpinModel.fromJson(response.data).data!.activities!.obs;
      } catch (e) {
        errorToast(EarnedSpinModel.fromJson(response.data).message.toString());

      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
