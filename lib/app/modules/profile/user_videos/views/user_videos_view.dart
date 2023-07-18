import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/user_videos_controller.dart';

class UserVideosView extends GetView<UserVideosController> {
  const UserVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => state!.isEmpty
          ? NoSearchResult(
              text: "No User Videos!",
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
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                Get.toNamed(Routes.PROFILE_VIDEOS, arguments: {
                                  "video_list": state,
                                  "init_page": index
                                });
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  imgNet(
                                      '${RestUrl.gifUrl}${state[index].gifImage}'),
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
                                                  color:
                                                      ColorManager.colorAccent,
                                                ),
                                              ),
                                              TextSpan(
                                                  text: " " +
                                                      state[index]
                                                          .views!
                                                          .formatViews(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                          Get.bottomSheet(
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Row(
                                                          children: const [
                                                            Icon(
                                                              IconlyBroken
                                                                  .delete,
                                                              color: Colors.red,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Delete Video",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Get.defaultDialog(
                                                            content: const Text(
                                                                "you want to delete this video?"),
                                                            title:
                                                                "Are your sure?",
                                                            titleStyle:
                                                                const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                            confirm: InkWell(
                                                              child: Container(
                                                                width:
                                                                    Get.width,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .red
                                                                        .shade400),
                                                                child:
                                                                    const Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                              ),
                                                              onTap: () => controller
                                                                  .deleteUserVideo(
                                                                      state[index]
                                                                          .id!)
                                                                  .then(
                                                                      (value) {
                                                                if (Get
                                                                    .isDialogOpen!) {
                                                                  Get.back();
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                              }),
                                                            ),
                                                            cancel: InkWell(
                                                              child: Container(
                                                                width:
                                                                    Get.width,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .green),
                                                                child: const Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                              ),
                                                              onTap: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                            ));
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Divider(
                                                      height: 2,
                                                    ),
                                                    InkWell(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Row(
                                                          children: const [
                                                            Icon(
                                                              IconlyBroken.lock,
                                                              color: ColorManager
                                                                  .colorAccent,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                                "Make video private",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700))
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Get.defaultDialog(
                                                            content: const Text(
                                                                "you want to private this video?"),
                                                            title:
                                                                "Are your sure?",
                                                            titleStyle:
                                                                const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                            confirm: InkWell(
                                                              child: Container(
                                                                width:
                                                                    Get.width,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .red
                                                                        .shade400),
                                                                child:
                                                                    const Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                              ),
                                                              onTap: () => controller
                                                                  .makeVideoPrivateOrPublic(
                                                                      state[index]
                                                                          .id!,
                                                                      "Private")
                                                                  .then((value) =>
                                                                      Navigator.pop(
                                                                          context)),
                                                            ),
                                                            cancel: InkWell(
                                                              child: Container(
                                                                width:
                                                                    Get.width,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .green),
                                                                child: const Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                              ),
                                                              onTap: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                            ));
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                              isScrollControlled: false,
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: Colors.red,
                                        icon: const Icon(
                                            Icons.more_vert_outlined)),
                                  )
                                ],
                              ),
                            )),
                  ),
                ))
              ],
            ),
      onLoading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [loader()],
      ),
      onError: (error) => NoSearchResult(
        text: "No User Videos!",
      ),
      onEmpty: NoSearchResult(
        text: "No User Videos!",
      ),
    );
  }
}
