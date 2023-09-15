import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:just_audio/just_audio.dart';
import 'package:thrill/app/widgets/no_search_result.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/utils.dart';
import '../../../widgets/focus_detector.dart';
import '../controllers/sounds_controller.dart';

class SoundsView extends GetView<SoundsController> {
  const SoundsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();
    final playerController = PlayerController();

    final progressNotifier = ValueNotifier<ProgressBarState>(
      ProgressBarState(
        current: Duration.zero,
        buffered: Duration.zero,
        total: Duration.zero,
      ),
    );
    var isPlayerPlaying = false.obs;
    controller.getSoundDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sound Details",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
      ),
      body: controller.obx((state) {
        var duration =
            (audioPlayer.setUrl(RestUrl.awsSoundUrl + state!.sound.toString()));

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FocusDetector(
                              onVisibilityGained: () {},
                              onVisibilityLost: () {
                                audioPlayer.pause();
                                controller.isPlaying.value =
                                    audioPlayer.playing;
                                controller.animationController!.stop();
                              },
                              onForegroundLost: () {
                                audioPlayer.pause();
                                controller.isPlaying.value =
                                    audioPlayer.playing;
                                controller.animationController!.stop();
                              },
                              onForegroundGained: () {
                                audioPlayer.play();
                                controller.isPlaying.value =
                                    audioPlayer.playing;
                                controller.animationController!.repeat();
                              },
                              onFocusLost: () {
                                audioPlayer.pause();
                                controller.isPlaying.value =
                                    audioPlayer.playing;
                                controller.animationController!.stop();
                              },
                              onFocusGained: () {},
                              child: InkWell(
                                onTap: () async {
                                  audioTotalDuration.value = (await duration)!;
                                  audioPlayer.positionStream
                                      .listen((position) async {
                                    final oldState = progressNotifier.value;
                                    audioDuration.value = position;
                                    progressNotifier.value = ProgressBarState(
                                      current: position,
                                      buffered: oldState.buffered,
                                      total: oldState.total,
                                    );

                                    if (position == oldState.total) {
                                      audioPlayer.playerStateStream.drain();
                                      await playerController.seekTo(0);
                                      await audioPlayer.seek(Duration.zero);
                                      audioDuration.value = Duration.zero;
                                      // isPlaying.value = false;
                                    }
                                    print(position);
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

                                  playerController.onCurrentDurationChanged
                                      .listen((duration) async {
                                    audioDuration.value =
                                        Duration(seconds: duration);

                                    Duration playerDuration =
                                        Duration(seconds: duration);

                                    print(duration);

                                    if (Duration(seconds: duration) >=
                                        audioTotalDuration.value) {
                                      audioPlayer.seek(Duration.zero);
                                      controller.animationController!.stop();
                                    }
                                  });

                                  if (audioDuration.value >=
                                          audioTotalDuration.value &&
                                      audioTotalDuration.value !=
                                          Duration.zero) {
                                    controller.animationController!.stop();
                                    audioPlayer
                                        .seek(Duration.zero)
                                        .then((value) {
                                      if (audioPlayer.playing) {
                                        audioPlayer.pause();
                                        controller.animationController!.stop();
                                      } else {
                                        controller.animationController!
                                            .repeat();

                                        audioPlayer.play();
                                      }
                                    });
                                  }
                                  if (audioPlayer.playing) {
                                    audioPlayer.pause();
                                    controller.animationController!.stop();
                                  } else {
                                    audioPlayer.play();
                                    controller.animationController!.repeat();
                                  }
                                  isPlayerPlaying.value = audioPlayer.playing;
                                },
                                child: RotationTransition(
                                  turns: Tween(begin: 0.0, end: 1.0)
                                      .animate(controller.animationController!),
                                  child: SvgPicture.asset(
                                    "assets/spinning_disc.svg",
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                              ),
                            ),

                            // imgProfile(Get.arguments["profile"] as String),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                          child: Text(
                        state!.sound != null ? state!.name.toString() : "",
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
                      border: Border.all(
                          color: ColorManager.colorAccent, width: 2)),
                  child: InkWell(
                      onTap: () {
                        controller.addSoundToFavourite(
                            controller.soundDetails.id!,
                            controller.soundDetails.isFavouriteSound
                                        ?.isFavorite ==
                                    1
                                ? "0"
                                : "1");
                        // userController.addToFavourites(
                        //     widget.map["sound_id"], "sound", 1);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.bookmark,
                                size: 18,
                                color: ColorManager.colorAccent,
                              ),
                            ),
                            controller.soundDetails.isFavouriteSound
                                        ?.isFavorite ==
                                    1
                                ? TextSpan(
                                    text: "  Remove from favourites",
                                    style: TextStyle(
                                        color: ColorManager.colorAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))
                                : TextSpan(
                                    text: "  Add to Favourites",
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
                InkWell(
                  onTap: () {
                    state!.soundOwner!.id != GetStorage().read("userId")
                        ? Get.toNamed(Routes.OTHERS_PROFILE,
                            arguments: {"profileId": state!.soundOwner!.id})
                        : Get.toNamed(Routes.PROFILE);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          imgProfile(state!.soundOwner != null
                              ? state!.soundOwner!.avtars.toString()
                              : ""),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state!.soundOwner!.name ??
                                    state!.soundOwner!.username!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                  state!.soundOwner != null
                                      ? "@" +
                                          state!.soundOwner!.username.toString()
                                      : "",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                    thickness: 2,
                  ),
                ),
                controller.obx(
                    (state) => Expanded(
                        child: NotificationListener<ScrollEndNotification>(
                            onNotification: (scrollNotification) {
                              if (scrollNotification.metrics.pixels ==
                                  scrollNotification.metrics.maxScrollExtent) {
                                controller.getPaginationVideosBySound();
                              }
                              return true;
                            },
                            child: GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              physics: const BouncingScrollPhysics(),
                              childAspectRatio: 0.8,
                              children: List.generate(
                                  controller.videoList.length,
                                  (index) => Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.SOUND_VIDEOS,
                                                arguments: {
                                                  'current_page': controller
                                                      .currentPage.value,
                                                  "video_id": controller
                                                      .videoList[index].id,
                                                  "init_page": index,
                                                  "sound_name": state!.sound
                                                });
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
                                              imgNet(controller
                                                      .videoList[index].gifImage
                                                      .toString()
                                                      .isEmpty
                                                  ? '${RestUrl.thambUrl}thumb-not-available.png'
                                                  : '${RestUrl.gifUrl}${controller.videoList[index].gifImage}'),
                                              Container(
                                                  height: Get.height,
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const WidgetSpan(
                                                              child: Icon(
                                                                Icons
                                                                    .play_circle,
                                                                size: 18,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                                text: " " +
                                                                    (controller.videoList[index].views ??
                                                                            0)
                                                                        .formatViews(),
                                                                style: const TextStyle(
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
                            ))),
                    onError: (error) => NoSearchResult(
                          text: "No Videos for this sound!",
                        ),
                    onEmpty: NoSearchResult(
                      text: "No Videos for this sound!",
                    )),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                    color: ColorManager.colorAccent,
                    borderRadius: BorderRadius.circular(50)),
                child: InkWell(
                    onTap: () async {
                      controller.downloadAudio(
                          controller.soundDetails.sound!.obs,
                          controller.soundDetails.soundOwner!.id
                                  .toString()
                                  .isEmpty
                              ? controller.soundDetails.soundOwner!.id
                                  .toString()
                                  .obs
                              : controller.soundDetails.soundOwner!.id
                                  .toString()
                                  .obs,
                          controller.soundDetails.name.toString().obs,
                          false);
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
        );
      }, onLoading: soundsViewShimmer()),
    );
  }
}
