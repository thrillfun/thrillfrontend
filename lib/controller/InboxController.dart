import 'dart:developer';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

class InboxController extends GetxController with StateMixin<RxList<Inbox>> {
  var inboxList = RxList<Inbox>();
  var isInboxLoading = false.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  String token = GetStorage().read("token");

  Future<void> getInbox() async {
    inboxList.clear();
    isInboxLoading.value = true;
    dio.options.headers['Authorization'] = "Bearer $token";
    dio.get("/user/chat-inbox").then((response) {
      inboxList = InboxModel.fromJson(response.data).data!.obs;
      inboxList.isEmpty
          ? change(inboxList, status: RxStatus.empty())
          : change(inboxList, status: RxStatus.success());
      isInboxLoading.value = false;

    }).onError((error, stackTrace) {
      change(inboxList,
          status: RxStatus.error(
              error.toString()));

    } );
    isInboxLoading.value = false;

    update();
  }
}
