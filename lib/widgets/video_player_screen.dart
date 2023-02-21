import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/search_hash_tags_model.dart';
import 'package:thrill/widgets/better_video_player.dart';

import '../utils/util.dart';

class VideoPlayerScreen extends StatefulWidget {

  VideoPlayerScreen(
      {this.hashTagVideos,
        this.position,
        this.likedVideos,
        this.userVideos,
        required this.isFav,
        required this.isFeed,
        required this.isLock,
        this.privateVideos,
        this.videosList});

  List<HashTagsDetails>? hashTagVideos;
  List<LikedVideos>? likedVideos;
  List<Videos>? userVideos;
  List<PrivateVideos>? privateVideos;
  List<VideosList>? videosList;
  bool isFav = false;
  bool isLock = false;
  bool isFeed = false;
  int? position;


  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  PageController? preloadPageController;
  var isOnPageTurning = false.obs;
  var itemIndex = 0.obs;
  PublicVideos publicVideos = PublicVideos();


  @override
  void initState() {
    // TODO: implement initState
    preloadPageController = PageController(initialPage: widget.position ?? 0);
    preloadPageController!.addListener(scrollListener);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
            controller: preloadPageController,
            itemCount: widget.isFeed
                ? widget.userVideos!.length
                : widget.isFav
                ? widget.likedVideos!.length
                : widget.isLock
                ? widget.privateVideos!.length
                : widget.hashTagVideos!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              late PublicUser publicUser;
              widget.isFeed
                  ? widget.userVideos!.forEach((hashTagVideos) {
                publicUser = PublicUser(
                    id: widget.userVideos![index].user!.id,
                    name: widget.userVideos![index].user?.name.toString(),
                    username: widget.userVideos![index].user?.username,
                    email: widget.userVideos![index].user?.email,
                    dob: widget.userVideos![index].user?.dob,
                    phone: widget.userVideos![index].user?.phone,
                    avatar: widget.userVideos![index].user!.avatar,
                    socialLoginType:
                    widget.userVideos![index].user?.socialLoginType,
                                        firebaseToken: widget.userVideos![index].user!.firebaseToken,

                    socialLoginId: widget.userVideos![index].user?.socialLoginId,
                    firstName: widget.userVideos![index].user?.firstName,
                    lastName: widget.userVideos![index].user?.lastName,
                    gender:widget. userVideos![index].user?.gender,
                    isFollow: widget.userVideos![index].isfollow,
                    likes: widget.userVideos![index].likes.toString());
              })
                  : widget.isFav
                  ? widget.likedVideos!.forEach((hashTagVideos) {
                publicUser = PublicUser(
                    id: widget.likedVideos![index].user!.id,
                    name: widget.likedVideos![index].user?.name.toString(),
                    username: widget.likedVideos![index].user?.username,
                    email: widget.likedVideos![index].user?.email,
                    dob: widget.likedVideos![index].user?.dob,
                    phone: widget.likedVideos![index].user?.phone,
                    avatar: widget.likedVideos![index].user!.avatar,
                    socialLoginType:
                    widget. likedVideos![index].user?.socialLoginType,
                    socialLoginId:
                    widget.likedVideos![index].user?.socialLoginId,
                                        firebaseToken: widget.likedVideos![index].user!.firebaseToken,

                    firstName: widget.likedVideos![index].user?.firstName,
                    lastName: widget.likedVideos![index].user?.lastName,
                    gender: widget.likedVideos![index].user?.gender,
                    isFollow: widget.likedVideos![index].isfollow,
                    likes: widget.likedVideos![index].likes.toString());
              })
                  : widget.isLock
                  ? widget.privateVideos!.forEach((element) {
                publicUser = PublicUser(
                    id: widget.privateVideos![index].user!.id,
                    name: widget.privateVideos![index]
                        .user
                        ?.name
                        .toString(),
                    username:
                    widget.privateVideos![index].user?.username,
                    email: widget.privateVideos![index].user?.email,
                    dob: widget.privateVideos![index].user?.dob,
                    phone: widget.privateVideos![index].user?.phone,
                    avatar: widget.privateVideos![index].user!.avatar,
                    socialLoginType: widget.privateVideos![index]
                        .user
                        ?.socialLoginType,
                    socialLoginId:
                    widget.privateVideos![index].user?.socialLoginId,
                    firstName:
                    widget.privateVideos![index].user?.firstName,
                                        firebaseToken: widget.privateVideos![index].user!.firebaseToken,

                    lastName:
                    widget.privateVideos![index].user?.lastName,
                    gender: widget.privateVideos![index].user?.gender,
                    isFollow: widget.privateVideos![index].isfollow,
                    likes:
                    widget.privateVideos![index].likes.toString());
              })
                  : widget.hashTagVideos!.forEach((videos) {
                publicUser = PublicUser(
                    id: widget.hashTagVideos![index].user!.id,
                    name: widget.hashTagVideos![index]
                        .user
                        ?.name
                        .toString(),
                    username:
                    widget.hashTagVideos![index].user?.username,
                    email: widget.hashTagVideos![index].user?.email,
                    dob: widget.hashTagVideos![index].user?.dob,
                    phone: widget.hashTagVideos![index].user?.phone,
                    avatar: widget.hashTagVideos![index].user!.avatar,
                    firebaseToken: widget.hashTagVideos![index].user!.firebaseToken,
                    socialLoginType: widget.hashTagVideos![index]
                        .user
                        ?.socialLoginType,
                    socialLoginId:
                    widget.hashTagVideos![index].user?.socialLoginId,
                    firstName:
                    widget.hashTagVideos![index].user?.firstName,
                    lastName:
                    widget.hashTagVideos![index].user?.lastName,
                    gender: widget.hashTagVideos![index].user?.gender,
                    isFollow: widget.userVideos![index].isfollow,
                    likes: widget.userVideos![index].likes.toString());
              });
              return AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio /
                    MediaQuery.of(context).size.aspectRatio,
                child: Obx(() =>

                    BetterReelsPlayer(
                      widget. isFeed
                          ? widget.userVideos![index].gifImage.toString()
                          : widget.isFav
                          ? widget.likedVideos![index].gifImage.toString()
                          : widget.isLock
                          ? widget.privateVideos![index].gifImage.toString()
                          : widget.hashTagVideos![index].gifImage.toString(),
                      widget.isFeed
                          ? widget.userVideos![index].video.toString()
                          : widget.isFav
                          ? widget.likedVideos![index].video.toString()
                          : widget.isLock
                          ? widget.privateVideos![index].gifImage.toString()
                          : widget.hashTagVideos![index].video.toString(),
                      index.obs,
                      widget.position!.obs,
                      isOnPageTurning,
                          () {
                        videosController.likeVideo(
                            1,
                            widget.isFeed
                                ? widget.userVideos![index].id!
                                : widget.isFav
                                ? widget.likedVideos![index].id!
                                : widget.isLock
                                ? widget.privateVideos![index].id!
                                : widget.hashTagVideos![index].id!);
                      },
                      publicUser,
                      widget.isFeed
                          ? widget.userVideos![index].id!.toInt()
                          : widget.isFav
                          ? widget.likedVideos![index].id!.toInt()
                          : widget.isLock
                          ? widget.privateVideos![index].id!.toInt()
                          : widget.hashTagVideos![index].id!.toInt(),
                      widget.isFeed
                          ? widget.userVideos![index].soundName.toString()
                          : widget.isFav
                          ? widget.likedVideos![index].soundName.toString()
                          : widget.isLock
                          ? widget.privateVideos![index].soundName.toString()
                          : widget.hashTagVideos![index].soundName.toString(),
                      true.obs,
                      publicVideos,
                      widget.isFeed
                          ? widget.userVideos![index].user!.id!
                          : widget.isFav
                          ? widget.likedVideos![index].user!.id!
                          : widget.isLock
                          ? widget.privateVideos![index].user!.id!
                          : widget.hashTagVideos![index].user!.id!,
                      widget.isFeed
                          ? widget.userVideos![index].user!.username.toString().obs
                          : widget.isFav
                          ? widget.likedVideos![index]
                          .user!
                          .username
                          .toString()
                          .obs
                          : widget.isLock
                          ? widget.privateVideos![index]
                          .user!
                          .username
                          .toString()
                          .obs
                          : widget.hashTagVideos![index]
                          .user!
                          .username
                          .toString()
                          .obs,
                      widget. isFeed
                          ? widget.userVideos![index].description.toString().obs
                          : widget.isFav
                          ? widget.likedVideos![index].description.toString().obs
                          :widget. isLock
                          ?widget. privateVideos![index]
                          .description
                          .toString()
                          .obs
                          : widget.hashTagVideos![index]
                          .description
                          .toString()
                          .obs,
                      false.obs,
                      widget.isFeed
                          ? []
                          : widget.isFav
                          ? []
                          : widget.isLock
                          ? []
                          : [],
                      // : hashTagVideos![index].hashtags!,
                      widget.isFeed
                          ? widget.userVideos![index].sound.toString()
                          : widget.isFav
                          ? widget.likedVideos![index].sound.toString()
                          : widget.isLock
                          ? widget.privateVideos![index].soundName.toString()
                          : widget.hashTagVideos![index].sound.toString(),
                      widget. isFeed
                          ? widget.userVideos![index].soundOwner.toString()
                          : widget.isFav
                          ? widget.likedVideos![index].soundOwner.toString()
                          :widget. isLock
                          ?widget. privateVideos![index].soundOwner.toString()
                          :widget. hashTagVideos![index].soundOwner.toString(),
                      widget.isFeed
                          ? widget.userVideos![index]
                          .videoLikeStatus
                          .toString()
                          .isEmpty ||
                          widget.userVideos![index]
                              .videoLikeStatus
                              .toString() ==
                              "null"
                          ? "0"
                          : widget.userVideos![index].videoLikeStatus.toString()
                          :widget. isFav
                          ?widget. likedVideos![index]
                          .videoLikeStatus
                          .toString()
                          .isEmpty ||
                          widget.likedVideos![index]
                              .videoLikeStatus
                              .toString() ==
                              "null"
                          ? "0"
                          : widget.likedVideos![index]
                          .videoLikeStatus
                          .toString()
                          : widget.isLock
                          ? widget.privateVideos![index]
                          .videoLikeStatus
                          .toString()
                          : "",
                      widget. isFeed
                          ?widget. userVideos != null &&
                          widget.userVideos![index]
                              .isCommentable
                              .toString()
                              .toLowerCase() ==
                              "yes"
                          ? true.obs
                          : false.obs
                          : widget.isFav
                          ?widget. likedVideos != null &&
                          widget.likedVideos![index]
                              .isCommentable
                              .toString()
                              .toLowerCase() ==
                              "yes"
                          ? true.obs
                          : false.obs
                          : true.obs,
                      isfollow: widget.isFeed
                          ? widget.userVideos![index].isfollow
                          :widget. isFav
                          ? widget.likedVideos![index].isfollow
                          : widget.isLock
                          ?widget. privateVideos![index].isfollow
                          : 0,
                      like: widget.isFeed
                          ? widget.userVideos![index].likes!.obs
                          : widget.isFav
                          ? widget.likedVideos![index].likes!.obs
                          : widget.isLock
                          ? widget.privateVideos![index].likes!.obs
                          : 0.obs,
                      soundId: widget. isFeed
                          ? widget.userVideos![index].soundId
                          : widget.isFav
                          ? widget.likedVideos![index].soundId
                          : widget.isLock
                          ? widget.privateVideos![index].soundId
                          : widget.hashTagVideos![index].soundId,
                    )),
              );
            }));
  }


  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
     setState(() {
       widget.position = preloadPageController!.page!.toInt();
       isOnPageTurning.value = false;
     });
    } else if (!isOnPageTurning.value &&
        widget.position!.toDouble() != preloadPageController!.page) {
      if ((widget.position!.toDouble() - preloadPageController!.page!.toDouble())
          .abs() >
          0.1) {
        setState(() {
          isOnPageTurning.value = true;
        });
      }
    }
    Get.appUpdate();
  }
}


