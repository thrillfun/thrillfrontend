import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';

class HashTagsScreen extends StatelessWidget {
  HashTagsScreen({this.tagName});

  String? tagName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            loadSvgCacheImage("background_2.svg"),
            GetX<DiscoverController>(
                builder: (controller) => controller.isHashTagsLoading.value
                    ? Container(
                        height: Get.height,
                        width: Get.width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : controller.hashTagsDetailsList.isEmpty
                        ? SizedBox(
                            height: Get.height,
                            child: const Center(
                              child: Text(
                                'No Videos Found for related hashtag',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 20,),
                              Text(
                                tagName ?? "",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Flexible(
                                  child: GridView(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 200),
                                children: List.generate(
                                    controller.hashTagsDetailsList.length,
                                    (videoIndex) => InkWell(
                                        onTap: () {
                                          Get.to(VideoPlayerScreen(
                                            isLock: false,
                                            isFav: false,
                                            isFeed: false,
                                            position: videoIndex,
                                            hashTagVideos:
                                                controller.hashTagsDetailsList,
                                          ));
                                        },
                                        child: Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: RestUrl.gifUrl +
                                                      controller
                                                          .hashTagsDetailsList[
                                                              index]
                                                          .gifImage
                                                          .toString())),
                                        ))),
                              ))
                            ],
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
                )
          ],
        ));
  }
}
