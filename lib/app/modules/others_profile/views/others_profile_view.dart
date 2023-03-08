import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/others_profile/other_user_videos/views/other_user_videos_view.dart';
import 'package:thrill/app/modules/others_profile/others_liked_videos/views/others_liked_videos_view.dart';

import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';
import '../controllers/others_profile_controller.dart';

class OthersProfileView extends GetView<OthersProfileController> {
  const OthersProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedTab = 0.obs;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20,),
          controller.obx(
            (state) => Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/profile_background.svg",
                      fit: BoxFit.contain,
                      width: Get.width,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/23.svg",
                          height: 100,
                          width: 100,
                        ),
                        Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            height: 80,
                            width: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: state!.value.avatar.toString().isEmpty
                                  ? RestUrl.placeholderImage
                                  : '${RestUrl.profileUrl}${state.value.avatar}',
                              placeholder: (a, b) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.value.name}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Visibility(
                        visible: state.value.isVerified == 'true',
                        child: SvgPicture.asset(
                          'assets/verified.svg',
                        ))
                  ],
                ),
                Text(
                  '@${state.value.username}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.OTHERS_FOLLOWERS,arguments: {"index":0});
                        },
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${state.value.following}'
                                    '\n',
                                style: TextStyle(
                                    color: Get.isPlatformDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: following,
                                style: TextStyle(
                                    color: Get.isPlatformDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ])),
                    ),
                    const SizedBox(
                      height: 45,
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.OTHERS_FOLLOWERS,arguments: {"index":1});

                        // followersController
                        //     .getUserFollowers(state.value.id!)
                        //     .then((value) => followersController
                        //         .getUserFollowing(state.value.id!)
                        //         .then((value) => Get.to(FollowingAndFollowers(
                        //             false.obs, state.value.id!.obs))));

                        // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                      },
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${state.value.followers}'
                                    '\n',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Get.isPlatformDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: followers,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Get.isPlatformDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500)),
                          ])),
                    ),
                    Container(
                      height: 45,
                      child: const VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ),
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '${state.value.likes!.isEmpty ? 0 : state.value.likes}'
                                  '\n',
                              style: TextStyle(
                                  color: Get.isPlatformDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: likes,
                              style: TextStyle(
                                  color: Get.isPlatformDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ])),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: ColorManager.colorAccent),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: InkWell(
                              onTap: () {
                                // userDetailsController.followUnfollowUser(
                                //     int.parse(controller
                                //         .otherUserProfile.value.id
                                //         .toString()),
                                //     isFollow!.value == 0
                                //         ? "follow"
                                //         : "unfollow",
                                //     token: controller
                                //         .otherUserProfile.value.firebaseToken
                                //         .toString());
                                // userDetailsController
                                //     .getOtherUserProfile(userId);
                              },
                              child: Text(
                                  isFollow == 0 ? "Follow" : "Following",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ))),
                    Expanded(
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: ColorManager.colorAccent),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: InkWell(
                              onTap: () {
                                // Get.to(ChatScreen(
                                //     inboxModel: Inbox(
                                //         id: controller
                                //             .otherUserProfile.value.id,
                                //         userImage: controller
                                //             .otherUserProfile.value.avatar,
                                //         name: controller
                                //             .otherUserProfile.value.name)));
                              },
                              child: const Text("Message",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ))),
                    ClipOval(
                      child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/referral');
                          },
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: ColorManager.colorAccentTransparent),
                              padding: const EdgeInsets.all(15),
                              child: Icon(
                                Icons.camera,
                                size: 16,
                                color: ColorManager.dayNightIcon,
                              ))),
                    ),
                    ClipOval(
                      child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/referral');
                          },
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: ColorManager.colorAccentTransparent),
                              padding: const EdgeInsets.all(15),
                              child: Icon(
                                Icons.bookmark,
                                size: 16,
                                color: ColorManager.dayNightIcon,
                              ))),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            onLoading: loader(),
            onEmpty: emptyListWidget(),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 10,

                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  bottom:
                      TabBar(onTap: (index) => selectedTab.value = index, tabs: [
                    Obx(() => Tab(
                          icon: Icon(
                            Icons.dashboard,
                            color: selectedTab.value == 0
                                ? ColorManager.colorAccent
                                : ColorManager.colorAccentTransparent,
                          ),
                        )),
                    Obx(() => Tab(
                          icon: Icon(
                            Icons.favorite,
                            color: selectedTab.value == 1
                                ? ColorManager.colorAccent
                                : ColorManager.colorAccentTransparent,
                          ),
                        ))
                  ]),
                ),
                body: const TabBarView(
                  children: [OtherUserVideosView(), OthersLikedVideosView()],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
