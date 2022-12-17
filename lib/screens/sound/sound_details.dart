import 'dart:convert';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as justAudio;
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/page_manager.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

var progressCount = "".obs;

class SoundDetails extends StatefulWidget {
  SoundDetails({Key? key, required this.map}) : super(key: key);
  final Map map;

  @override
  State<SoundDetails> createState() => _SoundDetailsState();
}

class _SoundDetailsState extends State<SoundDetails>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;

  List<VideoModel> videoList = List.empty(growable: true);
  var title = "";
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  justAudio.AudioPlayer audioPlayer = justAudio.AudioPlayer();

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.map['soundName'] != null) title = widget.map['soundName'];
    super.initState();
    getVideos();
    try {} catch (_) {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      appBar: AppBar(
        backgroundColor: Colors.transparent.withOpacity(0),
        elevation: 0,
        iconTheme: IconThemeData(
            color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
      ),
      body: videoList.isEmpty
          ? Center(
              child: loader(),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    height: Get.height,
                    width: Get.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset("assets/Image.png"),
                                Container(
                                  alignment: Alignment.topLeft,
                                  color: Colors.transparent.withOpacity(0),
                                  height: 60,
                                  width: 60,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      RotationTransition(
                                        turns: Tween(begin: 0.0, end: 1.0)
                                            .animate(_controller!),
                                        child: Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Color(0xFF2F8897),
                                                      Color(0xff1F2A52),
                                                      Color(0xff1F244E)
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: ColorManager.cyan)),
                                      ),
                                      Center(
                                          child: InkWell(
                                        onTap: () async {
                                          // if (!isPlaying.value) {
                                          //   audioPlayer
                                          //       .play(
                                          //           "https://thrillvideo.s3.amazonaws.com/sound/" +
                                          //               widget.map["sound"])
                                          //       .then((value) {
                                          //     isPlaying.value = true;
                                          //   });
                                          //
                                          //   _controller!.forward();
                                          //   _controller!.repeat();
                                          // } else {
                                          //   isPlaying.value = false;
                                          //   audioPlayer.pause();
                                          //   _controller!.stop();
                                          // }
                                        },
                                        child: Obx(() => !isPlaying.value
                                            ? const Icon(
                                                Icons.play_circle,
                                                size: 25,
                                                color: Colors.white,
                                              )
                                            : const Icon(
                                                Icons.pause_circle,
                                                size: 25,
                                                color: Colors.white,
                                              )),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Flexible(
                                child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ))
                          ],
                        ),
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: ColorManager.colorAccent, width: 2)),
                            child: InkWell(
                                onTap: () {
                                  musicPlayerBottomSheet(
                                      widget.map["userProfile"].toString().obs,
                                      title.obs,
                                      widget.map["sound"].toString().obs);
                                },
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.play_circle,
                                          size: 18,
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                      TextSpan(
                                          text: "  Play Song",
                                          style: TextStyle(
                                              color: ColorManager.colorAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                    ],
                                  ),
                                )),
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: ColorManager.colorAccent,
                                      width: 2)),
                              child: InkWell(
                                  onTap: () {
                                    userController.addToFavourites(
                                        widget.map["sound_id"], "sound", 1);
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(
                                            Icons.bookmark,
                                            size: 18,
                                            color: ColorManager.colorAccent,
                                          ),
                                        ),
                                        TextSpan(
                                            text: "  Add to  Favourites",
                                            style: TextStyle(
                                                color: ColorManager.colorAccent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  imageUrl: widget.map['profile']
                                              .toString()
                                              .isEmpty ||
                                          widget.map['profile'] == null ||
                                          widget.map["profile"] == "null"
                                      ? RestUrl.placeholderImage
                                      : RestUrl.profileUrl +
                                          widget.map['profile'].toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.map["name"].toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text("@" + widget.map["username"].toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          )),
                          InkWell(
                            onTap: () {
                              userController.followUnfollowUser(
                                  widget.map["id"],
                                  widget.map["isFollow"] == 0
                                      ? "follow"
                                      : "unfollow");
                            },
                            child: widget.map["isFollow"] == 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: ColorManager.colorAccent,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Text(
                                      "Follow",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorManager.colorAccent),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Text(
                                      "Following",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.colorAccent),
                                    ),
                                  ),
                          )
                        ],
                      )),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: const Divider(
                          color: Color.fromRGBO(238, 238, 238, 1),
                          thickness: 2,
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: Get.width / Get.height,
                        children: List.generate(
                            videoList.length,
                            (index) => Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: GestureDetector(
                                    onTap: () {
                                      List<PublicVideos> videosList1 = [];
                                      videoList.forEach((element) {
                                        var user = PublicUser(
                                          id: element.user?.id,
                                          name: element.user?.name,
                                          facebook: element.user?.facebook,
                                          firstName: element.user?.firstName,
                                          lastName: element.user?.lastName,
                                          username: element.user?.username,
                                          isfollow: 0,
                                        );
                                        videosList1.add(PublicVideos(
                                          id: element.id,
                                          video: element.video,
                                          description: element.description,
                                          sound: element.sound,
                                          soundName: element.sound,
                                          soundCategoryName:
                                              element.sound_category_name,
                                          soundOwner: element.sound_owner,
                                          filter: element.filter,
                                          likes: element.likes,
                                          views: element.views,
                                          gifImage: element.gif_image,
                                          speed: element.speed,
                                          comments: element.comments,
                                          isDuet: "no",
                                          duetFrom: "",
                                          isCommentable: "yes",
                                          user: user,
                                        ));
                                      });
                                      Get.to(VideoPlayerItem(
                                        videosList: videosList1,
                                        position: index,
                                      ));
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      alignment: Alignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          placeholder: (a, b) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          fit: BoxFit.fill,
                                          errorWidget: (a, b, c) =>
                                              Image.network(
                                            '${RestUrl.thambUrl}thumb-not-available.png',
                                            fit: BoxFit.fill,
                                          ),
                                          imageUrl: videoList[index]
                                                  .gif_image
                                                  .isEmpty
                                              ? '${RestUrl.thambUrl}thumb-not-available.png'
                                              : '${RestUrl.gifUrl}${videoList[index].gif_image}',
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.fill)),
                                          ),
                                        ),
                                        Container(
                                            height: Get.height,
                                            alignment: Alignment.bottomLeft,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const WidgetSpan(
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          size: 18,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                          text: " " +
                                                              videoList[index]
                                                                  .views
                                                                  .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      16)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                        const Icon(
                                          Icons.play_circle,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     ElevatedButton(
                      //         onPressed: () {
                      //          // Get.to(() => const Favourites());
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //             primary: ColorManager.deepPurple,
                      //             fixedSize:
                      //                 Size(MediaQuery.of(context).size.width * .30, 30),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(50))),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: const [
                      //             Icon(
                      //               Icons.bookmark_outline_outlined,
                      //               color: Colors.white,
                      //               size: 20,
                      //             ),
                      //             SizedBox(
                      //               width: 10,
                      //             ),
                      //             Text(
                      //               save,
                      //               style: TextStyle(fontSize: 16),
                      //             )
                      //           ],
                      //         )),
                      //     const SizedBox(
                      //       width: 15,
                      //     ),
                      //     ElevatedButton(
                      //         onPressed: () {
                      //          // Get.to(() => const Record());
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //             primary: ColorManager.cyan,
                      //             fixedSize:
                      //                 Size(MediaQuery.of(context).size.width * .30, 30),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(50))),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Image.asset(
                      //               'assets/cam.png',
                      //               scale: 1.5,
                      //             ),
                      //             const SizedBox(
                      //               width: 10,
                      //             ),
                      //             const Text(
                      //               create,
                      //               style: TextStyle(fontSize: 16),
                      //             )
                      //           ],
                      //         ))
                      //   ],
                      // ),

                      const SizedBox(
                        height: 20,
                      ),
                    ]),
                  ),
                ),
                Container(
                  height: Get.height,
                  width: Get.width,
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: Get.width,
                    height: 60,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                        color: ColorManager.colorAccent,
                        borderRadius: BorderRadius.circular(50)),
                    child: InkWell(
                        onTap: () async {
                          soundsController.downloadAudio(widget.map["sound"],
                              widget.map["user"], widget.map["id"]);
                        },
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.music_note,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                  text: "  Use this sound",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                            ],
                          ),
                        )),
                  ),
                )
              ],
            ),
    );
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  getVideos() async {
    try {
      var response = await RestApi.getVideosBySound(widget.map["sound"]);
      var json = jsonDecode(response.body);
      List jsonList = json["data"];
      videoList = jsonList.map((e) => VideoModel.fromJson(e)).toList();
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }
}
