import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:like_button/like_button.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/modules/comments/controllers/comments_controller.dart';
import 'package:thrill/app/modules/comments/views/comments_view.dart';
import 'package:thrill/app/rest/models/related_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:thrill/app/widgets/focus_detector.dart';
import 'package:video_player/video_player.dart';

import '../../../rest/models/site_settings_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../../home/controllers/home_controller.dart';
import '../../login/views/login_view.dart';
import '../controllers/related_videos_controller.dart';

var volume = 1.0.obs;
var comment = "".obs;
var isVideoPaused = false.obs;

class RelatedVideosView extends StatefulWidget {
  RelatedVideosView(
      {this.videoUrl,
      this.pageController,
      this.nextPage,
      this.videoId,
      this.gifImage,
      this.pageIndex,
      this.currentPageIndex,
      this.isPaused,
      this.callback,
      this.publicUser,
      this.soundName,
      this.isDuetable,
      this.UserId,
      this.userName,
      this.description,
      this.isHome,
      this.hashtagsList,
      this.sound,
      this.soundOwner,
      this.videoLikeStatus,
      this.isCommentAllowed,
      this.like,
      this.isfollow,
      this.commentsCount,
      this.soundId,
      this.avatar,
      this.fcmToken,
      this.isLastPage});

  String? videoUrl, fcmToken;
  PageController? pageController;
  int? nextPage;
  int? videoId;
  String? avatar;
  String? gifImage, sound, soundOwner;
  String? videoLikeStatus;
  RxInt? pageIndex, currentPageIndex;
  RxBool? isPaused;
  RxBool? isCommentAllowed;
  VoidCallback? callback;
  User? publicUser;
  String? soundName;
  RxBool? isDuetable = false.obs;
  int? UserId;
  RxString? description, userName;
  RxBool? isHome = false.obs;
  List<Hashtags>? hashtagsList;
  RxInt? like = 0.obs;
  int? isfollow = 0;
  RxInt? commentsCount = 0.obs;
  int? soundId = 0;
  bool? isLastPage;
  VoidCallback? movePage;

  @override
  State<RelatedVideosView> createState() => _RelatedVideosViewState();
}

class _RelatedVideosViewState extends State<RelatedVideosView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController videoPlayerController;
  var relatedVideosController = Get.find<RelatedVideosController>();
  var homeController = Get.find<HomeController>();

  var commentsController = Get.find<CommentsController>();
  late AnimationController _controller;
  bool keepAlive = false;
  var isVisible = false.obs;
  var postView = false.obs;
  var isVideoPaused = false.obs;
  var isMuted = false.obs;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    enableWakeLock();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    commentsController.getComments(widget.videoId!);
    videoPlayerController =
        VideoPlayerController.network(RestUrl.videoUrl + widget.videoUrl!)
          ..setLooping(true)
          ..initialize().then((value) {
            relatedVideosController.isInitialised.value = true;
            _controller.repeat();
            setState(() {});
          });

    videoPlayerController.addListener(() async {
      // relatedVideosController.currentDuration.value =
      //     videoPlayerController.value.position;

      // if (videoPlayerController.value.duration ==
      //         videoPlayerController.value.position &&
      //     videoPlayerController.value.position > Duration.zero) {
      //   relatedVideosController.postVideoView(widget.videoId!);
      //   // widget.pageController!.animateToPage(widget.nextPage!,
      //   //     duration: const Duration(milliseconds: 700), curve: Curves.easeOut);
      //   // setState(() {});
      // }

      Future.delayed(const Duration(seconds: 1)).then((value) {
        if (Get.isBottomSheetOpen! || isVisible.isFalse) {
          videoPlayerController.pause();
        } else if (!Get.isBottomSheetOpen! && isVisible.isTrue) {
          videoPlayerController.play();
        }
      });
    });

    relatedVideosController.isDialogVisible.listen((p0) {
      if (p0 == true) {
        setState(() {
          videoPlayerController.pause();
        });
      } else {
        videoPlayerController.play();
        setState(() {});
      }
    });

    setState(() {});
    relatedVideosController.checkUserBlocked(widget.UserId!);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.pageController!.dispose();
    disableWakeLock();
    videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
              onDoubleTap: () {
                checkForLogin(() {
                  relatedVideosController.likeVideo(
                      relatedVideosController.isLiked.isFalse ? 1 : 0,
                      widget.videoId!,
                      userName: widget.userName!.value);
                });
              },
              onTap: () {
                if (videoPlayerController.value.volume > 0.0) {
                  setState(() {
                    videoPlayerController.setVolume(0.0);
                    // _controller.stop();
                    // isVisible.value = false;
                    isMuted.value = true;
                  });
                } else {
                  setState(() {
                    videoPlayerController.setVolume(1.0);
                    // _controller.repeat();
                    // isVisible.value = true;
                    isMuted.value = false;
                  });
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FocusDetector(
                      onVisibilityGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      onVisibilityLost: () {
                        videoPlayerController.pause();
                        isVisible.value = false;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      onForegroundLost: () {
                        videoPlayerController.pause();
                        isVisible.value = false;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      onForegroundGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      onFocusLost: () {
                        if (mounted) {
                          videoPlayerController.pause();
                          isVisible.value = false;
                          setState(() {});
                        }
                      },
                      onFocusGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        setState(() {});
                      },
                      child: VideoPlayer(videoPlayerController)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: Get.height / 2,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 50.0,
                            spreadRadius: 50, //New
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () => null,
                      child: Container(
                        height: Get.height / 2,
                        width: 150,
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10, right: 20),
                              child: Obx(() => LikeButton(
                                    countPostion: CountPostion.bottom,
                                    likeCountAnimationType:
                                        LikeCountAnimationType.all,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    circleColor: const CircleColor(
                                        start: Colors.red, end: Colors.red),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor: Colors.red,
                                      dotSecondaryColor: Colors.red,
                                    ),
                                    onTap: (_) {
                                      relatedVideosController.likeVideo(
                                          relatedVideosController
                                                  .isLiked.isFalse
                                              ? 1
                                              : 0,
                                          widget.videoId!,
                                          token: widget.fcmToken,
                                          userName: widget.userName!.value);

                                      return Future.value(
                                          relatedVideosController
                                              .isLiked.isFalse);
                                    },
                                    likeBuilder: (bool isLiked) {
                                      return Obx(() => Icon(
                                            relatedVideosController
                                                    .isLiked.isTrue
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            color: relatedVideosController
                                                    .isLiked.isTrue
                                                ? Colors.red
                                                : Colors.white,
                                            size: 25,
                                          ));
                                    },
                                    likeCount: relatedVideosController
                                        .totalLikes.value,
                                    countBuilder: (int? count, bool isLiked,
                                        String text) {
                                      return Text(
                                        relatedVideosController.totalLikes.value
                                            .toString(),
                                        style: TextStyle(
                                            color: relatedVideosController
                                                    .isLiked.isTrue
                                                ? Colors.red
                                                : Colors.white),
                                      );
                                    },
                                  )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        commentsController
                                            .getComments(widget.videoId!)
                                            .then((value) {
                                          Get.bottomSheet(
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10)),
                                              child: CommentsView(
                                                videoId: widget.videoId!,
                                                userId: widget.UserId,
                                                isCommentAllowed:
                                                    widget.isCommentAllowed,
                                                isfollow:
                                                    relatedVideosController
                                                            .isUserFollowed
                                                            .isTrue
                                                        ? 1
                                                        : 0,
                                                userName:
                                                    widget.userName!.value,
                                                avatar: widget.avatar ?? "",
                                                fcmToken: widget.fcmToken,
                                                description:
                                                    widget.description?.value,
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                      icon: const Icon(
                                        IconlyLight.chat,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                  Obx(() => Text(
                                        commentsController.commentsCount.value
                                            .toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 10, top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        await relatedVideosController
                                            .createDynamicLink(
                                                widget.currentPageIndex!.value
                                                    .toString(),
                                                "video",
                                                widget.userName.toString(),
                                                widget.avatar.toString())
                                            .then((value) => Share.share(
                                                'You need to watch this awesome video only on Thrill!!!' +
                                                    " " +
                                                    value));
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
                                  right: 10, top: 10, bottom: 80),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        relatedVideosController
                                            .getVideoFavStatus(widget.videoId!)
                                            .then((value) =>
                                                showVideoBottomSheet(() {
                                                  Get.defaultDialog(
                                                      content: const Text(
                                                          "you want to delete this video?"),
                                                      title: "Are your sure?",
                                                      confirm: InkWell(
                                                        child: Container(
                                                          width: Get.width,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors.red
                                                                  .shade400),
                                                          child:
                                                              const Text("Yes"),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                        ),
                                                        onTap: () => relatedVideosController
                                                            .deleteUserVideo(
                                                                widget.videoId!)
                                                            .then((value) =>
                                                                relatedVideosController
                                                                    .refereshVideos()
                                                                    .then((value) =>
                                                                        Get.back())),
                                                      ),
                                                      cancel: InkWell(
                                                        child: Container(
                                                          width: Get.width,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color:
                                                                  Colors.green),
                                                          child: const Text(
                                                              "Cancel"),
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                        ),
                                                        onTap: () => Get.back(),
                                                      ));
                                                }, () {
                                                  relatedVideosController
                                                      .favUnfavVideo(
                                                          widget.videoId!,
                                                          relatedVideosController
                                                                  .isVideoFavourite
                                                                  .isFalse
                                                              ? "fav"
                                                              : "unfav");
                                                }, () async {
                                                  await relatedVideosController
                                                      .createDynamicLink(
                                                          widget
                                                              .currentPageIndex!
                                                              .value
                                                              .toString(),
                                                          "video",
                                                          widget.userName
                                                              .toString(),
                                                          widget.avatar
                                                              .toString())
                                                      .then((value) =>
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      value)));

                                                  successToast(
                                                      "link copied successfully");
                                                }, () async {
                                                  await relatedVideosController
                                                      .checkIfVideoReported(
                                                          widget.videoId!,
                                                          await GetStorage()
                                                              .read("userId"))
                                                      .then((value) async {
                                                    if (value) {
                                                      errorToast(
                                                          "video is already reported");
                                                    } else {
                                                      await relatedVideosController
                                                          .getSiteSettings()
                                                          .then((_) =>
                                                              showReportDialog(
                                                                  widget
                                                                      .videoId!,
                                                                  widget
                                                                      .userName!
                                                                      .value,
                                                                  widget
                                                                      .UserId!));
                                                    }
                                                  });
                                                }, () {
                                                  Get.back(closeOverlays: true);
                                                  relatedVideosController
                                                      .downloadAndProcessVideo(
                                                          widget.videoUrl!,
                                                          widget.userName
                                                              .toString());
                                                }, () async {
                                                  await relatedVideosController
                                                      .checkUserBlocked(
                                                          widget.UserId!)
                                                      .then((value) async =>
                                                          await relatedVideosController
                                                              .blockUnblockUser(
                                                                  widget
                                                                      .UserId!,
                                                                  value));
                                                },
                                                    relatedVideosController
                                                        .isUserBlocked,
                                                    relatedVideosController
                                                        .isVideoFavourite,
                                                    widget.isDuetable!.value,
                                                    widget.UserId!));
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
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 80),
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
                                        ? showLoginBottomSheet(false.obs)
                                        : showLoginBottomSheet(true.obs));
                              } else {
                                await Permission.phone.request().then(
                                    (value) async => await SimDataPlugin
                                            .getSimData()
                                        .then((value) => value.cards.isEmpty
                                            ? showLoginBottomSheet(false.obs)
                                            : showLoginBottomSheet(true.obs)));
                              }
                            } else {
                              if (widget.UserId ==
                                  GetStorage().read("userId")) {
                                widget.callback;
                              } else {
                                Get.toNamed(Routes.OTHERS_PROFILE,
                                    arguments: {"profileId": widget.UserId});
                              }
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                alignment: Alignment.bottomLeft,
                                width: 45,
                                height: 45,
                                child: imgProfile(
                                    widget.publicUser!.avatar.toString()),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.publicUser!.username ?? "",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                        width: 10,
                                      ),
                                      Visibility(
                                        child: InkWell(
                                            onTap: () async {
                                              checkForLogin(() {
                                                relatedVideosController
                                                    .followUnfollowUser(
                                                  widget.UserId!,
                                                  relatedVideosController
                                                          .isUserFollowed
                                                          .isFalse
                                                      ? "follow"
                                                      : "unfollow",
                                                );
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              child: Obx(() => Text(
                                                    relatedVideosController
                                                            .isUserFollowed
                                                            .isFalse
                                                        ? "Follow"
                                                        : "Following",
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white),
                                                  )),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorManager
                                                          .colorAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            )),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    widget.publicUser!.name!.isEmpty
                                        ? widget.publicUser!.username!
                                        : widget.publicUser!.name!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
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
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 100, bottom: 10),
                          child: ReadMoreText(
                            widget.description!.value + " ",
                            trimLines: 2,
                            colorClickableText: ColorManager.colorAccent,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'More',
                            trimExpandedText: 'Less',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            moreStyle: const TextStyle(
                                fontSize: 12,
                                color: ColorManager.colorAccent,
                                fontWeight: FontWeight.w700),
                            lessStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ColorManager.colorAccent),
                          ),
                        )),
                        Visibility(
                          visible: widget.hashtagsList!.isNotEmpty,
                          child: Container(
                            height: 35,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                                itemCount: widget.hashtagsList?.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => InkWell(
                                      onTap: () async {
                                        checkForLogin(() async {
                                          await GetStorage().write("hashtagId",
                                              widget.hashtagsList![index].id);
                                          Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                              arguments: {
                                                "hashtag_name":
                                                    "${widget.hashtagsList![index].name}",
                                                "hashtagId": widget
                                                    .hashtagsList![index].id
                                              });
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
                                          widget.hashtagsList![index].name
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
                            checkForLogin(() async {
                              await GetStorage()
                                  .write("profileId", widget.UserId);

                              DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                              AndroidDeviceInfo androidInfo =
                                  await deviceInfo.androidInfo;

                              try {
                                if (androidInfo.version.sdkInt > 31) {
                                  if (await Permission.audio.isGranted) {
                                    Get.toNamed(Routes.SOUNDS, arguments: {
                                      "sound_id": widget.soundId,
                                      "sound_name": widget.soundName.toString(),
                                      "sound_url": widget.sound,
                                    });
                                    // refreshAlreadyCapturedImages();
                                  } else if (await Permission.audio.isDenied ||
                                      await Permission
                                          .audio.isPermanentlyDenied ||
                                      await Permission.audio.isLimited) {
                                    await Permission.audio.request().then(
                                        (value) async => value.isGranted
                                            ? Get.toNamed(Routes.SOUNDS,
                                                arguments: {
                                                    "sound_id": widget.soundId,
                                                    "sound_name": widget
                                                        .soundName
                                                        .toString(),
                                                    "sound_url": widget.sound,
                                                  })
                                            : await openAppSettings()
                                                .then((value) {
                                                if (value) {
                                                  Get.toNamed(Routes.SOUNDS,
                                                      arguments: {
                                                        "sound_id":
                                                            widget.soundId,
                                                        "sound_name": widget
                                                            .soundName
                                                            .toString(),
                                                        "sound_url":
                                                            widget.sound,
                                                      });
                                                } else {
                                                  errorToast(
                                                      'Audio Permission not granted!');
                                                }
                                              }));
                                  }
                                } else {
                                  if (await Permission.storage.isGranted) {
                                    Get.toNamed(Routes.SOUNDS, arguments: {
                                      "sound_url": "".obs,
                                      "sound_owner": GetStorage()
                                              .read("name")
                                              .toString()
                                              .isEmpty
                                          ? GetStorage()
                                              .read("username")
                                              .toString()
                                              .obs
                                          : GetStorage()
                                              .read("name")
                                              .toString()
                                              .obs
                                    });
                                    // refreshAlreadyCapturedImages();
                                  } else if (await Permission
                                          .storage.isDenied ||
                                      await Permission
                                          .storage.isPermanentlyDenied ||
                                      await Permission.storage.isLimited) {
                                    await Permission.storage.request().then(
                                        (value) async => value.isGranted
                                            ? Get.toNamed(Routes.SOUNDS,
                                                arguments: {
                                                    "sound_id": widget.soundId,
                                                    "sound_name": widget
                                                        .soundName
                                                        .toString(),
                                                    "sound_url": widget.sound,
                                                  })
                                            : await openAppSettings()
                                                .then((value) {
                                                if (value) {
                                                  Get.toNamed(Routes.SOUNDS,
                                                      arguments: {
                                                        "sound_id":
                                                            widget.soundId,
                                                        "sound_name": widget
                                                            .soundName
                                                            .toString(),
                                                        "sound_url":
                                                            widget.sound,
                                                      });
                                                } else {
                                                  errorToast(
                                                      'Audio Permission not granted!');
                                                }
                                              }));
                                  }
                                }
                              } catch (e) {
                                Logger().e(e);
                              }
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
                              Flexible(
                                  child: Text(
                                widget.soundName!.isNotEmpty &&
                                        widget.soundName.toString() != "null" &&
                                        !widget.soundName!
                                            .toLowerCase()
                                            .contains("original")
                                    ? widget.soundName! +
                                        " by ${widget.soundOwner.toString().isEmpty ? widget.publicUser!.name!.isEmpty ? widget.publicUser!.username : widget.publicUser!.name : widget.soundOwner.toString()}"
                                    : "Original Sound" +
                                        " by ${widget.soundOwner.toString().isEmpty ? widget.publicUser!.name!.isEmpty ? widget.publicUser!.username : widget.publicUser!.name : widget.soundOwner.toString()}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )),
                              const SizedBox(
                                width: 40,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          IgnorePointer(
            child: Visibility(
              visible: isMuted.isTrue,
              child: Align(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: ColorManager.colorAccent.withOpacity(0.5),
                      child: Icon(
                        BoxIcons.bx_volume_mute,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ),
          ),
          // IgnorePointer(
          //   child: Obx((() => Visibility(
          //         visible: isVideoPaused.value,
          //         child: Center(
          //             child: ClipOval(
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
          //       ))),
          // ),
        ],
      ),
    );
  }

  showLoginBottomSheet(RxBool isPhoneAvailable) => showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => LoginView(isPhoneAvailable));

  showReportDialog(int videoId, String name, int id) async {
    try {
      List<String> reasonList = [];
      for (SiteSettings element in relatedVideosController.siteSettingsList) {
        if (element.name == 'report_reason') {
          reasonList = element.value.toString().split(',');
          break;
        }
      }
      Get.bottomSheet(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Center(
                child: Text(
                  'Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Why are you reporting this post?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: Container(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: List.generate(
                      reasonList.length,
                      (index) => InkWell(
                            onTap: () {
                              relatedVideosController.reportVideo(
                                  videoId, id, reasonList[index].toString());
                            },
                            child: Container(
                                margin: const EdgeInsets.only(
                                    top: 0, left: 10, right: 10, bottom: 0),
                                width: Get.width,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          reasonList[index].toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        )),
                                        const Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ))),
                          )),
                ),
              ))
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          isScrollControlled: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    } catch (e) {
      closeDialogue(context);
      showErrorToast(context, e.toString());
      return;
    }
  }
}
