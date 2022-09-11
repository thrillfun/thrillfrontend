import 'dart:convert';
import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/level_model.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import '../controller/data_controller.dart';
import '../models/follower_model.dart';
import '../widgets/video_item.dart';

var controller = Get.find<DataController>();
  var selectedTabIndex = 0.obs;

class FollowingAndFollowers extends StatelessWidget {
  var usersController = Get.find<UserController>();

  FollowingAndFollowers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    usersController.getUserFollowers(usersController.userId.value);
    usersController.getUserFollowing(usersController.userId.value);

    return GetX<UserController>(
        builder: ((userController) => Scaffold(
            backgroundColor: Colors.grey.shade300,
            body: SafeArea(
                child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color(0xFF2F8897),
                    Color(0xff1F2A52),
                    Color(0xff1F244E)
                  ])),
                  alignment: Alignment.bottomCenter,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => selectedTabIndex.value = 0,
                              child: Text(
                                followers,
                                style: TextStyle(
                                  color: selectedTabIndex.value == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => selectedTabIndex.value = 1,
                              child: Text(
                                following,
                                style: TextStyle(
                                  color: selectedTabIndex.value == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedAlign(
                          alignment: selectedTabIndex.value == 0
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: ColorManager.cyan,
                            height: 3,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                          ))
                    ],
                  ),
                ),
                selectedTabIndex.value == 1
                    ? usersController.followingModel.value.isEmpty
                        ? const Flexible(
                            child: Center(
                              child: Text(
                                "You are not following anyone",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : followingTabLayout()
                    : usersController.followersModel.value.isEmpty
                        ? const Flexible(
                            child: Center(
                            child: Text("No Followers Yet",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ))
                        : followersTabLayout()
              ],
            )))));
  }

  followingTabLayout() {
    return GetX<UserController>(
        init: UserController(),
        builder: (controller) => controller.isFollowingLoading.value
            ? const Flexible(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : Expanded(
                child: ListView.builder(
                  itemCount: controller.followingModel.value.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(2),
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: Colors.white60)),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      errorWidget: (a, b, c) => Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SvgPicture.asset(
                                          'assets/profile.svg',
                                          width: 10,
                                          height: 10,
                                          fit: BoxFit.contain,
                                          color: Colors.white60,
                                        ),
                                      ),
                                      imageUrl: controller.followingModel!
                                              .value[index].avtars!.isEmpty
                                          ? "https://www.pngmart.com/files/21/Account-Avatar-Profile-PNG-Photo.png"
                                          : '${RestUrl.profileUrl}${controller.followingModel.value[index].avtars}',
                                      placeholder: (a, b) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    usersController.userId.value =
                                        controller.followingModel[index].id!;
                                    Get.to(ViewProfile(
                                      mapData: {},
                                      userId: controller
                                          .followingModel[index].id!
                                          .toString(),
                                    ));
                                  },
                                  child: Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        controller.followingModel!.value![index]
                                            .username!,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        controller.followingModel!.value![index]
                                            .name!,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      // Text(
                                      //   getStarredEmail(followingList[index].email),
                                      //   style: const TextStyle(
                                      //       color: Colors.black, fontSize: 12),
                                      //   overflow: TextOverflow.ellipsis,
                                      //   maxLines: 1,
                                      // ),
                                      // const SizedBox(
                                      //   height: 2,
                                      // ),
                                      // Text(
                                      //   getFormattedDate(followingList[index].date),
                                      //   style: const TextStyle(
                                      //       color: Colors.black, fontSize: 12),
                                      //   overflow: TextOverflow.ellipsis,
                                      //   maxLines: 1,
                                      // ),
                                    ],
                                  )),
                                ),
                              ),
                              GetX<DataController>(
                                  builder: (dataController) => Visibility(
                                      visible: dataController.isMyProfile.value,
                                      child: IconButton(
                                          onPressed: () async {
                                            var response = await dataController
                                                .followUnfollowUser(controller
                                                    .followingModel!
                                                    .value![index]
                                                    .id!);
                                            GetSnackBar(
                                              message: "${response.message}",
                                              title: "Unfollowed",
                                              duration: Duration(seconds: 3),
                                              backgroundGradient:
                                                  LinearGradient(colors: [
                                                Color(0xFF2F8897),
                                                Color(0xff1F2A52),
                                                Color(0xff1F244E)
                                              ]),
                                              isDismissible: true,
                                            ).show();
                                          },
                                          icon: Icon(Icons.person_remove))))
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 2,
                        )
                      ],
                    );
                  },
                ),
              ));
  }

  followersTabLayout() {
    return GetX<UserController>(
        init: UserController(),
        builder: ((controller) => controller.isFollowersLoading.value
            ? const Flexible(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : Expanded(
                child: ListView.builder(
                  itemCount: controller.followersModel.value.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            controller.userId.value =
                                controller.followersModel[index].id!;
                            Get.off(ViewProfile(
                              mapData: {},
                              userId: controller.userId.value.toString(),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.white60)),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget: (a, b, c) => Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: SvgPicture.asset(
                                            'assets/profile.svg',
                                            width: 10,
                                            height: 10,
                                            fit: BoxFit.contain,
                                            color: Colors.white60,
                                          ),
                                        ),
                                        imageUrl: controller.followersModel
                                                .value[index].avtars!.isEmpty
                                            ? "https://www.pngmart.com/files/21/Account-Avatar-Profile-PNG-Photo.png"
                                            : '${RestUrl.profileUrl}${controller.followersModel.value![index].avtars!}',
                                        placeholder: (a, b) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      controller.followersModel.value![index]
                                          .username!,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      controller
                                          .followersModel.value[index].name!,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    // Text(
                                    //   getStarredEmail(followerList[index].email),
                                    //   style: const TextStyle(
                                    //       color: Colors.black, fontSize: 12),
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 1,
                                    // ),
                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Text(
                                    //   getFormattedDate(followerList[index].date),
                                    //   style: const TextStyle(
                                    //       color: Colors.black, fontSize: 12),
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 1,
                                    // ),
                                  ],
                                )),
                                GetX<DataController>(
                                    builder: (dataController) => Visibility(
                                        visible:
                                            dataController.isMyProfile.value,
                                        child: InkWell(
                                          child: Text('follow'),
                                          onTap: () async {
                                            var response = await dataController
                                                .followUnfollowUser(
                                                    usersController
                                                        .userId.value);
                                            GetSnackBar(
                                              message: "${response.message}",
                                              title: "Unfollowed",
                                              duration: Duration(seconds: 3),
                                              backgroundGradient:
                                                  const LinearGradient(colors: [
                                                Color(0xFF2F8897),
                                                Color(0xff1F2A52),
                                                Color(0xff1F244E)
                                              ]),
                                              isDismissible: true,
                                            ).show();
                                          },
                                        )))
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                        )
                      ],
                    );
                  },
                ),
              )));
  }
}
