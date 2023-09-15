import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../rest/rest_urls.dart';
import '../../../../../utils/color_manager.dart';
import '../../../../../utils/page_manager.dart';
import '../../../../../utils/utils.dart';
import '../controllers/favourite_sounds_controller.dart';

class FavouriteSoundsView extends GetView<FavouriteSoundsController> {
  FavouriteSoundsView({Key? key}) : super(key: key);
  var isPlayerVisible = false.obs;
  var selectedIndex = 0.obs;
  final audioPlayer = AudioPlayer();
  final playerController = PlayerController();
  var duration = Duration.zero;
  TextEditingController _controller = TextEditingController();
  var soundName = "".obs;
  var soundOwner = "".obs;
  var avatar = "".obs;
  var isPlayerPlaying = false.obs;
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? Column(
                children: [emptyListWidget()],
              )
            : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      selectedIndex.value = index;
                                      soundName.value = state[index].name!;
                                      soundOwner.value =
                                          state[index].user != null
                                              ? state[index].user!.name!
                                              : "";

                                      avatar.value = state[index].user != null
                                          ? state[index].user!.avatar.toString()
                                          : "";
                                      duration = (await audioPlayer.setUrl(
                                          RestUrl.awsSoundUrl +
                                              state[index].sound.toString()))!;
                                      audioTotalDuration.value = duration!;
                                      audioPlayer.positionStream
                                          .listen((position) async {
                                        final oldState = progressNotifier.value;
                                        audioDuration.value = position;
                                        progressNotifier.value =
                                            ProgressBarState(
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
                                        progressNotifier.value =
                                            ProgressBarState(
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
                                        }
                                      });

                                      audioPlayer.play();

                                      if (isPlayerVisible.isFalse) {
                                        isPlayerVisible.value = true;
                                      }
                                      isPlayerPlaying.value =
                                          audioPlayer.playing;
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: imgSound(
                                              state[index].user != null
                                                  ? state[index]
                                                      .user!
                                                      .avatar
                                                      .toString()
                                                  : ""),
                                        ),
                                        Obx(() => isPlayerPlaying.value &&
                                                selectedIndex.value == index
                                            ? const Icon(
                                                Icons
                                                    .pause_circle_filled_outlined,
                                                size: 20,
                                                color: ColorManager.colorAccent,
                                              )
                                            : const Icon(
                                                IconlyBold.play,
                                                size: 20,
                                                color: ColorManager.colorAccent,
                                              ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      child: Container(
                                        margin: const EdgeInsets.all(0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state[index].name.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                state[index].user == null
                                                    ? ""
                                                    : state[index]
                                                        .user!
                                                        .username
                                                        .toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                            ]),
                                      ),
                                      onTap: () async {
                                        Get.toNamed(Routes.SOUNDS, arguments: {
                                          "sound_id": state[index].id,
                                          "sound_url":
                                              state[index].sound.toString(),
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => {
                                      // controller.addSoundToFavourite(
                                      //     controller.searchList[0].sounds![index].id!,
                                      //     controller.searchList[0].sounds![index].isFavouriteSoundCount == 0
                                      //         ? "1"
                                      //         : "0")
                                    },
                                    icon: const Icon(
                                      IconlyBold.bookmark,
                                      color: ColorManager.colorAccent,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                  VisibilityDetector(
                      key: const Key("miniplayer"),
                      child: Obx(() => Visibility(
                          visible: isPlayerVisible.value,
                          child: SizedBox(
                            height: 80,
                            child: Card(
                              margin: const EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 2,
                                      color: ColorManager.colorAccent
                                          .withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child:
                                              Obx(() => imgSound(avatar.value)),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Obx(() => Text(
                                                  soundName.value,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )),
                                            Obx(() => Text(
                                                  soundOwner.value,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                            Obx(() => ProgressBar(
                                                thumbRadius: 5,
                                                barHeight: 3,
                                                baseBarColor: ColorManager
                                                    .colorAccentTransparent,
                                                bufferedBarColor: ColorManager
                                                    .colorAccentTransparent,
                                                timeLabelLocation:
                                                    TimeLabelLocation.none,
                                                thumbColor:
                                                    ColorManager.colorAccent,
                                                progressBarColor:
                                                    ColorManager.colorAccent,
                                                buffered: progressNotifier
                                                    .value.buffered,
                                                progress: audioDuration.value,
                                                onSeek: (duration) =>
                                                    audioPlayer.seek(duration),
                                                total:
                                                    audioTotalDuration.value))
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (audioDuration.value >=
                                                audioTotalDuration.value &&
                                            audioTotalDuration.value !=
                                                Duration.zero) {
                                          audioPlayer
                                              .seek(Duration.zero)
                                              .then((value) {
                                            if (audioPlayer.playing) {
                                              audioPlayer.pause();
                                            } else {
                                              audioPlayer.play();
                                            }
                                          });
                                        }
                                        if (audioPlayer.playing) {
                                          audioPlayer.pause();
                                        } else {
                                          audioPlayer.play();
                                        }
                                        isPlayerPlaying.value =
                                            audioPlayer.playing;
                                      },
                                      child: Obx(() => isPlayerPlaying.value &&
                                              audioDuration.value <=
                                                  audioTotalDuration.value &&
                                              audioTotalDuration.value !=
                                                  Duration.zero
                                          ? const Icon(
                                              Icons
                                                  .pause_circle_filled_outlined,
                                              size: 50,
                                              color: ColorManager.colorAccent,
                                            )
                                          : audioDuration.value >=
                                                      audioTotalDuration
                                                          .value &&
                                                  audioTotalDuration.value !=
                                                      Duration.zero &&
                                                  isPlayerPlaying.value
                                              ? const Icon(
                                                  Icons.refresh_rounded,
                                                  size: 50,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )
                                              : const Icon(
                                                  IconlyBold.play,
                                                  size: 50,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))),
                      onVisibilityChanged: (info) => {
                            if (info.visibleFraction < 0.9)
                              {
                                audioPlayer.stop(),
                                isPlayerPlaying.value = audioPlayer.playing
                              }
                          })
                ],
              ),
        onLoading: searchSoundShimmer(),
        onEmpty: Column(
          children: [emptyListWidget(data: "No favourite sounds")],
        ));
  }
}
