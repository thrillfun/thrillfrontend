import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/hash_tags_details_controller.dart';

class HashTagsDetailsView extends GetView<HashTagsDetailsController> {
  const HashTagsDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (Get.arguments["hashtag_name"] as String),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 24),
                              ),
                              Text(
                                state!.length.toString() + " Videos",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: ColorManager.colorAccent),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 20),
                                  child: InkWell(
                                    onTap: () async {
                                      await controller.addHashtagToFavourite();
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.bookmark,
                                              size: 18,
                                              color: ColorManager.colorAccent,
                                            ),
                                          ),
                                          TextSpan(
                                              text: "  Add to Favourites",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      ColorManager.colorAccent,
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
                      Expanded(
                          child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                            childAspectRatio: 0.8,
                        mainAxisSpacing: 5,
                        children: List.generate(
                            state!.length,
                            (videoIndex) => Stack(
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Get.toNamed(Routes.HASH_TAGS_VIDEO_PLAYER,arguments: {"hash_tags_videos":state,"init_page":videoIndex});
                                          // List<PublicVideos> videosList1 = [
                                          // ];
                                          // state!.forEach((element) {
                                          //   var user = PublicUser(
                                          //     id: element.user?.id,
                                          //     name: element.user?.name,
                                          //     facebook: element.user
                                          //         ?.facebook,
                                          //     firstName: element.user
                                          //         ?.firstName,
                                          //     lastName: element.user
                                          //         ?.lastName,
                                          //     username: element.user
                                          //         ?.username,
                                          //     isFollow: 0,
                                          //   );
                                          //   videosList1.add(PublicVideos(
                                          //     id: element.id,
                                          //     video: element.video,
                                          //     description: element
                                          //         .description,
                                          //     sound: element.sound,
                                          //     soundName: element.soundName,
                                          //     soundCategoryName:
                                          //     element.soundCategoryName,
                                          //     soundOwner: element
                                          //         .soundOwner,
                                          //     filter: element.filter,
                                          //     likes: element.likes,
                                          //     views: element.views,
                                          //     gifImage: element.gifImage,
                                          //     speed: element.speed,
                                          //     comments: element.comments,
                                          //     isDuet: "no",
                                          //     duetFrom: "",
                                          //     isCommentable: "yes",
                                          //     user: user,
                                          //   ));
                                          // });
                                          // Get.to(VideoPlayerItem(
                                          //   videosList: videosList1,
                                          //   position: index,
                                          // ));
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
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: imgNet(RestUrl.gifUrl +
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
                                                      Icons.play_circle,
                                                      size: 18,
                                                      color: ColorManager
                                                          .colorAccent,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text: " " +
                                                          state[videoIndex]
                                                              .views
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16)),
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
                ),
            onLoading: Container(
              child: loader(),
              height: Get.height,
              width: Get.width,
              alignment: Alignment.center,
            ),
            onEmpty: emptyListWidget(data: "No videos for this hashtag"),
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
        //   ),);

        );
  }
}
