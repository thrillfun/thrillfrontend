import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../../rest/models/comments_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';

class CommentsController extends GetxController with StateMixin {
  //TODO: Implement CommentsController
  var fieldNode = FocusNode().obs;

  final count = 0.obs;
  @override
  void onInit() {
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

  var commentsList = RxList<CommentData>();
  var dio = Dio(
      BaseOptions(baseUrl: RestUrl.baseUrl, responseType: ResponseType.json));

  Future<void> getComments(int videoId) async {
    change(commentsList, status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/video/comments", queryParameters: {"video_id": videoId}).then(
            (value) {
          commentsList = CommentsModel.fromJson(value.data).commentsData!.obs;
          change(commentsList, status: RxStatus.success());
        }).onError((error, stackTrace) {
      change(commentsList, status: RxStatus.error());
    });
  }

  postComment({int? videoId, String? userId, String? comment,String fcmToken="",userName=""}) async {
    change(commentsList, status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/video/comment", queryParameters: {
      "video_id": "$videoId",
      "comment_by": userId,
      "comment": comment
    }).then((value) {
      try {
        successToast(value.data["message"]);
        change(commentsList, status: RxStatus.success());
        sendNotification(fcmToken,title: "New Comments",body: "${userName} commented on your video");

        getComments(videoId!);
      } catch (e) {
        Logger().wtf(e);
        change(commentsList, status: RxStatus.error());
      }
    }).onError((error, stackTrace) {
      change(commentsList, status: RxStatus.error());
    });
  }

  Future<void> likeComment(String commentId, String isLike,String fcmToken) async {
    change(commentsList, status: RxStatus.loading());

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/video/comment-like", queryParameters: {
      "comment_id": commentId,
      "is_like": isLike,
    }).then((value) {
      try {
        change(commentsList, status: RxStatus.success());

        successToast(value.data["message"]);
        sendNotification(fcmToken,title: "Somebody liked your comment");
      } catch (e) {
        Logger().wtf(e);
        change(commentsList, status: RxStatus.error());
      }
    }).onError((error, stackTrace) {
      change(commentsList, status: RxStatus.error());
    });
  }}
Future<void> sendNotification(String fcmToken,
    {String? body = "", String? title = "", String? image = ""}) async {
  var dio = Dio(BaseOptions(baseUrl: "https://fcm.googleapis.com/fcm"));
  dio.options.headers = {
    "Authorization":
    "key= AAAAzWymZ2o:APA91bGABMolgt7oiBiFeTU7aCEj_hL-HSLlwiCxNGaxkRl385anrsMMNLjuuqmYnV7atq8vZ5LCNBPt3lPNA1-0ZDKuCJHezvoRBpL9VGvixJ-HHqPScZlwhjeQJPhbsiLDSTtZK-MN"
  };
  final data = {
    "to": fcmToken,
    "notification": {"body": body, "title": title, "image": image},
    "priority": "high",
    "image": image,
    "data": {
      "url":image,
      "body":body,
      "title":title,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "image":
      image
    }
  };
  dio.post("/send", data: jsonEncode(data)).then((value) {
    Logger().wtf(value);
  }).onError((error, stackTrace) {
    Logger().wtf(error);
  });
}
