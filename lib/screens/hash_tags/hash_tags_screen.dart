import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';

class HashTagsScreen extends StatelessWidget {
  HashTagsScreen({this.tagName, this.videoCount, this.videosList});

  String? tagName;
  int? videoCount;
  List<HashTagVideos>? videosList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
          backgroundColor: Colors.transparent.withOpacity(0),
          elevation: 0,
          title: Text(
            "Trending Hashtag",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: Get.width,
            height: Get.height,
            child: GetX<DiscoverController>(
                builder: (controller) => controller.searchList.isEmpty
                    ? SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: const Center(
                          child: Text(
                            "Nothing here",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  child: const Icon(
                                    Icons.numbers,
                                    color: ColorManager.colorAccent,
                                    size: 36,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color:
                                          ColorManager.colorAccentTransparent),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tagName!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      controller.hashTagsDetailsList.isEmpty
                                          ? videosList!.length.toString() +
                                              " Videos"
                                          : controller
                                                  .hashTagsDetailsList.length
                                                  .toString() +
                                              " Videos",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: ColorManager.colorAccent),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 20),
                                        child: InkWell(
                                          onTap: () async {
                                            await usersController
                                                .addToFavourites(
                                                    videoCount!, "hashtag", 1);
                                          },
                                          child: RichText(
                                            text: const TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Icon(
                                                    Icons.bookmark,
                                                    size: 18,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: "  Add to Favourites",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: ColorManager
                                                            .colorAccent,
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ))
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              width: Get.width,
                              height: 50,
                              child: const Divider(
                                thickness: 1,
                              ),
                            ),
                            controller.hashTagsDetailsList.isEmpty
                                ? Flexible(
                                    child: GridView.count(
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    childAspectRatio: Get.width / Get.height,
                                    mainAxisSpacing: 5,
                                    children: List.generate(
                                        videosList!.length,
                                        (videoIndex) => Stack(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      List<PublicVideos>
                                                          videosList1 = [];
                                                      videosList!
                                                          .forEach((element) {
                                                        var user = PublicUser(
                                                            id: element
                                                                .user?.id,
                                                            name: element
                                                                .user?.name,
                                                            facebook: element
                                                                .user?.facebook,
                                                            firstName: element
                                                                .user
                                                                ?.firstName,
                                                            lastName: element
                                                                .user?.lastName,
                                                            username: element
                                                                .user?.username,
                                                            likes: element.likes
                                                                .toString(),
                                                            isfollow: element
                                                                .isfollow);
                                                        videosList1
                                                            .add(PublicVideos(
                                                          id: element.id,
                                                          video: element.video,
                                                          description: element
                                                              .description,
                                                          sound: element.sound,
                                                          soundName:
                                                              element.soundName,
                                                          soundCategoryName: element
                                                              .soundCategoryName,
                                                          soundOwner: element
                                                              .soundOwner,
                                                          filter:
                                                              element.filter,
                                                          likes: element.likes,
                                                          videoLikeStatus: 0,
                                                          views: element.views,
                                                          gifImage:
                                                              element.gifImage,
                                                          speed: element.speed,
                                                          comments:
                                                              element.comments,
                                                          isDuet: "no",
                                                          duetFrom: "",
                                                          isCommentable: "yes",
                                                          user: user,
                                                        ));
                                                      });
                                                      Get.to(VideoPlayerItem(
                                                        videosList: videosList1,
                                                        position: index,
                                                      ));
                                                      // Get.to(
                                                      //     VideoPlayerScreen(
                                                      //   isLock: false,
                                                      //   isFav: false,
                                                      //   isFeed: false,
                                                      //   position: videoIndex,
                                                      //   hashTagVideos: controller
                                                      //       .hashTagsDetailsList,
                                                      // ));
                                                    },
                                                    child: Card(
                                                      elevation: 10,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: imgNet(RestUrl
                                                                  .gifUrl +
                                                              videosList![index]
                                                                  .gifImage
                                                                  .toString())),
                                                    )),
                                                Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              const WidgetSpan(
                                                                child: Icon(
                                                                  Icons
                                                                      .play_circle,
                                                                  size: 18,
                                                                  color: ColorManager
                                                                      .colorAccent,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                  text: " " +
                                                                      videosList![
                                                                              index]
                                                                          .views
                                                                          .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16)),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                              ],
                                            )),
                                  ))
                                : Flexible(
                                    child: GridView.count(
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    childAspectRatio: Get.width / Get.height,
                                    mainAxisSpacing: 5,
                                    children: List.generate(
                                        controller.hashTagsDetailsList.length,
                                        (videoIndex) => Stack(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      List<PublicVideos>
                                                          videosList1 = [];
                                                      controller
                                                          .hashTagsDetailsList
                                                          .forEach((element) {
                                                        var user = PublicUser(
                                                          id: element.user?.id,
                                                          name: element
                                                              .user?.name,
                                                          facebook: element
                                                              .user?.facebook,
                                                          firstName: element
                                                              .user?.firstName,
                                                          lastName: element
                                                              .user?.lastName,
                                                          username: element
                                                              .user?.username,
                                                          isfollow: 0,
                                                        );
                                                        videosList1
                                                            .add(PublicVideos(
                                                          id: element.id,
                                                          video: element.video,
                                                          description: element
                                                              .description,
                                                          sound: element.sound,
                                                          soundName:
                                                              element.soundName,
                                                          soundCategoryName: element
                                                              .soundCategoryName,
                                                          soundOwner: element
                                                              .soundOwner,
                                                          filter:
                                                              element.filter,
                                                          likes: element.likes,
                                                          views: element.views,
                                                          gifImage:
                                                              element.gifImage,
                                                          speed: element.speed,
                                                          comments:
                                                              element.comments,
                                                          isDuet: "no",
                                                          duetFrom: "",
                                                          isCommentable: "yes",
                                                          user: user,
                                                        ));
                                                      });
                                                      Get.to(VideoPlayerItem(
                                                        videosList: videosList1,
                                                        position: index,
                                                      ));
                                                      // Get.to(
                                                      //     VideoPlayerScreen(
                                                      //   isLock: false,
                                                      //   isFav: false,
                                                      //   isFeed: false,
                                                      //   position: videoIndex,
                                                      //   hashTagVideos: controller
                                                      //       .hashTagsDetailsList,
                                                      // ));
                                                    },
                                                    child: Card(
                                                      elevation: 10,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: imgNet(RestUrl
                                                                  .gifUrl +
                                                              controller
                                                                  .hashTagsDetailsList[
                                                                      index]
                                                                  .gifImage
                                                                  .toString())),
                                                    )),
                                                Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              const WidgetSpan(
                                                                child: Icon(
                                                                  Icons
                                                                      .play_circle,
                                                                  size: 18,
                                                                  color: ColorManager
                                                                      .colorAccent,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                  text: " " +
                                                                      controller
                                                                          .hashTagsDetailsList[
                                                                              index]
                                                                          .views
                                                                          .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16)),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                              ],
                                            )),
                                  ))
                          ],
                        ),
                      )

                // : StaggeredGridView.countBuilder(
                //     staggeredTileBuilder: (index) => index % 2 == 0
                //         ? const StaggeredTile.count(0, 1)
                //         : const StaggeredTile.count(1, 1),
                //     physics: const NeverScrollableScrollPhysics(),
                //     //cross axis cell count
                //     mainAxisSpacing: 8,
                //     // vertical spacing between items
                //     crossAxisSpacing: 8,
                //     // horizontal spacing between items
                //     crossAxisCount: 3,
                //     shrinkWrap: true,
                //     itemCount: controller.searchList.length,
                //     itemBuilder: (context, index) => Wrap(
                //       children: ,
                //     ),
                //   ),
                ),
          ),
        ));
  }
}
