import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/rest/models/user_private_video_model.dart';

import '../../../../rest/rest_urls.dart';
import '../controllers/private_videos_player_controller.dart';

class PrivateVideosPlayerView extends GetView<PrivateVideosPlayerController> {
  const PrivateVideosPlayerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var pageViewController = PageController(initialPage: Get.arguments["init_page"]);
    var playerController = BetterPlayerListVideoPlayerController();
    return PageView.builder(
        itemCount: (Get.arguments["private_videos"] as List<PrivateVideos>).length,
        scrollDirection: Axis.vertical,
        controller: pageViewController,
        itemBuilder: (context, index) => BetterPlayerListVideoPlayer(
          BetterPlayerDataSource.network(RestUrl.videoUrl +
              (Get.arguments["private_videos"] as List<PrivateVideos>)[index].video!),
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
