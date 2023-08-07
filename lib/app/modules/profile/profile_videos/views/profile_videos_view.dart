import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:logger/logger.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/modules/bindings/AdsController.dart';
import 'package:thrill/app/rest/models/user_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/widgets/focus_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../rest/models/site_settings_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../../../comments/controllers/comments_controller.dart';
import '../../../comments/views/comments_view.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../login/views/login_view.dart';
import '../controllers/profile_videos_controller.dart';

class ProfileVideosView extends GetView<ProfileVideosController> {
  ProfileVideosView({Key? key}) : super(key: key);
  var pageViewController =
      PageController(initialPage: Get.arguments["init_page"] ?? 0);

  var playerController = BetterPlayerListVideoPlayerController();
  var commentsController = Get.find<CommentsController>();
  AnimationController? _controller;
  var pageController = PageController();
  var adsController = Get.find<AdsController>();
  @override
  Widget build(BuildContext context) {
    controller.getUserVideos();
    adsController.loadNativeAd();

    return Scaffold(
      body: controller.obx(
          (state) => PageView.builder(
              itemCount: state!.length,
              scrollDirection: Axis.vertical,
              controller: pageViewController,
              allowImplicitScrolling: true,
              onPageChanged: (index) {
                if (index == state!.length - 1) {
                  controller.getPaginationAllVideos(0);
                }
                if (state[index].id != null) {
                  commentsController.getComments(state[index].id!);
                  controller.followUnfollowStatus(state[index].id!);

                  controller.videoLikeStatus(
                    state[index].id!,
                  );
                }

                if (index % 8 == 0) {
                  adsController.loadNativeAd();
                }
              },
              itemBuilder: (context, index) {
                _controller = AnimationController(vsync: Scaffold.of(context));
                return state![index].id == null
                    ? Obx(
                        () => adsController.nativeAdIsLoaded.isFalse
                            ? Container(
                                height: Get.height,
                                width: Get.width,
                                child: loader(),
                                alignment: Alignment.center,
                              )
                            : Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    height: Get.height,
                                    width: Get.width,
                                    margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewPadding
                                            .bottom),
                                    child: AdWidget(
                                      ad: adsController.nativeAd!,
                                    ),
                                  ),
                                ],
                              ),
                      )
                    : LikedVideos(
                        videoUrl: state[index].video.toString(),
                        pageController: pageViewController!,
                        nextPage: index + 1,
                        videoId: state[index].id!,
                        gifImage: state[index].gifImage,
                        soundName: state[index].soundName,
                        UserId: state[index].user!.id,
                        userName: state[index].user!.username!.obs,
                        description: state[index].description!.obs,
                        hashtagsList: state[index].hashtags ?? [],
                        soundOwner: state[index].soundOwner,
                        sound: state[index].sound,
                        videoLikeStatus: state[index]
                            .videoLikeStatus
                            .toString(), //no such parameter
                        isCommentAllowed: state[index].isCommentable == "Yes"
                            ? true.obs
                            : false.obs,
                        like: state[index].likes!.obs,
                        isfollow: 0,
                        commentsCount: state[index].comments!.obs,
                        soundId: state[index].soundId,
                        avatar: state[index].user!.avatar,
                        currentPageIndex: index.obs,
                        fcmToken: state[index].user!.firebaseToken,
                        publicUser: state[index].user,
                      );
              }),
          onLoading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: loader(),
              )
            ],
          ),
          onError: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "No videos found",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
          onEmpty: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "No following Videos",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )),
    );
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

class LikedVideos extends StatefulWidget {
  LikedVideos(
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

  @override
  State<LikedVideos> createState() => _LikedVideosState();
}

class _LikedVideosState extends State<LikedVideos>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late VideoPlayerController videoPlayerController;
  var relatedVideosController = Get.find<ProfileVideosController>();
  var homeController = Get.find<HomeController>();

  var commentsController = Get.find<CommentsController>();
  late AnimationController _controller;
  var isVisible = false.obs;
  var currentDuration = Duration().obs;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    commentsController.getComments(widget.videoId!);
    videoPlayerController =
        VideoPlayerController.network(RestUrl.videoUrl + widget.videoUrl!)
          ..setLooping(false)
          ..initialize().then((value) {
            relatedVideosController.isInitialised.value = true;
            _controller.repeat();
            setState(() {});
          });

    videoPlayerController.addListener(() async {
      currentDuration.value = videoPlayerController.value.position;

      if (videoPlayerController.value.duration ==
              videoPlayerController.value.position &&
          videoPlayerController.value.position > Duration.zero) {
        widget.pageController!.animateToPage(widget.nextPage!,
            duration: const Duration(milliseconds: 700), curve: Curves.easeOut);
        setState(() {});
      }
    });

    currentDuration.listen((duration) async {
      Future.delayed(Duration(seconds: 1)).then((value) {
        try {
          if (Get.isOverlaysOpen || isVisible.isFalse) {
            setState(() {
              videoPlayerController.pause();
            });
          } else {
            videoPlayerController.play();
            setState(() {});
          }
        } catch (e) {
          Logger().e(e);
        }
      });
      /*  //code to automatically take to video less than 10 seconds
      // if(videoPlayerController.value.duration.inSeconds>=10){
      //   widget.pageController!.animateToPage(widget.nextPage!,
      //       duration: const Duration(milliseconds: 700), curve: Curves.easeOut);
      //   setState(() {});
      // }*/
      if (videoPlayerController.value.duration.inSeconds > 0 &&
          duration.inSeconds > 0) {
        if (videoPlayerController.value.duration.inSeconds > 10) {
          if (duration.inSeconds > 0 && duration.inSeconds == 9) {
            await relatedVideosController.postVideoView(widget.videoId!);
          }
        }
      }
      if (videoPlayerController.value.duration.inSeconds < 10 &&
          duration.inSeconds > 0) {
        if (duration.inSeconds == 5) {
          await relatedVideosController.postVideoView(widget.videoId!);
        }
      }
    });
    setState(() {});

    relatedVideosController.checkUserBlocked(widget.UserId!);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();

    if (videoPlayerController.value.duration ==
            videoPlayerController.value.position &&
        videoPlayerController.value.position > Duration.zero) {
      //  relatedVideosController.postVideoView(widget.videoId!).then((value) {});
    }

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
                if (videoPlayerController.value.isPlaying) {
                  videoPlayerController.pause();
                  _controller.stop();
                  isVisible.value = false;
                  setState(() {});
                } else {
                  videoPlayerController.play();
                  _controller.repeat();
                  isVisible.value = true;

                  setState(() {});
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FocusDetector(
                      onVisibilityGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        setState(() {});
                      },
                      onVisibilityLost: () {
                        videoPlayerController.pause();
                        isVisible.value = false;
                        setState(() {});
                      },
                      onForegroundLost: () {
                        videoPlayerController.pause();
                        isVisible.value = false;
                        setState(() {});
                      },
                      onForegroundGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        setState(() {});
                      },
                      onFocusLost: () {
                        videoPlayerController.pause();
                        isVisible.value = false;
                        setState(() {});
                      },
                      onFocusGained: () {
                        videoPlayerController.play();
                        isVisible.value = true;
                        setState(() {});
                      },
                      child: Obx(() => relatedVideosController
                              .isInitialised.isFalse
                          ? loader()
                          : SizedBox(
                              height:
                                  videoPlayerController.value.aspectRatio < 1.5
                                      ? Get.height
                                      : Get.height / 3,
                              width:
                                  videoPlayerController.value.aspectRatio > 1.5
                                      ? videoPlayerController.value.size.width
                                      : Get.width,
                              child: VideoPlayer(videoPlayerController)))),
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
                              Obx(() => InkWell(
                                  child: Icon(
                                    relatedVideosController.isLiked.isTrue
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    color:
                                        relatedVideosController.isLiked.isTrue
                                            ? Colors.red
                                            : Colors.white,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    checkForLogin(() {
                                      relatedVideosController.likeVideo(
                                          relatedVideosController
                                                  .isLiked.isFalse
                                              ? 1
                                              : 0,
                                          widget.videoId!,
                                          token: widget.fcmToken,
                                          userName: widget.userName!.value);
                                    });
                                  })),
                              Obx(() => Text(
                                    relatedVideosController.totalLikes.value
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                  ))
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
                                      Get.bottomSheet(
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          child: CommentsView(
                                            videoId: widget.videoId!,
                                            userId: widget.UserId,
                                            isCommentAllowed:
                                                widget.isCommentAllowed,
                                            isfollow: relatedVideosController
                                                    .isUserFollowed.isTrue
                                                ? 1
                                                : 0,
                                            userName: widget.userName!.value,
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
                              right: 10, top: 10, bottom: 10),
                          child: Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Get.bottomSheet(
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
                                                            onPressed: () {},
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
                                                                    GetStorage()
                                                                        .read(
                                                                            "userId")) {
                                                                  Get.defaultDialog(
                                                                      content: const Text("you want to delete this video?"),
                                                                      title: "Are your sure?",
                                                                      confirm: InkWell(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              Get.width,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: Colors.red.shade400),
                                                                          child:
                                                                              const Text("Yes"),
                                                                          padding:
                                                                              const EdgeInsets.all(10),
                                                                        ),
                                                                        onTap: () => relatedVideosController.deleteUserVideo(widget.videoId!).then((value) => relatedVideosController
                                                                            .getUserVideos()
                                                                            .then((value) =>
                                                                                Get.back())),
                                                                      ),
                                                                      cancel: InkWell(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              Get.width,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: Colors.green),
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
                                                                } else {
                                                                  // relatedVideosController
                                                                  //     .favUnfavVideo(
                                                                  //         widget
                                                                  //             .videoId!,
                                                                  //         "fav");
                                                                }
                                                              },
                                                              icon: widget.UserId ==
                                                                      GetStorage()
                                                                          .read(
                                                                              "userId")
                                                                  ? const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: ColorManager
                                                                          .red,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .save,
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
                                                                      color: ColorManager
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
                                                                    text: await relatedVideosController.createDynamicLink(
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
                                                                relatedVideosController.downloadAndProcessVideo(
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
                                                                    .cards
                                                                    .isEmpty
                                                                ? showLoginBottomSheet(
                                                                    false.obs)
                                                                : showLoginBottomSheet(
                                                                    true.obs));
                                                      } else {
                                                        await Permission.phone
                                                            .request()
                                                            .then((value) async => await SimDataPlugin
                                                                    .getSimData()
                                                                .then((value) => value
                                                                        .cards
                                                                        .isEmpty
                                                                    ? showLoginBottomSheet(
                                                                        false
                                                                            .obs)
                                                                    : showLoginBottomSheet(
                                                                        true.obs)));
                                                      }
                                                    } else {
                                                      await relatedVideosController
                                                          .checkIfVideoReported(
                                                              widget.videoId!,
                                                              widget.UserId!)
                                                          .then((value) async {
                                                        if (value) {
                                                          errorToast(
                                                              "video is already reported");
                                                        } else {
                                                          await relatedVideosController
                                                              .getSiteSettings()
                                                              .then((_) => showReportDialog(
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
                                                        color:
                                                            Color(0xffFF2400),
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
                                                                    .cards
                                                                    .isEmpty
                                                                ? showLoginBottomSheet(
                                                                    false.obs)
                                                                : showLoginBottomSheet(
                                                                    true.obs));
                                                      } else {
                                                        await Permission.phone
                                                            .request()
                                                            .then((value) async => await SimDataPlugin
                                                                    .getSimData()
                                                                .then((value) => value
                                                                        .cards
                                                                        .isEmpty
                                                                    ? showLoginBottomSheet(
                                                                        false
                                                                            .obs)
                                                                    : showLoginBottomSheet(
                                                                        true.obs)));
                                                      }
                                                    } else {
                                                      await relatedVideosController
                                                          .checkUserBlocked(
                                                              widget.UserId!)
                                                          .then((value) async =>
                                                              await relatedVideosController
                                                                  .blockUnblockUser(
                                                                      widget
                                                                          .UserId!,
                                                                      value));
                                                    }
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
                                                            relatedVideosController
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
                                                // InkWell(
                                                //   onTap: () async {
                                                //     if (await GetStorage()
                                                //             .read("token") ==
                                                //         null) {
                                                //       if (await Permission
                                                //           .phone.isGranted) {
                                                //         await SimDataPlugin
                                                //                 .getSimData()
                                                //             .then((value) => value
                                                //                     .cards
                                                //                     .isEmpty
                                                //                 ? Get.bottomSheet(
                                                //                     LoginView(
                                                //                         false
                                                //                             .obs))
                                                //                 : Get.bottomSheet(
                                                //                     LoginView(true
                                                //                         .obs)));
                                                //       } else {
                                                //         await Permission.phone
                                                //             .request()
                                                //             .then((value) async => await SimDataPlugin
                                                //                     .getSimData()
                                                //                 .then((value) => value
                                                //                         .cards
                                                //                         .isEmpty
                                                //                     ? Get.bottomSheet(
                                                //                         LoginView(false
                                                //                             .obs))
                                                //                     : Get.bottomSheet(
                                                //                         LoginView(
                                                //                             true.obs))));
                                                //       }
                                                //     } else {
                                                //       relatedVideosController
                                                //           .notInterested(
                                                //         widget.videoId!,
                                                //       );
                                                //     }
                                                //     // userDetailsController
                                                //     //     .followUnfollowUser(
                                                //     //     widget.UserId,
                                                //     //     widget.isfollow == 0
                                                //     //         ? "follow"
                                                //     //         : "unfollow",
                                                //     //     token: widget
                                                //     //         .publicUser!
                                                //     //         .firebaseToken
                                                //     //         .toString());
                                                //     // followingVideosController
                                                //     //     .getAllVideos();
                                                //   },
                                                //   child: Row(
                                                //     children: [
                                                //       widget.isfollow! == 0
                                                //           ? const Icon(
                                                //               Icons.report,
                                                //               color: ColorManager
                                                //                   .colorAccent,
                                                //               size: 30,
                                                //             )
                                                //           : const Icon(
                                                //               Icons.report,
                                                //               color: ColorManager
                                                //                   .colorAccent,
                                                //               size: 30,
                                                //             ),
                                                //       const SizedBox(
                                                //         width: 10,
                                                //       ),
                                                //       const Text(
                                                //         "Not Interested",
                                                //         style: TextStyle(
                                                //             fontWeight:
                                                //                 FontWeight.bold,
                                                //             color: ColorManager
                                                //                 .colorAccent),
                                                //       )
                                                //     ],
                                                //   ),
                                                // )
                                              ]),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        isScrollControlled: false,
                                        backgroundColor: Theme.of(context)
                                            .scaffoldBackgroundColor);
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
                                child: imgProfile(
                                    widget.publicUser!.avatar.toString()),
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
                                        widget.publicUser!.name!.isEmpty
                                            ? widget.publicUser!.username!
                                            : widget.publicUser!.name!,
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
                                                          ? showLoginBottomSheet(
                                                              false.obs)
                                                          : showLoginBottomSheet(
                                                              true.obs));
                                                } else {
                                                  await Permission.phone
                                                      .request()
                                                      .then((value) async =>
                                                          await SimDataPlugin
                                                                  .getSimData()
                                                              .then((value) => value
                                                                      .cards
                                                                      .isEmpty
                                                                  ? showLoginBottomSheet(
                                                                      false.obs)
                                                                  : showLoginBottomSheet(
                                                                      true.obs)));
                                                }
                                              } else {
                                                relatedVideosController
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
                                    widget.publicUser == null
                                        ? ""
                                        : widget.publicUser!.name!,
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
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            moreStyle: TextStyle(
                                fontSize: 14,
                                color: ColorManager.colorAccent,
                                fontWeight: FontWeight.w700),
                            lessStyle: TextStyle(
                                fontSize: 14,
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
                                        await GetStorage().write(
                                            "hashtagId",
                                            widget.hashtagsList![index]
                                                .hashtagId);
                                        Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                            arguments: {
                                              "hashtag_name":
                                                  "${widget.hashtagsList![index].hashtag!.name}",
                                              "hashtagId": widget
                                                  .hashtagsList![index]
                                                  .hashtag!
                                                  .id
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
                                          widget.hashtagsList![index].hashtag!
                                              .name
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

                            DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                            AndroidDeviceInfo androidInfo =
                                await deviceInfo.androidInfo;
                            if (androidInfo.version.sdkInt > 31) {
                              if (await Permission.audio.isGranted) {
                                Get.toNamed(Routes.SOUNDS, arguments: {
                                  "sound_id": widget.soundId,
                                  "sound_name": widget.soundName.toString(),
                                  "sound_url": widget.sound,
                                });
                                // refreshAlreadyCapturedImages();
                              } else {
                                await Permission.audio
                                    .request()
                                    .then((value) async {
                                  Get.toNamed(Routes.SOUNDS, arguments: {
                                    "sound_id": widget.soundId,
                                    "sound_name": widget.soundName.toString(),
                                    "sound_url": widget.sound,
                                  });
                                });
                              }
                            } else {
                              if (await Permission.storage.isGranted) {
                                Get.toNamed(Routes.SOUNDS, arguments: {
                                  "sound_id": widget.soundId,
                                  "sound_name": widget.soundName.toString(),
                                  "sound_url": widget.sound,
                                });
                                // refreshAlreadyCapturedImages();
                              } else {
                                await Permission.storage.request().then(
                                    (value) =>
                                        Get.toNamed(Routes.SOUNDS, arguments: {
                                          "sound_id": widget.soundId,
                                          "sound_name":
                                              widget.soundName.toString(),
                                          "sound_url": widget.sound,
                                        }));
                              }
                            }
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
                                        " by ${widget.publicUser!.name!.isEmpty ? widget.publicUser!.username : widget.publicUser!.name}"
                                    : "Original Sound" +
                                        " by ${widget.publicUser!.name!.isEmpty ? widget.publicUser!.username : widget.publicUser!.name}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              )),
                              SizedBox(
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
              Center(
                child: const Text(
                  'Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: const Text(
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
