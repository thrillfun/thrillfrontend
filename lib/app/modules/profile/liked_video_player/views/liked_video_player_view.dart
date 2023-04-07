import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/rest/models/user_liked_videos_model.dart';

import '../../../../rest/models/site_settings_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../../../comments/controllers/comments_controller.dart';
import '../../../comments/views/comments_view.dart';
import '../../../login/views/login_view.dart';
import '../controllers/liked_video_player_controller.dart';

class LikedVideoPlayerView extends GetView<LikedVideoPlayerController> {
  const LikedVideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pageViewController = PageController(
        initialPage: Get.arguments["init_page"]);
    var playerController = BetterPlayerListVideoPlayerController();
    var commentsController = Get.find<CommentsController>();
    late AnimationController _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
          itemCount: (Get.arguments["liked_videos"] as List<LikedVideos>)
              .length,
          scrollDirection: Axis.vertical,
          controller: pageViewController,
          itemBuilder: (context, index) {
            _controller = AnimationController(vsync: Scaffold.of(context));

            return Stack(children: [
              InkWell(
                onTapDown: (istap) {
                  playerController.pause();
                },
                onTapUp: (istap) {
                  if (controller.eventType == BetterPlayerEventType.play) {
                    playerController.pause();
                  }
                  else {
                    playerController.play();
                  }
                },
                onTap: () {},
                onDoubleTap: () {},
                child: BetterPlayerListVideoPlayer(

                  BetterPlayerDataSource.network(RestUrl.videoUrl +
                      (Get.arguments["liked_videos"] as List<
                          LikedVideos>)[index]
                          .video!),
                  betterPlayerListVideoPlayerController: playerController,
                  configuration: BetterPlayerConfiguration(
                      autoPlay: true,
                      aspectRatio: Get.size.aspectRatio,
                      fit: Get.size.aspectRatio <
                          1.5 ? BoxFit.contain : BoxFit.fill,
                      eventListener: (eventListener) async {
                        controller.eventType =
                            eventListener.betterPlayerEventType;
                        if (eventListener.betterPlayerEventType ==
                            BetterPlayerEventType.finished &&
                            eventListener.betterPlayerEventType !=
                                BetterPlayerEventType.pause &&
                            eventListener.betterPlayerEventType !=
                                BetterPlayerEventType.play) {
                          if (Get.isBottomSheetOpen == false) {
                            playerController.seekTo(Duration.zero);

                            pageViewController.animateToPage(index + 1,
                                duration: Duration(seconds: 1),
                                curve: Curves.easeIn);
                          }
                          // videosController
                          //     .postVideoView(state[index].id!)
                          //     .then((value) {
                          //
                          // });
                        }
                      },
                      controlsConfiguration:
                      const BetterPlayerControlsConfiguration(
                          showControls: false)),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10, right: 20),
                      child: Column(
                        children: [
                          LikeButton(
                              countPostion: CountPostion.bottom,
                              size: 28,
                              circleColor: CircleColor(
                                  start: Colors.red.shade200,
                                  end: Colors.red),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Colors.red.shade200,
                                dotSecondaryColor: Colors.red,
                              ),
                              likeBuilder: (bool isLiked) {
                                (Get.arguments["liked_videos"] as List<
                                    LikedVideos>)[index].videoLikeStatus == 0
                                    ? isLiked = false
                                    : isLiked = true;
                                return Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color:
                                  isLiked ? Colors.red : Colors.white,
                                  size: 25,
                                );
                              },
                              likeCount: (Get.arguments["liked_videos"] as List<
                                  LikedVideos>)[index].videoLikeStatus,
                              countBuilder:
                                  (int? count, bool isLiked, String text) {
                                var color =
                                isLiked ? Colors.white : Colors.white;
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "0",
                                    style: TextStyle(color: color),
                                  );
                                } else
                                  result = Text(
                                    text,
                                    style: TextStyle(color: color),
                                  );
                                return result;
                              },
                              onTap: (_) async {
                                controller.likeVideo(
                                    (Get.arguments["liked_videos"] as List<
                                        LikedVideos>)[index].videoLikeStatus ==
                                        0
                                        ? 1
                                        : 0,
                                    (Get.arguments["liked_videos"] as List<
                                        LikedVideos>)[index].id!,
                                    token: (Get
                                        .arguments["liked_videos"] as List<
                                        LikedVideos>)[index].user!
                                        .firebaseToken);
                              }),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                commentsController
                                    .getComments(
                                    (Get.arguments["liked_videos"] as List<
                                        LikedVideos>)[index].id!)
                                    .then((value) {
                                  Get.bottomSheet(CommentsView(
                                      videoId: (Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].id,
                                      userId: (Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].user!.id,
                                      isCommentAllowed:
                                      true.obs,
                                      // (Get.arguments["liked_videos"] as List<LikedVideos>)[index].isCommentable ==
                                      //     "Yes"
                                      //     ? true.obs
                                      //     : false.obs
                                      isfollow: int.parse((Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].user!.following
                                          .toString()),
                                      userName: (Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].user!.username,
                                      avatar: (Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].user!.avatar ??
                                          "",
                                      fcmToken: (Get
                                          .arguments["liked_videos"] as List<
                                          LikedVideos>)[index].user!
                                          .firebaseToken,description: (Get
                                      .arguments["liked_videos"] as List<
                                      LikedVideos>)[index].description,));
                                });
                                // GetStorage().read("videoPrivacy") ==
                                //     "Private"
                                //     ? showErrorToast(
                                //     context, "this video is private!")
                                //     : showComments();
                              },
                              icon: const Icon(
                                IconlyLight.chat,
                                color: Colors.white,
                                size: 25,
                              )),
                          Text(
                            (Get.arguments["liked_videos"] as List<
                                LikedVideos>)[index].comments != null
                                ? "${(Get.arguments["liked_videos"] as List<
                                LikedVideos>)[index].comments}"
                                : "0",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          right: 10, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                Share.share(
                                    'You need to watch this awesome video only on Thrill!!!');
                              },
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 22,
                              )),
                          const Text(
                            "Share",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          right: 10, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.bottomSheet(

                                  Scaffold(body: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        // VideoModel videModel = VideoModel(
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .id!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .comments!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .video!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .description!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .likes!,
                                                        //     null,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .filter!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .gifImage!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .sound!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .soundName!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .soundCategoryName!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .views!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .speed!,
                                                        //     [],
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .isDuet!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .duetFrom!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .isDuetable!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .isCommentable!,
                                                        //     widget
                                                        //         .publicVideos
                                                        //         .soundOwner!);
                                                        // Get.to(RecordDuet(
                                                        //     videoModel:
                                                        //     videModel));
                                                      },
                                                      icon: const Icon(
                                                        IconlyLight.plus,
                                                        color: ColorManager
                                                            .colorAccent,
                                                        size: 30,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Duet",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed:
                                                            () async {
                                                          if ((Get
                                                              .arguments["liked_videos"] as List<
                                                              LikedVideos>)[index]
                                                              .user!.id ==
                                                              GetStorage()
                                                                  .read(
                                                                  "userId")) {
                                                            Get
                                                                .defaultDialog(
                                                                content:
                                                                const Text(
                                                                    "you want to delete this video?"),
                                                                title:
                                                                "Are your sure?",
                                                                confirm:
                                                                InkWell(
                                                                  child:
                                                                  Container(
                                                                    width:
                                                                    Get
                                                                        .width,
                                                                    alignment:
                                                                    Alignment
                                                                        .center,
                                                                    decoration:
                                                                    BoxDecoration(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            10),
                                                                        color: Colors
                                                                            .red
                                                                            .shade400),
                                                                    child:
                                                                    const Text(
                                                                        "Yes"),
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                  ),
                                                                  onTap: () =>
                                                                      controller
                                                                          .deleteUserVideo(
                                                                          (Get
                                                                              .arguments["liked_videos"] as List<
                                                                              LikedVideos>)[index]
                                                                              .user!
                                                                              .id!)
                                                                          .then((
                                                                          value) =>
                                                                          Get
                                                                              .back()),
                                                                ),
                                                                cancel:
                                                                InkWell(
                                                                  child:
                                                                  Container(
                                                                    width:
                                                                    Get
                                                                        .width,
                                                                    decoration:
                                                                    BoxDecoration(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            10),
                                                                        color: Colors
                                                                            .green),
                                                                    child:
                                                                    const Text(
                                                                        "Cancel"),
                                                                    alignment:
                                                                    Alignment
                                                                        .center,
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                  ),
                                                                  onTap: () =>
                                                                      Get
                                                                          .back(),
                                                                ));

                                                            //  showDeleteDialog();
                                                          }
                                                        },
                                                        icon: (Get
                                                            .arguments["liked_videos"] as List<
                                                            LikedVideos>)[index]
                                                            .user!.id
                                                            ==
                                                            GetStorage()
                                                                .read(
                                                                "userId")
                                                            ? const Icon(
                                                          Icons
                                                              .delete,
                                                          color:
                                                          ColorManager
                                                              .red,
                                                        )
                                                            : const Icon(
                                                          Icons.save,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )),
                                                    (Get
                                                        .arguments["liked_videos"] as List<
                                                        LikedVideos>)[index]
                                                        .user!.id ==
                                                        GetStorage()
                                                            .read(
                                                            "userId")
                                                        ? const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color:
                                                          ColorManager
                                                              .red,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                        : const Text(
                                                      "Save",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed:
                                                            () async {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: await controller
                                                                      .createDynamicLink(
                                                                      index
                                                                          .toString(),
                                                                      "video",
                                                                      (Get
                                                                          .arguments["liked_videos"] as List<
                                                                          LikedVideos>)[index]
                                                                          .user!
                                                                          .username
                                                                          .toString(),
                                                                      (Get
                                                                          .arguments["liked_videos"] as List<
                                                                          LikedVideos>)[index]
                                                                          .user!
                                                                          .avatar
                                                                          .toString())));

                                                          successToast(
                                                              "link copied successfully");
                                                        },
                                                        icon: const Icon(
                                                          Icons.link,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )),
                                                    const Text(
                                                      "Link",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          Get.back(
                                                              closeOverlays:
                                                              true);
                                                          controller
                                                              .downloadAndProcessVideo(
                                                              (Get
                                                                  .arguments["liked_videos"] as List<
                                                                  LikedVideos>)[index]
                                                                  .video!,
                                                              (Get
                                                                  .arguments["liked_videos"] as List<
                                                                  LikedVideos>)[index]
                                                                  .user!
                                                                  .username
                                                                  .toString());
                                                        },
                                                        icon: const Icon(
                                                          Icons.download,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )),
                                                    const Text(
                                                      "Download",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color: Colors.black
                                                .withOpacity(0.3),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (await GetStorage()
                                                  .read("token") ==
                                                  null) {
                                                if (await Permission
                                                    .phone.isGranted) {
                                                  await SimDataPlugin
                                                      .getSimData()
                                                      .then((value) =>
                                                  value
                                                      .cards.isEmpty
                                                      ? Get.bottomSheet(
                                                      LoginView(
                                                          false
                                                              .obs))
                                                      : Get.bottomSheet(
                                                      LoginView(true
                                                          .obs)));
                                                } else {
                                                  await Permission.phone
                                                      .request()
                                                      .then((value) async =>
                                                  await SimDataPlugin
                                                      .getSimData()
                                                      .then((value) =>
                                                  value
                                                      .cards
                                                      .isEmpty
                                                      ? Get.bottomSheet(
                                                      LoginView(
                                                          false
                                                              .obs))
                                                      : Get.bottomSheet(
                                                      LoginView(
                                                          true.obs))));
                                                }
                                              } else {
                                                await controller
                                                    .checkIfVideoReported(
                                                    (Get
                                                        .arguments["liked_videos"] as List<
                                                        LikedVideos>)[index]
                                                        .id!,
                                                    await GetStorage()
                                                        .read("userId"))
                                                    .then((value) async {
                                                  if (value == true) {
                                                    errorToast(
                                                        "video is already reported");
                                                  } else {
                                                    await controller
                                                        .getSiteSettings()
                                                        .then((_) =>
                                                        showReportDialog(
                                                            (Get
                                                                .arguments["liked_videos"] as List<
                                                                LikedVideos>)[index]
                                                                .user!.id!,
                                                            (Get
                                                                .arguments["liked_videos"] as List<
                                                                LikedVideos>)[index]
                                                                .user!
                                                                .username!,
                                                            (Get
                                                                .arguments["liked_videos"] as List<
                                                                LikedVideos>)[index]
                                                                .user!
                                                                .id!));
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.chat,
                                                  color: Color(0xffFF2400),
                                                  size: 30,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Report...",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(
                                                          0xffFF2400)),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (await GetStorage()
                                                  .read("token") ==
                                                  null) {
                                                if (await Permission
                                                    .phone.isGranted) {
                                                  await SimDataPlugin
                                                      .getSimData()
                                                      .then((value) =>
                                                  value
                                                      .cards.isEmpty
                                                      ? Get.bottomSheet(
                                                      LoginView(
                                                          false
                                                              .obs))
                                                      : Get.bottomSheet(
                                                      LoginView(true
                                                          .obs)));
                                                } else {
                                                  await Permission.phone
                                                      .request()
                                                      .then((value) async =>
                                                  await SimDataPlugin
                                                      .getSimData()
                                                      .then((value) =>
                                                  value
                                                      .cards
                                                      .isEmpty
                                                      ? Get.bottomSheet(
                                                      LoginView(
                                                          false
                                                              .obs))
                                                      : Get.bottomSheet(
                                                      LoginView(
                                                          true.obs))));
                                                }
                                              } else {
                                                await controller
                                                    .checkUserBlocked(
                                                    (Get
                                                        .arguments["liked_videos"] as List<
                                                        LikedVideos>)[index]
                                                        .user!.id!)
                                                    .then((value) async =>
                                                await controller
                                                    .blockUnblockUser(
                                                    (Get
                                                        .arguments["liked_videos"] as List<
                                                        LikedVideos>)[index]
                                                        .user!.id!,
                                                    value));
                                              }
                                              // if (
                                              //     GetStorage().read(
                                              //         "token") !=
                                              //         null) {
                                              //   usersController
                                              //       .isUserBlocked(
                                              //       widget.UserId);
                                              //   Future.delayed(
                                              //       const Duration(
                                              //           seconds: 1))
                                              //       .then((value) =>
                                              //   usersController
                                              //       .userBlocked.value
                                              //       ? usersController
                                              //       .blockUnblockUser(
                                              //       widget.UserId,
                                              //       "Unblock")
                                              //       : usersController
                                              //       .blockUnblockUser(
                                              //       widget.UserId,
                                              //       "Block"));
                                              // } else {
                                              //   showLoginAlert();
                                              // }
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.block,
                                                  color: ColorManager
                                                      .colorAccent,
                                                  size: 30,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Obx(() =>
                                                    Text(
                                                      controller
                                                          .isUserBlocked
                                                          .isFalse
                                                          ? "Block User..."
                                                          : "Unblock User...",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: ColorManager
                                                              .colorAccent),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                              visible: GetStorage()
                                                  .read("token") !=
                                                  null,
                                              child: InkWell(
                                                onTap: () async {
                                                  if (await GetStorage()
                                                      .read("token") ==
                                                      null) {
                                                    if (await Permission
                                                        .phone.isGranted) {
                                                      await SimDataPlugin
                                                          .getSimData()
                                                          .then((value) =>
                                                      value
                                                          .cards
                                                          .isEmpty
                                                          ? Get.bottomSheet(
                                                          LoginView(
                                                              false
                                                                  .obs))
                                                          : Get.bottomSheet(
                                                          LoginView(
                                                              true.obs)));
                                                    } else {
                                                      await Permission.phone
                                                          .request().then((
                                                          value) async =>
                                                      await SimDataPlugin
                                                          .getSimData()
                                                          .then((value) =>
                                                      value
                                                          .cards
                                                          .isEmpty
                                                          ? Get.bottomSheet(
                                                          LoginView(false
                                                              .obs))
                                                          : Get.bottomSheet(
                                                          LoginView(
                                                              true.obs))));
                                                    }
                                                  } else {
                                                    controller
                                                        .followUnfollowUser(
                                                        (Get
                                                            .arguments["liked_videos"] as List<
                                                            LikedVideos>)[index]
                                                            .user!.id!,
                                                        int.parse((Get
                                                            .arguments["liked_videos"] as List<
                                                            LikedVideos>)[index]
                                                            .user!.following
                                                            .toString()) ==
                                                            0
                                                            ? "follow"
                                                            : "unfollow");
                                                  }
                                                  // userDetailsController
                                                  //     .followUnfollowUser(
                                                  //     widget.UserId,
                                                  //     widget.isfollow == 0
                                                  //         ? "follow"
                                                  //         : "unfollow",
                                                  //     token: widget
                                                  //         .publicUser!
                                                  //         .firebaseToken
                                                  //         .toString());
                                                  // relatedVideosController
                                                  //     .getAllVideos();
                                                },
                                                child: Row(
                                                  children: [
                                                    int.parse((Get
                                                        .arguments["liked_videos"] as List<
                                                        LikedVideos>)[index]
                                                        .user!.following
                                                        .toString()) == 0
                                                        ? const Icon(
                                                      Icons.report,
                                                      color: ColorManager
                                                          .colorAccent,
                                                      size: 30,
                                                    )
                                                        : const Icon(
                                                      Icons.report,
                                                      color: ColorManager
                                                          .colorAccent,
                                                      size: 30,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    const Text(
                                                      "Report Video",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: ColorManager
                                                              .colorAccent),
                                                    )
                                                  ],
                                                ),
                                              ))
                                        ]),
                                  ),),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(15)),
                                );
                              },
                              icon: const Icon(
                                IconlyBold.more_circle,
                                color: Colors.white,
                                size: 25,
                              )),
                          const Text(
                            "More",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await GetStorage().read("token") == null) {
                          if (await Permission.phone.isGranted) {
                            await SimDataPlugin.getSimData().then((value) =>
                            value.cards.isEmpty
                                ? Get.bottomSheet(LoginView(false.obs))
                                : Get.bottomSheet(LoginView(true.obs)));
                          } else {
                            await Permission.phone.request().then(
                                    (value) async =>
                                await SimDataPlugin.getSimData().then(
                                        (value) =>
                                    value.cards.isEmpty
                                        ? Get.bottomSheet(
                                        LoginView(false.obs))
                                        : Get.bottomSheet(
                                        LoginView(true.obs))));
                          }
                        } else {
                          if ((Get.arguments["liked_videos"] as List<
                              LikedVideos>)[index].user!.id ==
                              GetStorage().read("userId")) {
                            Get.toNamed(Routes.PROFILE);
                          }
                          else {
                            Get.toNamed(Routes.OTHERS_PROFILE, arguments: {
                              "profileId": (Get
                                  .arguments["liked_videos"] as List<
                                  LikedVideos>)[index].user!.id
                            });
                          }
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            alignment: Alignment.bottomLeft,
                            width: 60,
                            height: 60,
                            child: CachedNetworkImage(
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                              imageUrl: (Get.arguments["liked_videos"] as List<
                                  LikedVideos>)[index].user!.avatar == null ||
                                  (Get.arguments["liked_videos"] as List<
                                      LikedVideos>)[index].user!.avatar!.isEmpty
                                  ? RestUrl.placeholderImage
                                  : RestUrl.profileUrl +
                                  (Get.arguments["liked_videos"] as List<
                                      LikedVideos>)[index].user!.avatar
                                      .toString(),
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    (Get.arguments["liked_videos"] as List<
                                        LikedVideos>)[index].user!.username ??
                                        "",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                    width: 10,
                                  ),
                                  Visibility(
                                    child: InkWell(
                                        onTap: () async {
                                          if (await GetStorage()
                                              .read("token") ==
                                              null) {
                                            if (await Permission
                                                .phone.isGranted) {
                                              await SimDataPlugin
                                                  .getSimData()
                                                  .then((value) =>
                                              value
                                                  .cards.isEmpty
                                                  ? Get.bottomSheet(
                                                  LoginView(
                                                      false.obs))
                                                  : Get.bottomSheet(
                                                  LoginView(
                                                      true.obs)));
                                            } else {
                                              await Permission.phone
                                                  .request()
                                                  .then((value) async =>
                                              await SimDataPlugin
                                                  .getSimData()
                                                  .then((value) =>
                                              value
                                                  .cards.isEmpty
                                                  ? Get.bottomSheet(
                                                  LoginView(
                                                      false
                                                          .obs))
                                                  : Get.bottomSheet(
                                                  LoginView(true.obs))));
                                            }
                                          } else {
                                            controller
                                                .followUnfollowUser(
                                              (Get
                                                  .arguments["liked_videos"] as List<
                                                  LikedVideos>)[index].user!
                                                  .id!,
                                              int.parse((Get
                                                  .arguments["liked_videos"] as List<
                                                  LikedVideos>)[index].user!
                                                  .following.toString()) == 0
                                                  ? "follow"
                                                  : "unfollow",
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10),
                                          child: Text(
                                            int.parse((Get
                                                .arguments["liked_videos"] as List<
                                                LikedVideos>)[index].user!
                                                .following
                                                .toString()) == 0
                                                ? "Follow"
                                                : "Following",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorManager
                                                      .colorAccent),
                                              borderRadius:
                                              BorderRadius.circular(5)),
                                        )),
                                    visible: GetStorage().read("token") !=
                                        null &&
                                        (Get.arguments["liked_videos"] as List<
                                            LikedVideos>)[index].user!.id !=
                                            GetStorage().read("userId"),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                (Get.arguments["liked_videos"] as List<
                                    LikedVideos>)[index].user!.name ?? "",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        (Get.arguments["liked_videos"] as List<
                            LikedVideos>)[index].description.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Visibility(
                      visible: (Get.arguments["liked_videos"] as List<
                          LikedVideos>)[index].hashtags != null,
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                            itemCount: (Get.arguments["liked_videos"] as List<
                                LikedVideos>)[index].hashtags?.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, hashtagIndex) =>
                                InkWell(
                                  onTap: () async {
                                    await GetStorage().write("hashtagId",
                                        (Get.arguments["liked_videos"] as List<
                                            LikedVideos>)[index]
                                            .hashtags![hashtagIndex].id);
                                    Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                        arguments: {
                                          "hashtag_name":
                                          "${(Get
                                              .arguments["liked_videos"] as List<
                                              LikedVideos>)[index]
                                              .hashtags![hashtagIndex].name}"
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorManager.colorAccent,
                                        border: Border.all(
                                            color: Colors.transparent),
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(5))),
                                    margin: const EdgeInsets.only(
                                        right: 5, top: 5, bottom: 5),
                                    padding: const EdgeInsets.all(5),
                                    alignment: Alignment.center,
                                    child: Text(
                                      (Get.arguments["liked_videos"] as List<
                                          LikedVideos>)[index]
                                          .hashtags![hashtagIndex]
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10),
                                    ),
                                  ),
                                )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await GetStorage()
                            .write("profileId", (Get
                            .arguments["liked_videos"] as List<
                            LikedVideos>)[index].user!.id);

                        Get.toNamed(Routes.SOUNDS, arguments: {
                          "sound_name": (Get.arguments["liked_videos"] as List<
                              LikedVideos>)[index].soundName.toString(),
                          "sound_url": (Get.arguments["liked_videos"] as List<
                              LikedVideos>)[index].sound,
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller),
                              child: SvgPicture.asset(
                                "assets/spinning_disc.svg",
                                height: 30,
                              ),
                            ),

                            // Lottie.network(
                            //     "https://assets2.lottiefiles.com/packages/lf20_e3odbuvw.json",
                            //     height: 50),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            (Get.arguments["liked_videos"] as List<
                                LikedVideos>)[index].soundName!.isEmpty
                                ? "Original Sound"
                                : (Get.arguments["liked_videos"] as List<
                                LikedVideos>)[index].soundName! +
                                " by ${(Get.arguments["liked_videos"] as List<
                                    LikedVideos>)[index].user!.name}",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],);
          }),);
  }

  showReportDialog(int videoId, String name, int id) async {
    var dropDownValue = "Reason".obs;
    List<String> dropDownValues = [
      "Reason",
    ];
    try {
      List jsonList = controller.siteSettingsList;
      for (SiteSettings element in jsonList) {
        if (element.name == 'report_reason') {
          List reasonList = element.value.toString().split(',');
          for (String reason in reasonList) {
            dropDownValues.add(reason);
          }
          break;
        }
      }
    } catch (e) {
      closeDialogue(Get.context!);
      showErrorToast(Get.context!, e.toString());
      return;
    }
    Get.defaultDialog(
      title: "Report $name's Video ?",
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: Container(
          width: getWidth(Get.context!) * .80,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please select a reason for what you want to report this video....",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5)),
                child: Obx(() =>
                    DropdownButton(
                      value: dropDownValue.value,
                      underline: Container(),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      icon: const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        dropDownValue.value = value.toString();
                      },
                      items: dropDownValues.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    )),
              ),
              const SizedBox(
                height: 15,
              ),
              Obx(() =>
                  ElevatedButton(
                      onPressed: dropDownValue.value == "Reason"
                          ? null
                          : () async {
                        try {
                          controller.reportVideo(
                              videoId, id, dropDownValue.value);
                        } catch (e) {
                          closeDialogue(Get.context!);
                          showErrorToast(Get.context!, e.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5)),
                      child: const Text("Report")))
            ],
          )),
    );
  }

}
