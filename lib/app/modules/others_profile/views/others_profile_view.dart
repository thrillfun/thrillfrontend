import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
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
    controller.getUserProfile(Get.arguments["profileId"]);
    controller.searchHashtags("");
    return Scaffold(
      body: controller.obx(
          (state) => Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent.withOpacity(0.0),
                actions:   [InkWell(
                    onTap: () async {
                      Share.share(
                          await controller
                              .createDynamicLink(
                              controller
                                  .userProfile
                                  .value
                                  .id
                                  .toString(),
                              "profile",
                              controller
                                  .userProfile
                                  .value
                                  .name!,
                              controller
                                  .userProfile
                                  .value
                                  .avatar!));
                    },
                    child: Container(
                        margin: const EdgeInsets
                            .symmetric(
                            horizontal: 10),
                        padding:
                        const EdgeInsets.all(15),
                        child: Icon(
                          Icons.share,
                          size: 18,
                          color: Colors.white
                              ,
                        )))],
              ),
              body: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                            gradient: ColorManager.postGradient,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewPadding.top,
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).viewPadding.top,
                          ),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20, top: 60),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 80,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${state!.value.name.toString().isEmpty ? state.value.username : state.value.name}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Visibility(
                                            visible: state.value.isVerified ==
                                                'true',
                                            child: SvgPicture.asset(
                                              'assets/verified.svg',
                                            ))
                                      ],
                                    ),
                                    Text(
                                      '@${state.value.username}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Visibility(
                                      visible:
                                          state.value.bio.toString().isNotEmpty,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: ReadMoreText(
                                            state.value.bio.toString() + " ",
                                            trimLines: 2,
                                            colorClickableText:
                                            ColorManager.colorAccent,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'More',
                                            trimExpandedText: 'Less',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                            moreStyle: TextStyle(
                                                fontSize: 14,
                                                color: ColorManager.colorAccent,
                                                fontWeight: FontWeight.w700),
                                            lessStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                ColorManager.colorAccent),
                                          )),),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.OTHERS_FOLLOWERS,
                                                arguments: {
                                                  "index": 0,
                                                  "profileId":
                                                      "${state.value.id}"
                                                });
                                          },
                                          child: Column(
                                            children: [
                                              Obx(() => Text('${state.value.following}',
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                      FontWeight.w700))),
                                              const Text(following,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300))
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.OTHERS_FOLLOWERS,
                                                arguments: {
                                                  "index": 1,
                                                  "profileId":
                                                      "${state.value.id}"
                                                });
                                          },
                                          child: Column(
                                            children: [
                                              Text('${state.value.followers}',
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const Text(followers,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300))
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                                '${state.value.likes == null || state.value.likes!.isEmpty ? 0 : state.value.likes}',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                    FontWeight.w700)),
                                            const Text(likes,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w300))
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: ColorManager
                                                        .colorAccent),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 20),
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.followUnfollowUser(
                                                        controller.userProfile
                                                            .value.id!,
                                                        controller.isUserFollowed.isFalse
                                                            ? "follow"
                                                            : "unfollow");

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
                                                  child: Obx(() => Text(
                                                      controller
                                                      .isUserFollowed.isFalse
                                                          ? "Follow"
                                                          : "Following",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.white))),
                                                ))),
                                        // Expanded(
                                        //     child: Container(
                                        //         margin:
                                        //             const EdgeInsets.symmetric(
                                        //                 horizontal: 10),
                                        //         alignment: Alignment.center,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius:
                                        //               BorderRadius.circular(20),
                                        //           border: Border.all(
                                        //               color: ColorManager
                                        //                   .colorAccent),
                                        //         ),
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //                 vertical: 10,
                                        //                 horizontal: 20),
                                        //         child: InkWell(
                                        //           onTap: () {
                                        //             // Get.to(ChatScreen(
                                        //             //     inboxModel: Inbox(
                                        //             //         id: controller
                                        //             //             .otherUserProfile.value.id,
                                        //             //         userImage: controller
                                        //             //             .otherUserProfile.value.avatar,
                                        //             //         name: controller
                                        //             //             .otherUserProfile.value.name)));
                                        //           },
                                        //           child: const Text("Message",
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 fontWeight:
                                        //                     FontWeight.w600,
                                        //               )),
                                        //         ))),
                                     Padding(padding: EdgeInsets.only(right: 10),child:    InkWell(
                                         onTap: () {
                                           controller.isFollowingVisible
                                               .toggle();
                                         },
                                         child: Column(children: [Icon(
                                           IconlyBroken.user_2,
                                           size: 28,
                                           color: ColorManager
                                               .dayNightIcon,
                                         )],)),)


                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => Get.defaultDialog(
                                    title: "",
                                    middleText: "",
                                    backgroundColor:
                                        Colors.transparent.withOpacity(0.0),
                                    contentPadding: EdgeInsets.zero,
                                    content: SizedBox(
                                      height: Get.height / 2,
                                      child: imgProfileDialog(
                                          state.value.avatar.toString()),
                                    )),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/profile_progress.svg",
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                      ),
                                      Container(
                                        height: 80,
                                        width: 80,
                                        child: imgProfileDetails(
                                            state!.value.avatar.toString()),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
          Obx(() => Visibility(
              visible: controller.isFollowingVisible.isTrue,
              child:GetX<OthersProfileController>(builder: (controller)=>controller.isSuggestedLoading.isTrue?loader(): Container(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        controller.searchList[0].users!.length,
                            (index) => InkWell(
                          onTap: () => Get.offAndToNamed(Routes.OTHERS_PROFILE,arguments:{"profileId": controller.searchList[0].users![index].id!})
                          ,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    InkWell(
                                      onTap: ()  {
                                        Get.offAndToNamed(Routes.OTHERS_PROFILE,arguments:{"profileId": controller.searchList[0].users![index].id!});
                                        // controller.getUserProfile(controller.followersModel[index].id! );
                                      },
                                      child: imgProfile( controller.searchList[0].users![index]
                                          .avatar
                                          .toString()),
                                    ),
                                    InkWell(
                                      onTap: () => controller
                                          .followUnfollowTopUser(
                                          controller.searchList[0].users![
                                          index]
                                              .id!,
                                          controller.searchList[0].users![index]
                                              .isfollow ==
                                              0
                                              ? "follow"
                                              : "unfollow"),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape
                                                .circle,
                                            color: ColorManager
                                                .colorPrimaryLight
                                                .withOpacity(
                                                0.5)),
                                        child: Icon(
                                          controller.searchList[0].users![index].isfollow ==
                                              0
                                              ? Icons.add
                                              : Icons.remove ,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(

                                  controller.searchList[0].users![index]
                                      .name
                                      ??
                                      controller.searchList[0].users![index]
                                          .username.toString()
                                  ,

                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,),
                                )
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
              ))

             )
                  )
                  ,
                  Expanded(
                    child: DefaultTabController(
                      length: 1,
                      child: Scaffold(
                        body: Column(
                          children: [
                            TabBar(
                                onTap: (index) => selectedTab.value = index,
                                tabs: [
                                  Tab(
                                    text: "Posts",
                                  ),
                                  // Tab(
                                  //   text: "Liked",
                                  // )
                                ]),
                            Expanded(
                                child: TabBarView(
                              children: [
                                OtherUserVideosView(),
                                // OthersLikedVideosView()
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          onLoading: Container(
            child: loader(),
            height: Get.height,
            width: Get.width,
            alignment: Alignment.center,
          )),
    );
  }
}
