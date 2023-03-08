import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_private_videos_controller.dart';

class UserPrivateVideosView extends GetView<UserPrivateVideosController> {
  const UserPrivateVideosView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
            (state) => state!.isEmpty
            ? Column(
          children: [emptyListWidget()],
        )
            : Column(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: GridView.count(
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: List.generate(
                        state.length,
                            (index) => GestureDetector(
                          onTap: () {
                            // Get.to(VideoPlayerScreen(
                            //   isFav: false,
                            //   isFeed: false,
                            //   isLock: true,
                            //   position: index,
                            //   privateVideos: state.value,
                            // ));
                            // Navigator.pushReplacementNamed(context, '/',
                            //     arguments: {'videoModel': privateList[index]});
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // CachedNetworkImage(
                              //     placeholder: (a, b) => const Center(
                              //       child: CircularProgressIndicator(),
                              //     ),
                              //     fit: BoxFit.cover,
                              //     imageUrl:privateList[index].gif_image.isEmpty
                              //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                              //         : '${RestUrl.gifUrl}${privateList[index].gif_image}'),
                              imgNet(
                                  '${RestUrl.gifUrl}${state[index].gifImage}'),
                              Positioned(
                                  bottom: 5,
                                  left: 5,
                                  right: 5,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                                    state[index]
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
                                  )),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                    onPressed: () {
                                      // showDeleteVideoDialog(
                                      //     videosController
                                      //         .privateVideosList![index].id!,
                                      //     videosController.privateVideosList,
                                      //     index);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: Colors.red,
                                    icon: const Icon(
                                        Icons.delete_forever_outlined)),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                child: IconButton(
                                    onPressed: () {
                                      // showPrivate2PublicDialog(privateList[index].id);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: Colors.green,
                                    icon: const Icon(Icons
                                        .published_with_changes_outlined)),
                              )
                            ],
                          ),
                        )),
                  ),
                ))
          ],
        ),
        onLoading: Column(
          children: [Expanded(child: loader())],
        ),
        onEmpty: Column(
          children: [Expanded(child: emptyListWidget())],
        ));

  }
}
