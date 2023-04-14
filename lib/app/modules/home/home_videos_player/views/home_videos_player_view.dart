import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/app/utils/color_manager.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/home_videos_player_controller.dart';

class HomeVideosPlayerView extends GetView<HomeVideosPlayerController> {
  const HomeVideosPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() => controller.videoScreens[controller.selectedIndex.value]),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        controller.listOfScreens.length,
                        (index) => Obx(() => InkWell(
                            onTap: () => controller.selectedIndex.value = index,
                            child: Text(
                              controller.listOfScreens[index],
                              style: TextStyle(
                                  color: index == controller.selectedIndex.value
                                      ? Colors.white
                                      : ColorManager.colorAccent,
                                  fontSize:
                                      index == controller.selectedIndex.value
                                          ? 22
                                          : 16),
                            ))),
                      )),
                ),
                InkWell(
                  onTap: () => Get.toNamed(Routes.CAMERA,arguments: {"sound_url":"".obs,"sound_owner":GetStorage().read("name").toString().isEmpty?GetStorage().read("username").toString().obs:GetStorage().read("name").toString().obs}),
                  child: Icon(IconlyBroken.camera,color: Colors.white,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
