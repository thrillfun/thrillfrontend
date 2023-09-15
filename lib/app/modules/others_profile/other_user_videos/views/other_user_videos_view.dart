import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../../rest/models/user_details_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/other_user_videos_controller.dart';

class OtherUserVideosView extends GetView<OtherUserVideosController> {
  const OtherUserVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getUserVideos();
    return controller.obx(
      (state) => state!.isEmpty
          ? NoSearchResult(
              text: "No Videos!",
            )
          : Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: NotificationListener<ScrollEndNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification.metrics.pixels ==
                            scrollNotification.metrics.maxScrollExtent) {
                          controller.getPaginationAllVideos(1);
                        }
                        return true;
                      },
                      child: GridView.count(
                        padding: const EdgeInsets.all(10),
                        shrinkWrap: true,
                        controller: controller.scrollController,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        children: List.generate(
                            state!.length,
                            (index) => GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.OTHERS_PROFILE_VIDEOS,
                                        arguments: {
                                          'current_page':
                                              controller.currentPage.value,
                                          "video_id": state[index].id!,
                                          "init_page": index,
                                          "profileId":
                                              Get.arguments["profileId"]
                                        });
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      imgNet(
                                          '${RestUrl.gifUrl}${controller.userVideos[index].gifImage}'),
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
                                                          (controller
                                                                      .userVideos[
                                                                          index]
                                                                      .views ??
                                                                  0)
                                                              .formatViews(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                        shadows: <Shadow>[
                                                          Shadow(
                                                            offset: Offset(
                                                                0.0, 0.0),
                                                            blurRadius: 8.0,
                                                            color: Colors.black,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                )),
                      )),
                ))
              ],
            ),
      onLoading: profileShimmer(),
      onEmpty: emptyListWidget(),
    );
  }
}
