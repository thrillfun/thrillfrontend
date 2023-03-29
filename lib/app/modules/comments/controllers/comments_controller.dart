import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../rest/models/comments_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';

class CommentsController extends GetxController with StateMixin {
  //TODO: Implement CommentsController

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

  postComment({int? videoId, String? userId, String? comment}) async {
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

        getComments(videoId!);
      } catch (e) {
        errorToast(value.data["message"]);
        change(commentsList, status: RxStatus.error());
      }
    }).onError((error, stackTrace) {
      change(commentsList, status: RxStatus.error());
    });
  }

  Future<void> likeComment(String commentId, String isLike) async {
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
      } catch (e) {
        errorToast(value.data["message"]);
        change(commentsList, status: RxStatus.error());
      }
    }).onError((error, stackTrace) {
      change(commentsList, status: RxStatus.error());
    });
  }}
