import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:easy_audio_trimmer/easy_audio_trimmer.dart' as audioTrimmer;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';
import '../../controllers/camera_controller.dart';
import '../../views/camera_view.dart';
import '../controllers/video_thumbnail_controller.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

class VideoThumbnailView extends GetView<VideoThumbnailController> {
  const VideoThumbnailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cameraController = Get.find<CameraController>();
    var isLocalSound = false.obs;

    if (cameraController.selectedSound.value.isEmpty &&
        cameraController.userUploadedSound.value.isEmpty) {
      controller.initialiseVideoTrimmer(Get.arguments['video_file']);
    } else {
      controller.initialiseVideoTrimmer('${saveCacheDirectory}output.mp4');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () async {
              if (cameraController.selectedSound.value.isEmpty &&
                  cameraController.userUploadedSound.value.isEmpty) {
                await FFmpegKit.execute(
                        "-y -i ${controller.videoFile.value} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                    .then((audio) async {
                  Get.toNamed(Routes.POST_SCREEN, arguments: {
                    "sound_url": "${saveCacheDirectory}originalAudio.mp3",
                    "file_path": controller.videoFile.value,
                    "is_original": isLocalSound.isTrue
                        ? "local"
                        : cameraController.userUploadedSound.isNotEmpty
                            ? "original"
                            : "extracted",
                    "sound_name": cameraController.soundName.value.isNotEmpty
                        ? "${cameraController.soundName.value}"
                        : null,
                    "sound_owner": cameraController.soundOwner.isEmpty
                        ? GetStorage().read("userId").toString()
                        : cameraController.soundOwner.value,
                  });
                });
              } else {
                String replaceAudio =
                    '-y -i ${controller.videoFile.value}  -i ${cameraController.selectedSound.value.isEmpty ? cameraController.userUploadedSound.value : cameraController.selectedSound.value} -map 0:v? -map 1:a -c:v copy ${saveCacheDirectory}output.mp4';

                await FFmpegKit.executeAsync(replaceAudio, (session) async {
                  var returnCode = await session.getReturnCode();
                  if (ReturnCode.isSuccess(returnCode)) {
                    Get.toNamed(Routes.POST_SCREEN, arguments: {
                      "sound_url": cameraController.selectedSound.value.isEmpty
                          ? cameraController.userUploadedSound.value
                          : cameraController.selectedSound.value,
                      "file_path": '${saveCacheDirectory}output.mp4',
                      "is_original": isLocalSound.isTrue
                          ? "local"
                          : cameraController.userUploadedSound.isNotEmpty
                              ? "original"
                              : "original",
                      "sound_name": cameraController.soundName.value.isNotEmpty
                          ? "${cameraController.soundName.value}"
                          : null,
                      "sound_owner": cameraController.soundOwner.isEmpty
                          ? GetStorage().read("userId").toString()
                          : cameraController.soundOwner.value,
                    });
                  } else {
                    errorToast(returnCode!.getValue().toString());
                  }
                }, (log) {
                  Logger().wtf(log.getMessage());
                });
                // await FFmpegKit.execute(
                //         "-y -i ${controller.videoFile.value} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                //     .then((audio) async {});
                // Get.toNamed(Routes.POST_SCREEN, arguments: {
                //   "sound_url": cameraController.selectedSound.value.isEmpty
                //       ? cameraController.userUploadedSound.value
                //       : cameraController.selectedSound.value,
                //   "file_path": controller.videoFile.value,
                //   "is_original": isLocalSound.isTrue
                //       ? "local"
                //       : cameraController.userUploadedSound.isNotEmpty
                //           ? "original"
                //           : "original",
                //   "sound_name": cameraController.soundName.value.isNotEmpty
                //       ? "${cameraController.soundName.value}"
                //       : null,
                //   "sound_owner": cameraController.soundOwner.isEmpty
                //       ? GetStorage().read("userId").toString()
                //       : cameraController.soundOwner.value,
                // });
              }
              controller.editedFile.release();
            },
            child: Row(
              children: const [
                Text(
                  'Post',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorManager.colorAccent),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: ColorManager.colorAccent,
                )
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Stack(
            children: [
              Obx(() => controller.isInitialised.isTrue
                  ? Align(
                      child: VideoViewer(trimmer: controller.trimmer!),
                      alignment: Alignment.center,
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: loader(),
                    )),
              Obx(
                () => Align(
                    alignment: Alignment.topCenter,
                    child: controller.isInitialised.isTrue
                        ? TrimViewer(
                            editorProperties: const TrimEditorProperties(
                                circlePaintColor: ColorManager.colorAccent,
                                borderPaintColor: ColorManager.colorAccent),
                            trimmer: controller.trimmer!,
                            viewerHeight: 50.0,
                            viewerWidth: 250,
                            maxVideoLength: const Duration(seconds: 60),
                            onChangeStart: (value) =>
                                controller.startValue.value = value,
                            onChangeEnd: (value) {
                              controller.endValue.value = value;
                            },
                          )
                        : loader()),
              ),
              Obx(() => Visibility(
                  visible: controller.isInitialised.isTrue,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorManager.colorAccent.withOpacity(0.3)),
                      child: IconButton(
                          onPressed: () {
                            if (controller.trimmer != null &&
                                controller.trimmer?.videoPlayerController !=
                                    null) {
                              controller.trimmer!.videoPlayerController!.value
                                      .isPlaying
                                  ? controller.trimmer?.videoPlayerController!
                                      .pause()
                                  : controller.trimmer?.videoPlayerController!
                                      .play();
                              controller.trimmer!.videoPlayerController!.value
                                      .isPlaying
                                  ? controller.isVideoPlaying.value = true
                                  : controller.isVideoPlaying.value = false;
                            }
                          },
                          icon: Obx(() => controller.isVideoPlaying.isTrue
                              ? Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ))),
                    ),
                  )))
            ],
          ),

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Obx(
          //     () => controller.isAudioTrimmerInitialised.isFalse && controller.soundTrimmer!=null
          //         ? loader()
          //         : audioTrimmer.TrimViewer(
          //       trimmer: controller.soundTrimmer!,
          //       viewerHeight: 100,
          //       viewerWidth: Get.width,
          //       durationStyle: audioTrimmer.DurationStyle.FORMAT_MM_SS,
          //       backgroundColor: Colors.blueGrey.shade200,
          //       barColor: Colors.white,
          //       durationTextStyle:
          //       TextStyle(color: Theme.of(context).primaryColor),
          //       allowAudioSelection: true ,
          //       editorProperties: audioTrimmer.TrimEditorProperties(
          //         circleSize: 5,
          //         borderPaintColor: Colors.blueGrey.shade900,
          //         borderWidth: 2,
          //         scrubberWidth: 2,
          //         borderRadius: 10,
          //         scrubberPaintColor: Colors.blueGrey,
          //         circlePaintColor: Colors.pink.shade800,
          //       ),
          //       areaProperties: audioTrimmer.TrimAreaProperties.edgeBlur(
          //           blurEdges: true, borderRadius: 10,startIcon: Icon(Icons.bar_chart),endIcon: Container(width: 5,height: Get.height,child: Icon(Icons.battery_6_bar_sharp),)),
          //       onChangeStart: (value) {
          //         controller.startValue.value = value;
          //       },
          //       onChangeEnd: (value) {
          //         controller.endValue.value = value;
          //       },
          //       onChangePlaybackState: (value) {
          //         // controller.isPlaying.value = value;
          //         // if (controller.isPlaying.isTrue) {
          //         //   controller.audioPlayer?.play();
          //         // } else {
          //         //   controller.audioPlayer?.pause();
          //         // }
          //       },
          //     ),
          //   ),
          // ),

          Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    child: Icon(Icons.crop),
                    onTap: () async {
                      Get.bottomSheet(
                        Padding(padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),child: TrimmerView(File(controller.videoFile.value)),)
                          ,
                          isScrollControlled: true);
                      // await controller.trimmer?.saveTrimmedVideo(
                      //     startValue: controller.startValue.value,
                      //     endValue: controller.endValue.value,
                      //     storageDir: StorageDir.temporaryDirectory,
                      //     outputFormat: FileFormat.mp4,
                      //     videoFileName:
                      //         '${DateTime.now().millisecondsSinceEpoch}',
                      //     onSave: (videoFile) async {
                      //       // if (videoFile != null) {
                      //       //   controller.videoFile.value = videoFile!;
                      //       //   controller.openGalleryEditor(videoFile,
                      //       //       tool: imgly.Tool.trim);
                      //       // }
                      //       if (controller.endValue.value -
                      //               controller.startValue.value <
                      //           5000) {
                      //         // await controller
                      //         //     .openGalleryEditor(controller.videoFile.value,
                      //         //     tool: imgly.Tool.trim)
                      //         //     .then((value) async {
                      //         //   controller.videoFile.value = value.video;
                      //         //   controller.initialiseVideoTrimmer(value.video!);
                      //         // });
                      //         errorToast(
                      //             'Trim is Too small atleast trim 5 seconds');
                      //       } else {
                      //         controller.initialiseVideoTrimmer(videoFile!);
                      //       }
                      //     });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Icon(Icons.library_music),
                    onTap: () async {
                      Get.bottomSheet(
                          Padding(padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),child: AudioTrimmerView(File(   cameraController.selectedSound.value.isNotEmpty
                              ? cameraController.userUploadedSound.value
                              : cameraController.selectedSound.value)),)
                          ,
                          isScrollControlled: true);
                      // if (controller.endValue.value -
                      //         controller.startValue.value <
                      //     5000) {
                      //   controller
                      //       .openGalleryEditor(controller.videoFile.value,
                      //           tool: imgly.Tool.audio)
                      //       .then((value) {
                      //     if (value != null) {
                      //       controller.videoFile.value = value.video;
                      //       controller.initialiseVideoTrimmer(value.video);
                      //     }
                      //   });
                      // } else {
                      //   await controller.trimmer.saveTrimmedVideo(
                      //       startValue: controller.startValue.value,
                      //       endValue: controller.endValue.value,
                      //       storageDir: StorageDir.temporaryDirectory,
                      //       videoFileName:
                      //           '${DateTime.now().millisecondsSinceEpoch}',
                      //       onSave: (videoFile) async {
                      //         if (videoFile != null) {
                      //           controller.videoFile.value = videoFile;
                      //           controller.openGalleryEditor(videoFile,
                      //               tool: imgly.Tool.audio);
                      //         }
                      //       });
                      // }

                      controller.initTrimmer(
                          cameraController.selectedSound.value.isEmpty
                              ? cameraController.userUploadedSound.value
                              : cameraController.selectedSound.value);

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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Icon(Icons.tag_faces_sharp),
                    onTap: () async {
                      if (controller.endValue.value -
                              controller.startValue.value <
                          5000) {
                        controller
                            .openGalleryEditor(controller.videoFile.value,
                                tool: imgly.Tool.sticker)
                            .then((value) {
                          if (value != null) {
                            controller.videoFile.value = value.video;
                            controller.initialiseVideoTrimmer(value.video);
                          }
                        });
                      } else {
                        await controller.trimmer?.saveTrimmedVideo(
                            startValue: controller.startValue.value,
                            endValue: controller.endValue.value,
                            storageDir: StorageDir.temporaryDirectory,
                            videoFileName:
                                '${DateTime.now().millisecondsSinceEpoch}',
                            onSave: (videoFile) async {
                              if (videoFile != null) {
                                controller.videoFile.value = videoFile;
                                controller.openGalleryEditor(videoFile,
                                    tool: imgly.Tool.sticker);
                              }
                            });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Icon(Icons.font_download),
                    onTap: () async {
                      if (controller.endValue.value -
                              controller.startValue.value <
                          5000) {
                        controller
                            .openGalleryEditor(controller.videoFile.value,
                                tool: imgly.Tool.textDesign)
                            .then((value) {
                          controller.videoFile.value = value.video;
                          controller.initialiseVideoTrimmer(value.video);
                        });
                      } else {
                        await controller.trimmer?.saveTrimmedVideo(
                            startValue: controller.startValue.value,
                            endValue: controller.endValue.value,
                            storageDir: StorageDir.temporaryDirectory,
                            videoFileName:
                                '${DateTime.now().millisecondsSinceEpoch}',
                            onSave: (videoFile) async {
                              if (videoFile != null) {
                                controller.videoFile.value = videoFile;
                                controller.openGalleryEditor(videoFile,
                                    tool: imgly.Tool.textDesign);
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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Icon(Icons.edit_road),
                    onTap: () async {
                      if (controller.endValue.value -
                              controller.startValue.value <
                          5000) {
                        controller
                            .openGalleryEditor(controller.videoFile.value,
                                tool: imgly.Tool.filter)
                            .then((value) async {
                          controller.videoFile.value = value.video;
                          //  await controller.trimmer!.loadVideo(videoFile: File(value!.video));
                          controller.initialiseVideoTrimmer(value.video);
                        });
                      } else {
                        await controller.trimmer?.saveTrimmedVideo(
                            startValue: controller.startValue.value,
                            endValue: controller.endValue.value,
                            storageDir: StorageDir.temporaryDirectory,
                            videoFileName:
                                '${DateTime.now().millisecondsSinceEpoch}',
                            onSave: (videoFile) async {
                              if (videoFile != null) {
                                controller.videoFile.value = videoFile;
                                controller.openGalleryEditor(videoFile,
                                    tool: imgly.Tool.filter);
                              }
                            });
                      }
                    },
                  ),
                ],
              )),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(top: 30),
              width: 160,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                onTap: () async {
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                  if (androidInfo.version.sdkInt > 31) {
                    if (await Permission.audio.isGranted) {
                      cameraController.getAlbums().then((value) =>
                          Get.bottomSheet(
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top),
                                child: SelectSoundView(
                                  context: context,
                                  animationController:
                                      cameraController.animationController,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              isScrollControlled: true));
                      // refreshAlreadyCapturedImages();
                    } else {
                      await Permission.audio.request().then((value) async {
                        cameraController.getAlbums().then((value) =>
                            Get.bottomSheet(
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top),
                                  child: SelectSoundView(
                                    context: context,
                                    animationController:
                                        cameraController.animationController,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                isScrollControlled: true));
                      });
                    }
                  } else {
                    if (await Permission.storage.isGranted) {
                      cameraController.getAlbums().then((value) =>
                          Get.bottomSheet(
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top),
                                child: SelectSoundView(
                                  context: context,
                                  animationController:
                                      cameraController.animationController,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              isScrollControlled: true));
                      // refreshAlreadyCapturedImages();
                    } else {
                      await Permission.storage.request().then((value) =>
                          cameraController.getAlbums().then((value) =>
                              Get.bottomSheet(
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).padding.top),
                                    child: SelectSoundView(
                                      context: context,
                                      animationController:
                                          cameraController.animationController,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  isScrollControlled: true)));
                    }
                  }

                  // favouritesController.getFavourites().then(
                  //       (_) async =>
                  //       soundsController.getSoundsList().then((_) {
                  //         soundsController.getAlbums();
                  //         Get.bottomSheet(SoundListBottomSheet(),
                  //             isScrollControlled: true);
                  //       }),
                  // );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Visibility(
                        visible:
                            cameraController.soundName.toString().isNotEmpty,
                        child: InkWell(
                            onTap: () {
                              cameraController.selectedSound.value = "";
                              cameraController.userUploadedSound.value = "";
                              cameraController.soundName.value = "";
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                IconlyBold.close_square,
                                color: Colors.red.shade800,
                              ),
                            )))),
                    Icon(
                      IonIcons.musical_notes_sharp,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Obx(() => Text(
                              cameraController.soundName.value.isNotEmpty
                                  ? cameraController.soundName.value
                                  : "Select Sound",
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            )))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class AudioTrimmerView extends StatefulWidget {
  final File file;

  const AudioTrimmerView(this.file, {Key? key}) : super(key: key);
  @override
  State<AudioTrimmerView> createState() => _AudioTrimmerViewState();
}

class _AudioTrimmerViewState extends State<AudioTrimmerView> {
  final audioTrimmer.Trimmer _trimmer = audioTrimmer.Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });
    await _trimmer.loadAudio(audioFile: widget.file);
    setState(() {
      isLoading = false;
    });
  }

  _saveAudio() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedAudio(
      startValue: _startValue,
      endValue: _endValue,
      audioFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Audio Trimmer"),
        ),
        body: isLoading
            ? const CircularProgressIndicator()
            : Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                  _progressVisibility ? null : () => _saveAudio(),
                  child: const Text("SAVE"),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: audioTrimmer.TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 100,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: audioTrimmer.DurationStyle.FORMAT_MM_SS,
                      backgroundColor: Theme.of(context).primaryColor,
                      barColor: Colors.white,
                      durationTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor),
                      allowAudioSelection: true,
                      editorProperties: audioTrimmer.TrimEditorProperties(
                        circleSize: 10,
                        borderPaintColor: Colors.pink,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.pink.shade800,
                      ),
                      areaProperties:
                      audioTrimmer.TrimAreaProperties.edgeBlur(blurEdges: true),
                      onChangeStart: (value) => _startValue = value,
                      onChangeEnd: (value) => _endValue = value,
                      onChangePlaybackState: (value) {
                        if (mounted) {
                          setState(() => _isPlaying = value);
                        }
                      },
                    ),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                    Icons.pause,
                    size: 80.0,
                    color: Theme.of(context).primaryColor,
                  )
                      : Icon(
                    Icons.play_arrow,
                    size: 80.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    bool playbackState =
                    await _trimmer.audioPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  var controller = Get.find<VideoThumbnailController>();
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await _trimmer
        .saveTrimmedVideo(
            startValue: controller.startValue.value,
            endValue: controller.endValue.value,
            onSave: (String? outputPath) async {
              _value = outputPath;
            })
        .then((value) {
      setState(() {
        _progressVisibility = false;
      });
    });

    return _value;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
               Padding(padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),child:  ElevatedButton(
                 onPressed: _progressVisibility
                     ? null
                     : () async {
                   _saveVideo().then((outputPath)async  {

                     await _trimmer
                         .saveTrimmedVideo(
                         startValue: controller.startValue.value,
                         endValue: controller.endValue.value,
                         onSave: (String? outputPath) async {
                           controller.videoFile.value =
                               outputPath ?? controller.videoFile.value;
                           await controller
                               .initialiseVideoTrimmer(controller.videoFile.value);
                           if(Get.isOverlaysOpen){
                             Get.back();
                           }
                           print('OUTPUT PATH: $outputPath');
                         });


                   });
                 },
                 child: Text("SAVE"),
               ),),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: controller.videoDuration.value,
                    onChangeStart: (value) =>
                        controller.startValue.value = value,
                    onChangeEnd: (value) => controller.endValue.value = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
