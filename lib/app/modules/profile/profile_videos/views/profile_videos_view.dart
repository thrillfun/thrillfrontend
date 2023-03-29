import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/rest/models/user_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../controllers/profile_videos_controller.dart';

class ProfileVideosView extends GetView<ProfileVideosController> {
  const ProfileVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pageViewController = PageController(initialPage: Get.arguments["init_page"]);
    var playerController = BetterPlayerListVideoPlayerController();
    return PageView.builder(
        itemCount: (Get.arguments["video_list"] as List<Videos>).length,
        scrollDirection: Axis.vertical,
        controller: pageViewController,
        itemBuilder: (context, index) => BetterPlayerListVideoPlayer(
              BetterPlayerDataSource.network(RestUrl.videoUrl +
                  (Get.arguments["video_list"] as List<Videos>)[index].video!),
              betterPlayerListVideoPlayerController: playerController,
              configuration: BetterPlayerConfiguration(
                  autoPlay: true,
                  aspectRatio: Get.width / Get.height,
                  eventListener: (eventListener) async {

                    controller.eventType = eventListener.betterPlayerEventType;
                    if (eventListener.betterPlayerEventType ==
                        BetterPlayerEventType.finished && eventListener.betterPlayerEventType!=BetterPlayerEventType.pause &&eventListener.betterPlayerEventType !=
                        BetterPlayerEventType.play) {
                      playerController.seekTo(Duration.zero);

                      pageViewController.animateToPage(index + 1,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeIn);
                      // videosController
                      //     .postVideoView(state[index].id!)
                      //     .then((value) {
                      //
                      // });


                    }
                  },
                  controlsConfiguration:
                      const BetterPlayerControlsConfiguration(showControls: false)),
            ));
  }
}
