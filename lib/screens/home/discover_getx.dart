import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';

class DiscoverGetx extends StatelessWidget {
  DiscoverGetx({Key? key}) : super(key: key);
  var pageIndex = 0.obs;
  bool isOnPageTurning = false;

  @override
  Widget build(BuildContext context) {
    return GetX<DiscoverController>(
      builder: (controller) => controller.isLoading.value
          ? Container(
              height: Get.height,
              width: Get.width,
              alignment: Alignment.center,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              decoration: const BoxDecoration(gradient: gradient),
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBody: true,
                  body: SafeArea(
                      child: Stack(
                    children: [
                      SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: const Center(
                                    child: Text(
                                      "Getting videos.",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.only(top: 80),
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
                                        itemBuilder:
                                            (context, index, realIndex) {
                                          return Stack(
                                            children: [
                                              Stack(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                children: [
                                                  Card(
                                                    elevation: 5,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // if you need this
                                                      side: const BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child:
                                                            CachedNetworkImage(
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              errorWidget(),
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
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
                                                          index:
                                                              pageIndex.value,
                                                        ))),
                                                  ),
                                                ],
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 20),
                                        child: StaggeredGridView.countBuilder(
                                            staggeredTileBuilder: (index) =>
                                                index % 7 == 0
                                                    ? const StaggeredTile.count(
                                                        1, 2)
                                                    : const StaggeredTile.count(
                                                        1, 1),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            //cross axis cell count
                                            mainAxisSpacing: 8,
                                            // vertical spacing between items
                                            crossAxisSpacing: 8,
                                            // horizontal spacing between items
                                            crossAxisCount: 3,
                                            shrinkWrap: true,
                                            itemCount:
                                                controller.hasTagsList.length,
                                            itemBuilder: (context, index) =>
                                                InkWell(
                                                  onTap: () async {
                                                    await controller
                                                        .getVideosByHashTags(
                                                            controller
                                                                .hasTagsList[
                                                                    index]
                                                                .hashtagId!
                                                                .toInt());

                                                    Get.to(VideoPlayerScreen(
                                                      isFav: false,
                                                      isLock: false,
                                                      isFeed: false,
                                                      position: index,
                                                      hashTagVideos: controller
                                                          .searchList[index]
                                                          .videos,
                                                    ));
                                                  },
                                                  child: Card(
                                                    elevation: 8,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                errorWidget(),
                                                            imageUrl: RestUrl
                                                                    .gifUrl +
                                                                controller
                                                                    .hashTagsVideos[
                                                                        index]
                                                                    .gifImage!
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
                              color: ColorManager.colorAccent.withOpacity(0.5),
                              blur: 5,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: InkWell(
                                    onTap: () {
                                      Get.to(SearchGetx());
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
                                      color: ColorManager.colorAccent
                                          .withOpacity(0.5),
                                      child: InkWell(
                                          onTap: () {
                                            // controller.getVideosByHashTags(
                                            //     controller.hasTagsList[index]
                                            //         .hashtagId!
                                            //         .toInt());

                                            Get.to(HashTagsScreen(controller
                                                .hasTagsList[index].hashtagName
                                                .toString()));
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
                  )))),
    );
  }
}
