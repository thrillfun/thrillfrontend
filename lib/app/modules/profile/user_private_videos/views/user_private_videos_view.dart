import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.lock_clock)],
              )
            : Column(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
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
                                            Get.bottomSheet(Scaffold(
                                              body: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      child: Text("Delete Video",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                                                      onTap: () {
                                                        Get.defaultDialog(
                                                            content: const Text(
                                                                "you want to delete this video?"),
                                                            title: "Are your sure?",
                                                            titleStyle: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w700),
                                                            confirm: InkWell(
                                                              child: Container(
                                                                width: Get.width,
                                                                alignment: Alignment.center,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(10),
                                                                    color: Colors
                                                                        .red.shade400),
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight.w700,
                                                                      color: Colors.white),
                                                                ),
                                                                padding: EdgeInsets.all(10),
                                                              ),
                                                              onTap: () => controller
                                                                  .deleteUserVideo(
                                                                  state[index].id!)
                                                                  .then((value) =>
                                                                  Get.back()),
                                                            ),
                                                            cancel: InkWell(
                                                              child: Container(
                                                                width: Get.width,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(10),
                                                                    color: Colors.green),
                                                                child: Text("Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight.w700,
                                                                        color:
                                                                        Colors.white)),
                                                                alignment: Alignment.center,
                                                                padding: EdgeInsets.all(10),
                                                              ),
                                                              onTap: () => Get.back(),
                                                            ));
                                                      },
                                                    ),
                                                    SizedBox(height: 10,),
                                                    InkWell(
                                                      child: Text("Make video private",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700)),
                                                      onTap: () {
                                                        Get.defaultDialog(
                                                            content: const Text(
                                                                "you want to public this video?"),
                                                            title: "Are your sure?",
                                                            titleStyle: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w700),
                                                            confirm: InkWell(
                                                              child: Container(
                                                                width: Get.width,
                                                                alignment: Alignment.center,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(10),
                                                                    color: Colors
                                                                        .red.shade400),
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight.w700,
                                                                      color: Colors.white),
                                                                ),
                                                                padding: EdgeInsets.all(10),
                                                              ),
                                                              onTap: () => controller
                                                                  .makeVideoPrivateOrPublic(
                                                                  state[index].id!,"Public")
                                                                  .then((value) =>
                                                                  Get.back()),
                                                            ),
                                                            cancel: InkWell(
                                                              child: Container(
                                                                width: Get.width,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(10),
                                                                    color: Colors.green),
                                                                child: Text("Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight.w700,
                                                                        color:
                                                                        Colors.white)),
                                                                alignment: Alignment.center,
                                                                padding: EdgeInsets.all(10),
                                                              ),
                                                              onTap: () => Get.back(),
                                                            ));
                                                      },
                                                    )
                                                  ],
                                                ),),
                                            ));
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: Colors.red,
                                          icon: const Icon(Icons.more_vert_outlined)),
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
