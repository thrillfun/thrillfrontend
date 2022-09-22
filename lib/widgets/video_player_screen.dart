import 'dart:convert';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/fluent.dart';
import 'package:iconify_flutter/icons/icon_park_outline.dart';
import 'package:iconly/iconly.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/model/comments_model.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/video/duet.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/better_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  VideoPlayerScreen(this.hashTagVideos, this.position);

  List<HashTagsDetails> hashTagVideos;
  int position;

  var isOnPageTurning = false.obs;

  @override
  Widget build(BuildContext context) {
    PreloadPageController preloadPageController =
        PreloadPageController(initialPage: position);
    var current = position.obs;

    void scrollListener() {
      if (isOnPageTurning.value &&
          preloadPageController.page ==
              preloadPageController.page!.roundToDouble()) {
        current.value = preloadPageController.page!.toInt();
        isOnPageTurning.value = false;
      } else if (!isOnPageTurning.value &&
          current.value.toDouble() != preloadPageController.page) {
        if ((current.value.toDouble() - preloadPageController.page!.toDouble())
                .abs() >
            0.1) {
          isOnPageTurning.value = true;
        }
      }
    }

    preloadPageController.addListener(scrollListener);
    late PublicUser publicUser;
    hashTagVideos.forEach((hashTagVideos) {
      publicUser = PublicUser(
          id: hashTagVideos.user!.id,
          name: hashTagVideos.user?.name.toString(),
          username: hashTagVideos.user?.username,
          email: hashTagVideos.user?.email,
          dob: hashTagVideos.user?.dob,
          phone: hashTagVideos.user?.phone,
          avatar: hashTagVideos.user!.avatar,
          socialLoginType: hashTagVideos.user?.socialLoginType,
          socialLoginId: hashTagVideos.user?.socialLoginId,
          firstName: hashTagVideos.user?.firstName,
          lastName: hashTagVideos.user?.lastName,
          gender: hashTagVideos.user?.gender);
    });

    PublicVideos publicVideos = PublicVideos();

    return Scaffold(
        body: PreloadPageView.builder(
      controller: preloadPageController,
      preloadPagesCount: 6,
      itemCount: hashTagVideos.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) => AspectRatio(
        aspectRatio: MediaQuery.of(context).size.aspectRatio /
            MediaQuery.of(context).size.aspectRatio,
        child: Obx(() => BetterReelsPlayer(
            hashTagVideos[index].gifImage.toString(),
            hashTagVideos[index].video.toString(),
            index,
            current.value,
            isOnPageTurning.value,
            () {},
            publicUser,
            hashTagVideos[index].id!.toInt(),
            hashTagVideos[index].soundName.toString(),
            true,
            publicVideos,
            hashTagVideos[index].user!.id!,
            hashTagVideos[index].user!.username.toString(),
            hashTagVideos[index].description.toString(),
            false,
            hashTagVideos[index].hashtags!)),
      ),
    ));
  }
}
