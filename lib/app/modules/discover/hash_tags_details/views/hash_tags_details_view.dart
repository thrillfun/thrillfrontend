import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/hash_tags_details_controller.dart';

class HashTagsDetailsView extends GetView<HashTagsDetailsController> {
  const HashTagsDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getVideosByHashTags();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tending Hashtag",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 24)),
          elevation: 0,
        ),
        body: controller.obx(
            (state) => Container(
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
                                color: ColorManager.colorAccentTransparent),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              (Get.arguments["hashtag_name"] as String)
                                  .replaceAll("#", ""),
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColorManager.colorAccent),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () async {
                              await controller.addHashtagToFavourite();
                            },
                            child: Obx(() => Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.bookmark,
                                          size: 18,
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                      controller.isFavouriteHastag.isFalse
                                          ? TextSpan(
                                              text: "  Add to Favourites",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      ColorManager.colorAccent,
                                                  fontSize: 14))
                                          : TextSpan(
                                              text: "  Remove from favourites",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      ColorManager.colorAccent,
                                                  fontSize: 14)),
                                    ],
                                  ),
                                )),
                          )),
                      SizedBox(
                        width: Get.width,
                        height: 50,
                        child: const Divider(
                          thickness: 1,
                        ),
                      ),
                      Expanded(
                          child: NotificationListener<ScrollEndNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent) {
                            controller.getPaginationVideosByHashTags();
                          }
                          return true;
                        },
                        child: controller.obx(
                            (state) => GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  childAspectRatio: 0.8,
                                  mainAxisSpacing: 5,
                                  children: List.generate(state!.length,
                                      (videoIndex) {
                                    return state[videoIndex].id == null
                                        ? Container(
                                            color: Colors.red,
                                            width: controller
                                                .bannerAd!.size.width
                                                .toDouble(),
                                            height: controller
                                                .bannerAd!.size.height
                                                .toDouble(),
                                            child: null,
                                          )
                                        : Stack(
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    Get.toNamed(
                                                        Routes
                                                            .HASH_TAGS_VIDEO_PLAYER,
                                                        arguments: {
                                                          'current_page':
                                                              controller
                                                                  .currentPage
                                                                  .value,
                                                          "video_id":
                                                              state[videoIndex]
                                                                  .id,
                                                          "hashtagId":
                                                              Get.arguments[
                                                                  "hashtagId"],
                                                          "init_page":
                                                              videoIndex
                                                        });
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
                                                            state[videoIndex]
                                                                .gifImage
                                                                .toString())),
                                                  )),
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
                                                                Icons
                                                                    .play_circle,
                                                                size: 18,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                                text: " " +
                                                                    NumberFormat
                                                                            .compact()
                                                                        .format(state[videoIndex]
                                                                            .views)
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        14)),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          );
                                  }),
                                ),
                            onLoading: null,
                            onEmpty: emptyListWidget(
                                data: "No videos for this hashtag")),
                      ))
                    ],
                  ),
                ),
            onLoading: hashtagsViewShimmer())

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
        //   ),);

        );
  }
}
