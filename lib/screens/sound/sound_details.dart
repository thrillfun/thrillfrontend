import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/page_manager.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

var progressCount = "".obs;
var isPlaying = false.obs;
var isAudioLoading = true.obs;
var audioDuration = const Duration().obs;
var audioTotalDuration = const Duration().obs;
var audioBuffered = const Duration().obs;
var isPlayerInit = false.obs;

var isFollow = 0.obs;

class SoundDetails extends StatefulWidget {
  SoundDetails({Key? key, required this.map}) : super(key: key);
  final Map map;

  @override
  State<SoundDetails> createState() => _SoundDetailsState();
}

class _SoundDetailsState extends State<SoundDetails>
    with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late Duration duration;
  late PlayerController playerController;

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

  @override
  void initState() {
    super.initState();
    playerController = PlayerController();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.map['soundName'] != null) title = widget.map['soundName'];

    if (widget.map["isFollow"] == 0) {
      isFollow.value = 0;
    } else {
      isFollow.value = 1;
    }
    setupAudioPlayer();
    getVideos();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _controller!.dispose();
    playerController.dispose();
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Flexible(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset("assets/Image.png"),
                                imgProfile(widget.map["profile"].toString()),
                              ],
                            ),
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
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: ColorManager.colorAccent, width: 2)),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Obx(() => InkWell(
                                    onTap: () async {
                                      audioPlayer.positionStream
                                          .listen((position) {
                                        final oldState = progressNotifier.value;
                                        audioDuration.value = position;
                                        progressNotifier.value =
                                            ProgressBarState(
                                          current: position,
                                          buffered: oldState.buffered,
                                          total: oldState.total,
                                        );
                                      });
                                      audioPlayer.bufferedPositionStream
                                          .listen((position) {
                                        final oldState = progressNotifier.value;
                                        audioBuffered.value = position;
                                        progressNotifier.value =
                                            ProgressBarState(
                                          current: oldState.current,
                                          buffered: position,
                                          total: oldState.total,
                                        );
                                      });
                                      audioPlayer.playerStateStream
                                          .listen((event) {
                                        if (event.playing) {
                                          isPlaying.value = true;
                                        } else {
                                          isPlaying.value = false;
                                        }
                                      });
                                      if (!isPlaying.value) {
                                        //await audioPlayer.play();
                                        await playerController.startPlayer();
                                        isPlaying.value = true;
                                      } else {
                                        // await audioPlayer.pause();
                                        await playerController.pausePlayer();
                                        isPlaying.value = false;
                                      }
                                    },
                                    child: isPlaying.value
                                        ? const Icon(
                                            Icons.pause_circle,
                                            color: ColorManager.colorAccent,
                                            size: 40,
                                          )
                                        : const Icon(
                                            Icons.play_circle,
                                            color: ColorManager.colorAccent,
                                            size: 40,
                                          ))),
                                // Obx(() => ProgressBar(
                                //     bufferedBarColor:
                                //         ColorManager.colorAccent.withOpacity(0.3),
                                //     thumbColor: ColorManager.colorAccent,
                                //     baseBarColor: ColorManager.colorPrimaryLight
                                //         .withOpacity(0.2),
                                //     progressBarColor:
                                //         ColorManager.colorAccent.withOpacity(0.8),
                                //     onSeek: seek,
                                //     buffered: audioBuffered.value,
                                //     progress: audioDuration.value,
                                //     total: audioTotalDuration.value))
                              ],
                            )),
                        Flexible(
                          child: Obx(() => !isPlayerInit.value
                              ? const CircularProgressIndicator()
                              : Visibility(
                                  visible: isPlayerInit.value,
                                  child: AudioFileWaveforms(
                                    margin: const EdgeInsets.only(right: 20),
                                    playerWaveStyle: const PlayerWaveStyle(
                                        waveThickness: 2,
                                        visualizerHeight: 10,
                                        fixedWaveColor:
                                            ColorManager.colorAccentTransparent,
                                        liveWaveColor:
                                            ColorManager.colorAccent),
                                    animationCurve: Curves.easeInBack,
                                    animationDuration: audioTotalDuration.value,
                                    size: Size(
                                        MediaQuery.of(context).size.width / 1.5,
                                        100),
                                    playerController: playerController,
                                  ))),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            imgProfile(widget.map['profile'].toString()),
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
                          onTap: () async {
                            await userController
                                .followUnfollowUser(widget.map["id"],
                                    isFollow.value == 0 ? "follow" : "unfollow")
                                .then((value) {
                              isFollow.value == 0
                                  ? isFollow.value = 1
                                  : isFollow.value = 0;

                              relatedVideosController.getAllVideos();
                            });
                          },
                          child: Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: isFollow.value == 0
                                    ? BoxDecoration(
                                        color: ColorManager.colorAccent,
                                        borderRadius: BorderRadius.circular(20))
                                    : BoxDecoration(
                                        border: Border.all(
                                            color: ColorManager.colorAccent),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                child: Text(
                                  isFollow.value == 0 ? "Follow" : "Following",
                                  style: isFollow.value == 0
                                      ? const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)
                                      : const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.colorAccent),
                                ),
                              )),
                        )
                      ],
                    ),

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
                      childAspectRatio: 0.8,
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
                                        isFollow: widget.map["isFollow"],
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
                                          isDuet: element.is_duet,
                                          duetFrom: element.duet_from,
                                          isCommentable: element.is_commentable,
                                          user: user,
                                          videoLikeStatus: 0));
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
                                      imgNet(videoList[index].gif_image.isEmpty
                                          ? '${RestUrl.thambUrl}thumb-not-available.png'
                                          : '${RestUrl.gifUrl}${videoList[index].gif_image}'),
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
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16)),
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
                          soundsController.downloadAudio(
                              widget.map["sound"],
                              widget.map["user"].toString(),
                              widget.map["id"],
                              widget.map["soundName"],
                              false);
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

  setupAudioPlayer() async {
    audioPlayer = AudioPlayer();
    duration = (await audioPlayer.setUrl(RestUrl.soundUrl + widget.map["sound"].toString()))!;

    audioTotalDuration.value = duration;

    var soundName = widget.map["sound"].toString();
    var directory = await getTemporaryDirectory();
    await FileSupport()
        .downloadCustomLocation(
      url: "${RestUrl.awsSoundUrl}$soundName",
      path: directory.path,
      filename: soundName.split('.').first,
      extension: ".${soundName.split('.').last}",
      progress: (progress) async {},
    )
        .then((value) async {
      await playerController.preparePlayer(value!.path).then((value) {
        isPlayerInit.value = true;
      });
    });

    audioTotalDuration.value = Duration(seconds: playerController.maxDuration);
    playerController.onCurrentDurationChanged.listen((duration) async {
      Duration playerDuration = Duration(seconds: duration);
      if (playerDuration == audioTotalDuration.value) {
        await playerController.seekTo(0);
        isPlaying.value = false;
        setState(() {});
      }
    });
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
