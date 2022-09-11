import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/top_hastag_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:get/get.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/widgets/better_video_player.dart';
import 'package:thrill/widgets/video_player_screen.dart';

class DiscoverGetx extends StatelessWidget {
  DiscoverGetx({Key? key}) : super(key: key);
  var pageIndex = 0.obs;
  bool isOnPageTurning = false;

  @override
  Widget build(BuildContext context) {
    return GetX<DiscoverController>(
        builder: (controller) => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                extendBody: true,
                body: SafeArea(
                    child: Stack(
                  children: [
                    SingleChildScrollView(
                        child: controller.hashTagsVideos.isEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                child: const Center(
                                  child: Text(
                                    "No Videos Found.",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 80),
                                child: Column(
                                  children: [
                                    CarouselSlider.builder(
                                      options: CarouselOptions(
                                        onPageChanged: ((index, reason) =>
                                            pageIndex.value = index),
                                        autoPlayAnimationDuration:
                                            const Duration(seconds: 7),
                                        autoPlayCurve: Curves.easeIn,
                                        viewportFraction: 1,
                                        enlargeCenterPage: true,
                                        enableInfiniteScroll: false,
                                        autoPlay: false,
                                      ),
                                      itemCount:
                                          controller.discoverBanners.length,
                                      itemBuilder: (context, index, realIndex) {
                                        return Stack(
                                          children: [
                                            Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Card(
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20), // if you need this
                                                    side: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: CachedNetworkImage(
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            image: DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .fill),
                                                          ),
                                                        ),
                                                        fit: BoxFit.contain,
                                                        imageUrl:
                                                            '${RestUrl.bannerUrl}${controller.discoverBanners[index].image}',
                                                      )),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Obx((() =>
                                                      CarouselIndicator(
                                                        count: controller
                                                            .discoverBanners
                                                            .length,
                                                        index: pageIndex.value,
                                                      ))),
                                                ),
                                              ],
                                            )

                                            // Align(
                                            //   alignment: Alignment.bottomCenter,
                                            //   child: Row(
                                            //       mainAxisAlignment: MainAxisAlignment.center,
                                            //       crossAxisAlignment:
                                            //           CrossAxisAlignment.center,
                                            //       children: [
                                            //         for (int i = 0;
                                            //             i < controller.discoverBanners.length;
                                            //             i++)
                                            //           Container(
                                            //               margin: const EdgeInsets.only(
                                            //                   left: 8, bottom: 8),
                                            //               height: 5,
                                            //               width: 20,
                                            //               decoration: BoxDecoration(
                                            //                   color: i == index
                                            //                       ? Colors.white
                                            //                       : Colors.grey,
                                            //                   borderRadius:
                                            //                       BorderRadius.circular(5))),
                                            //       ]),
                                            // )
                                          ],
                                        );
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: StaggeredGridView.countBuilder(
                                          staggeredTileBuilder: (index) =>
                                              index % 7 == 0
                                                  ? StaggeredTile.count(1, 2)
                                                  : StaggeredTile.count(1, 1),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          //cross axis cell count
                                          mainAxisSpacing:
                                              8, // vertical spacing between items
                                          crossAxisSpacing:
                                              8, // horizontal spacing between items
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          itemCount:
                                              controller.hashTagsVideos.length,
                                          itemBuilder: (context, index) =>
                                              InkWell(
                                                onTap: () {
                                                  // controller
                                                  //     .getVideosByHashTags(
                                                  //         controller
                                                  //             .hashTagsVideos[
                                                  //                 index]
                                                  //             .id!
                                                  //             .toInt());
                                                  // Get.to(VideoPlayerScreen(
                                                  //     controller
                                                  //         .hashTagsDetailsList));
                                                },
                                                child: Card(
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl: RestUrl
                                                                  .gifUrl +
                                                              controller
                                                                  .hashTagsVideos[
                                                                      index]
                                                                  .gifImage
                                                                  .toString())),
                                                ),
                                              )),
                                    ),
                                  ],
                                ),
                              )),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                            height: 5,
                          ),
                          GlassContainer(
                            color: Colors.black.withOpacity(0.3),
                            blur: 5,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                  onTap: () {
                                    Get.dialog(GlassContainer(
                                      child: Column(
                                        children: [
                                          Text("Hello this is just for example")
                                        ],
                                      ),
                                    ));
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

                          Flexible(
                              child: SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemCount: controller.hasTagsList.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 5),
                                  child: GlassContainer(
                                    blur: 10,
                                    shadowColor: Colors.transparent,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.4)),
                                    color: Colors.black.withOpacity(0.3),
                                    child: InkWell(
                                        onTap: () {
                                          controller.getVideosByHashTags(
                                              controller
                                                  .hasTagsList[index].hashtagId!
                                                  .toInt());

                                          Get.to(HashTagsScreen());
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            margin: const EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                            ),
                                            child: Text(
                                              '#' +
                                                  controller.hasTagsList[index]
                                                      .hashtagName
                                                      .toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ))),
                                  )),
                            ),
                          ))

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
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
