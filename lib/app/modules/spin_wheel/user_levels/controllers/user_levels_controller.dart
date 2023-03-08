import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/models/user_level_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../../../../utils/utils.dart';

class UserLevelsController extends GetxController with StateMixin<RxList<Activities>> {
  //TODO: Implement UserLevelsController
  RxList<Activities> activityList = RxList();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  final count = 0.obs;
  @override
  void onInit() {
    getEarnedSpinData();
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
  getEarnedSpinData() async {
    change(activityList, status: RxStatus.loading());

    try {
      dio.options.headers['Authorization'] =
      "Bearer ${await GetStorage().read("token")}";
      await dio.get("spin-wheel/earned-spin").then((response) {
        if (response.data["status"] == true) {
          activityList.value =
              UserLevelModel.fromJson(response.data).data!.activities??[];
          change(activityList, status: RxStatus.success());
        } else {
          errorToast(response.data["message"]);
        }
      }).onError((error, stackTrace) {
        change(activityList, status: RxStatus.error(error.toString()));
      });
    } on Exception catch (e) {
      change(activityList, status: RxStatus.error(e.toString()));

      log(e.toString());
    }
  }
}
