import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';

class HashTagsScreen extends StatelessWidget {
  HashTagsScreen(this.name);

  String name;

  @override
  Widget build(BuildContext context) {
    discoverController.searchHashtags(name);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            loadSvgCacheImage("background_2.svg"),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      "#" + name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.topCenter,
                  ),
                  GetX<DiscoverController>(
                    builder: (controller) => controller
                            .isSearchingHashtags.value
                        ? Container(
                            height: Get.height,
                            width: Get.width,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : controller.searchList.isEmpty
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
                            : StaggeredGridView.countBuilder(
                                staggeredTileBuilder: (index) => index % 7 == 0
                                    ? const StaggeredTile.count(1, 2)
                                    : const StaggeredTile.count(1, 1),
                                physics: const NeverScrollableScrollPhysics(),
                                //cross axis cell count
                                mainAxisSpacing: 8,
                                // vertical spacing between items
                                crossAxisSpacing: 8,
                                // horizontal spacing between items
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                itemCount: controller.searchList.length,
                                itemBuilder: (context, index) => Wrap(
                                  children: List.generate(
                                      controller
                                          .searchList[index].videos!.length,
                                      (videoIndex) => InkWell(
                                          onTap: () {
                                            Get.to(VideoPlayerScreen(
                                              isLock: false,
                                              isFav: false,
                                              isFeed: false,
                                              position: videoIndex,
                                              hashTagVideos: controller
                                                  .searchList![index].videos,
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
                                                            .searchList[index]
                                                            .videos![videoIndex]
                                                            .gifImage
                                                            .toString())),
                                          ))),
                                ),
                              ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
