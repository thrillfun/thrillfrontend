import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/following_videos/controllers/following_videos_controller.dart';
import 'package:thrill/app/modules/following_videos/views/following_videos_view.dart';
import 'package:thrill/app/modules/trending_videos/controllers/trending_videos_controller.dart';
import 'package:thrill/app/modules/trending_videos/views/trending_videos_view.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/utils.dart';
import '../../../related_videos/controllers/related_videos_controller.dart';
import '../../../related_videos/views/related_videos_view.dart';
import '../views/home_videos_player_view.dart';

class HomeVideosPlayerController extends GetxController {
  var storage = GetStorage();
  var selectedIndex = 0.obs;
  var pageController = PageController();
  var followingPageController = PageController();

  var listOfScreens = ["For you", "Following", "Trending"];
  List<Widget> videoScreens = [];
  final info = NetworkInfo();
  BetterPlayerEventType? eventType;
  final count = 0.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var playerController = BetterPlayerListVideoPlayerController();

  @override
  void onInit() {
    videoScreens = [
      GetX<RelatedVideosController>(
          builder: (controller) => controller.isLoading.isTrue
              ? loader()
              : Stack(
                  children: [
                    PageView.builder(
                        itemCount: controller.relatedVideosList.length,
                        scrollDirection: Axis.vertical,
                        controller: pageController,
                        itemBuilder: (context, index) => RelatedVideosView(
                              videoUrl: controller
                                  .relatedVideosList[index].video
                                  .toString(),
                              pageController: pageController!,
                              nextPage: index + 1,
                              videoId: controller.relatedVideosList[index].id!,
                              gifImage:
                                  controller.relatedVideosList[index].gifImage,
                              publicUser:
                                  controller.relatedVideosList[index].user,
                              soundName:
                                  controller.relatedVideosList[index].soundName,
                              UserId:
                                  controller.relatedVideosList[index].user!.id,
                              userName: controller
                                  .relatedVideosList[index].user!.username!.obs,
                              description: controller
                                  .relatedVideosList[index].description!.obs,
                              hashtagsList: controller
                                      .relatedVideosList[index].hashtags ??
                                  [],
                              soundOwner: controller
                                  .relatedVideosList[index].soundOwner,
                              sound: controller.relatedVideosList[index].sound,
                              videoLikeStatus: controller
                                  .relatedVideosList[index].videoLikeStatus
                                  .toString(),
                              isCommentAllowed: controller
                                          .relatedVideosList[index]
                                          .isCommentable ==
                                      "Yes"
                                  ? true.obs
                                  : false.obs,
                              like: controller
                                  .relatedVideosList[index].likes!.obs,
                              isfollow: controller
                                  .relatedVideosList[index].user!.isfollow!,
                              commentsCount: controller
                                  .relatedVideosList[index].comments!.obs,
                              soundId:
                                  controller.relatedVideosList[index].soundId,
                              avatar: controller
                                  .relatedVideosList[index].user!.avatar,
                              currentPageIndex: index.obs,
                              fcmToken: controller
                                  .relatedVideosList[index].user!.firebaseToken,
                            )),
                  ],
                )),
      GetX<FollowingVideosController>(
          builder: (controller) => controller.isLoading.isTrue
              ? loader()
              : Stack(
                  children: [
                    PageView.builder(
                        itemCount: controller.followingVideosList.length,
                        scrollDirection: Axis.vertical,
                        controller: followingPageController,
                        itemBuilder: (context, index) => FollowingVideosView(
                              videoUrl: controller
                                  .followingVideosList[index].video
                                  .toString(),
                              pageController: followingPageController!,
                              nextPage: index + 1,
                              videoId: controller.followingVideosList[index].id!,
                              gifImage:
                                  controller.followingVideosList[index].gifImage,
                              publicUser:
                                  controller.followingVideosList[index].user,
                              soundName:
                                  controller.followingVideosList[index].soundName,
                              UserId:
                                  controller.followingVideosList[index].user!.id,
                              userName: controller
                                  .followingVideosList[index].user!.username!.obs,
                              description: controller
                                  .followingVideosList[index].description!.obs,
                              hashtagsList: controller
                                      .followingVideosList[index].hashtags,
                              soundOwner: controller
                                  .followingVideosList[index].soundOwner,
                              sound: controller.followingVideosList[index].sound,
                              videoLikeStatus: controller
                                  .followingVideosList[index].videoLikeStatus
                                  .toString(),
                              isCommentAllowed: controller
                                          .followingVideosList[index]
                                          .isCommentable ==
                                      "Yes"
                                  ? true.obs
                                  : false.obs,
                              like: controller
                                  .followingVideosList[index].likes!.obs,
                              isfollow: controller
                                  .followingVideosList[index].user!.isfollow!,
                              commentsCount: controller
                                  .followingVideosList[index].comments!.obs,
                              soundId:
                                  controller.followingVideosList[index].videoLikeStatus,
                              avatar: controller
                                  .followingVideosList[index].user!.avatar,
                              currentPageIndex: index.obs,
                              fcmToken: controller
                                  .followingVideosList[index].user!.firebaseToken,
                            )),
                  ],
                )),
      GetX<TrendingVideosController>(
          builder: (controller) => controller.isLoading.isTrue
              ? loader()
              : Stack(
                  children: [
                    PageView.builder(
                        itemCount: controller.followingVideosList.length,
                        scrollDirection: Axis.vertical,
                        controller: pageController,
                        itemBuilder: (context, index) => TrendingVideosView(
                              videoUrl: controller
                                  .followingVideosList[index].video
                                  .toString(),
                              pageController: pageController!,
                              nextPage: index + 1,
                              videoId: controller.followingVideosList[index].id!,
                              gifImage:
                                  controller.followingVideosList[index].gifImage,
                              publicUser:
                                  controller.followingVideosList[index].user,
                              soundName:
                                  controller.followingVideosList[index].soundName,
                              UserId:
                                  controller.followingVideosList[index].user!.id,
                              userName: controller
                                  .followingVideosList[index].user!.username!.obs,
                              description: controller
                                  .followingVideosList[index].description!.obs,
                              hashtagsList: controller
                                      .followingVideosList[index].hashtags ??
                                  [],
                              soundOwner: controller
                                  .followingVideosList[index].soundOwner,
                              sound: controller.followingVideosList[index].sound,
                              videoLikeStatus: controller
                                  .followingVideosList[index].videoLikeStatus
                                  .toString(),
                              isCommentAllowed: controller
                                          .followingVideosList[index]
                                          .isCommentable ==
                                      "Yes"
                                  ? true.obs
                                  : false.obs,
                              like: controller
                                  .followingVideosList[index].likes!.obs,
                              isfollow: controller
                                  .followingVideosList[index].user!.isfollow!,
                              commentsCount: controller
                                  .followingVideosList[index].comments!.obs,
                              soundId:
                                  controller.followingVideosList[index].videoLikeStatus,
                              avatar: controller
                                  .followingVideosList[index].user!.avatar,
                              currentPageIndex: index.obs,
                              fcmToken: controller
                                  .followingVideosList[index].user!.firebaseToken,
                            )),
                  ],
                )),
    ];
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
}
