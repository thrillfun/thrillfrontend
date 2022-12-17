import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/comments_like_response.dart';
import 'package:thrill/controller/model/comments_post_response.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import 'model/comments_model.dart';

class CommentsController extends GetxController {
  var isLoading = false.obs;
  var isCommentsLoading = false.obs;
  var commentsModel = RxList<CommentData>();
  var videoId = 0.obs;
  var commentsPostResponse = CommentsPostResponse().obs;
  var token = GetStorage().read('token');

  Future<void> getComments(int videoId) async {
    isCommentsLoading.value = true;

    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/comments'),
          headers: {"Authorization": "Bearer $token"},
          body: {"video_id": "${videoId}"}).timeout(const Duration(seconds: 10));

      var result = jsonDecode(response.body);
      try {
        commentsModel = CommentsModel.fromJson(result).commentsData!.obs;
      } catch (e) {
        errorToast(CommentsModel.fromJson(result).message.toString());
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    isCommentsLoading.value = false;
    commentsModel.refresh();
    update();
  }

  Future<void>postComment(int videoId, String userId, String comment) async {
    isLoading.value = true;

    try {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/video/comment'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "video_id": "$videoId",
        "comment_by": userId,
        "comment": comment
      }).timeout(const Duration(seconds: 10));
      var result = jsonDecode(response.body);
      try {
        commentsPostResponse = CommentsPostResponse.fromJson(result).obs;
        successToast(CommentsPostResponse.fromJson(result).message.toString());
      } catch (e) {
        errorToast(CommentsPostResponse.fromJson(result).message.toString());
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    commentsModel.refresh();
    isLoading.value = false;
    update();
  }

  likeComment(String commentId, String isLike) async {
    isLoading.value = true;

    try {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/video/comment-like'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "comment_id": commentId,
        "is_like": isLike,
      }).timeout(const Duration(seconds: 10));
      var result = jsonDecode(response.body);
      try {
        isLoading.value = false;
        update();

        successToast(CommentLikeResponse.fromJson(result).message.toString());
      } catch (e) {

        errorToast(CommentLikeResponse.fromJson(result).message.toString());
      }
    } on Exception catch (e) {
      log.printError(info: e.toString());
    }
    isLoading.value = false;
    update();
    commentsModel.refresh();
  }
}
