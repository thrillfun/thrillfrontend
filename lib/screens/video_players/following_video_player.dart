import 'package:flutter/gestures.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:thrill/controller/videos_controller.dart' as uvController;

import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';

import '../../common/color.dart';
import '../../controller/comments/comments_controller.dart';
import '../../controller/notifications/notifications_controller.dart';
import '../../controller/users/other_users_controller.dart';
import '../../controller/users_controller.dart';
import '../../controller/videos/UserVideosController.dart';
import '../../controller/videos/hashtags_videos_controller.dart';
import '../../controller/videos/like_videos_controller.dart';
import '../../models/video_model.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';
import '../../widgets/better_video_player.dart';
import '../auth/login_getx.dart';
import '../profile/profile.dart';
import '../profile/view_profile.dart';
import '../sound/sound_details.dart';
import '../video/duet.dart';
class FollowingVideoPlayer extends GetView<FollowingVideosController>{
  var videosController = Get.find<uvController.VideosController>();
  var commentsController = Get.find<CommentsController>();
  var usersController = Get.find<UserController>();
  var otherUsersController = Get.find<OtherUsersController>();
  var likedVideosController = Get.find<LikedVideosController>();
  var userVideosController = Get.find<UserVideosController>();
  var relatedVideosController = Get.find<RelatedVideosController>();
  var hashtagVideosController = Get.find<HashtagVideosController>();
  var isPaused = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:
        controller.obx(
                (state) => PageView.builder(
                scrollDirection: Axis.vertical,
                controller: controller.pageViewController,
                itemCount: state!.length,
                itemBuilder: (context, index) {
                  var betterPlayerController = BetterPlayerController( BetterPlayerConfiguration(
                    aspectRatio: Get.width / Get.height,
                    expandToFill: true,
                    autoPlay: true,
                    fit: BoxFit.contain,
                    eventListener: (eventListener) async {

                      controller.eventType = eventListener;
                      if (eventListener.betterPlayerEventType ==
                          BetterPlayerEventType.finished && eventListener.betterPlayerEventType!=BetterPlayerEventType.pause&&eventListener.betterPlayerEventType !=
                          BetterPlayerEventType.play) {
                        seek(Duration.zero);

                        videosController
                            .postVideoView(state[index].id!)
                            .then((value) {
                          controller.pageViewController.animateToPage(index + 1,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeIn);
                        });

                      }
                    },
                    controlsConfiguration:
                    const BetterPlayerControlsConfiguration(
                      showControls: false,
                        playerTheme: BetterPlayerTheme.cupertino,
                        controlsHideTime: Duration(seconds: 0),
                        playIcon: Icons.play_circle,
                        pauseIcon: Icons.pause_circle,
                        enableSkips: false,
                        enableAudioTracks: false,
                        enableProgressBarDrag: false,
                        enableProgressText: false,
                        enableProgressBar: false,
                        enableOverflowMenu: false,
                        enablePlayPause: false,
                        enableFullscreen: false,
                        enableMute: false,
                        enablePlaybackSpeed: false),),betterPlayerDataSource: BetterPlayerDataSource.network(
                      "${RestUrl.videoUrl}${state[index].video.toString()}"));

                  return Stack(
                    children: [
                      GestureDetector(
                          onDoubleTap: ()async=>await controller.likeVideo(
                              state[index].videoLikeStatus ==0 ? 1 : 0,
                              state[index].id!,
                              userId:  state[index].user!.id!,
                              token:  state[index].user!.firebaseToken),
                          onLongPressEnd: (_) {
                            betterPlayerController.play();
                          },
                          onLongPressStart: (_)=>betterPlayerController.pause(),
                          onTap: () {
                            // if (volume.value == 1) {
                            //   volume.value = 0;
                            // } else {
                            //   volume.value = 1;
                            // }
                            // setState(() {
                            //   betterPlayerController.setVolume(volume.value);
                            // });
                          },
                          child: Stack(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  color: Colors.black,
                                  child: AspectRatio(
                                    aspectRatio: Get.width/Get.height,
                                    child:
                                    BetterPlayer(
                                      controller:betterPlayerController,

                                    ),
                                  )),
                              Container(
                                alignment: Alignment.centerRight,
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
                                                start: Colors.red.shade200, end: Colors.red),
                                            bubblesColor: BubblesColor(
                                              dotPrimaryColor: Colors.red.shade200,
                                              dotSecondaryColor: Colors.red,
                                            ),
                                            likeBuilder: (bool isLiked) {
                                              state[index].videoLikeStatus == 0
                                                  ? isLiked = false
                                                  : isLiked = true;
                                              return Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_outline,
                                                color: isLiked ? Colors.red : Colors.white,
                                                size: 25,
                                              );
                                            },
                                            likeCount:  state[index].likes!,
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
                                            onTap: (_) async =>
                                            await controller.likeVideo(
                                                state[index].videoLikeStatus ==0 ? 1 : 0,
                                                state[index].id!,
                                                userId:  state[index].user!.id!,
                                                token:  state[index].user!.firebaseToken),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:  const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                commentsController
                                                    .getComments( state[index].id!.toInt());
                                                GetStorage().read("videoPrivacy") == "Private"
                                                    ? showErrorToast(
                                                    context, "this video is private!")
                                                    : showComments(
                                                    state[index].id!,
                                                    state[index].user!.id!,
                                                    state[index].isCommentable!.toLowerCase()=="yes"?true:false,
                                                    state[index].user!.isFollow!,
                                                    state[index].user!.username!,
                                                    state[index].user!.avatar!

                                                );
                                              },
                                              icon: const Icon(
                                                IconlyLight.chat,
                                                color: Colors.white,
                                                size: 25,
                                              )),
                                          Text(
                                            state[index].comments != null
                                                ? "${ state[index].comments}"
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
                                          right: 10, top: 10, bottom: 90),
                                      child: Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                Get.bottomSheet(
                                                    Container(
                                                      height: 300,
                                                      margin: const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                      child: Column(children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Container(
                                                              margin: const EdgeInsets.only(
                                                                  right: 10),
                                                              child: Column(
                                                                children: [
                                                                  IconButton(
                                                                    onPressed: () {
                                                                      VideoModel videModel = VideoModel(
                                                                          state[index]
                                                                              .id!,
                                                                          state[index].comments!,
                                                                          state[index].video!,
                                                                          state[index].description!,
                                                                          state[index].likes!,
                                                                          null,
                                                                          state[index].filter!,
                                                                          state[index].gifImage!,
                                                                          state[index].sound!,
                                                                          state[index].soundName!,
                                                                          state[index].soundCategoryName!,
                                                                          state[index].views!,
                                                                          state[index].speed!,
                                                                          [],
                                                                          state[index].isDuet!,
                                                                          state[index].duetFrom!,
                                                                          state[index].isDuetable!,
                                                                          state[index].isCommentable!,
                                                                          state[index].soundOwner!);
                                                                      Get.to(RecordDuet(
                                                                          videoModel:
                                                                          videModel));
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
                                                                        FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets.only(
                                                                  right: 10),
                                                              child: Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () {
                                                                        if ( state[index].user!.id ==
                                                                            GetStorage().read(
                                                                                "user")[
                                                                            'id']) {
                                                                          showDeleteDialog(state[index].id!);
                                                                        }
                                                                      },
                                                                      icon:  state[index].user!.id ==
                                                                          usersController
                                                                              .userProfile
                                                                              .value
                                                                              .id
                                                                          ? const Icon(
                                                                        Icons.delete,
                                                                        color:
                                                                        ColorManager
                                                                            .red,
                                                                      )
                                                                          : const Icon(
                                                                        Icons.save,
                                                                        color: ColorManager
                                                                            .colorAccent,
                                                                      )),
                                                                  state[index].user!.id==
                                                                      usersController
                                                                          .userProfile
                                                                          .value
                                                                          .id
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
                                                              margin: const EdgeInsets.only(
                                                                  right: 10),
                                                              child: Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async {
                                                                        var deepLink = await userDetailsController
                                                                            .createDynamicLink(
                                                                            "${ state[index].user!.id}",
                                                                            'profile',
                                                                            "${ state[index].user!.name}",
                                                                            "${ state[index].user!.avatar}");
                                                                        //         +
                                                                        // widget.publicUser!
                                                                        //         .name
                                                                        //         .toString() +
                                                                        // widget
                                                                        //     .publicUser!
                                                                        //     .avatar
                                                                        //     .toString()
                                                                        GetStorage().write(
                                                                            "deeplink",
                                                                            deepLink
                                                                                .toString());
                                                                        Clipboard.setData(
                                                                            ClipboardData(
                                                                                text: deepLink
                                                                                    .toString()));
                                                                        successToast(
                                                                            "Link copied!");
                                                                        //     widget.videoUrl));
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
                                                                        FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets.only(
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
                                                                            RestUrl.videoUrl+ state[index].video.toString(),
                                                                            state[index].user!.
                                                                            username!
                                                                                .toString());
                                                                        // GallerySaver.saveVideo(
                                                                        //         RestUrl.videoUrl +
                                                                        //             widget
                                                                        //                 .videoUrl)
                                                                        //     .then((value) =>
                                                                        //         showSuccessToast(
                                                                        //             context,
                                                                        //             "Video Saved Successfully"));
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
                                                                        FontWeight.bold),
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
                                                          color:
                                                          Colors.black.withOpacity(0.3),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        InkWell(
                                                          onTap: () =>
                                                          GetStorage().read("token") !=
                                                              null
                                                              ? showReportDialog(
                                                              state[index].id!,
                                                              state[index].user!.username!,
                                                              state[index].user!.id!)
                                                              : showLoginAlert(),
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
                                                                    color: Color(0xffFF2400)),
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
                                                          onTap: () {
                                                            if (GetStorage()
                                                                .read("token")
                                                                .toString()
                                                                .isNotEmpty &&
                                                                GetStorage().read("token") !=
                                                                    null) {
                                                              usersController.isUserBlocked(
                                                                  state[index].user!.id!.toInt());
                                                              Future.delayed(const Duration(
                                                                  seconds: 1))
                                                                  .then((value) => usersController
                                                                  .userBlocked.value
                                                                  ? usersController
                                                                  .blockUnblockUser(
                                                                  state[index].user!.id!,
                                                                  "Unblock")
                                                                  : usersController
                                                                  .blockUnblockUser(
                                                                  state[index].user!.id!,
                                                                  "Block"));
                                                            } else {
                                                              showLoginAlert();
                                                            }
                                                          },
                                                          child: Row(
                                                            children: const [
                                                              Icon(
                                                                Icons.block,
                                                                color:
                                                                ColorManager.colorAccent,
                                                                size: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "Block User...",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: ColorManager
                                                                        .colorAccent),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Visibility(
                                                            visible: userDetailsController
                                                                .storage
                                                                .read("token") !=
                                                                null,
                                                            child: InkWell(
                                                              onTap: () {
                                                                userDetailsController
                                                                    .followUnfollowUser(
                                                                    state[index].user!.id!
                                                                    ,
                                                                    state[index].user!.isFollow! == 0
                                                                        ? "follow"
                                                                        : "unfollow",
                                                                    token:  state[index].user!
                                                                        .firebaseToken
                                                                        .toString());
                                                                controller
                                                                    .getFollowingVideos();
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  state[index].user!.isFollow! == 0
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
                                                                  Text(
                                                                    "Report Video",
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: ColorManager
                                                                            .colorAccent),
                                                                  )
                                                                ],
                                                              ),
                                                            ))
                                                      ]),
                                                    ),
                                                    backgroundColor: ColorManager.dayNight,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(15)),
                                                    persistent: false);
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
                                margin: const EdgeInsets.only(bottom: 90),
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (GetStorage().read("token") != null) {
                                          state[index].user!.id ==
                                              usersController.storage.read("userId")
                                              ? await userVideosController.getUserVideos()
                                              : await userVideosController
                                              .getOtherUserVideos( state[index].user!.id!);
                                          state[index].user!.id ==
                                              usersController.storage.read("userId")
                                              ? await likedVideosController
                                              .getUserLikedVideos()
                                              : await likedVideosController
                                              .getOthersLikedVideos(
                                              state[index].user!.id!);
                                          state[index].user!.id ==
                                              usersController.storage.read("userId")
                                              ? await userDetailsController
                                              .getUserProfile()
                                              .then((value) {
                                            Get.to(Profile(isProfile: true.obs));
                                          })
                                              : await otherUsersController
                                              .getOtherUserProfile( state[index].user!.id!)
                                              .then((value) {
                                            Get.to(ViewProfile(
                                                state[index].user!.id.toString(),
                                                state[index].user!.isFollow!.obs,
                                                state[index].user!.username.toString(),
                                                state[index].user!.avatar.toString()));
                                          });
                                        } else {
                                          Get.bottomSheet(LoginGetxScreen(),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20)));
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
                                              imageUrl:  state[index].user!.avatar == null ||
                                                  state[index].user!.avatar!.isEmpty
                                                  ? RestUrl.placeholderImage
                                                  : RestUrl.profileUrl +
                                                  state[index].user!.avatar.toString(),
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
                                                    state[index].user!.username ?? "",
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
                                                        onTap: () {
                                                          if (userDetailsController.storage
                                                              .read("token") ==
                                                              null) {
                                                            errorToast("login to continue");
                                                          } else {
                                                            userDetailsController
                                                                .followUnfollowUser(
                                                                state[index].user!.id!,
                                                                state[index].user!.isFollow == 0
                                                                    ? "follow"
                                                                    : "unfollow",
                                                                token: state[index].user!
                                                                    .firebaseToken
                                                                    .toString());
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 5, horizontal: 10),
                                                          child: Text(
                                                            state[index].user!.isFollow == 0
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
                                                    visible: userDetailsController.storage
                                                        .read("token") !=
                                                        null &&
                                                        state[index].user!.id !=
                                                            userDetailsController.storage
                                                                .read("userId"),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                state[index].user!.name ?? "",
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
                                        state[index].description.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    // Visibility(
                                    //   visible: state[index].hashtagsList.isNotEmpty,
                                    //   child: Container(
                                    //     height: 35,
                                    //     margin: const EdgeInsets.symmetric(horizontal: 10),
                                    //     child: ListView.builder(
                                    //         itemCount: widget.hashtagsList.length,
                                    //         shrinkWrap: true,
                                    //         scrollDirection: Axis.horizontal,
                                    //         itemBuilder: (context, index) => InkWell(
                                    //           onTap: () async {
                                    //             await hashtagVideosController
                                    //                 .getVideosByHashTags(
                                    //                 widget.hashtagsList[index].id!)
                                    //                 .then((value) =>
                                    //                 Get.to(() => HashTagsScreen(
                                    //                   tagName: widget
                                    //                       .hashtagsList[index]
                                    //                       .name,
                                    //                   videoCount: widget
                                    //                       .hashtagsList[index].id,
                                    //                 )));
                                    //           },
                                    //           child: Container(
                                    //             decoration: BoxDecoration(
                                    //                 color: ColorManager.colorAccent,
                                    //                 border: Border.all(
                                    //                     color: Colors.transparent),
                                    //                 borderRadius: const BorderRadius.all(
                                    //                     Radius.circular(5))),
                                    //             margin: const EdgeInsets.only(
                                    //                 right: 5, top: 5, bottom: 5),
                                    //             padding: const EdgeInsets.all(5),
                                    //             alignment: Alignment.center,
                                    //             child: Text(
                                    //               widget.hashtagsList[index].name
                                    //                   .toString(),
                                    //               style: const TextStyle(
                                    //                   color: Colors.white, fontSize: 10),
                                    //             ),
                                    //           ),
                                    //         )),
                                    //   ),
                                    // ),
                                    GestureDetector(
                                      onTap: () => Get.to(SoundDetails(
                                        map: {
                                          "sound": state[index].sound,
                                          "user": state[index].soundOwner.toString().isEmpty
                                              ? state[index].user!.username.toString()
                                              : state[index].soundOwner,
                                          "soundName": state[index].soundName,
                                          "title": state[index].soundOwner,
                                          "id": state[index].id,
                                          "profile": state[index].user!.avatar,
                                          "name": state[index].user!.name,
                                          "sound_id": state[index].soundId,
                                          "username": state[index].user!.username,
                                          "isFollow": state[index].user!.isFollow,
                                          "userProfile": state[index].user!.avatar != null
                                              ? state[index].user!.avatar
                                              : RestUrl.placeholderImage
                                        },
                                      )),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: Lottie.network(
                                                "https://assets2.lottiefiles.com/packages/lf20_e3odbuvw.json",
                                                height: 50),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(state[index].soundName.toString().isEmpty
                                              ? "Original Sound"
                                              : state[index].soundName.toString() +
                                              " by ${state[index].user!.name}",
                                            style: const TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                      // IgnorePointer(
                      //   child: Obx((() => Visibility(
                      //     // visible: volume.value <= 0,
                      //     child: Center(
                      //         child: ClipOval(
                      //           child: Container(
                      //             padding: const EdgeInsets.all(10),
                      //             color: ColorManager.colorAccent.withOpacity(0.5),
                      //             child: const Icon(
                      //               IconlyLight.volume_off,
                      //               size: 25,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //         )),
                      //   ))),
                      // ),
                      // IgnorePointer(
                      //   child: Obx((() => Visibility(
                      //    // visible: isVideoPaused.value,
                      //     child: Center(
                      //         child: ClipOval(
                      //           child: Container(
                      //             padding: const EdgeInsets.all(10),
                      //             color: ColorManager.colorAccent.withOpacity(0.5),
                      //             child: const Icon(
                      //               IconlyLight.play,
                      //               size: 25,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //         )),
                      //   ))),
                      // )
                    ],
                  );
                }


            ),
            onLoading: Container(child: loader(),height: Get.height,width: Get.width,
              alignment: Alignment.center,)
        ),
      ),
    );
  }
  showComments(int videoId,int userId,bool isCommentAllowed,int isFollow,String userName,String avatar) {
    // showModalBottomSheet(
    //     context: context,
    //     builder: (BuildContext context) => );
    Get.bottomSheet(
        CommentsScreen(
          videoId: videoId,
          userId: userId,
          isCommentAllowed: isCommentAllowed.obs,
          isfollow: isFollow,
          userName:userName,
          avatar: avatar,
        ),
        backgroundColor: ColorManager.dayNight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
  }

  showDeleteDialog(int videoId) {
    Get.defaultDialog(
      backgroundColor: Colors.transparent.withOpacity(0),
      content: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: ColorManager.colorAccent,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            margin: const EdgeInsets.only(top: 60),
            height: 160,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "This will permanently delete your video, continue?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorManager.colorAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            primary: Colors.red),
                        onPressed: () =>
                            videosController.deleteVideo(videoId),
                        child: const Text('Yes')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            primary: ColorManager.colorAccent),
                        onPressed: () => Get.back(),
                        child: const Text('No')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50))),
            child: const Icon(
              Icons.error,
              color: Colors.red,
              size: 100,
            ),
          ),
        ],
      ),
      middleText: "",
      title: "",
    );
  }
}

