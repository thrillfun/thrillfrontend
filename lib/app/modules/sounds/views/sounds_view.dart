import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/sounds_controller.dart';

class SoundsView extends GetView<SoundsController> {
  const SoundsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Stack(
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
                          imgProfile(Get.arguments["profile"] as String),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                        child: Text(
                      Get.arguments["sound_name"] as String,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: ColorManager.colorAccent, width: 2)),
                child: InkWell(
                    onTap: () {
                      // userController.addToFavourites(
                      //     widget.map["sound_id"], "sound", 1);
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
                                audioPlayer.positionStream.listen((position) {
                                  final oldState = progressNotifier.value;
                                  audioDuration.value = position;
                                  progressNotifier.value = ProgressBarState(
                                    current: position,
                                    buffered: oldState.buffered,
                                    total: oldState.total,
                                  );
                                });
                                audioPlayer.bufferedPositionStream
                                    .listen((position) {
                                  final oldState = progressNotifier.value;
                                  audioBuffered.value = position;
                                  progressNotifier.value = ProgressBarState(
                                    current: oldState.current,
                                    buffered: position,
                                    total: oldState.total,
                                  );
                                });
                                audioPlayer.playerStateStream.listen((event) {
                                  if (event.playing) {
                                    isPlaying.value = true;
                                  } else {
                                    isPlaying.value = false;
                                  }
                                });
                                if (!isPlaying.value) {
                                  //await audioPlayer.play();
                                  await controller.playerController
                                      .startPlayer();
                                  isPlaying.value = true;
                                } else {
                                  // await audioPlayer.pause();
                                  await controller.playerController
                                      .pausePlayer();
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
                    child: Obx(() => !controller.isPlayerInit.value
                        ? const CircularProgressIndicator()
                        : Visibility(
                            visible: controller.isPlayerInit.value,
                            child: AudioFileWaveforms(
                              margin: const EdgeInsets.only(right: 20),
                              playerWaveStyle: const PlayerWaveStyle(
                                  waveThickness: 2,
                                  visualizerHeight: 10,
                                  fixedWaveColor:
                                      ColorManager.colorAccentTransparent,
                                  liveWaveColor: ColorManager.colorAccent),
                              animationCurve: Curves.easeInBack,
                              animationDuration: audioTotalDuration.value,
                              size: Size(
                                  MediaQuery.of(context).size.width / 1.5, 100),
                              playerController: controller.playerController,
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
                      imgProfile(Get.arguments["profile"] as String),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Get.arguments["profile_name"] as String,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text("@" + Get.arguments["user_name"],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  )),
                  InkWell(
                    onTap: () async {
                      // await userController
                      //     .followUnfollowUser(widget.map["id"],
                      //     isFollow.value == 0 ? "follow" : "unfollow")
                      //     .then((value) {
                      //   isFollow.value == 0
                      //       ? isFollow.value = 1
                      //       : isFollow.value = 0;
                      //
                      //   relatedVideosController.getAllVideos();
                      // });
                    },
                    child: Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration:
                              (Get.arguments["is_follow"] as Rx<int?>).value ==
                                      0
                                  ? BoxDecoration(
                                      color: ColorManager.colorAccent,
                                      borderRadius: BorderRadius.circular(20))
                                  : BoxDecoration(
                                      border: Border.all(
                                          color: ColorManager.colorAccent),
                                      borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            (Get.arguments["is_follow"] as Rx<int?>).value == 0
                                ? "Follow"
                                : "Following",
                            style: const TextStyle(
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
              controller.obx(
                  (state) => GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.8,
                        children: List.generate(
                            state!.length,
                            (index) => Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: GestureDetector(
                                    onTap: () {
                                      // List<PublicVideos> videosList1 = [];
                                      // videoList.forEach((element) {
                                      //   var user = PublicUser(
                                      //     id: element.user?.id,
                                      //     name: element.user?.name,
                                      //     facebook: element.user?.facebook,
                                      //     firstName: element.user?.firstName,
                                      //     lastName: element.user?.lastName,
                                      //     username: element.user?.username,
                                      //     isFollow: widget.map["isFollow"],
                                      //   );
                                      //   videosList1.add(PublicVideos(
                                      //       id: element.id,
                                      //       video: element.video,
                                      //       description: element.description,
                                      //       sound: element.sound,
                                      //       soundName: element.sound,
                                      //       soundCategoryName:
                                      //       element.sound_category_name,
                                      //       soundOwner: element.sound_owner,
                                      //       filter: element.filter,
                                      //       likes: element.likes,
                                      //       views: element.views,
                                      //       gifImage: element.gif_image,
                                      //       speed: element.speed,
                                      //       comments: element.comments,
                                      //       isDuet: element.is_duet,
                                      //       duetFrom: element.duet_from,
                                      //       isCommentable: element.is_commentable,
                                      //       user: user,
                                      //       videoLikeStatus: 0));
                                      // });
                                      // Get.to(VideoPlayerItem(
                                      //   videosList: videosList1,
                                      //   position: index,
                                      // ));
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      alignment: Alignment.center,
                                      children: [
                                        imgNet(state[index]
                                                .gifImage
                                                .toString()
                                                .isEmpty
                                            ? '${RestUrl.thambUrl}thumb-not-available.png'
                                            : '${RestUrl.gifUrl}${state[index].gifImage}'),
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
                                                              state[index]
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
                  onError: (error) =>
                      emptyListWidget(data: "No videos for this sound"),
                  onEmpty: emptyListWidget(data: "No videos for this sound")),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                  color: ColorManager.colorAccent,
                  borderRadius: BorderRadius.circular(50)),
              child: InkWell(
                  onTap: () async {
                    controller.downloadAudio(
                        Get.arguments["sound_url"],
                        Get.arguments["user_name"],
                        Get.arguments["sound_name"],
                        true);
                    // soundsController.downloadAudio(
                    //     widget.map["sound"],
                    //     widget.map["user"].toString(),
                    //     widget.map["id"],
                    //     widget.map["soundName"],
                    //     false);
                  },
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.music_note,
                            size: 18,
                          ),
                        ),
                        TextSpan(
                            text: "  Use this sound",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
