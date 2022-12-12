import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/widgets/better_video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  VideoPlayerItem({this.videosList, this.position});

  List<PublicVideos>? videosList;
  int? position;

  var itemIndex = 0.obs;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  PublicVideos publicVideos = PublicVideos();
  bool isFav = false;
  bool isLock = false;
  bool isFeed = false;
  var current = 0.obs;
  var related = 0.obs;
  var popular = 0.obs;
  var isOnPageTurning = false.obs;

  PreloadPageController? preloadPageController;

  @override
  void initState() {
    // TODO: implement initState
    preloadPageController = PreloadPageController();
    preloadPageController!.addListener(scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PreloadPageView.builder(
            controller: preloadPageController,
            preloadPagesCount: 6,
            itemCount: widget.videosList!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              late PublicUser publicUser;
              widget.videosList!.forEach((videos) {
                publicUser = PublicUser(
                    id: widget.videosList![index].user!.id,
                    name: widget.videosList![index].user?.name.toString(),
                    username: widget.videosList![index].user?.username,
                    email: widget.videosList![index].user?.email,
                    dob: widget.videosList![index].user?.dob,
                    phone: widget.videosList![index].user?.phone,
                    avatar: widget.videosList![index].user!.avatar,
                    socialLoginType:
                        widget.videosList![index].user?.socialLoginType,
                    socialLoginId:
                        widget.videosList![index].user?.socialLoginId,
                    firstName: widget.videosList![index].user?.firstName,
                    lastName: widget.videosList![index].user?.lastName,
                    gender: widget.videosList![index].user?.gender);
              });
              return AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio /
                    MediaQuery.of(context).size.aspectRatio,
                child: BetterReelsPlayer(
                  widget.videosList![index].gifImage.toString(),
                  widget.videosList![index].video.toString(),
                  index.obs,
                  current,
                  isOnPageTurning,
                  () {
                    videosController.likeVideo(
                        widget.videosList![index].videoLikeStatus == 0 ? 1 : 0,
                        widget.videosList![index].id!);
                  },
                  publicUser,
                  widget.videosList![index].id!.toInt(),
                  widget.videosList![index].soundName.toString(),
                  true.obs,
                  publicVideos,
                  widget.videosList![index].user!.id!,
                  widget.videosList![index].user!.username.toString().obs,
                  widget.videosList![index].description.toString().obs,
                  false.obs,
                  isFeed
                      ? []
                      : isFav
                          ? []
                          : isLock
                              ? []
                              : [],
                  // : hashTagVideos![index].hashtags!,
                  widget.videosList![index].sound.toString(),
                  widget.videosList![index].soundOwner.toString(),
                  widget.videosList![index].videoLikeStatus.toString(),
                  widget.videosList != null &&
                          widget.videosList![index].isCommentable.obs
                                  .toString()
                                  .toLowerCase() ==
                              "yes"
                      ? true.obs
                      : false.obs,
                  like: widget.videosList![index].likes!.obs,
                  isfollow: widget.videosList![index].isfollow,
                ),
              );
            }));
  }

  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      setState(() {
        current.value = preloadPageController!.page!.toInt();
        isOnPageTurning.value = false;
      });
    } else if (!isOnPageTurning.value &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!.toDouble()).abs() >
          0.1) {
        setState(() {
          isOnPageTurning.value = true;
        });
      }
    }
  }
}
