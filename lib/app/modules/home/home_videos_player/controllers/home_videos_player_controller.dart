import 'dart:convert';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/modules/following_videos/controllers/following_videos_controller.dart';
import 'package:thrill/app/modules/following_videos/views/following_videos_view.dart';
import 'package:thrill/app/modules/trending_videos/controllers/trending_videos_controller.dart';
import 'package:thrill/app/modules/trending_videos/views/trending_videos_view.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../../rest/models/search_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/utils.dart';
import '../../../related_videos/controllers/related_videos_controller.dart';
import '../../../related_videos/views/related_videos_view.dart';
import '../views/home_videos_player_view.dart';

class HomeVideosPlayerController extends GetxController {
  var storage = GetStorage();
  var selectedIndex = 0.obs;
  final pageController = LoopPageController();
  final trendingPageController = LoopPageController();
  final followingPageController = LoopPageController();
  RxList<SearchData> searchList = RxList();

  var listOfScreens = ["For you", "Following", "Trending"];
  var isVisibleIndicator = [true, false, false];
  List<Widget> videoScreens = [];
  final info = NetworkInfo();
  BetterPlayerEventType? eventType;
  final count = 0.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var playerController = BetterPlayerListVideoPlayerController();
  var followingVideosController = Get.find<FollowingVideosController>();
  var trendingVideosController = Get.find<TrendingVideosController>();
  var relatedVideosController = Get.find<RelatedVideosController>();
  @override
  void onInit() {
    searchHashtags("");
    videoScreens = [
      relatedVideosController.obx(
          (state) => Stack(
                children: [
                  RefreshIndicator(
                      color: ColorManager.colorAccent,
                      child: LoopPageView.builder(
                          itemCount: state!.length,
                          scrollDirection: Axis.vertical,
                          controller: pageController,
                          itemBuilder: (context, index) => RelatedVideosView(
                                videoUrl: state[index].video.toString(),
                                pageController: pageController!,
                                nextPage: index + 1,
                                videoId: state[index].id!,
                                gifImage: state[index].gifImage,
                                publicUser: state[index].user,
                                soundName: state[index].soundName,
                                UserId: state[index].user!.id,
                                userName: state[index].user!.username!.obs,
                                description: state[index].description!.obs,
                                hashtagsList: state[index].hashtags ?? [],
                                soundOwner: state[index].soundOwner ?? "",
                                sound: state[index].sound,
                                videoLikeStatus:
                                    state[index].videoLikeStatus.toString(),
                                isCommentAllowed:
                                    state[index].isCommentable == "Yes"
                                        ? true.obs
                                        : false.obs,
                                like: state[index].likes!.obs,
                                isfollow: state[index].user!.isfollow!,
                                commentsCount: state[index].comments!.obs,
                                soundId: state[index].soundId,
                                avatar: state[index].user!.avatar,
                                currentPageIndex: index.obs,
                                fcmToken: state[index].user!.firebaseToken,
                                isLastPage:
                                    index == (state.length - 1) ? true : false,
                              )),
                      onRefresh: () =>
                          relatedVideosController.refereshVideos()),
                ],
              ),
          onLoading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: loader(),
              )
            ],
          ),
          onError: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(
                    child: Text(
                      "No videos found",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
          onEmpty: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "No following Videos",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )),
      followingVideosController.obx(
        (state) => state!.isEmpty
            ? emptyFollowingLayout()
            : Stack(
                children: [
                  LoopPageView.builder(
                      itemCount: state!.length,
                      scrollDirection: Axis.vertical,
                      controller: followingPageController,
                      itemBuilder: (context, index) => FollowingVideosView(
                            videoUrl: state[index].video.toString(),
                            pageController: followingPageController!,
                            nextPage: index + 1,
                            videoId: state[index].id!,
                            gifImage: state[index].gifImage,
                            publicUser: state[index].user,
                            soundName: state[index].soundName,
                            UserId: state[index].user!.id,
                            userName: state[index].user!.username!.obs,
                            description: state[index].description!.obs,
                            hashtagsList: state[index].hashtags,
                            soundOwner: state[index].soundOwner ?? "",
                            sound: state[index].sound,
                            videoLikeStatus:
                                state[index].videoLikeStatus.toString(),
                            isCommentAllowed:
                                state[index].isCommentable == "Yes"
                                    ? true.obs
                                    : false.obs,
                            like: state[index].likes!.obs,
                            isfollow: state[index].user!.isfollow!,
                            commentsCount: state[index].comments!.obs,
                            soundId: state[index].soundId,
                            avatar: state[index].user!.avatar,
                            currentPageIndex: index.obs,
                            fcmToken: state[index].user!.firebaseToken,
                          )),
                ],
              ),
        onLoading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: loader(),
            )
          ],
        ),
        onError: (error) => Center(
          child: NoSearchResult(
            text: "No Videos Found!",
          ),
        ),
      ),
      trendingVideosController.obx(
          (state) => Stack(
                children: [
                  LoopPageView.builder(
                      itemCount: state!.length,
                      scrollDirection: Axis.vertical,
                      controller: trendingPageController,
                      itemBuilder: (context, index) => TrendingVideosView(
                            videoUrl: state[index].video.toString(),
                            pageController: pageController!,
                            nextPage: index + 1,
                            videoId: state[index].id!,
                            gifImage: state[index].gifImage,
                            publicUser: state[index].user,
                            soundName: state[index].soundName,
                            UserId: state[index].user!.id,
                            userName: state[index].user!.username!.obs,
                            description: state[index].description!.obs,
                            hashtagsList: state[index].hashtags ?? [],
                            soundOwner: state[index].soundOwner,
                            sound: state[index].sound,
                            videoLikeStatus:
                                state[index].videoLikeStatus.toString(),
                            isCommentAllowed:
                                state[index].isCommentable == "Yes"
                                    ? true.obs
                                    : false.obs,
                            like: state[index].likes!.obs,
                            isfollow: state[index].user!.isfollow!,
                            commentsCount: state[index].comments!.obs,
                            soundId: state[index].soundId,
                            avatar: state[index].user!.avatar,
                            currentPageIndex: index.obs,
                            fcmToken: state[index].user!.firebaseToken,
                          )),
                ],
              ),
          onLoading: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: loader(),
              )
            ],
          ),
          onError: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "No Trending Videos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
          onEmpty: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "No following Videos",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )),
    ];
    //  await Future.delayed(Duration(seconds: 2));
    checkDynamicLink();
    super.onInit();
  }

  Future<void> searchHashtags(String searchQuery) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get("hashtag/search?search=$searchQuery").then((value) {
      searchList = SearchHashTagsModel.fromJson(value.data).data!.obs;
    }).onError((error, stackTrace) {});
  }

  emptyFollowingLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Top Creators",
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Follow top profiles to see quality videos here",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.5),
                fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: CarouselSlider.builder(
                itemCount: searchList[0].users!.length,
                itemBuilder: (context, index, pageViewIndex) => Column(
                      children: [
                        Expanded(
                            child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            InkWell(
                              onTap: () async {
                                checkForLogin(() {
                                  Get.toNamed(Routes.OTHERS_PROFILE,
                                      arguments: {
                                        "profileId":
                                            searchList[0].users![index].id
                                      });
                                });
                              },
                              child: CachedNetworkImage(
                                  placeholder: (a, b) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  fit: BoxFit.fill,
                                  height: 200,
                                  width: 150,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                  errorWidget: (context, string, dynamic) =>
                                      CachedNetworkImage(
                                          placeholder: (a, b) => Center(
                                                child: loader(),
                                              ),
                                          fit: BoxFit.fill,
                                          height: 60,
                                          width: 60,
                                          imageBuilder: (context,
                                                  imageProvider) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                          imageUrl:
                                              "https://st4.depositphotos.com/9998432/24359/v/600/depositphotos_243599464-stock-illustration-person-gray-photo-placeholder-man.jpg"),
                                  imageUrl: RestUrl.profileUrl +
                                      searchList[0].users![index].avatar!),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              width: 150,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3), //New
                                    blurRadius: 25.0,
                                  )
                                ],
                              ),
                              child: Text(
                                searchList[0].users![index].name ??
                                    searchList[0].users![index].username!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        )),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () => {
                            checkForLogin(() {
                              followUnfollowUser(
                                  searchList[0].users![index].id!,
                                  (searchList[0].users![index].isfollow ??
                                              searchList[0]
                                                  .users![index]
                                                  .isFollowCount) ==
                                          0
                                      ? "follow"
                                      : "unfollow",
                                  fcmToken: searchList[0]
                                      .users![index]
                                      .firebaseToken!,
                                  image: searchList[0].users![index].avatar!);
                            })
                          },
                          child: (searchList[0].users![index].isfollow ??
                                      searchList[0]
                                          .users![index]
                                          .isFollowCount) ==
                                  0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: ColorManager.colorAccent,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Follow",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: ColorManager.colorAccent),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text(
                                    "Following",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.colorAccent),
                                  ),
                                ),
                        )
                      ],
                    ),
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.5,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.bounceIn,
                  enlargeCenterPage: false,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                )),
          )
        ],
      );
  Future<void> followUnfollowUser(
    int userId,
    String action, {
    String fcmToken = "",
    String image = "",
    String name = "",
  }) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      if (value.data["status"]) {
        if (action == "follow") {
          sendNotification(fcmToken,
              body: "$name started following you!",
              title: "New follower!",
              image: image);
        }
        followingVideosController.getAllVideos(false);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

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
        "url": image,
        "body": body,
        "title": title,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image": image
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  checkDynamicLink() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      if (initialLink.link.queryParameters["type"] == "profile") {
        // Get.toNamed(Routes.OTHERS_PROFILE, arguments: {
        //   "profileId": pendingDynamicLinkData.link.queryParameters["id"]
        // });
        successToast(initialLink.link.queryParameters["type"].toString());
      } else if (initialLink.link.queryParameters["type"] == "video") {
        successToast(initialLink.link.queryParameters["id"].toString());
      } else if (initialLink.link.queryParameters["type"] == "referal") {
        await GetStorage().write("referral_code",
            initialLink.link.queryParameters["referal"].toString());
        successToast(initialLink!.link.queryParameters["referal"].toString());
      }
    }
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
