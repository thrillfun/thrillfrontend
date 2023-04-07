import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:just_audio/just_audio.dart';

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
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: GetX<SoundsController>(
                  builder: (controller) => controller.isProfileLoading.isTrue
                      ? loader()
                      : Row(
                          children: [
                            Flexible(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset("assets/Image.png"),
                                  Obx(() => InkWell(
                                      onTap: () async {
                                        audioPlayer.setAudioSource(
                                            AudioSource.uri(Uri.parse(RestUrl
                                                    .soundUrl +
                                                Get.arguments["sound_url"])));

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
                                            )))
                                  // imgProfile(Get.arguments["profile"] as String),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Flexible(
                                child: Text(
                              Get.arguments["sound_name"]
                                          .toString()
                                          .toLowerCase()
                                          .contains("original") ||
                                      Get.arguments["sound_name"]
                                          .toString()
                                          .isEmpty
                                  ? Get.arguments["sound_name"] +
                                      " by " +
                                      (controller.userProfile.value.name
                                              .toString()
                                              .isEmpty
                                          ? controller
                                              .userProfile.value.username
                                          : controller.userProfile.value.name
                                              .toString())
                                  : Get.arguments["sound_name"].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ))
                          ],
                        ),
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

              GetX<SoundsController>(
                  builder: (controller) => controller.isProfileLoading.isTrue
                      ? loader()
                      : InkWell(onTap: (){
                        controller.userProfile.value.id!=GetStorage().read("userId")?
                            Get.toNamed(Routes.OTHERS_PROFILE,arguments: {"profileId":controller.userProfile.value.id}):Get.toNamed(Routes.PROFILE);
                  }
                    ,child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Row(
                            children: [
                              imgProfile(
                                  controller.userProfile.value.avatar ?? ""),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userProfile.value.name
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                      "@" +
                                          controller
                                              .userProfile.value.username
                                              .toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          )),
                      // InkWell(
                      //   onTap: () async {
                      //     // await userController
                      //     //     .followUnfollowUser(widget.map["id"],
                      //     //     isFollow.value == 0 ? "follow" : "unfollow")
                      //     //     .then((value) {
                      //     //   isFollow.value == 0
                      //     //       ? isFollow.value = 1
                      //     //       : isFollow.value = 0;
                      //     //
                      //     //   relatedVideosController.getAllVideos();
                      //     // });
                      //   },
                      //   child: Obx(() => Container(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 20, vertical: 10),
                      //         decoration: (Get.arguments["is_follow"]
                      //                         as Rx<int?>)
                      //                     .value ==
                      //                 0
                      //             ? BoxDecoration(
                      //                 color: ColorManager.colorAccent,
                      //                 borderRadius:
                      //                     BorderRadius.circular(20))
                      //             : BoxDecoration(
                      //                 border: Border.all(
                      //                     color:
                      //                         ColorManager.colorAccent),
                      //                 borderRadius:
                      //                     BorderRadius.circular(20)),
                      //         child: Text(
                      //           (Get.arguments["is_follow"] as Rx<int?>)
                      //                       .value ==
                      //                   0
                      //               ? "Follow"
                      //               : "Following",
                      //           style: const TextStyle(
                      //               fontSize: 14,
                      //               fontWeight: FontWeight.w600,
                      //               color: ColorManager.colorAccent),
                      //         ),
                      //       )),
                      // )
                    ],
                  ),)),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Divider(
                  color: Color.fromRGBO(238, 238, 238, 1),
                  thickness: 2,
                ),
              ),
              Expanded(
                child: controller.obx(
                    (state) => state!.isEmpty
                        ? Icon(IconlyBroken.volume_off)
                        : GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            physics: const BouncingScrollPhysics(),
                            childAspectRatio: 0.8,
                            children: List.generate(
                                state!.length,
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
                                            imgNet(state[index]
                                                    .gifImage
                                                    .toString()
                                                    .isEmpty
                                                ? '${RestUrl.thambUrl}thumb-not-available.png'
                                                : '${RestUrl.gifUrl}${state[index].gifImage}'),
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
                                                                  state[index]
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
                          ),
                    onError: (error) =>
                        emptyListWidget(data: "No videos for this sound"),
                    onEmpty: emptyListWidget(data: "No videos for this sound")),
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
                    Get.toNamed(Routes.SOUNDS, arguments: {
                      "sound_name": Get.arguments["sound_name"],
                      "sound_url": Get.arguments["sound_url"],
                    });
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
