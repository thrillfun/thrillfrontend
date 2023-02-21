import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/better_video_player.dart';

import '../controller/users/followers_controller.dart';
import '../controller/videos/UserVideosController.dart';
import '../controller/videos/like_videos_controller.dart';

class FollowingAndFollowers extends GetView<UserController> {
  var usersController = Get.find<UserController>();
  var selectedTab = 0.obs;

  FollowingAndFollowers(this.isProfile, this.userId);

  var isProfile = false.obs;
  var userId = 0.obs;
  var selectedTabIndex = 0.obs;
  var discoverController = Get.find<DiscoverController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: ColorManager.dayNight,
            appBar: AppBar(
              bottom: TabBar(
                  unselectedLabelColor: Get.isPlatformDarkMode
                      ? Colors.white
                      : const Color(0xff9E9E9E),
                  indicatorColor: ColorManager.colorAccent,
                  labelColor: ColorManager.colorAccent,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  automaticIndicatorColorAdjustment: true,
                  onTap: (int index) {
                    if (isProfile.isTrue) {
                      if (index == 0) {
                        controller.getUserFollowers(
                            controller.storage.read("userId"));
                      } else {
                        controller.getUserFollowing(
                            controller.storage.read("userId"));
                      }
                    } else {
                      if (index == 0) {
                        controller.getUserFollowers(userId.value);
                      } else {
                        controller.getUserFollowing(userId.value);
                      }
                    }
                    selectedTab.value = index;
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(
                      text: "Followers",
                    ),
                    Tab(
                      text: "Following",
                    )
                  ]),
              actions: [
                IconButton(
                    onPressed: () => Get.to(SearchGetx()),
                    icon: Icon(
                      Icons.search,
                      color: ColorManager.dayNightText,
                    ))
              ],
              iconTheme: IconThemeData(color: ColorManager.dayNightText),
              backgroundColor: Colors.transparent.withOpacity(0.0),
              elevation: 0,
              title: Text(
                usersController.userProfile.value.name ?? "",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.dayNightText),
              ),
            ),
            body:
                TabBarView(children: [followersLayout(), followingLayout()])));
  }



  followingLayout() => Followings(isProfile, userId.value);

  followersLayout() => Followers(userId.value);

  suggested() => SearchData();
}

class Followings extends GetView<FollowersController> {
  var userDetailsController = Get.find<UserDetailsController>();
  var usersController = Get.find<UserController>();
  var likedVideosController = Get.find<LikedVideosController>();
  var userVideosController = Get.find<UserVideosController>();

  Followings(this.isProfile, this.userid);

  var isProfile = false.obs;
  var userid = 0;
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (_) => controller.followingModel.isEmpty
            ? Column(
                children: [emptyListWidget()],
              )
            : ListView.builder(
                itemCount: controller.followingModel!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => controller
                        .followingModel.isEmpty
                    ? emptyListWidget()
                    : Container(
                        width: Get.width,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      controller.followingModel![index].id ==
                                              GetStorage().read("userId")
                                          ? await likedVideosController
                                              .getUserLikedVideos()
                                          : await likedVideosController
                                              .getOthersLikedVideos(controller
                                                  .followingModel![index].id!);

                                      controller.followingModel![index].id ==
                                              GetStorage().read("userId")
                                          ? await userVideosController
                                              .getUserVideos()
                                          : await userVideosController
                                              .getOtherUserVideos(controller
                                                  .followingModel![index].id!);
                                      controller.followingModel![index].id ==
                                              GetStorage().read("userId")
                                          ? await userDetailsController
                                              .getUserProfile()
                                              .then(
                                                  (value) => Get.to(Profile()))
                                          : await otherUsersController
                                              .getOtherUserProfile(controller
                                                  .followingModel![index].id!)
                                              .then((value) => Get.to(ViewProfile(
                                                  controller.followingModel[index].id
                                                      .toString(),
                                                  controller
                                                      .followingModel[index]
                                                      .isFolling!
                                                      .obs,
                                                  controller.followingModel[index].name.toString(),
                                                  controller.followingModel[index].avtars.toString())));
                                    },
                                    child: imgProfile(controller
                                        .followingModel![index].avtars
                                        .toString()),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.followingModel[index].name
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: ColorManager.dayNightText,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          controller
                                              .followingModel[index].username
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: ColorManager.dayNightText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (isProfile.isTrue) {
                                  userController.followUnfollowUser(
                                    controller.followingModel[index].id!,
                                    "unfollow",
                                  );
                                } else {
                                  usersController.followUnfollowUser(
                                      controller.followersModel[index].id!,
                                      controller.followersModel[index]
                                                  .isFolling ==
                                              0
                                          ? "follow"
                                          : "unfollow");
                                }
                                controller.getUserFollowing(this.userid);
                                ;
                              },
                              child: isProfile.isTrue
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ColorManager.colorAccent),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text(
                                        "Following",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: ColorManager.colorAccent),
                                      ),
                                    )
                                  : controller.followingModel[index]
                                              .isFolling ==
                                          0
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: ColorManager.colorAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Text(
                                            "Follow",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      ColorManager.colorAccent),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Text(
                                            "Following",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorManager.colorAccent),
                                          ),
                                        ),
                            )
                          ],
                        ),
                      )),
        onLoading: Column(
          children: [Expanded(child: loader())],
        ),
        onEmpty: Column(
          children: [emptyListWidget()],
        ));
  }
}

class Followers extends GetView<FollowersController> {
  Followers(this.userId);
  var userDetailsController = Get.find<UserDetailsController>();
  var usersController = Get.find<UserController>();

  var likedVideosController = Get.find<LikedVideosController>();
  var userVideosController = Get.find<UserVideosController>();
  var userId = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
      (state) => controller.followersModel.isEmpty
          ? Column(
              children: [emptyListWidget()],
            )
          : Wrap(
              children: List.generate(
                  controller.followersModel.length,
                  (index) => InkWell(
                        onTap: () async {
                          state![index].id == GetStorage().read("userId")
                              ? await likedVideosController.getUserLikedVideos()
                              : await likedVideosController
                                  .getOthersLikedVideos(state![index].id!);

                          state![index].id == GetStorage().read("userId")
                              ? await userVideosController.getUserVideos()
                              : await userVideosController
                                  .getOtherUserVideos(state[index].id!);
                          state![index].id == GetStorage().read("userId")
                              ? await userDetailsController
                                  .getUserProfile()
                                  .then((value) => Get.to(Profile()))
                              : await otherUsersController
                                  .getOtherUserProfile(state[index].id!)
                                  .then((value) => Get.to(ViewProfile(
                                      controller.followersModel[index].id
                                          .toString(),
                                      controller
                                          .followersModel[index].isFolling!.obs,
                                      controller.followersModel[index].name
                                          .toString(),
                                      controller.followersModel[index].avtars
                                          .toString())));
                        },
                        child: Container(
                          width: Get.width,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    imgProfile(controller
                                        .followersModel![index].avtars
                                        .toString()),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller
                                                .followersModel![index].name
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color:
                                                    ColorManager.dayNightText,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            controller
                                                .followersModel[index].username
                                                .toString(),
                                            style: TextStyle(
                                                color:
                                                    ColorManager.dayNightText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  usersController.followUnfollowUser(
                                      controller.followersModel[index].id!,
                                      controller.followersModel[index]
                                                  .isFolling ==
                                              0
                                          ? "follow"
                                          : "unfollow");

                                  controller.getUserFollowers(userId);
                                },
                                child: controller
                                            .followersModel[index].isFolling ==
                                        0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: ColorManager.colorAccent,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: const Text(
                                          "Follow",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    ColorManager.colorAccent),
                                            borderRadius:
                                                BorderRadius.circular(20)),
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
                        ),
                      )),
            ),
      onLoading: Column(
        children: [Expanded(child: loader())],
      ),
    );
  }
}
