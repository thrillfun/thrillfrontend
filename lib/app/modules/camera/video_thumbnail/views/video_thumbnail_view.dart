import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../controllers/video_thumbnail_controller.dart';

class VideoThumbnailView extends GetView<VideoThumbnailController> {
  const VideoThumbnailView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Thumbnail'),
        centerTitle: true,
      ),
      body: controller.obx(
          (state) => Stack(
                children: [
                  InkWell(
                    onTap: () async {},
                    child: Obx(() =>
                        Image.file(File(controller.selectedThumbnail.value))),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: Get.height / 8,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: controller.entities.length,
                          itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  controller.currentSelectedFrame.value = index;
                                  controller.selectedThumbnail.value =
                                      controller.entities[index].path ?? "";
                                },
                                child: Obx(() => Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.5,
                                              color: controller
                                                          .currentSelectedFrame
                                                          .value ==
                                                      index
                                                  ? ColorManager.colorAccent
                                                  : Colors.transparent
                                                      .withOpacity(0.0)),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                            File(controller
                                                .entities[index].path),
                                            fit: BoxFit.cover),
                                      ),
                                    )),
                              )),
                    ),
                  ),
                  Obx(() => Visibility(
                      visible: controller.currentSelectedFrame.value >= 0 &&
                          controller.currentSelectedFrame.value.isLowerThan(60),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              successToast('okay going there');
                            },
                            icon: Icon(Icons.done)),
                      )))
                ],
              ),
          onLoading: Align(
            alignment: Alignment.center,
            child: loader(),
          )),
    );
  }
}
