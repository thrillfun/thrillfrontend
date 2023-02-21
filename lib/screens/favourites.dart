import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/Favourites/favourites_controller.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/hashtags/top_hashtags_controller.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/sound/sound_details.dart';

import '../controller/model/public_videosModel.dart';
import '../rest/rest_url.dart';
import '../utils/util.dart';
import '../widgets/video_item.dart';
import 'hash_tags/hash_tags_screen.dart';

class Favourites extends GetView<FavouritesController> {
  var selectedTab = 0.obs;
  var discoverController = Get.find<DiscoverController>();
  var topHashtagsController = Get.find<TopHashtagsController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: controller.obx(
            (state) => ListView(
                  children: [
                    favouritesTabbar(),
                    Obx(() => favouritesTabView())
                  ],
                ),
            onLoading: loader()),
      ),
    );
  }

  favouritesTabView() {
    if (selectedTab.value == 0) {
      return favouriteVideos();
    }
    if (selectedTab.value == 1) {
      return favouriteSounds();
    } else {
      return favouritesHashtags();
    }
  }

  favouritesTabbar() => DefaultTabController(
      length: 3,
      child: TabBar(
          unselectedLabelColor:
              Get.isPlatformDarkMode ? Colors.white : const Color(0xff9E9E9E),
          indicatorColor: ColorManager.colorAccent,
          labelColor: ColorManager.colorAccent,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          automaticIndicatorColorAdjustment: true,
          onTap: (int index) {
            selectedTab.value = index;
          },
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
          tabs: const [
            Tab(
              text: "Videos",
            ),
            Tab(
              text: "Sounds",
            ),
            Tab(
              text: "Hashtags",
            ),
            // Tab(
            //   text: "Local",
            // ),
          ]));

  favouriteSounds() => controller.obx(
      (_) => SizedBox(
            height: Get.height,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.favouriteSounds.length,
                itemBuilder: (context, index) => InkWell(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/Image.png",
                                      height: 80,
                                      width: 80,
                                    ),
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: imgProfile(controller
                                          .favouriteSounds[index].thumbnail
                                          .toString()),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.favouriteSounds[index].name
                                          .toString(),
                                      style: TextStyle(
                                          color: ColorManager.dayNightText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      controller.favouriteSounds[index].sound
                                          .toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      controller.favouriteSounds[index].sound
                                          .toString(),
                                      style: TextStyle(
                                        color: ColorManager.dayNightText,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              controller.favouriteSounds[index].id.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      onTap: () => {
                        Get.to(SoundDetails(
                          map: {
                            "sound": controller.favouriteSounds[index].sound,
                            "user": controller
                                    .favouriteSounds[index].user!.name!.isEmpty
                                ? controller.favouriteSounds[index].user!.name!
                                : "",
                            "soundName":
                                controller.favouriteSounds[index].sound,
                            "title": controller.favouriteSounds[index].name,
                            "id": controller.favouriteSounds[index].user!.id,
                            "profile":
                                controller.favouriteSounds[index].user!.avatar,
                            "name":
                                controller.favouriteSounds[index].user!.name,
                            "sound_id": controller.favouriteSounds[index].id,
                            "username": controller
                                .favouriteSounds[index].user!.username,
                            "isFollow": 0,
                            "userProfile": controller
                                    .favouriteSounds[index].user!.avatar
                                    .toString()
                                    .isEmpty
                                ? controller.favouriteSounds[index].user!.avatar
                                : RestUrl.placeholderImage
                          },
                        ))
                      },
                    )),
          ),
      onEmpty: emptyListWidget(),
      onLoading: loader());
  favouriteVideos() => controller.obx((_) => Container(
        height: Get.height,
        width: Get.width,
        margin: const EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          childAspectRatio: Get.width / Get.height,
          mainAxisSpacing: 10,
          children: List.generate(
              controller.favouriteVideos.length,
              (index) => InkWell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            fit: StackFit.loose,
                            children: [
                              imgNet(RestUrl.gifUrl +
                                  controller.favouriteVideos[index].gifImage!),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        child: Icon(
                                          Icons.play_circle,
                                          size: 14,
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "  " +
                                            controller
                                                .favouriteVideos[index].views
                                                .toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: controller
                                            .favouriteVideos[index].user!.avatar
                                            .toString()
                                            .isEmpty ||
                                        controller.favouriteVideos[index].user!
                                                .avatar
                                                .toString() ==
                                            "null"
                                    ? RestUrl.placeholderImage
                                    : RestUrl.profileUrl +
                                        controller
                                            .favouriteVideos[index].user!.avatar
                                            .toString(),
                                height: 20,
                                width: 20,
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              controller.favouriteVideos[index].user!.name
                                  .toString(),
                              style: TextStyle(
                                  color: ColorManager.dayNightText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        )
                      ],
                    ),
                    onTap: () {
                      List<PublicVideos> videosList1 = [];
                      controller.favouriteVideos.forEach((element) {
                        var user = PublicUser(
                          id: element.user?.id,
                          name: element.user?.name,
                          facebook: element.user?.facebook,
                          firstName: element.user?.firstName,
                          lastName: element.user?.lastName,
                          username: element.user?.username,
                          isFollow: 0,
                        );
                        videosList1.add(PublicVideos(
                          id: element.id,
                          video: element.video,
                          description: element.description,
                          sound: element.sound,
                          soundName: element.soundName,
                          soundCategoryName: element.soundCategoryName,
                          // soundOwner: element.soundOwner,
                          filter: element.filter,
                          likes: element.likes,
                          views: element.views,
                          gifImage: element.gifImage,
                          speed: element.speed,
                          comments: element.comments,
                          isDuet: "no",
                          duetFrom: "",
                          isCommentable: "yes",
                          // videoLikeStatus: element.videoLikeStatus,
                          user: user,
                        ));
                      });
                      Get.to(VideoPlayerItem(
                        videosList: videosList1,
                        position: index,
                      ));
                    },
                  )),
        ),
      ));
  favouritesHashtags() => controller.obx(
      (_) => SizedBox(
            height: Get.height,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.favouriteHashtags.length,
                itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        discoverController
                            .getVideosByHashTags(
                                controller.favouriteHashtags[index].id!)
                            .then((value) => HashTagsScreen(
                                  tagName:
                                      controller.favouriteHashtags[index].name,
                                  videoCount:
                                      controller.favouriteHashtags[index].id,
                                ));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            73, 204, 201, 0.08),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Icon(
                                      Icons.numbers,
                                      color: ColorManager.colorAccent,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  controller.favouriteHashtags[index].name ==
                                          null
                                      ? ""
                                      : controller
                                          .favouriteHashtags[index].name!,
                                  style: TextStyle(
                                      color: ColorManager.dayNightText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                )
                              ],
                            ),
                            Text(
                              controller.favouriteHashtags.length == null
                                  ? ""
                                  : controller.favouriteHashtags.length
                                      .toString()!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )),
          ),
      onEmpty: emptyListWidget(),
      onLoading: loader());
}
