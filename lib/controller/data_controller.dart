import 'dart:convert';


import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/model/video_model_controller.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';


var isLoading = true;

class DataController extends GetxController with StateMixin<dynamic> {
  var selectedIndex = 0.obs;

  Future<VideoModelsController> getUserVideos(int userId) async {
    isLoading = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.get(
        Uri.parse(
            'https://9starinfosolutions.com/thrill/api/video/list'),
        headers: {
          "Authorization":"Bearer$token"
        }).timeout(const Duration(seconds: 60));

    try {
      isLoading = false;
      update();
      return VideoModelsController.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading = false;
      update();
      return VideoModelsController.fromJson(json.decode(response.body));
    }
  }
}
