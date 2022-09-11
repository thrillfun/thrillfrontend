import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/comments_like_response.dart';
import 'package:thrill/controller/model/comments_post_response.dart';
import 'package:thrill/utils/util.dart';

import 'model/comments_model.dart';

class CommentsController extends GetxController {
  var isLoading = false.obs;
  var commentsModel = RxList<CommentData>();
  var videoId = 0.obs;
  var commentsPostResponse = CommentsPostResponse().obs;
  CommentsController() {}

  getComments(int videoId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
     var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/video/comments'),
          headers: {
            "Authorization": "Bearer $token"
          },
          body: {
            "video_id": "${videoId}"
          }).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
    try {
     
      commentsModel = CommentsModel.fromJson(result).commentsData!.obs;
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();
      errorToast(CommentsModel.fromJson(result).message.toString());
    }
  }

  postComment(int videoId, String userId, String comment) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http
        .post(Uri.parse('http://3.129.172.46/dev/api/video/comment'), headers: {
      "Authorization": "Bearer $token"
    }, body: {
      "video_id": "$videoId",
      "comment_by": userId,
      "comment": comment
    }).timeout(const Duration(seconds: 60));
    var result = jsonDecode(response.body);
    try {
      commentsPostResponse = CommentsPostResponse.fromJson(result).obs;
      successToast(CommentsPostResponse.fromJson(result).message.toString());
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();
      errorToast(CommentsPostResponse.fromJson(result).message.toString());
    }
  }

  likeComment(String commentId, String isLike) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/comment-like'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "comment_id": commentId,
          "is_like": isLike,
        }).timeout(const Duration(seconds: 60));
    var commentLikeResponse = CommentLikeResponse().obs;
    var result = jsonDecode(response.body);
    try {
      commentLikeResponse = CommentLikeResponse.fromJson(result).obs;
      isLoading.value = false;
      update();

      successToast(CommentLikeResponse.fromJson(result).message.toString());
    } catch (e) {
      isLoading.value = false;
      update();
      errorToast(CommentLikeResponse.fromJson(result).message.toString());
    }
  }
}
