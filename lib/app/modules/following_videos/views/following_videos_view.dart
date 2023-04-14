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
import 'package:thrill/app/modules/comments/controllers/comments_controller.dart';
import 'package:thrill/app/modules/home/controllers/home_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../rest/models/following_videos_model.dart';
import '../../../rest/models/site_settings_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../../comments/views/comments_view.dart';
import '../../login/views/login_view.dart';
import '../controllers/following_videos_controller.dart';

class FollowingVideosView extends StatefulWidget {
  FollowingVideosView(
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
      this.fcmToken});

  String? videoUrl, fcmToken;
  PageController? pageController;
  int? nextPage;
  int? videoId;
  String? avatar;
  String? gifImage, sound, soundOwner;
  String? videoLikeStatus;
  RxInt? pageIndex, currentPageIndex;
  RxBool? isPaused;
  RxBool? isCommentAllowed = true.obs;
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

  @override
  State<FollowingVideosView> createState() => _FollowingVideosViewState();
}

class _FollowingVideosViewState extends State<FollowingVideosView>
    with SingleTickerProviderStateMixin {
  var volume = 1.0.obs;
  var comment = "".obs;
  var isVideoPaused = false.obs;
  late VideoPlayerController videoPlayerController;
  var followingVideosController = Get.find<FollowingVideosController>();
  var homeController = Get.find<HomeController>();

  var commentsController = Get.find<CommentsController>();
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    videoPlayerController =
        VideoPlayerController.network(RestUrl.videoUrl + widget.videoUrl!)
          ..setLooping(false)
          ..initialize().then((value) {
            followingVideosController.isInitialised.value = true;
            _controller.repeat();

            setState(() {});
          })
          ..play();

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.duration ==
              videoPlayerController.value.position &&
          videoPlayerController.value.position > Duration.zero) {
        setState(() {
          widget.pageController!.animateToPage(widget.nextPage!,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut);
        });
      }
    });

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();

    if (videoPlayerController.value.duration ==
            videoPlayerController.value.position &&
        videoPlayerController.value.position > Duration.zero) {
      followingVideosController.postVideoView(widget.videoId!);
    }
    super.dispose();
  }

  @override
  void deactivate() {
    videoPlayerController.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
              onDoubleTap: () {
                followingVideosController.likeVideo(
                    widget.videoLikeStatus == "0" ? 1 : 0, widget.videoId!);
              },
              onTapUp: (onTap) {
                setState(() {
                  // videoPlayerController.setVolume(volume.value);
                  if (!videoPlayerController.value.isPlaying &&
                      videoPlayerController.value.isInitialized) {
                    videoPlayerController.play();
                    _controller.repeat();
                  }
                });
              },
              onTapDown: (onTap) {
                if (videoPlayerController.value.isPlaying &&
                    videoPlayerController.value.isInitialized) {
                  videoPlayerController.pause();
                  _controller.stop();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: VisibilityDetector(
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 0 &&
                            videoPlayerController.value.isPlaying) {
                          videoPlayerController.pause();
                        } else {
                          videoPlayerController.play();
                        }
                      },
                      key: const Key("unique key"),
                      child: Obx(() => followingVideosController
                              .isInitialised.isFalse
                          ? loader()
                          : SizedBox(
                              height:
                                  videoPlayerController.value.aspectRatio < 1.5
                                      ? Get.height
                                      : Get.height / 4,
                              width:
                                  videoPlayerController.value.aspectRatio > 1.5
                                      ? videoPlayerController.value.size.width
                                      : Get.width,
                              child: VideoPlayer(videoPlayerController))),
                    ),
                  ),
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
                  //AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio,child: VideoPlayer(videoPlayerController),)

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
                                  onTap: (_) async {
                                    followingVideosController.likeVideo(
                                        widget.videoLikeStatus == "0" ? 1 : 0,
                                        widget.videoId!,
                                        token: widget.fcmToken);
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
                                        .getComments(widget.videoId!)
                                        .then((value) {
                                      Get.bottomSheet(CommentsView(
                                        videoId: widget.videoId!,
                                        userId: widget.UserId,
                                        isCommentAllowed:
                                            widget.isCommentAllowed,
                                        isfollow: widget.isfollow,
                                        userName: widget.userName!.value,
                                        avatar: widget.avatar ?? "",
                                        fcmToken: widget.fcmToken,
                                        description: widget.description?.value,
                                      ));
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
                                widget.commentsCount != null
                                    ? "${widget.commentsCount}"
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
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          Padding(
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
                                                              if (widget
                                                                      .UserId ==
                                                                  GetStorage().read(
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
                                                                                Get.width,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red.shade400),
                                                                            child:
                                                                                const Text("Yes"),
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                          ),
                                                                          onTap: () => followingVideosController
                                                                              .deleteUserVideo(widget.videoId!)
                                                                              .then((value) => Get.back()),
                                                                        ),
                                                                        cancel:
                                                                            InkWell(
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                Get.width,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green),
                                                                            child:
                                                                                const Text("Cancel"),
                                                                            alignment:
                                                                                Alignment.center,
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                          ),
                                                                          onTap: () =>
                                                                              Get.back(),
                                                                        ));

                                                                //  showDeleteDialog();
                                                              }
                                                              else{
                                                                followingVideosController.favUnfavVideo(widget.videoId!, "fav");
                                                              }
                                                            },
                                                            icon: widget.UserId ==
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
                                                        widget.UserId ==
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
                                                              Clipboard.setData(ClipboardData(
                                                                  text: await followingVideosController.createDynamicLink(
                                                                      widget
                                                                          .currentPageIndex!
                                                                          .value
                                                                          .toString(),
                                                                      "video",
                                                                      widget
                                                                          .userName
                                                                          .toString(),
                                                                      widget
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
                                                              followingVideosController
                                                                  .downloadAndProcessVideo(
                                                                      widget
                                                                          .videoUrl!,
                                                                      widget
                                                                          .userName
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
                                                          .then((value) => value
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
                                                          .then((value) async => await SimDataPlugin
                                                                  .getSimData()
                                                              .then((value) => value
                                                                      .cards
                                                                      .isEmpty
                                                                  ? Get.bottomSheet(
                                                                      LoginView(
                                                                          false
                                                                              .obs))
                                                                  : Get.bottomSheet(
                                                                      LoginView(true.obs))));
                                                    }
                                                  } else {
                                                    await followingVideosController
                                                        .checkIfVideoReported(
                                                            widget.videoId!,
                                                            await GetStorage()
                                                                .read("userId"))
                                                        .then((value) async {
                                                      if (value) {
                                                        errorToast(
                                                            "video is already reported");
                                                      } else {
                                                        await followingVideosController
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
                                                          .then((value) => value
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
                                                          .then((value) async => await SimDataPlugin
                                                                  .getSimData()
                                                              .then((value) => value
                                                                      .cards
                                                                      .isEmpty
                                                                  ? Get.bottomSheet(
                                                                      LoginView(
                                                                          false
                                                                              .obs))
                                                                  : Get.bottomSheet(
                                                                      LoginView(true.obs))));
                                                    }
                                                  } else {
                                                    await followingVideosController
                                                        .checkUserBlocked(
                                                            widget.UserId!)
                                                        .then((value) async =>
                                                            await followingVideosController
                                                                .blockUnblockUser(
                                                                    widget
                                                                        .UserId!,
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
                                                    Obx(() => Text(
                                                          followingVideosController
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
                                                              .then((value) => value
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
                                                          await Permission.phone.request().then((value) async => await SimDataPlugin
                                                                  .getSimData()
                                                              .then((value) => value
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
                                                        followingVideosController
                                                            .followUnfollowUser(
                                                                widget.UserId!,
                                                                widget.isfollow ==
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
                                                      // followingVideosController
                                                      //     .getAllVideos();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        widget.isfollow! == 0
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
                                      ),
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
                    margin: const EdgeInsets.only(bottom: 90),
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
                                            (value) => value.cards.isEmpty
                                                ? Get.bottomSheet(
                                                    LoginView(false.obs))
                                                : Get.bottomSheet(
                                                    LoginView(true.obs))));
                              }
                            } else {
                              if (widget.UserId ==
                                  GetStorage().read("userId")) {
                                homeController.bottomNavIndex.value = 3;
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
                                  imageUrl: widget.publicUser!.avatar == null ||
                                          widget.publicUser!.avatar!.isEmpty
                                      ? RestUrl.placeholderImage
                                      : RestUrl.profileUrl +
                                          widget.publicUser!.avatar.toString(),
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
                                            onTap: () async {
                                              if (await GetStorage()
                                                      .read("token") ==
                                                  null) {
                                                if (await Permission
                                                    .phone.isGranted) {
                                                  await SimDataPlugin
                                                          .getSimData()
                                                      .then((value) => value
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
                                                      .then((value) async => await SimDataPlugin
                                                              .getSimData()
                                                          .then((value) => value
                                                                  .cards.isEmpty
                                                              ? Get.bottomSheet(
                                                                  LoginView(
                                                                      false
                                                                          .obs))
                                                              : Get.bottomSheet(
                                                                  LoginView(true.obs))));
                                                }
                                              } else {
                                                followingVideosController
                                                    .followUnfollowUser(
                                                  widget.UserId!,
                                                  widget.isfollow == 0
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
                                                      BorderRadius.circular(5)),
                                            )),
                                        visible: GetStorage().read("token") !=
                                                null &&
                                            widget.UserId !=
                                                GetStorage().read("userId"),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    widget.publicUser!.name ?? "",
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
                            widget.description!.value,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Visibility(
                          visible: widget.hashtagsList!=null,
                          child: Container(
                            height: 35,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                                itemCount: widget.hashtagsList?.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => InkWell(
                                      onTap: () async {
                                        await GetStorage().write("hashtagId",
                                            widget.hashtagsList![index].id);
                                        Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                            arguments: {
                                              "hashtag_name":
                                                  "${widget.hashtagsList![index].name}"
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
                            await GetStorage()
                                .write("profileId", widget.UserId);

                            Get.toNamed(Routes.SOUNDS, arguments: {
                              "sound_name": widget.soundName.toString(),
                              "sound_url": widget.sound,
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
                                widget.soundName!.isEmpty
                                    ? "Original Sound"
                                    : widget.soundName! +
                                        " by ${widget.publicUser!.name}",
                                style: const TextStyle(color: Colors.white),
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
              visible: !videoPlayerController.value.isPlaying,
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
            ),
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
          ),
        ],
      ),
    );
  }

  showReportDialog(int videoId, String name, int id) async {
    var dropDownValue = "Reason".obs;
    List<String> dropDownValues = [
      "Reason",
    ];
    try {
      List jsonList = followingVideosController.siteSettingsList;
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
      closeDialogue(context);
      showErrorToast(context, e.toString());
      return;
    }
    Get.defaultDialog(
      title: "Report $name's Video ?",
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: Container(
          width: getWidth(context) * .80,
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
                child: Obx(() => DropdownButton(
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
              Obx(() => ElevatedButton(
                  onPressed: dropDownValue.value == "Reason"
                      ? null
                      : () async {
                          try {
                            followingVideosController.reportVideo(
                                videoId, id, dropDownValue.value);
                          } catch (e) {
                            closeDialogue(context);
                            showErrorToast(context, e.toString());
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
