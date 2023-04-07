import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
      (state) => Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
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
                        Get.toNamed(Routes.PROFILE_VIDEOS, arguments: {
                          "video_list": state,
                          "init_page": index
                        });
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
                                                    "you want to private this video?"),
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
                                                      state[index].id!,"Private")
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
          ))
        ],
      ),
      onLoading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [loader()],
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
