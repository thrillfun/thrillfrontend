import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/sounds_controller.dart';

class SoundsView extends GetView<SoundsController> {
  const SoundsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var audioPlayer = AudioPlayer();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sound Details",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
      ),
      body: controller.obx((state) => Stack(
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
                          Image.asset("assets/Image.png"),
                          VisibilityDetector(
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction == 0 &&
                                  audioPlayer.playing) {
                                audioPlayer.pause();
                              } else {
                                audioPlayer.play();
                              }
                              controller.isPlaying.value =
                                  audioPlayer.playing;
                            },
                            key: const Key("unique key"),
                            child: Obx(() => InkWell(
                                onTap: () async {
                                  audioPlayer.setAudioSource(
                                      AudioSource.uri(Uri.parse(
                                          RestUrl.soundUrl +
                                              state!.sound.toString())));

                                  audioPlayer.playing
                                      ? audioPlayer.pause()
                                      : audioPlayer.play();
                                  controller.isPlaying.value =
                                      audioPlayer.playing;
                                },
                                child: controller.isPlaying.value
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
                          )

                          // imgProfile(Get.arguments["profile"] as String),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                        child: Text(
                          state!.sound!=null?state!.sound.toString():"",
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
                      controller.addSoundToFavourite();
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

              InkWell(
                onTap: () {
                  state!.soundOwner!.id !=
                      GetStorage().read("userId")
                      ? Get.toNamed(Routes.OTHERS_PROFILE,
                      arguments: {
                        "profileId": state!.soundOwner!.id
                      })
                      : Get.toNamed(Routes.PROFILE);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Row(
                          children: [
                            imgProfile(state!.soundOwner !=
                                null
                                ? state!.soundOwner!.avtars
                                .toString()
                                : ""),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state!.soundOwner!=null?state!.soundOwner!.name
                                      .toString():"",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                    state!.soundOwner!=null?
                                    "@" +
                                        state!.soundOwner!.username
                                            .toString():"",
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
              Expanded(
                child: GetX<SoundsController>(builder: (controller)=>GridView.count(
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
                              imgNet(controller.videoList[index]
                                  .gifImage
                                  .toString()
                                  .isEmpty
                                  ? '${RestUrl.thambUrl}thumb-not-available.png'
                                  : '${RestUrl.gifUrl}${controller.videoList[index].gifImage}'),
                              Container(
                                  height: Get.height,
                                  alignment: Alignment.bottomLeft,
                                  margin:
                                  const EdgeInsets.symmetric(
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
                                                Icons.play_circle,
                                                size: 18,
                                                color: ColorManager
                                                    .colorAccent,
                                              ),
                                            ),
                                            TextSpan(
                                                text: " " +
                                                    controller.videoList[index]
                                                        .views
                                                        .toString(),
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
                ),),
              ),


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
                        controller.soundDetails.sound!,
                        controller.soundDetails.soundOwner!.name.toString().isEmpty?controller.soundDetails.soundOwner!.username.toString():
                        controller.soundDetails.soundOwner!.name.toString(),
                        controller.soundDetails.sound!,
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
      ),onLoading: Container(
        alignment: Alignment.center,
        child: loader(),)),
    );
  }
}
