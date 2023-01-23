import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/hashtags/top_hashtags_controller.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';

import '../../controller/hashtags/search_hashtags_controller.dart';

var discoverController = Get.find<DiscoverController>();

var searchHashtagsController = Get.find<SearchHashtagsController>();

class DiscoverGetx extends GetView<TopHashtagsController> {
  const DiscoverGetx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pageIndex = 0.obs;
    return Scaffold(
        extendBody: true,
        backgroundColor: ColorManager.dayNight,
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: controller.obx((_) => Tophashtags(), onLoading:  Container(
              height: Get.height,
              width: Get.width,
              child: Center(
                child: loader(),
              ),
            ))));
  }

//   StaggeredGridView.countBuilder(
//   staggeredTileBuilder: (index) =>
//   index % 7 == 0
//   ? const StaggeredTile.count(
//   1, 2)
//       : const StaggeredTile.count(
//   1, 1),
//   physics:
//   const NeverScrollableScrollPhysics(),
//   //cross axis cell count
//   mainAxisSpacing: 8,
//   // vertical spacing between items
//   crossAxisSpacing: 8,
//   // horizontal spacing between items
//   crossAxisCount: 3,
//   shrinkWrap: true,
//   itemCount:
//   controller.hasTagsList.length,
//   itemBuilder: (context, index) =>
//   InkWell(
//   onTap: () async {
//   controller
//       .getVideosByHashTags(
//   controller
//       .hasTagsList[
//   index]
//       .hashtagId!
//       .toInt())
//       .then((value) => Get.to(
//   VideoPlayerScreen(
//   isFav: false,
//   isLock: false,
//   isFeed: false,
//   position: index,
//   hashTagVideos:
//   controller
//       .hashTagsDetailsList,
//   )));
// },
// child: Stack(
// fit: StackFit.expand,
// alignment:
// Alignment.bottomLeft,
// children: [
// Card(
// elevation: 8,
// shape:
// RoundedRectangleBorder(
// borderRadius:
// BorderRadius
//     .circular(
// 8)),
// child: ClipRRect(
// borderRadius:
// BorderRadius.circular(
// 8),
// child: CachedNetworkImage(
// fit: BoxFit
//     .cover,
// errorWidget: (context,
// url,
// error) =>
// errorWidget(),
// imageUrl: RestUrl
//     .gifUrl +
// controller
//     .hasTagsList[
// index]
// .videos!
// .first
//     .gifImage!
// .toString())),
// ),
// Padding(padding: EdgeInsets.all(10),child: Row(
// crossAxisAlignment: CrossAxisAlignment.end,
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// RichText(
// text: TextSpan(
// children: [
// const WidgetSpan(
// child: Icon(
// Icons
//     .remove_red_eye_outlined,
// color: Colors
//     .white,
// size: 20),
// ),
// TextSpan(
// style:const TextStyle(fontWeight: FontWeight.w700),
// text:
// " ${controller.hasTagsList[index].videos!.first.views} ",
// ),
// ],
// ),
// ),
// RichText(
// text: TextSpan(
// children: [
// const WidgetSpan(
// child: Icon(
// Icons
//     .heart_broken,
// color: Colors
//     .white,
// size: 18),
// ),
// TextSpan(
// style: TextStyle(fontWeight: FontWeight.w700),
//
// text:
// " ${controller.hasTagsList[index].videos!.first.likes} ",
// ),
// ],
// ),
// ),
// ],
// ),)
// ],
// ),
// )),
}

class HashtagsSuggestions extends GetView<TopHashtagsController> {
  const HashtagsSuggestions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Wrap(
        runSpacing: 10,
        children: List.generate(
            state!.length,
            (index) => Padding(
                padding: const EdgeInsets.only(
                    left: 5, right: 5, top: 20, bottom: 20),
                child: GlassContainer(
                  blur: 10,
                  shadowColor: Colors.transparent,
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                  color: ColorManager.colorAccent.withOpacity(0.5),
                  child: InkWell(
                      onTap: () async {
                        await hashtagVideosController
                            .getVideosByHashTags(state[index].hashtagId!)
                            .then((value) => Get.to(HashTagsScreen(
                                tagName: state[index].hashtagName.toString())));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 10, bottom: 10),
                          margin: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Text(
                            state[index].hashtagName.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ))),
                ))),
      ),

    );
  }
}

class Tophashtags extends GetView<TopHashtagsController> {
  const Tophashtags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                  height: 5,
                ),
                GlassContainer(
                  color: ColorManager.colorAccent.withOpacity(0.5),
                  blur: 5,
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: InkWell(
                        onTap: () async {
                          await searchHashtagsController
                              .searchHashtags("")
                              .then((value) {
                            Get.to(SearchGetx());
                          });
                        },
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                // GridView.builder(
                //     physics: NeverScrollableScrollPhysics(),
                //     gridDelegate:
                //         const SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 2,
                //       crossAxisSpacing: 5.0,
                //       mainAxisSpacing: 5.0,
                //     ),
                //     itemCount: controller.hasTagsList.length,
                //     scrollDirection: Axis.vertical,
                //     shrinkWrap: true,
                //     itemBuilder: ((context, index) => CachedNetworkImage(
                //         height: 250,
                //         width: 250,
                //         fit: BoxFit.cover,
                //         imageUrl: RestUrl.gifUrl +
                //             controller.hashTagsVideos[index].gifImage
                //                 .toString())))
                HashtagsSuggestions()
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state!.length,
              itemBuilder: (context, index) => Visibility(
                  visible: state[index].videos!.isNotEmpty,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          await hashtagVideosController
                              .getVideosByHashTags(state[index].hashtagId!)
                              .then((value) => Get.to(HashTagsScreen(
                                    tagName: state[index].hashtagName,
                                    videosList: state[index].videos,
                                    videoCount: state.length,
                                  )));
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
                                          color: ColorManager
                                              .colorAccentTransparent,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: const Icon(
                                        Icons.numbers,
                                        color: ColorManager.colorAccent,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state[index].hashtagName == null
                                            ? ""
                                            : state[index].hashtagName!,
                                        style: TextStyle(
                                            color: ColorManager.dayNightText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Trending Hashtag",
                                        style: TextStyle(
                                            color: ColorManager.dayNightText,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    state[index].videoCount == null
                                        ? ""
                                        : state[index].videoCount.toString()!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_right,
                                    color: ColorManager.colorAccent,
                                    size: 25,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: Get.width / Get.height,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                              state[index].videos!.take(3).length,
                              (videoIndex) => InkWell(
                                    onTap: () {},
                                    child: InkWell(
                                      onTap: () {
                                        List<PublicVideos> videosList1 = [];
                                        state[index].videos!.forEach((element) {
                                          var user = PublicUser(
                                            id: element.user?.id,
                                            name: element.user?.name,
                                            facebook: element.user?.facebook,
                                            firstName: element.user?.firstName,
                                            lastName: element.user?.lastName,
                                            username: element.user?.username,
                                            isfollow: 0,
                                          );
                                          videosList1.add(PublicVideos(
                                            id: element.id,
                                            video: element.video,
                                            description: element.description,
                                            sound: element.sound,
                                            soundName: element.soundName,
                                            soundCategoryName:
                                                element.soundCategoryName,
                                            soundOwner: element.soundOwner,
                                            filter: element.filter,
                                            likes: element.likes,
                                            views: element.views,
                                            gifImage: element.gifImage,
                                            speed: element.speed,
                                            comments: element.comments,
                                            isDuet: "no",
                                            duetFrom: "",
                                            isCommentable: "yes",
                                            user: user,
                                          ));
                                        });
                                        Get.to(VideoPlayerItem(
                                          videosList: videosList1,
                                          position: videoIndex,
                                        ));
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          imgNet(RestUrl.gifUrl +
                                              state[index]
                                                  .videos![videoIndex]
                                                  .gifImage
                                                  .toString()),
                                          Positioned(
                                              bottom: 10,
                                              left: 10,
                                              right: 10,
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
                                                                    .videos![
                                                                        videoIndex]
                                                                    .views
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16)),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  )),
                        ),
                      )
                    ],
                  )))
        ],
      ),
    );
  }
}
