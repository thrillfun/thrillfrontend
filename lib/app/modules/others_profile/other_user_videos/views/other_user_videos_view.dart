import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../../rest/models/user_details_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/other_user_videos_controller.dart';

class OtherUserVideosView extends GetView<OtherUserVideosController> {
  const OtherUserVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
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
                          Get.toNamed(Routes.OTHERS_PROFILE_VIDEOS,
                              arguments: {"video_list": state,"init_page":index});
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.play_circle,
                                              size: 18,
                                              color: ColorManager.colorAccent,
                                            ),
                                          ),
                                          TextSpan(
                                              text: " " +
                                                  controller
                                                      .userVideos[index].views
                                                      .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
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
      onEmpty: emptyListWidget(),
    );
  }
}
