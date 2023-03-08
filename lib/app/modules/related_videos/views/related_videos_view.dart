import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:video_player/video_player.dart';

import '../controllers/related_videos_controller.dart';

class RelatedVideosView extends StatefulWidget {
  RelatedVideosView({this.videoUrl, this.pageController, this.nextPage,this.videoId});

  String? videoUrl;
  PageController? pageController;
  int? nextPage;
  int? videoId;

  @override
  State<RelatedVideosView> createState() => _RelatedVideosViewState();
}

class _RelatedVideosViewState extends State<RelatedVideosView> {
  late VideoPlayerController videoPlayerController;
  var relatedVideosController = Get.find<RelatedVideosController>();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    videoPlayerController =
        VideoPlayerController.network(RestUrl.videoUrl + widget.videoUrl!)
          ..setLooping(false)
          ..initialize().then((value) {
            Logger().wtf("Initialised");

            relatedVideosController.isInitialised.value = true;
            setState(() {

            });
          })..play();



    videoPlayerController.addListener(() {
      if (videoPlayerController.value.duration ==
              videoPlayerController.value.position &&
          videoPlayerController.value.position > Duration.zero) {
        setState(() {
          widget.pageController!.animateToPage(widget.nextPage!,
              duration: Duration(milliseconds: 700), curve: Curves.easeOut);
        });
      }
    });

    setState(() {
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (videoPlayerController.value.duration ==
        videoPlayerController.value.position &&
        videoPlayerController.value.position > Duration.zero) {
      relatedVideosController.postVideoView(widget.videoId!).then((value) {
      });

      setState(() {
      });
    }
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(videoPlayerController);
  }
}
