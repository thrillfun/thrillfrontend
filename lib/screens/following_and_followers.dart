import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/utils/util.dart';

var selectedTabIndex = 0.obs;
var usersController = Get.find<UserController>();
var discoverController = Get.find<DiscoverController>();

class FollowingAndFollowers extends GetView<UserController> {
  var usersController = Get.find<UserController>();
  var selectedTab = 0.obs;

  FollowingAndFollowers({this.isProfile});

  RxBool? isProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => Get.to(SearchGetx()), icon: Icon(Icons.search))
          ],
          iconTheme: IconThemeData(
              color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
          backgroundColor: Colors.transparent.withOpacity(0.0),
          elevation: 0,
          title: Text(
            usersController.userProfile.value.name.toString(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
          ),
        ),
        body: ListView(
          children: [
            Obx(() => DefaultTabController(
                length: 3,
                initialIndex: selectedTab.value,
                child: TabBar(
                    onTap: (int index) {
                      selectedTab.value = index;
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    indicatorColor: const Color(0XffB2E3E3),
                    labelColor: ColorManager.colorAccent,
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18),
                    tabs: const [
                      Tab(
                        text: "Followers",
                      ),
                      Tab(
                        text: "Following",
                      ),
                      Tab(
                        text: "Suggested",
                      ),
                    ]))),
            Obx(() => tabview())
          ],
        ));
  }

  tabview() {
    if (selectedTab.value == 0) {
      return followersLayout();
    } else if (selectedTab.value == 1) {
      return followingLayout();
    } else {
      return suggested();
    }
  }

  followingLayout() => GetX<UserController>(builder:(usersController)=>
  usersController.isFollowingLoading.isTrue?Container(height: Get.height,width: Get.width,child: Center(child: loader(),),color: ColorManager.dayNight,):
  usersController.followingModel.isEmpty?Container(
    width: Get.width,
    height: Get.height,
    alignment: Alignment.center,
    child: const Text(
      "You are following nobody!",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
    ),
  ):Wrap(
    children: List.generate(
        controller.followingModel.length,
            (index) => Container(
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
                      onTap: () => controller
                          .getOthersProfile(
                          controller.followingModel[index].id!)
                          .then((value) => Get.to(ViewProfile(
                          controller.followingModel[index].id
                              .toString(),
                          controller.followingModel[index]
                              .isfollowing!.obs,controller.followingModel[index].name.toString()))),
                      child: imgProfile(controller
                          .followingModel[index].avtars
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
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            controller.followingModel[index].name
                                .toString() +
                                " | " +
                                controller
                                    .followingModel[index].rating
                                    .toString(),
                            maxLines: 1,
                            style: const TextStyle(
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
                  controller.followUnfollowUser(
                      controller.followingModel[index].id!,
                      "unfollow",
                      id: controller.userProfile.value.id);
                },
                child: Container(
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
        )),
  ) );

  followersLayout() => GetX<UserController>(
      builder: (usersController) =>
      usersController.isFollowersLoading.isTrue?Container(height: Get.height,width: Get.width,child: Center(child: loader(),),color: ColorManager.dayNight,):
      usersController.followersModel.isEmpty
          ? Flexible(
              child: Container(
              width: Get.width,
              height: Get.height,
              alignment: Alignment.center,
              child: const Text(
                "There are no followers!",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
              ),
            ))
          : Wrap(
              children: List.generate(
                  controller.followersModel.length,
                  (index) => InkWell(
                        onTap: () => controller
                            .getUserProfile(
                                controller.followingModel[index].id!)
                            .then((value) => Get.to(ViewProfile(
                                controller.followersModel[index].id.toString(),
                                controller
                                    .followersModel[index].isfollowing!.obs,controller.followersModel[index].name.toString()))),
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
                                        .followersModel[index].avtars
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
                                                .followersModel[index].name
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            controller
                                                    .followersModel[index].name
                                                    .toString() +
                                                " | " +
                                                controller.followersModel[index]
                                                    .rating
                                                    .toString(),
                                            style: const TextStyle(
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
                                  controller.followUnfollowUser(
                                      controller.followersModel[index].id!,
                                      controller.followersModel[index]
                                                  .isfollowing ==
                                              0
                                          ? "follow"
                                          : "unfollow");
                                },
                                child: controller.followersModel[index]
                                            .isfollowing ==
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
            ));

  suggested() => GetX<DiscoverController>(builder: (discoverController)=>
  discoverController.searchList.isEmpty? Container(
    width: Get.width,
    height: Get.height,
    alignment: Alignment.center,
    child: const Text(
      "There are no followers!",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
    ),
  ):
      ListView.builder(
      shrinkWrap: true,
      itemCount: discoverController.searchList[0].users!.length,
      itemBuilder: (context, index) => Container(
        width: Get.width,
        margin:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Row(
                children: [
                  imgProfile(discoverController
                      .searchList[0].users![index].avatar
                      .toString()),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discoverController
                              .searchList[0].users![index].name
                              .toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          discoverController
                              .searchList[0].users![index].name
                              .toString() +
                              " | " +
                              discoverController
                                  .searchList[0].users![index].likes
                                  .toString(),
                          style: const TextStyle(
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
                    discoverController.searchList[0].users![index].id!,
                    discoverController
                        .searchList[0].users![index].isfollow ==
                        0
                        ? "follow"
                        : "unfollow");
              },
              child: discoverController
                  .searchList[0].users![index].isfollow ==
                  0
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: ColorManager.colorAccent,
                    borderRadius: BorderRadius.circular(20)),
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
      )));
}
