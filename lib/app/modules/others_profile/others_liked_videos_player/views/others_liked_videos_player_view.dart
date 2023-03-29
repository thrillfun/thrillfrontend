import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../rest/models/user_liked_videos_model.dart';
import '../../../../rest/rest_urls.dart';
import '../controllers/others_liked_videos_player_controller.dart';

class OthersLikedVideosPlayerView
    extends GetView<OthersLikedVideosPlayerController> {
  const OthersLikedVideosPlayerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var pageViewController = PageController(initialPage: Get.arguments["init_page"]);
    var playerController = BetterPlayerListVideoPlayerController();
    return PageView.builder(
        itemCount: (Get.arguments["liked_videos"] as List<LikedVideos>).length,
        scrollDirection: Axis.vertical,
        controller: pageViewController,
        itemBuilder: (context, index) => BetterPlayerListVideoPlayer(
          BetterPlayerDataSource.network(RestUrl.videoUrl +
              (Get.arguments["liked_videos"] as List<LikedVideos>)[index].video!),
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
