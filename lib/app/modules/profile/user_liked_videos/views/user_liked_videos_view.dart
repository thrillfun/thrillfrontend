import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/rest/models/user_details_model.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_liked_videos.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_liked_videos_controller.dart';

class UserLikedVideosView extends GetView<UserLikedVideosController> {
  const UserLikedVideosView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => state!.isEmpty
          ? NoSearchResult(
              text: "No Liked Videos!",
            )
          : Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: GridView.count(
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    children: List.generate(
                        state!.length,
                        (index) => GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.LIKED_VIDEO_PLAYER,
                                    arguments: {
                                      "liked_videos": state,
                                      "init_page": index
                                    });
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  imgNet(
                                      '${RestUrl.gifUrl}${controller.likedVideos[index].gifImage}'),
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
                                                        controller
                                                            .likedVideos[index]
                                                            .views!
                                                            .formatViews(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            )),
                  ),
                ))
              ],
            ),
      onLoading: Column(
        children: [
          Expanded(child: loader()),
        ],
      ),
      onError: (error) => NoLikedVideos(),
      onEmpty: NoLikedVideos(),
    );
  }
}
