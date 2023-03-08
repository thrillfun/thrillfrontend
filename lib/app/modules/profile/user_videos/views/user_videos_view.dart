import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_videos_controller.dart';

class UserVideosView extends GetView<UserVideosController> {
  const UserVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                itemCount: state!.length,
                itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        // Get.to(VideoPlayerScreen(
                        //   isFav: false,
                        //   isFeed: true,
                        //   isLock: false,
                        //   position: index,
                        //   userVideos: controller.userVideos,
                        // ));
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imgNet('${RestUrl.gifUrl}${state[index].gifImage}'),
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
                                              state[index].views.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                    ],
                                  ))
                                ],
                              )),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                      content: const Text(
                                          "you want to delete this video?"),
                                      title: "Are your sure?",
                                      confirm: InkWell(
                                        child: Container(
                                          width: Get.width,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.red.shade400),

                                          child: Text("Yes"),
                                          padding: EdgeInsets.all(10),
                                        ),
                                        onTap: () => controller
                                            .deleteUserVideo(state[index].id!),
                                      ),
                                      cancel: InkWell(
                                        child: Container(
                                          width: Get.width,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.green),
                                          child: Text("Cancel"),alignment: Alignment.center,
                                          padding: EdgeInsets.all(10),
                                        ),
                                        onTap: () => Get.back(),
                                      ));
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: Colors.red,
                                icon:
                                    const Icon(Icons.delete_forever_outlined)),
                          )
                        ],
                      ),
                    )),
          ))
        ],
      ),
      onLoading: Column(
        children: [
          Expanded(
            child: loader(),
          )
        ],
      ),
      onError: (error) => Column(
        children: [emptyListWidget()],
      ),
      onEmpty: Column(
        children: [emptyListWidget()],
      ),
    );
  }
}
