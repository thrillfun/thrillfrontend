import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart' as uvController;
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/sound/sound_details.dart';
import 'package:thrill/screens/video/duet.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controller/comments/comments_controller.dart';
import '../controller/users/other_users_controller.dart';
import '../controller/users_controller.dart';
import '../controller/videos/UserVideosController.dart';
import '../controller/videos/hashtags_videos_controller.dart';
import '../controller/videos/like_videos_controller.dart';

var videosController = Get.find<uvController.VideosController>();
var commentsController = Get.find<CommentsController>();
var usersController = Get.find<UserController>();
var otherUsersController = Get.find<OtherUsersController>();
var likedVideosController = Get.find<LikedVideosController>();
var userVideosController = Get.find<UserVideosController>();
var relatedVideosController = Get.find<RelatedVideosController>();
var hashtagVideosController = Get.find<HashtagVideosController>();

class BetterReelsPlayer extends StatefulWidget {
  BetterReelsPlayer(
    this.gifImage,
    this.videoUrl,
    this.pageIndex,
    this.currentPageIndex,
    this.isPaused,
    this.callback,
    this.publicUser,
    this.videoId,
    this.soundName,
    this.isDuetable,
    this.publicVideos,
    this.UserId,
    this.userName,
    this.description,
    this.isHome,
    this.hashtagsList,
    this.sound,
    this.soundOwner,
    this.videoLikeStatus,
    this.isCommentAllowed, {
    this.like,
    this.isfollow,
    this.commentsCount,
  });

  String gifImage, sound, soundOwner;
  String videoLikeStatus;
  String videoUrl;
  RxInt pageIndex;
  RxInt currentPageIndex;
  RxBool isPaused;
  RxBool isCommentAllowed = true.obs;
  VoidCallback callback;
  PublicUser? publicUser;
  int videoId;
  String soundName;
  RxBool isDuetable = false.obs;
  PublicVideos publicVideos;
  int UserId;
  RxString userName;
  RxString description;
  RxBool isHome = false.obs;
  List<Hashtags> hashtagsList;
  RxInt? like = 0.obs;
  int? isfollow = 0;
  RxInt? commentsCount = 0.obs;

  @override
  State<BetterReelsPlayer> createState() => _VideoAppState();
}

class _VideoAppState extends State<BetterReelsPlayer>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  FocusNode fieldNode = FocusNode();
  var currentDuration = Duration().obs;

  var userController = Get.find<UserController>();
  TextEditingController? _textEditingController;
  var initialized = false.obs;
  var volume = 1.0.obs;
  var comment = "".obs;
  var isVideoPaused = false.obs;

  late VideoPlayerController betterPlayerController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();

    betterPlayerController = VideoPlayerController.network(
        RestUrl.videoUrl + widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false))
      ..setLooping(false)
      ..initialize().then((value) => setState(() {
            initialized.value = true;
          }));

    currentDuration.value = betterPlayerController.value.position;
  }

  @override
  void dispose() {
    if (initialized.value) {
      betterPlayerController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized.value &&
        widget.pageIndex.value == widget.currentPageIndex.value &&
        !widget.isPaused.value) {
      setState(() {
        betterPlayerController.play();
        isVideoPaused.value = false;
      });
    } else {
      setState(() {
        betterPlayerController.pause();
        isVideoPaused.value = true;
      });
    }

    return VisibilityDetector(
        key: const Key("key"),
        child: Stack(
          children: [
            GestureDetector(
                onDoubleTap: widget.callback,
                onLongPressEnd: (_) {
                  setState(() {
                    widget.isPaused = false.obs;
                  });
                },
                onTap: () {
                  if (volume.value == 1) {
                    volume.value = 0;
                  } else {
                    volume.value = 1;
                  }
                  setState(() {
                    betterPlayerController.setVolume(volume.value);
                  });
                },
                onLongPressStart: (_) {
                  setState(() {
                    widget.isPaused = true.obs;
                  });
                },
                child: Stack(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        color: Colors.black,
                        child: Obx(() => initialized.value
                            ? AspectRatio(
                                aspectRatio:
                                    betterPlayerController.value.aspectRatio,
                                child: ValueListenableBuilder(
                                  valueListenable: betterPlayerController,
                                  builder:
                                      (context, VideoPlayerValue value, child) {
                                    if (value.position == value.duration &&
                                        value.position > Duration.zero &&
                                        initialized.isTrue) {
                                      // var nextPage = preloadPageController!.page!.toInt();
                                      // nextPage++;
                                      // preloadPageController!.animateToPage(
                                      //     nextPage,
                                      //     duration: Duration(milliseconds: 400),
                                      //     curve: Curves.easeIn);
                                      videosController
                                          .postVideoView(widget.videoId);
                                    }
                                    return VideoPlayer(betterPlayerController);
                                  },
                                ),
                              )
                            : CachedNetworkImage(
                                height: Get.height,
                                width: Get.width,
                                fit: BoxFit.fill,
                                imageUrl: RestUrl.gifUrl + widget.gifImage))),
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
                                      start: Colors.red.shade200,
                                      end: Colors.red),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: Colors.red.shade200,
                                    dotSecondaryColor: Colors.red,
                                  ),
                                  likeBuilder: (bool isLiked) {
                                    widget.videoLikeStatus == "0"
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
                                  likeCount: widget.like!.value,
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
                                      await relatedVideosController.likeVideo(
                                          widget.videoLikeStatus == "0" ? 1 : 0,
                                          widget.videoId),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: widget.isHome.value
                                ? const EdgeInsets.only(right: 10)
                                : const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      commentsController
                                          .getComments(widget.videoId);
                                      GetStorage().read("videoPrivacy") ==
                                              "Private"
                                          ? showErrorToast(
                                              context, "this video is private!")
                                          : showComments();
                                    },
                                    icon: const Icon(
                                      IconlyLight.chat,
                                      color: Colors.white,
                                      size: 25,
                                    )),
                                Text(
                                  widget.commentsCount != null
                                      ? "${widget.commentsCount!.value}"
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
                                          Flexible(
                                              child: Container(
                                            height: 300,
                                            margin: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Column(children: [
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
                                                            VideoModel videModel = VideoModel(
                                                                widget
                                                                    .publicVideos
                                                                    .id!,
                                                                widget
                                                                    .publicVideos
                                                                    .comments!,
                                                                widget
                                                                    .publicVideos
                                                                    .video!,
                                                                widget
                                                                    .publicVideos
                                                                    .description!,
                                                                widget
                                                                    .publicVideos
                                                                    .likes!,
                                                                null,
                                                                widget
                                                                    .publicVideos
                                                                    .filter!,
                                                                widget
                                                                    .publicVideos
                                                                    .gifImage!,
                                                                widget
                                                                    .publicVideos
                                                                    .sound!,
                                                                widget
                                                                    .publicVideos
                                                                    .soundName!,
                                                                widget
                                                                    .publicVideos
                                                                    .soundCategoryName!,
                                                                widget
                                                                    .publicVideos
                                                                    .views!,
                                                                widget
                                                                    .publicVideos
                                                                    .speed!,
                                                                [],
                                                                widget
                                                                    .publicVideos
                                                                    .isDuet!,
                                                                widget
                                                                    .publicVideos
                                                                    .duetFrom!,
                                                                widget
                                                                    .publicVideos
                                                                    .isDuetable!,
                                                                widget
                                                                    .publicVideos
                                                                    .isCommentable!,
                                                                widget
                                                                    .publicVideos
                                                                    .soundOwner!);
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
                                                              if (widget
                                                                      .UserId ==
                                                                  GetStorage().read(
                                                                          "user")[
                                                                      'id']) {
                                                                showDeleteDialog();
                                                              }
                                                            },
                                                            icon: widget.UserId ==
                                                                    usersController
                                                                        .userProfile
                                                                        .value
                                                                        .id
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
                                                        widget.UserId ==
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
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Column(
                                                      children: [
                                                        IconButton(
                                                            onPressed:
                                                                () async {
                                                              var deepLink = await userDetailsController
                                                                  .createDynamicLink(
                                                                      "${widget.publicUser?.id}",
                                                                      'profile',
                                                                      "${widget.publicUser!.name}",
                                                                      "${widget.publicUser!.avatar}");
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
                                                              relatedVideosController.downloadAndProcessVideo(
                                                                      widget
                                                                          .videoUrl,
                                                                  widget
                                                                      .userName
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
                                                onTap: () => GetStorage()
                                                            .read("token") !=
                                                        null
                                                    ? showReportDialog(
                                                        widget.videoId,
                                                        widget.userName.value,
                                                        widget.UserId)
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
                                                onTap: () {
                                                  if (GetStorage()
                                                          .read("token")
                                                          .toString()
                                                          .isNotEmpty &&
                                                      GetStorage()
                                                              .read("token") !=
                                                          null) {
                                                    usersController
                                                        .isUserBlocked(
                                                            widget.UserId);
                                                    Future.delayed(
                                                            const Duration(
                                                                seconds: 1))
                                                        .then((value) => usersController
                                                                .userBlocked
                                                                .value
                                                            ? usersController
                                                                .blockUnblockUser(
                                                                    widget
                                                                        .UserId,
                                                                    "Unblock")
                                                            : usersController
                                                                .blockUnblockUser(
                                                                    widget
                                                                        .UserId,
                                                                    "Block"));
                                                  } else {
                                                    showLoginAlert();
                                                  }
                                                },
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.block,
                                                      color: ColorManager
                                                          .colorAccent,
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
                                              InkWell(
                                                onTap: () {
                                                  userDetailsController
                                                      .followUnfollowUser(
                                                          widget.UserId,
                                                          widget.isfollow == 0
                                                              ? "follow"
                                                              : "unfollow");
                                                },
                                                child: Row(
                                                  children: [
                                                    widget.isfollow! == 0
                                                        ? const Icon(
                                                            Icons.add,
                                                            color: ColorManager
                                                                .colorAccent,
                                                            size: 30,
                                                          )
                                                        : const Icon(
                                                            Icons.add,
                                                            color: ColorManager
                                                                .colorAccent,
                                                            size: 30,
                                                          ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      widget.isfollow == 0
                                                          ? "Follow"
                                                          : "Following",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorManager
                                                              .colorAccent),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ]),
                                          )),
                                          backgroundColor:
                                              ColorManager.dayNight,
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
                                widget.publicUser!.id ==
                                        usersController.storage.read("userId")
                                    ? await userVideosController.getUserVideos()
                                    : await userVideosController
                                        .getOtherUserVideos(
                                            widget.publicUser!.id!);
                                widget.publicUser!.id ==
                                        usersController.storage.read("userId")
                                    ? await likedVideosController
                                        .getUserLikedVideos()
                                    : await likedVideosController
                                        .getOthersLikedVideos(
                                            widget.publicUser!.id!);
                                widget.publicUser!.id ==
                                        usersController.storage.read("userId")
                                    ? await userDetailsController
                                        .getUserProfile()
                                        .then((value) {
                                        Get.to(Profile(isProfile: true.obs));
                                      })
                                    : await otherUsersController
                                        .getOtherUserProfile(
                                            widget.publicUser!.id!)
                                        .then((value) {
                                        Get.to(ViewProfile(
                                            widget.UserId.toString(),
                                            widget.isfollow!.obs,
                                            widget.userName.toString(),
                                            widget.publicUser!.avatar
                                                .toString()));
                                      });
                              } else {
                                Get.to(LoginGetxScreen());
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
                                    imageUrl: widget.publicUser!.avatar ==
                                                null ||
                                            widget.publicUser!.avatar!.isEmpty
                                        ? RestUrl.placeholderImage
                                        : RestUrl.profileUrl +
                                            widget.publicUser!.avatar
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
                                          widget.publicUser!.username ?? "",
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
                                                if (userDetailsController
                                                        .storage
                                                        .read("token") ==
                                                    null) {
                                                  errorToast(
                                                      "login to continue");
                                                } else {
                                                  userDetailsController
                                                      .followUnfollowUser(
                                                          widget.UserId,
                                                          widget.isfollow == 0
                                                              ? "follow"
                                                              : "unfollow");
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 10),
                                                child: Text(
                                                  widget.isfollow == 0
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
                                                        BorderRadius.circular(
                                                            5)),
                                              )),
                                          visible: widget.UserId !=
                                              usersController.storage
                                                  .read("userId"),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.publicUser!.name.toString() ?? "",
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
                              widget.description.value,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Visibility(
                            visible: widget.hashtagsList.isNotEmpty,
                            child: Container(
                              height: 35,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                  itemCount: widget.hashtagsList.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => InkWell(
                                        onTap: () async {
                                          await hashtagVideosController
                                              .getVideosByHashTags(widget
                                                  .hashtagsList[index].id!)
                                              .then((value) =>
                                                  Get.to(() => HashTagsScreen(
                                                        tagName: widget
                                                            .hashtagsList[index]
                                                            .name,
                                                        videoCount: widget
                                                            .hashtagsList[index]
                                                            .id,
                                                      )));
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
                                            widget.hashtagsList[index].name
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
                            onTap: () => Get.to(SoundDetails(
                              map: {
                                "sound": widget.sound,
                                "user": widget.soundOwner.isEmpty
                                    ? widget.userName
                                    : widget.soundOwner,
                                "soundName": widget.soundName,
                                "title": widget.soundOwner,
                                "id": widget.videoId,
                                "profile": widget.publicUser!.avatar,
                                "name": widget.publicUser!.name,
                                "sound_id": widget.publicVideos.id,
                                "username": widget.publicUser!.username,
                                "isFollow": widget.isfollow,
                                "userProfile": widget.publicUser!.avatar != null
                                    ? widget.publicUser!.avatar
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
                                Text(
                                  widget.soundName.isEmpty
                                      ? "Original Sound"
                                      : widget.soundName,
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
            IgnorePointer(
              child: Obx((() => Visibility(
                    visible: volume.value <= 0,
                    child: Center(
                        child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: ColorManager.colorAccent.withOpacity(0.5),
                        child: const Icon(
                          IconlyLight.volume_off,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ))),
            ),
            IgnorePointer(
              child: Obx((() => Visibility(
                    visible: isVideoPaused.value,
                    child: Center(
                        child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: ColorManager.colorAccent.withOpacity(0.5),
                        child: const Icon(
                          IconlyLight.play,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ))),
            )
          ],
        ),
        onVisibilityChanged: (VisibilityInfo info) {
          if (initialized.isTrue) {
            info.visibleFraction == 0
                ? betterPlayerController.pause()
                : betterPlayerController.play();
          }
        });
  }

  showReportDialog(int videoId, String name, int id) async {
    String dropDownValue = "Reason";
    List<String> dropDownValues = [
      "Reason",
    ];
    try {
      var response = await RestApi.getSiteSettings();
      var json = jsonDecode(response.body);
      if (json['status']) {
        List jsonList = json['data'] as List;
        for (var element in jsonList) {
          if (element['name'] == 'report_reason') {
            List reasonList = element['value'].toString().split(',');
            for (String reason in reasonList) {
              dropDownValues.add(reason);
            }
            break;
          }
        }
      } else {
        showErrorToast(context, json['message'].toString());
        return;
      }
    } catch (e) {
      closeDialogue(context);
      showErrorToast(context, e.toString());
      return;
    }
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                        width: getWidth(context) * .80,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "Report $name's Video ?",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5)),
                              child: DropdownButton(
                                value: dropDownValue,
                                underline: Container(),
                                isExpanded: true,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                                onChanged: (String? value) {
                                  setState(() {
                                    dropDownValue =
                                        value ?? dropDownValues.first;
                                  });
                                },
                                items: dropDownValues.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                                onPressed: dropDownValue == "Reason"
                                    ? null
                                    : () async {
                                        try {
                                          var response =
                                              await RestApi.reportVideo(
                                                  videoId, id, dropDownValue);
                                          var json = jsonDecode(response.body);
                                          closeDialogue(context);
                                          if (json['status']) {
                                            //Navigator.pop(context);
                                            showSuccessToast(context,
                                                json['message'].toString());
                                          } else {
                                            //Navigator.pop(context);
                                            showErrorToast(context,
                                                json['message'].toString());
                                          }
                                        } catch (e) {
                                          closeDialogue(context);
                                          showErrorToast(context, e.toString());
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 5)),
                                child: const Text("Report"))
                          ],
                        )),
                  ),
                );
              },
            ));
  }

  showDeleteDialog() {
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
                            videosController.deleteVideo(widget.videoId),
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

  showComments() {
    // showModalBottomSheet(
    //     context: context,
    //     builder: (BuildContext context) => );
    Get.bottomSheet(
        CommentsScreen(
          videoId: widget.videoId,
          userId: widget.UserId,
          isCommentAllowed: widget.isCommentAllowed,
          isfollow: widget.isfollow,
          userName: widget.userName.value,
          avatar: widget.publicUser!.avatar,
        ),
        backgroundColor: ColorManager.dayNight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
  }

  Future<Uri> createDynamicLink(String videoName) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse('${RestUrl.videoUrl}$videoName'),
      // ignore: prefer_const_constructors
      androidParameters: AndroidParameters(
        packageName: 'com.thrill',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await parameters.link;
    final Uri shortUrl = dynamicUrl;
    return shortUrl;
  }
}

// ignore: must_be_immutable
class CommentsScreen extends GetView<CommentsController> {
  CommentsScreen(
      {Key? key,
      this.videoId,
      this.userId,
      this.isCommentAllowed,
      this.isfollow,
      this.userName,
      this.avatar})
      : super(key: key);
  int? videoId, userId;
  RxBool? isCommentAllowed;
  int? isfollow;
  String? userName, avatar;

  FocusNode fieldNode = FocusNode();

  final _textEditingController = TextEditingController();
  RxString videoComment = "".obs;

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          const Divider(
            thickness: 2,
          ),
          Flexible(
            child: state!.isEmpty
                ? const Center(
                    child: Text("No Comments Yet", style: TextStyle()),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: state.length,
                    itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (GetStorage().read("token") != null) {
                                      userId == userDetailsController.storage.read("userId")
                                          ? await userDetailsController
                                              .getUserProfile()
                                              .then((value) => Get.to(
                                                  Profile(isProfile: true.obs)))
                                          : await otherUsersController
                                              .getOtherUserProfile(int.parse(
                                                  state[index]
                                                      .userId!
                                                      .toString()))
                                              .then((value) => Get.to(
                                                  ViewProfile(
                                                      userId.toString(),
                                                      isfollow!.obs,
                                                      userName.toString(),
                                                      avatar.toString())));
                                    } else {
                                      Get.to(LoginGetxScreen());
                                    }
                                  },
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: state[index].avatar!.isEmpty ||
                                              state[index].avatar == null
                                          ? "https://www.kindpng.com/picc/m/252-2524695_dummy-profile-image-jpg-hd-png-download.png"
                                          : RestUrl.profileUrl +
                                              state[index].avatar.toString(),
                                      fit: BoxFit.cover,
                                      height: 48,
                                      width: 48,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state[index].name.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () {
                                      controller.likeComment(
                                          state[index].id.toString(), "1");
                                      Future.delayed(const Duration(seconds: 1))
                                          .then((value) => commentsController
                                              .getComments(videoId!));
                                    },
                                    child: const Icon(
                                      IconlyLight.heart,
                                      size: 20,
                                    ),
                                  ),
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              state[index].comment.toString(),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                alignment: Alignment.bottomLeft,
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.likeComment(
                                            state[index].id.toString(), "1");
                                        Future.delayed(
                                                const Duration(seconds: 1))
                                            .then((value) => controller
                                                .getComments(videoId!));
                                      },
                                      child: const Icon(
                                        IconlyLight.heart,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      state[index]
                                              .commentLikeCounter
                                              .toString() +
                                          " Likes",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )),
                          ],
                        )),
                  ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Expanded(
            flex: 0,
            child: Container(
                margin: const EdgeInsets.all(15),
                child: GetStorage().read("token").toString().isEmpty ||
                        GetStorage().read("token") == null
                    ? Container(
                        alignment: Alignment.center,
                        width: Get.width,
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Login',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.back(closeOverlays: true);
                                  Get.to(LoginGetxScreen());
                                },
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: ColorManager.colorPrimaryLight)),
                          const TextSpan(
                              text: " to post comments",
                              style: TextStyle(color: Colors.grey))
                        ])),
                      )
                    : isCommentAllowed!.value
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: Flexible(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    focusNode: fieldNode,
                                    enabled: isCommentAllowed?.value,
                                    controller: _textEditingController,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: fieldNode.hasFocus
                                            ? ColorManager.colorAccent
                                            : Colors.grey),
                                    onChanged: (value) {
                                      videoComment.value = value;
                                    },
                                    decoration: InputDecoration(
                                      focusColor: ColorManager.colorAccent,
                                      fillColor: fieldNode.hasFocus
                                          ? ColorManager.colorAccentTransparent
                                          : Colors.grey.withOpacity(0.1),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: fieldNode.hasFocus
                                            ? const BorderSide(
                                                color: Color(0xff2DCBC8),
                                              )
                                            : const BorderSide(
                                                color: Color(0xffFAFAFA),
                                              ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: fieldNode.hasFocus
                                            ? const BorderSide(
                                                color: Color(0xff2DCBC8),
                                              )
                                            : BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                              ),
                                      ),
                                      filled: true,
                                      prefixIcon: Icon(
                                        Icons.message,
                                        color: fieldNode.hasFocus
                                            ? ColorManager.colorAccent
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                      prefixStyle: TextStyle(
                                          color: fieldNode.hasFocus
                                              ? const Color(0xff2DCBC8)
                                              : Colors.grey,
                                          fontSize: 14),
                                      hintText: "Type your message...",
                                      hintStyle: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                    Color.fromRGBO(255, 77, 103, 0.12),
                                    Color.fromRGBO(45, 203, 200, 1),
                                  ])),
                                  child: InkWell(
                                      onTap: () async {
                                        controller
                                            .postComment(
                                          videoId: videoId!,
                                          userId: userDetailsController.storage
                                              .read("userId")
                                              .toString(),
                                          comment: videoComment.value,
                                        )
                                            .then((value) async {
                                          await controller
                                              .getComments(videoId!);
                                          _textEditingController.clear();
                                        });
                                      },
                                      child: const Icon(
                                        IconlyLight.send,
                                        size: 20,
                                      )),
                                ),
                              )
                            ],
                          )
                        : SizedBox(
                            width: Get.width,
                            child: const Text(
                              'Comments are disabled for this video',
                              textAlign: TextAlign.center,
                            ),
                          )),
          )
        ],
      ),
      onLoading: loader(),
    );
  }
}
