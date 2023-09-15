import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_liked_videos.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

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
            ? NoSearchResult(
                text: "No Private Videos!",
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
                            controller.getPaginationAllVideos();
                            return true;
                          }
                          return false;
                        },
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
                                      Get.toNamed(Routes.PRIVATE_VIDEOS_PLAYER,
                                          arguments: {
                                            "private_videos": state,
                                            "init_page": index
                                          });
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
                                                                  .views!
                                                                  .formatViews(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      16)),
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
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        InkWell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Row(
                                                              children: const [
                                                                Icon(
                                                                  IconlyBroken
                                                                      .delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Delete Video",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
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
                                                                titleStyle: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                                confirm:
                                                                    InkWell(
                                                                  child:
                                                                      Container(
                                                                    width: Get
                                                                        .width,
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
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
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
                                                                  child:
                                                                      Container(
                                                                    width: Get
                                                                        .width,
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
                                                                                FontWeight.w700,
                                                                            color: Colors.white)),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  onTap: () {
                                                                    if (Get
                                                                        .isDialogOpen!) {
                                                                      Get.back();
                                                                    }
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ));
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(
                                                          height: 2,
                                                        ),
                                                        InkWell(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Row(
                                                              children: const [
                                                                Icon(
                                                                  IconlyBroken
                                                                      .lock,
                                                                  color: ColorManager
                                                                      .colorAccent,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    "Make video public",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w700))
                                                              ],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Get.defaultDialog(
                                                                content: const Text(
                                                                    "you want to public this video?"),
                                                                title:
                                                                    "Are your sure?",
                                                                titleStyle: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                                confirm:
                                                                    InkWell(
                                                                  child:
                                                                      Container(
                                                                    width: Get
                                                                        .width,
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
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  onTap: () => controller
                                                                      .makeVideoPrivateOrPublic(
                                                                          state[index]
                                                                              .id!,
                                                                          "Public")
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
                                                                  child:
                                                                      Container(
                                                                    width: Get
                                                                        .width,
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
                                                                                FontWeight.w700,
                                                                            color: Colors.white)),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                  ),
                                                                  onTap: () {
                                                                    if (Get
                                                                        .isDialogOpen!) {
                                                                      Get.back();
                                                                    }
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ));
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              color: Colors.red,
                                              icon: const Icon(
                                                  Icons.more_vert_outlined)),
                                        )
                                      ],
                                    ),
                                  )),
                        )),
                  ))
                ],
              ),
        onLoading: profileShimmer(),
        onEmpty: Column(
          children: [Expanded(child: NoLikedVideos())],
        ));
  }
}
