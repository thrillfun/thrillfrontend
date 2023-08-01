import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/widgets/focus_detector.dart';
import 'package:thrill/app/widgets/no_search_result.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../rest/models/site_settings_model.dart';
import '../../../../rest/models/user_videos_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../../../comments/controllers/comments_controller.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../login/views/login_view.dart';
import '../controllers/others_profile_videos_controller.dart';

class OthersProfileVideosView extends GetView<OthersProfileVideosController> {
  OthersProfileVideosView({Key? key}) : super(key: key);
  var pageViewController =
      PageController(initialPage: Get.arguments["init_page"] ?? 0);

  var playerController = BetterPlayerListVideoPlayerController();
  var commentsController = Get.find<CommentsController>();
  AnimationController? _controller;
  var pageController = PageController();

  @override
  Widget build(BuildContext context) {
    controller.refereshvideos();
    return Scaffold(
      body: controller.obx(
          (state) => state!.isEmpty
              ? NoSearchResult(
                  text: "No Videos!",
                )
              : PageView.builder(
                  itemCount: state!.length,
                  scrollDirection: Axis.vertical,
                  controller: pageViewController,
                  onPageChanged: (index) {
                    if (index == state!.length - 1) {
                      controller
                          .getPaginationAllVideos(controller.nextPage.value);
                    }
                  },
                  itemBuilder: (context, index) {
                    _controller =
                        AnimationController(vsync: Scaffold.of(context));
                    return OthersVideos(
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
                      videoLikeStatus: state[index].videoLikeStatus.toString(),
                      isCommentAllowed: state[index].isCommentable == "Yes"
                          ? true.obs
                          : false.obs,
                      like: state[index].likes!.obs,
                      isfollow:
                          state[index].user!.isFollow, //state[index].isfollow!
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
          onError: (error) => NoSearchResult(
                text: "No Videos!",
              ),
          onEmpty: NoSearchResult(
            text: "No Videos!",
          )),
    );
  }

  showReportDialog(int videoId, String name, int id) async {
    try {
      List<String> reasonList = [];
      for (SiteSettings element in controller.siteSettingsList) {
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
                              controller.reportVideo(
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
          backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor);
    } catch (e) {
      return;
    }
  }
}

class OthersVideos extends StatefulWidget {
  OthersVideos(
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
  State<OthersVideos> createState() => _OthersVideosState();
}

class _OthersVideosState extends State<OthersVideos>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController videoPlayerController;
  var relatedVideosController = Get.find<OthersProfileVideosController>();
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

      Future.delayed(const Duration(seconds: 1)).then((value) {
        if (Get.isBottomSheetOpen!) {
          videoPlayerController.pause();
        } else if (!Get.isBottomSheetOpen! && isVisible.isTrue) {
          videoPlayerController.play();
        }
      });
    });
    currentDuration.listen((duration) async {
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
                relatedVideosController
                    .likeVideo(
                  widget.videoLikeStatus == "0" ? 1 : 0,
                  widget.videoId!,
                )
                    .then((value) {
                  // if(Get.isDialogOpen!){
                  //   Get.back();
                  // }
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
                                    relatedVideosController.likeVideo(
                                      widget.videoLikeStatus == "0" ? 1 : 0,
                                      widget.videoId!,
                                      token: widget.fcmToken,
                                    );
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
                                      Get.bottomSheet(ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        child: ProfileCommentsView(
                                          videoId: widget.videoId!,
                                          userId: widget.UserId,
                                          isCommentAllowed:
                                              widget.isCommentAllowed,
                                          isfollow: widget.isfollow,
                                          userName: widget.userName!.value,
                                          avatar: widget.avatar ?? "",
                                          fcmToken: widget.fcmToken,
                                          description:
                                              widget.description?.value,
                                        ),
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
                                                                          onTap: () => relatedVideosController
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
                                                              relatedVideosController
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
                                                                      false.obs)
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
                                                                      false.obs)
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
                                              //                     .cards.isEmpty
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
                                              //                         LoginView(
                                              //                             false
                                              //                                 .obs))
                                              //                     : Get.bottomSheet(
                                              //                         LoginView(true.obs))));
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
                                        widget.publicUser == null
                                            ? ""
                                            : widget.publicUser!.username!,
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
                                                    )
                                                    .then((value) =>
                                                        relatedVideosController
                                                            .getUserVideos());
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
                                  SizedBox(
                                    width: 40,
                                  )
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
                                                  "${widget.hashtagsList![index].hashtag!.name}"
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
                              ))
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
    var dropDownValue = "Reason".obs;
    List<String> dropDownValues = [
      "Reason",
    ];
    try {
      List jsonList = relatedVideosController.siteSettingsList;
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
                            relatedVideosController.reportVideo(
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

class ProfileCommentsView extends GetView<CommentsController> {
  ProfileCommentsView(
      {Key? key,
      this.videoId,
      this.userId,
      this.isCommentAllowed,
      this.isfollow,
      this.userName,
      this.avatar,
      this.fcmToken,
      this.description})
      : super(key: key);
  int? videoId, userId;
  RxBool? isCommentAllowed;
  int? isfollow;
  String? userName, avatar, fcmToken, description = "";

  final _textEditingController = TextEditingController();
  RxString videoComment = "".obs;
  var relatedVideosController = Get.find<OthersProfileVideosController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: controller.obx(
          (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.all(10),
              //       child: Text(
              //         controller.commentsList.length == 0
              //             ? "No Comments"
              //             :  controller.commentsList.length==1?"${controller.commentsList.length} Comment":"${controller.commentsList.length} Comments",
              //         style: const TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ],
              //   mainAxisAlignment: MainAxisAlignment.center,
              // ),

              Flexible(
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (await GetStorage().read("token") ==
                                        null) {
                                      if (await Permission.phone.isGranted) {
                                        await SimDataPlugin.getSimData().then(
                                            (value) => value.cards.isEmpty
                                                ? Get.bottomSheet(
                                                    LoginView(false.obs))
                                                : Get.bottomSheet(
                                                    LoginView(true.obs)));
                                      } else {
                                        await Permission.phone.request().then(
                                            (value) async => await SimDataPlugin
                                                    .getSimData()
                                                .then((value) => value
                                                        .cards.isEmpty
                                                    ? Get.bottomSheet(
                                                        LoginView(false.obs))
                                                    : Get.bottomSheet(
                                                        LoginView(true.obs))));
                                      }
                                    } else {
                                      Get.toNamed(Routes.OTHERS_PROFILE,
                                          arguments: {"profileId": userId});
                                    }
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: imgProfile(avatar.toString()),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible:
                                      GetStorage().read("userId") != userId,
                                  child: InkWell(
                                      onTap: () {},
                                      child: Text(
                                        isfollow == 0 ? "Follow" : "Following",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: ColorManager.colorAccent),
                                      )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              description.toString(),
                              maxLines: 1,
                            )
                          ],
                        )),
                    const Divider(),
                    Expanded(
                        child: ListView.builder(
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
                                      if (await GetStorage().read("token") ==
                                          null) {
                                        if (await Permission.phone.isGranted) {
                                          await SimDataPlugin.getSimData().then(
                                              (value) => value.cards.isEmpty
                                                  ? Get.bottomSheet(
                                                      LoginView(false.obs))
                                                  : Get.bottomSheet(
                                                      LoginView(true.obs)));
                                        } else {
                                          await Permission.phone.request().then(
                                              (value) async =>
                                                  await SimDataPlugin
                                                          .getSimData()
                                                      .then((value) => value
                                                              .cards.isEmpty
                                                          ? Get.bottomSheet(
                                                              LoginView(
                                                                  false.obs))
                                                          : Get.bottomSheet(
                                                              LoginView(
                                                                  true.obs))));
                                        }
                                      } else {
                                        Get.toNamed(Routes.OTHERS_PROFILE,
                                            arguments: {
                                              "profileId": state[index].userId
                                            });
                                      }
                                    },
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: state[index]
                                                    .avatar!
                                                    .isEmpty ||
                                                state[index].avatar == null
                                            ? RestUrl.placeholderImage
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state[index].name.toString(),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          state[index].comment.toString(),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  InkWell(
                                      onTap: () => Get.defaultDialog(
                                          title: "Are you sure?",
                                          titleStyle: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24),
                                          middleText:
                                              "Are you sure you want to report this comment",
                                          confirm: ElevatedButton(
                                              onPressed: () => {Get.back()},
                                              child: Text("yes")),
                                          cancel: ElevatedButton(
                                              onPressed: () => {Get.back()},
                                              child: Text("no"))),
                                      child: Icon(
                                        IconlyBroken.info_circle,
                                        color: Colors.red.shade700,
                                      ))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                controller
                                                    .likeComment(
                                                        state[index]
                                                            .id
                                                            .toString(),
                                                        controller
                                                                    .commentsList[
                                                                        index]
                                                                    .commentLikeCounter ==
                                                                0
                                                            ? "1"
                                                            : "0",
                                                        fcmToken.toString())
                                                    .then((value) => controller
                                                        .getComments(videoId!));
                                              },
                                              child: Icon(
                                                controller.commentsList[index]
                                                            .commentLikeCounter ==
                                                        0
                                                    ? IconlyLight.heart
                                                    : IconlyBold.heart,
                                                size: 20,
                                                color: controller
                                                            .commentsList[index]
                                                            .commentLikeCounter ==
                                                        0
                                                    ? Colors.grey
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        )),
                                    Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          state[index]
                                                  .commentLikeCounter
                                                  .toString() +
                                              " Likes",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          )),
                    ))
                  ],
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
                                    ..onTap = () async {
                                      Get.back(closeOverlays: true);
                                      if (await Permission.phone.isGranted) {
                                        await SimDataPlugin.getSimData().then(
                                            (value) => value.cards.isEmpty
                                                ? Get.bottomSheet(
                                                    LoginView(false.obs))
                                                : Get.bottomSheet(
                                                    LoginView(true.obs)));
                                      } else {
                                        await Permission.phone.request().then(
                                            (value) async => await SimDataPlugin
                                                    .getSimData()
                                                .then((value) => value
                                                        .cards.isEmpty
                                                    ? Get.bottomSheet(
                                                        LoginView(false.obs))
                                                    : Get.bottomSheet(
                                                        LoginView(true.obs))));
                                      }
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
                                  Flexible(
                                    child: Obx(() => TextFormField(
                                          keyboardType: TextInputType.text,
                                          focusNode: controller.fieldNode.value,
                                          enabled: isCommentAllowed?.value,
                                          controller: _textEditingController,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: controller
                                                      .fieldNode.value.hasFocus
                                                  ? ColorManager.colorAccent
                                                  : Colors.grey),
                                          onChanged: (value) {
                                            videoComment.value = value;
                                          },
                                          decoration: InputDecoration(
                                            focusColor:
                                                ColorManager.colorAccent,
                                            fillColor: controller
                                                    .fieldNode.value.hasFocus
                                                ? ColorManager
                                                    .colorAccentTransparent
                                                : Colors.grey.withOpacity(0.1),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: controller
                                                      .fieldNode.value.hasFocus
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
                                              borderSide: controller
                                                      .fieldNode.value.hasFocus
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
                                              color: controller
                                                      .fieldNode.value.hasFocus
                                                  ? ColorManager.colorAccent
                                                  : Colors.grey
                                                      .withOpacity(0.3),
                                            ),
                                            prefixStyle: TextStyle(
                                                color: controller.fieldNode
                                                        .value.hasFocus
                                                    ? const Color(0xff2DCBC8)
                                                    : Colors.grey,
                                                fontSize: 14),
                                            hintText:
                                                "Add comment for $userName",
                                            hintStyle: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                        )),
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
                                                    userId: GetStorage()
                                                        .read("userId")
                                                        .toString(),
                                                    comment: videoComment.value,
                                                    fcmToken:
                                                        fcmToken.toString(),
                                                    userName: userName)
                                                .then((value) async {
                                              relatedVideosController
                                                  .getUserVideos();
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
          onLoading: Container(
            width: Get.width,
            height: Get.height,
            child: loader(),
          ),
        ));
  }
}
