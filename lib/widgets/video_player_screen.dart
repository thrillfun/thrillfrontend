import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/widgets/better_video_player.dart';
import 'package:thrill/controller/model/search_hashtag_model.dart' as searchList;

class VideoPlayerScreen extends StatelessWidget {
  VideoPlayerScreen(
      {this.hashTagVideos,
      this.position,
      this.likedVideos,
      this.userVideos,
      required this.isFav,
      required this.isFeed,
      required this.isLock,
      this.privateVideos});

  List<searchList.Videos>? hashTagVideos;
  List<LikedVideos>? likedVideos;
  List<Videos>? userVideos;
  List<PrivateVideos>? privateVideos;
  int? position;
  bool isFav = false;
  bool isLock = false;
  bool isFeed = false;

  var isOnPageTurning = false.obs;
  var itemIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    PreloadPageController preloadPageController =
        PreloadPageController(initialPage: position ?? 0);
    var current = position.obs;

    void scrollListener() {
      if (isOnPageTurning.value &&
          preloadPageController.page ==
              preloadPageController.page!.roundToDouble()) {
        current.value = preloadPageController.page!.toInt();
        isOnPageTurning.value = false;
      } else if (!isOnPageTurning.value &&
          current.value!.toDouble() != preloadPageController.page) {
        if ((current.value!.toDouble() - preloadPageController.page!.toDouble())
                .abs() >
            0.1) {
          isOnPageTurning.value = true;
        }
      }
    }

    preloadPageController.addListener(scrollListener);

    PublicVideos publicVideos = PublicVideos();

    return Scaffold(
        body: PreloadPageView.builder(
            controller: preloadPageController,
            preloadPagesCount: 6,
            itemCount: isFeed
                ? userVideos!.length
                : isFav
                    ? likedVideos!.length
                    : isLock
                        ? privateVideos!.length
                        : hashTagVideos!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              late PublicUser publicUser;
              isFeed
                  ? userVideos!.forEach((hashTagVideos) {
                      publicUser = PublicUser(
                          id: userVideos![index].user!.id,
                          name: userVideos![index].user?.name.toString(),
                          username: userVideos![index].user?.username,
                          email: userVideos![index].user?.email,
                          dob: userVideos![index].user?.dob,
                          phone: userVideos![index].user?.phone,
                          avatar: userVideos![index].user!.avatar,
                          socialLoginType:
                              userVideos![index].user?.socialLoginType,
                          socialLoginId: userVideos![index].user?.socialLoginId,
                          firstName: userVideos![index].user?.firstName,
                          lastName: userVideos![index].user?.lastName,
                          gender: userVideos![index].user?.gender);
                    })
                  : isFav
                      ? likedVideos!.forEach((hashTagVideos) {
                          publicUser = PublicUser(
                              id: likedVideos![index].user!.id,
                              name: likedVideos![index].user?.name.toString(),
                              username: likedVideos![index].user?.username,
                              email: likedVideos![index].user?.email,
                              dob: likedVideos![index].user?.dob,
                              phone: likedVideos![index].user?.phone,
                              avatar: likedVideos![index].user!.avatar,
                              socialLoginType:
                                  likedVideos![index].user?.socialLoginType,
                              socialLoginId:
                                  likedVideos![index].user?.socialLoginId,
                              firstName: likedVideos![index].user?.firstName,
                              lastName: likedVideos![index].user?.lastName,
                              gender: likedVideos![index].user?.gender);
                        })
                      : isLock
                          ? privateVideos!.forEach((element) {
                              publicUser = PublicUser(
                                  id: privateVideos![index].user!.id,
                                  name: privateVideos![index]
                                      .user
                                      ?.name
                                      .toString(),
                                  username:
                                      privateVideos![index].user?.username,
                                  email: privateVideos![index].user?.email,
                                  dob: privateVideos![index].user?.dob,
                                  phone: privateVideos![index].user?.phone,
                                  avatar: privateVideos![index].user!.avatar,
                                  socialLoginType: privateVideos![index]
                                      .user
                                      ?.socialLoginType,
                                  socialLoginId:
                                      privateVideos![index].user?.socialLoginId,
                                  firstName:
                                      privateVideos![index].user?.firstName,
                                  lastName:
                                      privateVideos![index].user?.lastName,
                                  gender: privateVideos![index].user?.gender);
                            })
                          : hashTagVideos!.forEach((videos) {
                              publicUser = PublicUser(
                                  id: hashTagVideos![index].user!.id,
                                  name: hashTagVideos![index]
                                      .user
                                      ?.name
                                      .toString(),
                                  username:
                                      hashTagVideos![index].user?.username,
                                  email: hashTagVideos![index].user?.email,
                                  dob: hashTagVideos![index].user?.dob,
                                  phone: hashTagVideos![index].user?.phone,
                                  avatar: hashTagVideos![index].user!.avatar,
                                  socialLoginType: hashTagVideos![index]
                                      .user
                                      ?.socialLoginType,
                                  socialLoginId:
                                      hashTagVideos![index].user?.socialLoginId,
                                  firstName:
                                      hashTagVideos![index].user?.firstName,
                                  lastName:
                                      hashTagVideos![index].user?.lastName,
                                  gender: hashTagVideos![index].user?.gender);
                            });
              return AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio /
                    MediaQuery.of(context).size.aspectRatio,
                child: Obx(() => BetterReelsPlayer(
                    isFeed
                        ? userVideos![index].gifImage.toString()
                        : isFav
                            ? likedVideos![index].gifImage.toString()
                            : isLock
                                ? privateVideos![index].gifImage.toString()
                                : hashTagVideos![index].gifImage.toString(),
                    isFeed
                        ? userVideos![index].video.toString()
                        : isFav
                            ? likedVideos![index].video.toString()
                            : isLock
                                ? privateVideos![index].gifImage.toString()
                                : hashTagVideos![index].video.toString(),
                    index,
                    current.value ?? 0,
                    isOnPageTurning.value,
                    () {},
                    publicUser,
                    isFeed
                        ? userVideos![index].id!.toInt()
                        : isFav
                            ? likedVideos![index].id!.toInt()
                            : isLock
                                ? privateVideos![index].id!.toInt()
                                : hashTagVideos![index].id!.toInt(),
                    isFeed
                        ? userVideos![index].soundName.toString()
                        : isFav
                            ? likedVideos![index].soundName.toString()
                            : isLock
                                ? privateVideos![index].soundName.toString()
                                : hashTagVideos![index].soundName.toString(),
                    true,
                    publicVideos,
                    isFeed
                        ? userVideos![index].user!.id!
                        : isFav
                            ? likedVideos![index].user!.id!
                            : isLock
                                ? privateVideos![index].user!.id!
                                : hashTagVideos![index].user!.id!,
                    isFeed
                        ? userVideos![index].user!.username.toString()
                        : isFav
                            ? likedVideos![index].user!.username.toString()
                            : isLock
                                ? privateVideos![index]
                                    .user!
                                    .username
                                    .toString()
                                : hashTagVideos![index]
                                    .user!
                                    .username
                                    .toString(),
                    isFeed
                        ? userVideos![index].description.toString()
                        : isFav
                            ? likedVideos![index].description.toString()
                            : isLock
                                ? privateVideos![index].description.toString()
                                : hashTagVideos![index].description.toString(),
                    false,
                    isFeed
                        ? []
                        : isFav
                            ? []
                            : isLock
                                ? []
                                : hashTagVideos![index].hashtags!,
                    isFeed
                        ? userVideos![index].sound.toString()
                        : isFav
                            ? likedVideos![index].sound.toString()
                            : isLock
                                ? privateVideos![index].soundName.toString()
                                : hashTagVideos![index].sound.toString(),
                    isFeed
                        ? userVideos![index].soundOwner.toString()
                        : isFav
                            ? likedVideos![index].soundOwner.toString()
                            : isLock
                                ? privateVideos![index].soundOwner.toString()
                                : hashTagVideos![index].soundOwner.toString(),
                    isFeed
                        ? userVideos![index].videoLikeStatus
                        : isFav
                            ? likedVideos![index].videoLikeStatus
                            : isLock
                                ? privateVideos![index].videoLikeStatus
                                : 0,
                    isFeed
                        ? userVideos!=null && userVideos![index]
                                    .isCommentable
                                    .toString()
                                    .toLowerCase() ==
                                "yes"
                            ? true
                            : false
                        : isFav
                            ?
                        likedVideos!=null && likedVideos![index]
                                        .isCommentable
                                        .toString()
                                        .toLowerCase() ==
                                    "yes"
                                ? true
                                : false
                            : true)),
              );
            }));
  }
}
