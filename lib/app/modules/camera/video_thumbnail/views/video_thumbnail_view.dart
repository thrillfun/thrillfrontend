import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:better_player/better_player.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';
import '../../controllers/camera_controller.dart';
import '../controllers/video_thumbnail_controller.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

class VideoThumbnailView extends GetView<VideoThumbnailController> {
  const VideoThumbnailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cameraController = Get.find<CameraController>();
    var isLocalSound = false.obs;
    controller.initialiseVideoTrimmer(Get.arguments['video_file']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          // Align(
          //   alignment: Alignment.topRight,
          //   child: Container(
          //     child: InkWell(
          //       child: Text('Done'),
          //       onTap: () async {
          //         await controller.trimmer.saveTrimmedVideo(
          //             startValue: controller.startValue.value,
          //             endValue: controller.endValue.value,
          //             storageDir: StorageDir.applicationDocumentsDirectory,
          //             videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
          //             onSave: (videoFile) async {
          //               if (videoFile != null) {
          //                 controller.openGalleryEditor(videoFile);
          //               }
          //             });
          //       },
          //     ),
          //   ),
          // ),
          Stack(
            children: [
              Obx(() => controller.isInitialised.isTrue?Align(child: VideoViewer(trimmer: controller.trimmer!),
                alignment: Alignment.center,):CircularProgressIndicator()),
              Obx(() => Visibility(
                  visible:  controller.isInitialised.isTrue,
                  child: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle,color: ColorManager.colorAccent.withOpacity(0.3)),
                  child: IconButton(
                      onPressed: () {
                        if(controller.trimmer!=null && controller.trimmer!.videoPlayerController!=null){
                          controller.trimmer!.videoPlayerController!.value.isPlaying
                              ? controller.trimmer!.videoPlayerController!.pause()
                              : controller.trimmer!.videoPlayerController!.play();
                          controller.trimmer!.videoPlayerController!.value.isPlaying
                              ? controller.isVideoPlaying.value = true
                              : controller.isVideoPlaying.value = false;
                        }
                      },
                      icon: Obx(() => controller.isVideoPlaying.isTrue
                          ? Icon(Icons.pause,color: Colors.white,)
                          : Icon(Icons.play_arrow,color: Colors.white,))),),
              )))
            ],
          ),
          Visibility(
            visible: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TrimViewer(
                trimmer: controller.trimmer!,
                viewerHeight: 50.0,
                viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: const Duration(seconds: 60),
                onChangeStart: (value) =>
                controller.startValue.value = value,
                onChangeEnd: (value) => controller.endValue.value = value,
              ),
            ),
          ),
          // Obx(() => ),
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [InkWell(
            child: Icon(Icons.crop),
            onTap: () async {

              if(controller.endValue<5){
                await controller.openGalleryEditor(Get.arguments['video_file'],tool: imgly.Tool.trim
                ).then((value) async {
                  await controller.initialiseVideoTrimmer(value.video);
                });

              }
              else{
                await controller.trimmer?.saveTrimmedVideo(
                    startValue: controller.startValue.value,
                    endValue: controller.endValue.value,
                    storageDir: StorageDir.temporaryDirectory,
                    videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                    onSave: (videoFile) async {
                      if (videoFile != null) {
                        controller.openGalleryEditor(videoFile,tool: imgly.Tool.trim
                        );
                      }
                    });
              }

            },
          ),
              InkWell(
                child: Icon(Icons.library_music),
                onTap: () async {
                  if(controller.endValue<5){
                    controller.openGalleryEditor(Get.arguments['video_file'],tool: imgly.Tool.audio
                    )
                    .then((value) {
                     if(value!=null){
                      controller.initialiseVideoTrimmer(value.video);
                     }
                    });

                  }
                  else{
                    await controller.trimmer!.saveTrimmedVideo(
                        startValue: controller.startValue.value,
                        endValue: controller.endValue.value,
                        storageDir: StorageDir.applicationDocumentsDirectory,
                        videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                        onSave: (videoFile) async {
                          if (videoFile != null) {
                            controller.openGalleryEditor(videoFile,tool: imgly.Tool.audio
                            );
                          }
                        });
                  }
                  // await controller.trimmer.saveTrimmedVideo(
                  //     startValue: controller.startValue.value,
                  //     endValue: controller.endValue.value,
                  //     storageDir: StorageDir.applicationDocumentsDirectory,
                  //     videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                  //     onSave: (videoFile) async {
                  //       if (videoFile != null) {
                  //         controller.openGalleryEditor(videoFile,tool: imgly.Tool.audio
                  //         );
                  //       }
                  //     });
                },
              ),InkWell(
                child: Icon(Icons.tag_faces_sharp),
                onTap: () async {
                  await controller.trimmer!.saveTrimmedVideo(
                      startValue: controller.startValue.value,
                      endValue: controller.endValue.value,
                      storageDir: StorageDir.applicationDocumentsDirectory,
                      videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                      onSave: (videoFile) async {
                        if (videoFile != null) {
                          controller.openGalleryEditor(videoFile,tool: imgly.Tool.sticker
                          );
                        }
                      });
                },
              ),InkWell(
                child: Icon(Icons.font_download),
                onTap: () async {

                  if(controller.endValue<5){
                    controller.openGalleryEditor(Get.arguments['video_file'], tool: imgly.Tool.textDesign
                    )
                        .then((value) {
                      if(value!=null){
                        controller.initialiseVideoTrimmer(value.video);
                      }
                    });

                  }
                  else{
                    await controller.trimmer!.saveTrimmedVideo(
                        startValue: controller.startValue.value,
                        endValue: controller.endValue.value,
                        storageDir: StorageDir.applicationDocumentsDirectory,
                        videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                        onSave: (videoFile) async {
                          if (videoFile != null) {
                            controller.openGalleryEditor(videoFile,tool: imgly.Tool.textDesign
                            );
                          }
                        });
                  }
                  // await controller.trimmer!.saveTrimmedVideo(
                  //     startValue: controller.startValue.value,
                  //     endValue: controller.endValue.value,
                  //     storageDir: StorageDir.applicationDocumentsDirectory,
                  //     videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                  //     onSave: (videoFile) async {
                  //       if (videoFile != null) {
                  //         controller.openGalleryEditor(videoFile,tool: imgly.Tool.textDesign
                  //         );
                  //       }
                  //     });
                },
              ),InkWell(
                child: Icon(Icons.edit_road),
                onTap: () async {
                  await controller.trimmer!.saveTrimmedVideo(
                      startValue: controller.startValue.value,
                      endValue: controller.endValue.value,
                      storageDir: StorageDir.applicationDocumentsDirectory,
                      videoFileName: '${DateTime.now().millisecondsSinceEpoch}',
                      onSave: (videoFile) async {
                        if (videoFile != null) {
                          controller.openGalleryEditor(videoFile,tool: imgly.Tool.filter
                          );
                        }
                      });
                },
              ),],)
          ),
        ],
      ),
    );
  }
}
