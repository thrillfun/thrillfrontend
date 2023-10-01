import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart' as camera;
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/supercontroller/video_editing_controller.dart';
import 'package:thrill/app/widgets/no_search_result.dart';
import 'package:torch_light/torch_light.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../main.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/custom_timer_painter.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';
import '../controllers/camera_controller.dart' as camController;

import '../select_sound/controllers/select_sound_controller.dart';

var isLocalSound = false.obs;

var vesdk = VESDK();

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraState();
}

class _CameraState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraView> {
  Timer? time;
  camera.CameraController? _controller;
  camController.CameraController cameraController =
      Get.find<camController.CameraController>();
  File? file;
  File? _imageFile;
  File? _videoFile;
  var loaderWidth = 50.0;
  var loaderHeight = 50.0;

  // Initial values
  var _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = true;
  bool _isRecordingInProgress = false;

  var isRecordingComplete = false.obs;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  camera.FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = camera.ResolutionPreset.values;

  camera.ResolutionPreset currentResolutionPreset =
      camera.ResolutionPreset.high;

  //get camera permission status and start camera

  // //check permission
  var defaultVideoSpeed = 1.0.obs;

  // List of items in our dropdown menu
  var items = [
    0.15,
    0.25,
    0.5,
    1.0,
    2.0,
    4.0,
    8.0,
  ].obs;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: _controller != null && _controller!.value.isInitialized
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).viewPadding.top),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: Get.height,
                          width: Get.width,
                          child: camera.CameraPreview(_controller!),
                        ),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: Column(
                        //     children: [
                        //       Container(
                        //         margin: EdgeInsets.symmetric(
                        //             horizontal: 10, vertical: 30),
                        //         padding: const EdgeInsets.all(10),
                        //         decoration: BoxDecoration(
                        //             shape: BoxShape.circle,
                        //             border: Border.all(
                        //                 color: ColorManager.colorAccent),
                        //             color: ColorManager.colorAccent
                        //                 .withOpacity(0.2)),
                        //         child: InkWell(
                        //           onTap: () async {
                        //             if (_currentFlashMode ==
                        //                     camera.FlashMode.off ||
                        //                 _currentFlashMode ==
                        //                     camera.FlashMode.auto) {
                        //               _controller!
                        //                   .setFlashMode(FlashMode.always);
                        //               await TorchLight.enableTorch();
                        //               setState(() {});
                        //             } else {
                        //               _controller!.setFlashMode(FlashMode.off);
                        //               await TorchLight.disableTorch();
                        //
                        //               setState(() {});
                        //             }
                        //             _currentFlashMode =
                        //                 _controller!.value.flashMode;
                        //
                        //             setState(() {});
                        //
                        //             //await openEditor();
                        //             // Get.to(VideoEditor(
                        //             //   file: _videoFile!,
                        //             // ));
                        //           },
                        //           child:
                        //               _currentFlashMode == camera.FlashMode.off
                        //                   ? const Icon(
                        //                       CupertinoIcons.bolt_slash_fill,
                        //                       color: Colors.white,
                        //                       size: 24,
                        //                     )
                        //                   : const Icon(
                        //                       CupertinoIcons.bolt_fill,
                        //                       color: Colors.white,
                        //                       size: 24,
                        //                     ),
                        //         ),
                        //       ),
                        //       //   Obx(() => DropdownButton(
                        //       //         value: defaultVideoSpeed.value,
                        //       //         items: items
                        //       //             .map((e) => DropdownMenuItem(
                        //       //                   child: Text(
                        //       //                     e.toString() + "x",
                        //       //                     style: const TextStyle(),
                        //       //                   ),
                        //       //                   value: e,
                        //       //                 ))
                        //       //             .toList(),
                        //       //         onChanged: (newValue) => {
                        //       //           defaultVideoSpeed.value =
                        //       //               double.parse(newValue.toString())
                        //       //         },
                        //       //       )),
                        //     ],
                        //   ),
                        // ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 30),
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      //preview button
                                      Obx(() => Visibility(
                                          visible: cameraController
                                                  .videosList.isNotEmpty &&
                                              cameraController
                                                  .thumbnail.isNotEmpty,
                                          child: InkWell(
                                            onTap: () async {
                                              // var file = File(cameraController
                                              //     .entities.last.path);
                                              // final videoInfo =
                                              //     FlutterVideoInfo();

                                              // var info = await videoInfo
                                              //     .getVideoInfo(file.path);

                                              // // cameraController
                                              // //     .animationController!
                                              // //     .animateBack(0,
                                              // //         duration: Duration(
                                              // //             milliseconds: info!
                                              // //                 .duration!
                                              // //                 .toInt()));

                                              // // cameraController
                                              // //         .animationController!
                                              // //         .value =
                                              // //     (info!.duration!.toDouble() /
                                              // //         1000);

                                              // // cameraController
                                              // //     .animationController!
                                              // //     .forward();
                                              // var duration = Duration(
                                              //     milliseconds:
                                              //         info!.duration!.toInt());
                                              // cameraController.entities
                                              //     .removeLast();
                                              // await file.delete(recursive: true);
                                              // var value = (duration.inSeconds *
                                              //     cameraController
                                              //         .animationController!
                                              //         .duration!
                                              //         .inSeconds /
                                              //     100);
                                              // value = value / 10;

                                              // if (cameraController
                                              //         .animationController!
                                              //         .duration!
                                              //         .inSeconds >=
                                              //     10) {
                                              //   cameraController
                                              //       .animationController!
                                              //       .value = cameraController
                                              //           .animationController!
                                              //           .value -
                                              //       value;
                                              // } else {
                                              //   cameraController
                                              //       .animationController!
                                              //       .value = cameraController
                                              //           .animationController!
                                              //           .value -
                                              //       (value * 10);
                                              // }

                                              // await cameraController
                                              //     .getVideoClips();
                                            },
                                            child: Container(
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: ColorManager
                                                          .colorAccent)),
                                              child: ClipOval(
                                                  child: Obx(() => cameraController
                                                          .thumbnail.isEmpty
                                                      ? CircularProgressIndicator()
                                                      : Image.file(
                                                          File(cameraController
                                                              .thumbnail.value),
                                                          fit: BoxFit.fill,
                                                        ))),
                                            ),
                                          ))),
                                      //video recording button click listener
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color:
                                                    ColorManager.colorAccent),
                                            color: ColorManager.colorAccent
                                                .withOpacity(0.2)),
                                        child: InkWell(
                                          onTap: () async {
                                            await ImagePicker()
                                                .pickVideo(
                                                    source: ImageSource.gallery)
                                                .then((value) async {
                                              if (value != null) {
                                                Get.toNamed(
                                                    Routes.VIDEO_THUMBNAIL,
                                                    arguments: {
                                                      'video_file': value.path
                                                    });
                                              }
                                            });
                                          },
                                          child: const Icon(
                                            FontAwesome.film,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () async {
                                          if (_isRecordingInProgress) {
                                            try {
                                              await stopVideoRecording()
                                                  .then((value) async {
                                                await cameraController
                                                    .getVideoClips();
                                              });
                                              if (cameraController
                                                  .isPlayerInit.isTrue) {
                                                await cameraController
                                                    .audioPlayer
                                                    .stop();
                                              }

                                              isRecordingRunning();
                                            } on camera
                                                .CameraException catch (e) {
                                              errorToast(e.toString());
                                            }
                                          } else {
                                            await startVideoRecording();
                                            isRecordingRunning();
                                          }
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Icon(
                                            //   Icons.circle,
                                            //   color: _isVideoCameraSelected
                                            //       ? Colors.transparent.withOpacity(0.0)
                                            //       : Colors.transparent.withOpacity(0.0),
                                            //   size: 75,
                                            // ),
                                            const Icon(
                                              Icons.circle,
                                              color: ColorManager
                                                  .colorPrimaryLight,
                                              size: 45,
                                            ),
                                            _isRecordingInProgress
                                                ? const Icon(
                                                    Icons.stop_rounded,
                                                    color: Colors.white,
                                                    size: 32,
                                                  )
                                                : Container(),

                                            AnimatedContainer(
                                              curve: Curves.easeIn,
                                              width: loaderWidth,
                                              height: loaderHeight,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: SizedBox(
                                                child: AnimatedBuilder(
                                                  animation: cameraController
                                                      .animationController!,
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return CustomPaint(
                                                        painter:
                                                            CustomTimerPainter(
                                                      animation: cameraController
                                                          .animationController!,
                                                      backgroundColor: ColorManager
                                                          .colorAccentTransparent
                                                          .withOpacity(0.0),
                                                      color: ColorManager
                                                          .colorAccent,
                                                    ));
                                                  },
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                                visible: !_isRecordingInProgress &&
                                                    cameraController
                                                            .animationController!
                                                            .value ==
                                                        0.0,
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 4,
                                                          color: ColorManager
                                                              .colorAccent),
                                                      shape: BoxShape.circle),
                                                )),
                                          ],
                                        ),
                                      ),

                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      ColorManager.colorAccent),
                                              shape: BoxShape.circle,
                                              color: ColorManager.colorAccent
                                                  .withOpacity(0.2)),
                                          child: InkWell(
                                            onTap: _isRecordingInProgress
                                                ? () async {
                                                    if (!_controller!.value
                                                        .isRecordingVideo) {
                                                      await resumeVideoRecording();
                                                      await cameraController
                                                          .audioPlayer
                                                          .play();
                                                    } else {
                                                      await pauseVideoRecording();
                                                      await cameraController
                                                          .audioPlayer
                                                          .pause();
                                                    }
                                                  }
                                                : () async {
                                                    _toggleCameraLens();
                                                    // setState(() {
                                                    //   _isCameraInitialized = false;
                                                    // });
                                                    // onNewCameraSelected(cameras[
                                                    // _isRearCameraSelected
                                                    //     ? 1
                                                    //     : 0]);
                                                    // setState(() {
                                                    //   _isRearCameraSelected =
                                                    //   !_isRearCameraSelected;
                                                    // });
                                                  },
                                            child: Icon(
                                              _isRearCameraSelected
                                                  ? FontAwesome.repeat
                                                  : Icons.camera_rear,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          )),
                                      Obx(() => Visibility(
                                          visible: isRecordingComplete.isTrue &&
                                                  cameraController
                                                      .animationController!
                                                      .isAnimating ||
                                              cameraController
                                                          .animationController!
                                                          .value >
                                                      0.05 &&
                                                  cameraController
                                                      .entities.isNotEmpty,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: ColorManager
                                                        .colorAccent),
                                                color: ColorManager.colorAccent
                                                    .withOpacity(0.2)),
                                            child: InkWell(
                                              onTap: () async {
                                                isRecordingComplete.value =
                                                    true;
                                                if (cameraController
                                                    .isPlayerInit.value) {
                                                  await cameraController
                                                      .audioPlayer
                                                      .stop();
                                                }
                                                var tempDirectory =
                                                    await getTemporaryDirectory();
                                                final dir = Directory(
                                                    tempDirectory.path);
                                                if (!await Directory(dir.path)
                                                    .exists()) {
                                                  await Directory(dir.path)
                                                      .create();
                                                }
                                                var outputFile = File(
                                                    '${dir.path}/output.mp4');
                                                ;
                                                if (outputFile.existsSync()) {
                                                  await outputFile.delete(
                                                      recursive: true);
                                                }

                                                setState(() {});

                                                cameraController
                                                    .getVideoClips();

                                                List<String> pathList = [];
                                                cameraController.entities
                                                    .forEach((element) {
                                                  pathList.add(element.path);
                                                });
                                                final File file = File(
                                                    '${dir.path}/txt/join_video.txt');

                                                if (!file.existsSync()) {
                                                  file.create(recursive: true);
                                                }
                                                await file.writeAsString(
                                                    "file ${pathList.join("\nfile ")} ");

                                                var mergeVideosCommand =
                                                    '-f concat -safe 0 -i ${dir.path}/txt/join_video.txt -c:v copy -c:a aac ${dir.path}/output.mp4';

                                                await FFmpegKit.executeAsync(
                                                    mergeVideosCommand,
                                                    (value) async {
                                                  var returnCode = await value
                                                      .getReturnCode();

                                                  if (ReturnCode.isSuccess(
                                                      returnCode)) {
                                                    Get.toNamed(
                                                        Routes.VIDEO_THUMBNAIL,
                                                        arguments: {
                                                          'video_file':
                                                              "${dir.path}/output.mp4"
                                                        });
                                                  } else {
                                                    errorToast(returnCode!
                                                        .getValue()
                                                        .toString());
                                                  }
                                                }, (log) {
                                                  Logger().w(
                                                      "Log Message: ${log.getMessage()}");
                                                });

                                              },
                                              child: const Icon(
                                                FontAwesome.check,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          )))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(top: 30),
                          width: 160,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: InkWell(
                            onTap: () async {
                              DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                              AndroidDeviceInfo androidInfo =
                                  await deviceInfo.androidInfo;
                              if (androidInfo.version.sdkInt > 31) {
                                if (await Permission.audio.isGranted) {
                                  cameraController.getAlbums().then((value) =>
                                      Get.bottomSheet(
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                    .padding
                                                    .top),
                                            child: SelectSoundView(
                                              context: context,
                                              animationController:
                                                  cameraController
                                                      .animationController,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          isScrollControlled: true));
                                  // refreshAlreadyCapturedImages();
                                } else {
                                  await Permission.audio
                                      .request()
                                      .then((value) async {
                                    cameraController.getAlbums().then((value) =>
                                        Get.bottomSheet(
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                      .padding
                                                      .top),
                                              child: SelectSoundView(
                                                context: context,
                                                animationController:
                                                    cameraController
                                                        .animationController,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isScrollControlled: true));
                                  });
                                }
                              } else {
                                if (await Permission.storage.isGranted) {
                                  cameraController.getAlbums().then((value) =>
                                      Get.bottomSheet(
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                    .padding
                                                    .top),
                                            child: SelectSoundView(
                                              context: context,
                                              animationController:
                                                  cameraController
                                                      .animationController,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          isScrollControlled: true));
                                  // refreshAlreadyCapturedImages();
                                } else {
                                  await Permission.storage.request().then(
                                      (value) => cameraController
                                          .getAlbums()
                                          .then((value) => Get.bottomSheet(
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                        .padding
                                                        .top),
                                                child: SelectSoundView(
                                                  context: context,
                                                  animationController:
                                                      cameraController
                                                          .animationController,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
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
                                    visible: cameraController.soundName
                                        .toString()
                                        .isNotEmpty,
                                    child: InkWell(
                                        onTap: () {
                                          cameraController.selectedSound.value =
                                              "";
                                          cameraController
                                              .userUploadedSound.value = "";
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
                                          cameraController
                                                  .soundName.value.isNotEmpty
                                              ? cameraController.soundName.value
                                              : "Select Sound",
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        )))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "loading",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
        onWillPop: onWillPopScope);
  }

  Future<bool> onWillPopScope() async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path);
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    final File file = File('${dir.path}/txt/join_video.txt');
    await file.delete(recursive: true);
    await cameraController.deleteFilesandReturn();
    return true;
  }

  @override
  void initState() {
    getPermissionStatus().then((value) => _getAvailableCameras());
    if (cameraController.isPlayerInit.isTrue) {
      cameraController.timer.value = cameraController.duration.inSeconds;
    }

    ever(cameraController.timer, (callback) => print(cameraController.timer));
    // _currentFlashMode = _controller.value.FlashMode.off;

    cameraController.animationController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        cameraController.animationController!.reset();
        loaderWidth = 50;
        loaderHeight = 50;
        setState(() {});

        await stopVideoRecording();
        await cameraController.getVideoClips();
        isRecordingComplete.value = true;
        if (cameraController.isPlayerInit.value) {
          await cameraController.audioPlayer.stop();
        }
        var tempDirectory =
        await getTemporaryDirectory();
        final dir = Directory(
            tempDirectory.path);
        if (!await Directory(dir.path)
            .exists()) {
          await Directory(dir.path)
              .create();
        }
        var outputFile = File(
            '${dir.path}/output.mp4');
        ;
        if (outputFile.existsSync()) {
          await outputFile.delete(
              recursive: true);
        }

        setState(() {});

        cameraController
            .getVideoClips();

        List<String> pathList = [];
        cameraController.entities
            .forEach((element) {
          pathList.add(element.path);
        });
        final File file = File(
            '${dir.path}/txt/join_video.txt');

        if (!file.existsSync()) {
          file.create(recursive: true);
        }
        await file.writeAsString(
            "file ${pathList.join("\nfile ")} ");

        var mergeVideosCommand =
            '-f concat -safe 0 -i ${dir.path}/txt/join_video.txt -c:v copy -c:a aac ${dir.path}/output.mp4';

        await FFmpegKit.executeAsync(
            mergeVideosCommand,
                (value) async {
              var returnCode = await value
                  .getReturnCode();

              if (ReturnCode.isSuccess(
                  returnCode)) {
                Get.toNamed(
                    Routes.VIDEO_THUMBNAIL,
                    arguments: {
                      'video_file':
                      "${dir.path}/output.mp4"
                    });
              } else {
                errorToast(returnCode!
                    .getValue()
                    .toString());
              }
            }, (log) {
          Logger().w(
              "Log Message: ${log.getMessage()}");
        });
      }
    });

    super.initState();
  }

  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await camera.availableCameras();
    _initCamera(cameras.first);
  }

  // init camera
  Future<void> _initCamera(camera.CameraDescription description) async {
    _controller = camera.CameraController(description, currentResolutionPreset,
        enableAudio: true);

    try {
      await _controller!.initialize();
      _currentFlashMode = _controller!.value.flashMode;

      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
      setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller!.description);
    }
  }

  //dispose camera controller and timer
  @override
  void dispose() {
    _controller!.dispose();
    time?.cancel();
    super.dispose();
  }

  void _toggleCameraLens() {
    // get current lens direction (front / rear)
    final lensDirection = _controller!.description.lensDirection;
    camera.CameraDescription newDescription;
    if (lensDirection == camera.CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == camera.CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == camera.CameraLensDirection.front);
    }

    if (newDescription != null) {
      _initCamera(newDescription);
      setState(() {});
    } else {
      print('Asked camera not available');
    }
  }

  void isRecordingRunning() async {
    if (cameraController.animationController!.isAnimating) {
      cameraController.animationController!.stop();
    } else {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 200))
            .then((value) => cameraController.animationController!.forward());
      }
    }
  }

  Future<void> getPermissionStatus() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt > 31) {
      if (await Permission.camera.isGranted &&
          await Permission.videos.isGranted &&
          await Permission.photos.isGranted &&
          await Permission.microphone.isGranted) {
        log('Camera Permission: GRANTED');
        log('Storage permission granted');
        setState(() {
          _isCameraPermissionGranted = true;
        });
        // Set and initialize the new camera
        onNewCameraSelected(cameras[0]);
        // refreshAlreadyCapturedImages();
      } else {
        await Permission.camera.request();
        await Permission.photos.request();
        await Permission.videos.request();
        await Permission.microphone.request();
      }
    } else {
      if (await Permission.camera.isGranted &&
          await Permission.storage.isGranted &&
          await Permission.microphone.isGranted) {
        log('Camera Permission: GRANTED');
        log('Storage permission granted');
        setState(() {
          _isCameraPermissionGranted = true;
        });
        // Set and initialize the new camera
        onNewCameraSelected(cameras[0]);
      } else {
        await Permission.camera.request();
        await Permission.storage.request();
        await Permission.microphone.request();
      }
    }
  }

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await _controller?.startVideoRecording().then((value) => {
            setState(() {
              loaderWidth = 70;
              loaderHeight = 70;
              _isRecordingInProgress = true;
              isRecordingComplete.value = false;
              if (cameraController.isPlayerInit.isTrue) {
                cameraController.audioPlayer.play();
              }
            })
          });
    } on camera.CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller!.value.isInitialized &&
        _controller!.value.isRecordingVideo &&
        _controller != null) {
      try {
        XFile file = await _controller!.stopVideoRecording();
        var videoFile = File(file.path);
        var tempPath = await getTemporaryDirectory();
        loaderHeight = 50;
        loaderWidth = 50;
        setState(() {
          _isRecordingInProgress = false;
          isRecordingComplete.value = true;
        });

        if (defaultVideoSpeed.value != 1.0) {
          Get.defaultDialog(
              title: "Please wait....", middleText: "", content: loader());
          await FFmpegKit.execute(
                  '-y -i ${file.path} -filter_complex "[0:v]setpts=${defaultVideoSpeed.value}*PTS[v]" -map "[v]" ${tempPath.path}output.mp4')
              .then((session) async {
            final returnCode = await session.getReturnCode();
            Get.back();
          });
          videoFile = File("${tempPath.path}output.mp4");
          checkDirectory().then((value) async {
            await videoFile.copy(value.path + '/${basename(file.path)}');
          });
        } else {
          checkDirectory().then((value) async {
            await videoFile.copy(value.path + '/${basename(file.path)}');
          });
        }
      } on camera.CameraException catch (e) {
        setState(() {
          _isRecordingInProgress = false;
        });
        errorToast(e.description.toString());
      }
    } else {
      return;
    }
  }

  Future<Directory> checkDirectory() async {
    var path = await getTemporaryDirectory();
    if (await Directory(path.path + "/videos").exists() == true) {
      print('Yes this directory Exists');
      return Directory(path.path + "/videos");
    } else {
      print('creating new Directory');
      return Directory(path.path + "/videos").create();
    }
  }

  //pause video recording and cancel timer
  Future<void> pauseVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      loaderHeight = 50;
      loaderWidth = 50;
      setState(() {});
      time?.cancel();
      // Video recording is not in progress
      return;
    }

    try {
      await _controller!.stopVideoRecording();
    } on camera.CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  //resume video recording
  Future<void> resumeVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    loaderHeight = 70;
    loaderWidth = 70;
    setState(() {});
    try {
      await _controller!.stopVideoRecording();
    } on camera.CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  // reset camera values to default
  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(camera.CameraDescription cameraDescription) async {
    final previousCameraController = _controller;

    final camera.CameraController cameraController = camera.CameraController(
        cameraDescription, camera.ResolutionPreset.high);

    await previousCameraController?.dispose();
    resetCameraValues();

    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }



    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
        _currentFlashMode = _controller!.value.flashMode;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }
}

class SelectSoundView extends GetView<SelectSoundController> {
  SelectSoundView({this.context, this.animationController});

  BuildContext? context;
  AnimationController? animationController;
  var isPlayerVisible = false.obs;
  var isPlayerPlaying = false.obs;
  var selectedIndex = 0.obs;
  final audioPlayer = AudioPlayer();
  final playerController = PlayerController();
  var duration = Duration.zero;
  var ownerName = "".obs;
  var avatar = "".obs;
  var selectedTab = 0.obs;

  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerLocalSounds = TextEditingController();

  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  Widget build(BuildContext context) {
    var cameraController = Get.find<camController.CameraController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: searchBarLayout(),
            ),
            TabBar(
                onTap: (int index) {
                  selectedTab.value = index;
                },
                indicatorColor: ColorManager.colorAccent,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                tabs: const [
                  Tab(
                    text: "Sounds",
                  ),
                  Tab(
                    text: "Local",
                  ),
                  Tab(
                    text: "Favourites",
                  )
                ]),
            Expanded(
              child: TabBarView(children: [
                Column(
                  children: [
                    Expanded(
                      child: controller.obx(
                          (_) => Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Obx(() => cameraController
                                          .isSoundsLoading.isFalse
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: controller
                                              .searchList[0].sounds!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      selectedIndex.value =
                                                          index;
                                                      cameraController
                                                              .soundName.value =
                                                          controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .name!;
                                                      cameraController
                                                          .soundOwner
                                                          .value = controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner !=
                                                              null
                                                          ? controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .soundOwner!
                                                              .id
                                                              .toString()
                                                          : controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .userId
                                                              .toString();

                                                      avatar.value = controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner !=
                                                              null
                                                          ? controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .soundOwner!
                                                              .avtars!
                                                          : "";
                                                      duration = (await audioPlayer
                                                          .setUrl(RestUrl
                                                                  .awsSoundUrl +
                                                              controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .sound
                                                                  .toString()))!;

                                                      if (duration.inSeconds <
                                                          61) {
                                                        cameraController
                                                            .animationController!
                                                            .duration = duration;
                                                      } else {
                                                        cameraController
                                                                .animationController!
                                                                .duration =
                                                            Duration(
                                                                seconds: 60);
                                                      }
                                                      if (cameraController
                                                          .animationController!
                                                          .isAnimating) {
                                                        cameraController
                                                            .animationController!
                                                            .forward();
                                                      }


                                                      audioTotalDuration.value =
                                                          duration!;
                                                      audioPlayer.positionStream
                                                          .listen(
                                                              (position) async {
                                                        final oldState =
                                                            progressNotifier
                                                                .value;
                                                        audioDuration.value =
                                                            position;
                                                        progressNotifier.value =
                                                            ProgressBarState(
                                                          current: position,
                                                          buffered:
                                                              oldState.buffered,
                                                          total: oldState.total,
                                                        );

                                                        if (position ==
                                                            oldState.total) {
                                                          audioPlayer
                                                              .playerStateStream
                                                              .drain();
                                                          await playerController
                                                              .seekTo(0);
                                                          await audioPlayer
                                                              .seek(Duration
                                                                  .zero);
                                                          audioDuration.value =
                                                              Duration.zero;
                                                          // isPlaying.value = false;
                                                        }
                                                        print(position);
                                                      });
                                                      audioPlayer
                                                          .bufferedPositionStream
                                                          .listen((position) {
                                                        final oldState =
                                                            progressNotifier
                                                                .value;
                                                        audioBuffered.value =
                                                            position;
                                                        progressNotifier.value =
                                                            ProgressBarState(
                                                          current:
                                                              oldState.current,
                                                          buffered: position,
                                                          total: oldState.total,
                                                        );
                                                      });

                                                      playerController
                                                          .onCurrentDurationChanged
                                                          .listen(
                                                              (duration) async {
                                                        audioDuration.value =
                                                            Duration(
                                                                seconds:
                                                                    duration);

                                                        Duration
                                                            playerDuration =
                                                            Duration(
                                                                seconds:
                                                                    duration);

                                                        print(duration);
                                                        if (Duration(
                                                                seconds:
                                                                    duration) >=
                                                            audioTotalDuration
                                                                .value) {
                                                          audioPlayer.seek(
                                                              Duration.zero);
                                                        }
                                                      });

                                                      audioPlayer.play();

                                                      if (isPlayerVisible
                                                          .isFalse) {
                                                        isPlayerVisible.value =
                                                            true;
                                                      }
                                                      isPlayerPlaying.value =
                                                          audioPlayer.playing;
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: imgSound(controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner !=
                                                                  null
                                                              ? controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner!
                                                                  .avtars
                                                                  .toString()
                                                              : ""),
                                                        ),
                                                        Obx(() => isPlayerPlaying
                                                                    .value &&
                                                                selectedIndex
                                                                        .value ==
                                                                    index
                                                            ? const Icon(
                                                                Icons
                                                                    .pause_circle_filled_outlined,
                                                                size: 25,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              )
                                                            : const Icon(
                                                                IconlyBold.play,
                                                                size: 25,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              ))
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      child: Container(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .name
                                                                    .toString(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                              Text(
                                                                controller
                                                                            .searchList[
                                                                                0]
                                                                            .sounds![
                                                                                index]
                                                                            .soundOwner !=
                                                                        null
                                                                    ? controller
                                                                            .searchList[
                                                                                0]
                                                                            .sounds![
                                                                                index]
                                                                            .soundOwner!
                                                                            .name ??
                                                                        controller
                                                                            .searchList[
                                                                                0]
                                                                            .sounds![
                                                                                index]
                                                                            .soundOwner!
                                                                            .username!
                                                                    : controller
                                                                        .searchList[
                                                                            0]
                                                                        .sounds![
                                                                            index]
                                                                        .username
                                                                        .toString(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ]),
                                                      ),
                                                      onTap: () async {
                                                        cameraController
                                                            .soundAuthorName
                                                            .value = controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .soundOwner ==
                                                                null
                                                            ? controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .username ??
                                                                ""
                                                            : controller
                                                                .searchList[0]
                                                                .sounds![index]
                                                                .soundOwner!
                                                                .username!;
                                                        var file = File(
                                                            saveCacheDirectory +
                                                                controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .sound!);
                                                        if (await file
                                                            .exists()) {
                                                          //     .toString();
                                                          cameraController
                                                                  .selectedSound
                                                                  .value =
                                                              file.uri
                                                                  .toString();

                                                          cameraController
                                                                  .userUploadedSound
                                                                  .value =
                                                              file.uri
                                                                  .toString();

                                                          cameraController
                                                                  .soundName
                                                                  .value =
                                                              controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .name!;
                                                          cameraController
                                                              .soundOwner
                                                              .value = controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner !=
                                                                  null
                                                              ? controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner!
                                                                  .id
                                                                  .toString()!
                                                              : "";

                                                          avatar
                                                              .value = controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner !=
                                                                  null
                                                              ? controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner!
                                                                  .avtars!
                                                              : "";

                                                          Future.delayed(Duration(
                                                                  milliseconds:
                                                                      200))
                                                              .then((value) =>
                                                                  animationController
                                                                      ?.reset());

                                                          cameraController
                                                              .setupAudioPlayer(
                                                                  file.path
                                                                      .toString());

                                                          Get.back();
                                                          if (Get
                                                              .isBottomSheetOpen!) {
                                                            Get.back();
                                                          }
                                                        } else {
                                                          var currentProgress =
                                                              "0".obs;
                                                          Get.defaultDialog(
                                                              title:
                                                                  "Downloading audio",
                                                              content: Obx(() =>
                                                                  Text(currentProgress
                                                                      .value)));
                                                          await FileSupport()
                                                              .downloadCustomLocation(
                                                            url:
                                                                "${RestUrl.awsSoundUrl}${controller.searchList[0].sounds?[index].sound}",
                                                            path:
                                                                saveCacheDirectory,
                                                            filename: basenameWithoutExtension(
                                                                controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .sound
                                                                    .toString()),
                                                            extension: ".mp3",
                                                            progress:
                                                                (progress) async {
                                                              currentProgress
                                                                      .value =
                                                                  progress;
                                                            },
                                                          )
                                                              .then((value) {
                                                            if (value != null) {
                                                              cameraController
                                                                      .userUploadedSound
                                                                      .value =
                                                                  value.uri
                                                                      .toString();

                                                              cameraController
                                                                      .soundName
                                                                      .value =
                                                                  controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .name!;
                                                              cameraController
                                                                  .soundOwner
                                                                  .value = controller
                                                                          .searchList[
                                                                              0]
                                                                          .sounds![
                                                                              index]
                                                                          .soundOwner !=
                                                                      null
                                                                  ? controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner!
                                                                      .id
                                                                      .toString()
                                                                  : "";

                                                              avatar
                                                                  .value = controller
                                                                          .searchList[
                                                                              0]
                                                                          .sounds![
                                                                              index]
                                                                          .soundOwner !=
                                                                      null
                                                                  ? controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner!
                                                                      .avtars!
                                                                  : "";
                                                              cameraController
                                                                  .setupAudioPlayer(
                                                                      value.path
                                                                          .toString());

                                                              Get.back();
                                                              if (Get
                                                                  .isBottomSheetOpen!) {
                                                                Get.back();
                                                              }
                                                            }
                                                            cameraController
                                                                    .selectedSound
                                                                    .value =
                                                                value!.uri
                                                                    .toString();

                                                            // Get.toNamed(Routes.CAMERA, arguments: {
                                                            //   "sound_url": value!.path,
                                                            //   "sound_name": soundName,
                                                            //   "sound_owner": userName
                                                            // });
                                                          });
                                                          animationController
                                                              ?.reset();
                                                        }
                                                        duration = (await audioPlayer
                                                            .setUrl(RestUrl
                                                                    .awsSoundUrl +
                                                                controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .sound
                                                                    .toString()))!;

                                                        if (duration.inSeconds <
                                                            61) {
                                                          cameraController
                                                              .animationController!
                                                              .duration = duration;
                                                        } else {
                                                          cameraController
                                                                  .animationController!
                                                                  .duration =
                                                              Duration(
                                                                  seconds: 60);
                                                        }
                                                        if (cameraController
                                                            .animationController!
                                                            .isAnimating) {
                                                          cameraController
                                                              .animationController!
                                                              .forward();
                                                        }
                                                        if (Get
                                                            .isBottomSheetOpen!) {
                                                          Get.back();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => {
                                                      // controller.addSoundToFavourite(
                                                      //     controller.searchList[0].sounds![index].id!,
                                                      //     controller.searchList[0].sounds![index].isFavouriteSoundCount == 0
                                                      //         ? "1"
                                                      //         : "0")
                                                    },
                                                    icon: const Icon(
                                                      IconlyBold.bookmark,
                                                      color: ColorManager
                                                          .colorAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                      : searchSoundShimmer()),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      VisibilityDetector(
                                          key: Key("miniplayer"),
                                          child: Obx(() => Visibility(
                                              visible: isPlayerVisible.value,
                                              child: SizedBox(
                                                height: 80,
                                                child: Card(
                                                  margin: EdgeInsets.all(0),
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          width: 2,
                                                          color: ColorManager
                                                              .colorAccent
                                                              .withOpacity(
                                                                  0.4)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Container(
                                                              height: 50,
                                                              width: 50,
                                                              child: Obx(() =>
                                                                  imgSound(avatar
                                                                      .value)),
                                                            ),
                                                          ],
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Obx(() => Text(
                                                                      cameraController
                                                                          .soundName
                                                                          .value,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w700),
                                                                    )),
                                                                Obx(() => Text(
                                                                      cameraController
                                                                          .soundOwner
                                                                          .value,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    )),
                                                                Obx(() => ProgressBar(
                                                                    thumbRadius:
                                                                        5,
                                                                    barHeight:
                                                                        3,
                                                                    baseBarColor:
                                                                        ColorManager
                                                                            .colorAccentTransparent,
                                                                    bufferedBarColor:
                                                                        ColorManager
                                                                            .colorAccentTransparent,
                                                                    timeLabelLocation:
                                                                        TimeLabelLocation
                                                                            .none,
                                                                    thumbColor: ColorManager
                                                                        .colorAccent,
                                                                    progressBarColor:
                                                                        ColorManager
                                                                            .colorAccent,
                                                                    buffered: progressNotifier
                                                                        .value
                                                                        .buffered,
                                                                    progress:
                                                                        audioDuration
                                                                            .value,
                                                                    onSeek: (duration) =>
                                                                        audioPlayer.seek(
                                                                            duration),
                                                                    total: audioTotalDuration
                                                                        .value))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (audioDuration
                                                                        .value >=
                                                                    audioTotalDuration
                                                                        .value &&
                                                                audioTotalDuration
                                                                        .value !=
                                                                    Duration
                                                                        .zero) {
                                                              audioPlayer
                                                                  .seek(Duration
                                                                      .zero)
                                                                  .then(
                                                                      (value) {
                                                                if (audioPlayer
                                                                    .playing) {
                                                                  audioPlayer
                                                                      .pause();
                                                                } else {
                                                                  audioPlayer
                                                                      .play();
                                                                }
                                                              });
                                                            }
                                                            if (audioPlayer
                                                                .playing) {
                                                              audioPlayer
                                                                  .pause();
                                                            } else {
                                                              audioPlayer
                                                                  .play();
                                                            }
                                                            isPlayerPlaying
                                                                    .value =
                                                                audioPlayer
                                                                    .playing;
                                                          },
                                                          child: Obx(() => isPlayerPlaying
                                                                      .value &&
                                                                  audioDuration
                                                                          .value <=
                                                                      audioTotalDuration
                                                                          .value &&
                                                                  audioTotalDuration
                                                                          .value !=
                                                                      Duration
                                                                          .zero
                                                              ? const Icon(
                                                                  Icons
                                                                      .pause_circle_filled_outlined,
                                                                  size: 50,
                                                                  color: ColorManager
                                                                      .colorAccent,
                                                                )
                                                              : audioDuration
                                                                              .value >=
                                                                          audioTotalDuration
                                                                              .value &&
                                                                      audioTotalDuration
                                                                              .value !=
                                                                          Duration
                                                                              .zero &&
                                                                      isPlayerPlaying
                                                                          .value
                                                                  ? const Icon(
                                                                      Icons
                                                                          .refresh_rounded,
                                                                      size: 50,
                                                                      color: ColorManager
                                                                          .colorAccent,
                                                                    )
                                                                  : const Icon(
                                                                      IconlyBold
                                                                          .play,
                                                                      size: 50,
                                                                      color: ColorManager
                                                                          .colorAccent,
                                                                    )),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ))),
                                          onVisibilityChanged: (info) => {
                                                if (info.visibleFraction < 0.9)
                                                  {
                                                    audioPlayer.stop(),
                                                    isPlayerPlaying.value =
                                                        audioPlayer.playing
                                                  }
                                              })
                                    ],
                                  )
                                ],
                              ),
                          onEmpty: NoSearchResult(
                            text: "No Sounds!",
                          ),
                          onLoading: searchSoundShimmer()),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                      child: GetX<SelectSoundController>(
                          builder: (controller) => Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          controller.localFilterList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  selectedIndex.value = index;

                                                  cameraController
                                                          .soundName.value =
                                                      controller
                                                          .localFilterList[
                                                              index]
                                                          .displayNameWOExt;

                                                  cameraController
                                                          .soundOwner.value =
                                                      GetStorage()
                                                          .read("userId")
                                                          .toString();

                                                  avatar.value = controller
                                                              .localFilterList[
                                                                  index]
                                                              .album !=
                                                          null
                                                      ? controller
                                                          .localFilterList[
                                                              index]
                                                          .album
                                                          .toString()
                                                      : "";

                                                  var file = await toFile(
                                                      controller
                                                          .localFilterList[
                                                              index]
                                                          .uri!);
                                                  duration = (await audioPlayer
                                                      .setAudioSource(
                                                          AudioSource.file(
                                                              file.path)))!;

                                                  if (duration.inSeconds < 61) {
                                                    cameraController
                                                        .animationController!
                                                        .duration = duration;
                                                  } else {
                                                    cameraController
                                                            .animationController!
                                                            .duration =
                                                        Duration(seconds: 60);
                                                  }
                                                  if (cameraController
                                                      .animationController!
                                                      .isAnimating) {
                                                    cameraController
                                                        .animationController!
                                                        .forward();
                                                  }
                                                  audioTotalDuration.value =
                                                      duration!;
                                                  audioPlayer.positionStream
                                                      .listen((position) async {
                                                    final oldState =
                                                        progressNotifier.value;
                                                    audioDuration.value =
                                                        position;
                                                    progressNotifier.value =
                                                        ProgressBarState(
                                                      current: position,
                                                      buffered:
                                                          oldState.buffered,
                                                      total: oldState.total,
                                                    );

                                                    if (position ==
                                                        oldState.total) {
                                                      audioPlayer
                                                          .playerStateStream
                                                          .drain();
                                                      await playerController
                                                          .seekTo(0);
                                                      await audioPlayer
                                                          .seek(Duration.zero);
                                                      audioDuration.value =
                                                          Duration.zero;
                                                      // isPlaying.value = false;
                                                    }
                                                    print(position);
                                                  });
                                                  audioPlayer
                                                      .bufferedPositionStream
                                                      .listen((position) {
                                                    final oldState =
                                                        progressNotifier.value;
                                                    audioBuffered.value =
                                                        position;
                                                    progressNotifier.value =
                                                        ProgressBarState(
                                                      current: oldState.current,
                                                      buffered: position,
                                                      total: oldState.total,
                                                    );
                                                  });

                                                  playerController
                                                      .onCurrentDurationChanged
                                                      .listen((duration) async {
                                                    audioDuration.value =
                                                        Duration(
                                                            seconds: duration);

                                                    Duration playerDuration =
                                                        Duration(
                                                            seconds: duration);

                                                    print(duration);
                                                    if (Duration(
                                                            seconds:
                                                                duration) >=
                                                        audioTotalDuration
                                                            .value) {
                                                      audioPlayer
                                                          .seek(Duration.zero);
                                                    }
                                                  });

                                                  audioPlayer.play();

                                                  if (isPlayerVisible.isFalse) {
                                                    isPlayerVisible.value =
                                                        true;
                                                  }
                                                  isPlayerPlaying.value =
                                                      audioPlayer.playing;
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      child: imgSound(controller
                                                                  .localFilterList[
                                                                      index]
                                                                  .artist !=
                                                              null
                                                          ? controller
                                                              .localFilterList[
                                                                  index]
                                                              .artist
                                                              .toString()
                                                          : ""),
                                                    ),
                                                    Obx(() => isPlayerPlaying
                                                                .value &&
                                                            selectedIndex
                                                                    .value ==
                                                                index
                                                        ? const Icon(
                                                            Icons
                                                                .pause_circle_filled_outlined,
                                                            size: 25,
                                                            color: ColorManager
                                                                .colorAccent,
                                                          )
                                                        : const Icon(
                                                            IconlyBold.play,
                                                            size: 25,
                                                            color: ColorManager
                                                                .colorAccent,
                                                          ))
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(0),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            controller
                                                                .localFilterList[
                                                                    index]
                                                                .title
                                                                .toString(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          Text(
                                                            controller
                                                                        .localFilterList[
                                                                            index]
                                                                        .artist ==
                                                                    null
                                                                ? ""
                                                                : controller
                                                                    .localFilterList[
                                                                        index]
                                                                    .artist!
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14),
                                                          ),
                                                        ]),
                                                  ),
                                                  onTap: () async {
                                                    var file = File(
                                                        saveCacheDirectory +
                                                            controller
                                                                .localFilterList[
                                                                    index]
                                                                .uri!);
                                                    cameraController
                                                        .userUploadedSound
                                                        .value = "";
                                                    if (await file.exists()) {
                                                      //     .toString();

                                                      cameraController
                                                              .selectedSound
                                                              .value =
                                                          file.uri.toString();

                                                      cameraController
                                                              .soundName.value =
                                                          controller
                                                              .localFilterList[
                                                                  index]
                                                              .displayNameWOExt;

                                                      cameraController
                                                              .soundOwner
                                                              .value =
                                                          controller
                                                              .localFilterList[
                                                                  index]
                                                              .title;

                                                      avatar.value = controller
                                                                  .localFilterList[
                                                                      index]
                                                                  .album !=
                                                              null
                                                          ? controller
                                                              .localFilterList[
                                                                  index]
                                                              .album
                                                              .toString()
                                                          : "";

                                                      animationController
                                                          ?.reset();

                                                      cameraController
                                                          .setupAudioPlayer(file
                                                              .path
                                                              .toString());
                                                      isLocalSound = true.obs;
                                                      if (Get
                                                          .isBottomSheetOpen!) {
                                                        Get.back();
                                                      }
                                                    } else {
                                                      cameraController
                                                              .selectedSound
                                                              .value =
                                                          controller
                                                              .localFilterList[
                                                                  index]
                                                              .uri
                                                              .toString();
                                                      cameraController
                                                              .soundName.value =
                                                          controller
                                                              .localFilterList[
                                                                  index]
                                                              .displayNameWOExt;
                                                      cameraController
                                                              .soundOwner
                                                              .value =
                                                          controller
                                                              .localFilterList[
                                                                  index]
                                                              .title;

                                                      avatar.value = controller
                                                                  .localFilterList[
                                                                      index]
                                                                  .album !=
                                                              null
                                                          ? controller
                                                              .localFilterList[
                                                                  index]
                                                              .album
                                                              .toString()
                                                          : "";

                                                      isLocalSound = true.obs;
                                                      Get.back();
                                                      if (Get
                                                          .isBottomSheetOpen!) {
                                                        Get.back();
                                                      }
                                                    }

                                                    var audioFile =
                                                        await toFile(controller
                                                            .localFilterList[
                                                                index]
                                                            .uri!);
                                                    duration = (await audioPlayer
                                                        .setAudioSource(
                                                            AudioSource.file(
                                                                audioFile
                                                                    .path)))!;

                                                    if (duration.inSeconds <
                                                        61) {
                                                      cameraController
                                                          .animationController!
                                                          .duration = duration;
                                                    } else {
                                                      cameraController
                                                              .animationController!
                                                              .duration =
                                                          Duration(seconds: 60);
                                                    }
                                                    if (cameraController
                                                        .animationController!
                                                        .isAnimating) {
                                                      cameraController
                                                          .animationController!
                                                          .forward();
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => {
                                                  // controller.addSoundToFavourite(
                                                  //     controller.searchList[0].sounds![index].id!,
                                                  //     controller.searchList[0].sounds![index].isFavouriteSoundCount == 0
                                                  //         ? "1"
                                                  //         : "0")
                                                },
                                                icon: const Icon(
                                                  IconlyBold.bookmark,
                                                  color:
                                                      ColorManager.colorAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  Align(
                                    child: VisibilityDetector(
                                        key: Key("miniplayer"),
                                        child: Obx(() => Visibility(
                                            visible: isPlayerVisible.value,
                                            child: SizedBox(
                                              height: 80,
                                              child: Card(
                                                margin: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 2,
                                                        color: ColorManager
                                                            .colorAccent
                                                            .withOpacity(0.4)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            height: 50,
                                                            width: 50,
                                                            child: Obx(() =>
                                                                imgSound(avatar
                                                                    .value)),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Obx(() => Text(
                                                                    cameraController
                                                                        .soundName
                                                                        .value,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  )),
                                                              Obx(() => Text(
                                                                    cameraController
                                                                        .soundName
                                                                        .value,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  )),
                                                              Obx(() => ProgressBar(
                                                                  thumbRadius:
                                                                      5,
                                                                  barHeight: 3,
                                                                  baseBarColor:
                                                                      ColorManager
                                                                          .colorAccentTransparent,
                                                                  bufferedBarColor:
                                                                      ColorManager
                                                                          .colorAccentTransparent,
                                                                  timeLabelLocation:
                                                                      TimeLabelLocation
                                                                          .none,
                                                                  thumbColor:
                                                                      ColorManager
                                                                          .colorAccent,
                                                                  progressBarColor:
                                                                      ColorManager
                                                                          .colorAccent,
                                                                  buffered:
                                                                      progressNotifier
                                                                          .value
                                                                          .buffered,
                                                                  progress:
                                                                      audioDuration
                                                                          .value,
                                                                  onSeek: (duration) =>
                                                                      audioPlayer
                                                                          .seek(
                                                                              duration),
                                                                  total:
                                                                      audioTotalDuration
                                                                          .value))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (audioDuration
                                                                      .value >=
                                                                  audioTotalDuration
                                                                      .value &&
                                                              audioTotalDuration
                                                                      .value !=
                                                                  Duration
                                                                      .zero) {
                                                            audioPlayer
                                                                .seek(Duration
                                                                    .zero)
                                                                .then((value) {
                                                              if (audioPlayer
                                                                  .playing) {
                                                                audioPlayer
                                                                    .pause();
                                                              } else {
                                                                audioPlayer
                                                                    .play();
                                                              }
                                                            });
                                                          }
                                                          if (audioPlayer
                                                              .playing) {
                                                            audioPlayer.pause();
                                                          } else {
                                                            audioPlayer.play();
                                                          }
                                                          isPlayerPlaying
                                                                  .value =
                                                              audioPlayer
                                                                  .playing;
                                                        },
                                                        child: Obx(() => isPlayerPlaying
                                                                    .value &&
                                                                audioDuration
                                                                        .value <=
                                                                    audioTotalDuration
                                                                        .value &&
                                                                audioTotalDuration
                                                                        .value !=
                                                                    Duration
                                                                        .zero
                                                            ? const Icon(
                                                                Icons
                                                                    .pause_circle_filled_outlined,
                                                                size: 50,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              )
                                                            : audioDuration.value >=
                                                                        audioTotalDuration
                                                                            .value &&
                                                                    audioTotalDuration
                                                                            .value !=
                                                                        Duration
                                                                            .zero &&
                                                                    isPlayerPlaying
                                                                        .value
                                                                ? const Icon(
                                                                    Icons
                                                                        .refresh_rounded,
                                                                    size: 50,
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                  )
                                                                : const Icon(
                                                                    IconlyBold
                                                                        .play,
                                                                    size: 50,
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                  )),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))),
                                        onVisibilityChanged: (info) => {
                                              if (info.visibleFraction < 0.9)
                                                {
                                                  audioPlayer.stop(),
                                                  isPlayerPlaying.value =
                                                      audioPlayer.playing
                                                }
                                            }),
                                    alignment: Alignment.bottomCenter,
                                  )
                                ],
                              )),
                    ),
                  ],
                ),
                GetX<SelectSoundController>(
                  builder: (controller) => controller.favouriteSounds!.isEmpty
                      ? Column(
                          children: [emptyListWidget()],
                        )
                      : Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Column(
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        controller.favouriteSounds.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                selectedIndex.value = index;
                                                cameraController
                                                        .soundAuthorName.value =
                                                    controller
                                                        .favouriteSounds[index]
                                                        .user!
                                                        .username!;

                                                cameraController
                                                        .soundName.value =
                                                    controller
                                                        .favouriteSounds[index]
                                                        .name!;

                                                cameraController
                                                        .soundOwner.value =
                                                    controller
                                                        .favouriteSounds[index]
                                                        .userId
                                                        .toString();

                                                avatar.value = controller
                                                            .favouriteSounds[
                                                                index]
                                                            .user!
                                                            .avatar !=
                                                        null
                                                    ? controller
                                                        .favouriteSounds[index]
                                                        .user!
                                                        .avatar!
                                                    : "";
                                                duration = (await audioPlayer
                                                    .setUrl(RestUrl
                                                            .awsSoundUrl +
                                                        controller
                                                            .favouriteSounds[
                                                                index]
                                                            .sound
                                                            .toString()))!;

                                                if (duration.inSeconds < 61) {
                                                  cameraController
                                                      .animationController!
                                                      .duration = duration;
                                                } else {
                                                  cameraController
                                                          .animationController!
                                                          .duration =
                                                      Duration(seconds: 60);
                                                }
                                                if (cameraController
                                                    .animationController!
                                                    .isAnimating) {
                                                  cameraController
                                                      .animationController!
                                                      .forward();
                                                }
                                                audioTotalDuration.value =
                                                    duration!;
                                                audioPlayer.positionStream
                                                    .listen((position) async {
                                                  final oldState =
                                                      progressNotifier.value;
                                                  audioDuration.value =
                                                      position;
                                                  progressNotifier.value =
                                                      ProgressBarState(
                                                    current: position,
                                                    buffered: oldState.buffered,
                                                    total: oldState.total,
                                                  );

                                                  if (position ==
                                                      oldState.total) {
                                                    audioPlayer
                                                        .playerStateStream
                                                        .drain();
                                                    await playerController
                                                        .seekTo(0);
                                                    await audioPlayer
                                                        .seek(Duration.zero);
                                                    audioDuration.value =
                                                        Duration.zero;
                                                    // isPlaying.value = false;
                                                  }
                                                  print(position);
                                                });
                                                audioPlayer
                                                    .bufferedPositionStream
                                                    .listen((position) {
                                                  final oldState =
                                                      progressNotifier.value;
                                                  audioBuffered.value =
                                                      position;
                                                  progressNotifier.value =
                                                      ProgressBarState(
                                                    current: oldState.current,
                                                    buffered: position,
                                                    total: oldState.total,
                                                  );
                                                });

                                                playerController
                                                    .onCurrentDurationChanged
                                                    .listen((duration) async {
                                                  audioDuration.value =
                                                      Duration(
                                                          seconds: duration);

                                                  Duration playerDuration =
                                                      Duration(
                                                          seconds: duration);

                                                  print(duration);
                                                  if (Duration(
                                                          seconds: duration) >=
                                                      audioTotalDuration
                                                          .value) {
                                                    audioPlayer
                                                        .seek(Duration.zero);
                                                  }
                                                });

                                                audioPlayer.play();

                                                if (isPlayerVisible.isFalse) {
                                                  isPlayerVisible.value = true;
                                                }
                                                isPlayerPlaying.value =
                                                    audioPlayer.playing;
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: imgSound(controller
                                                                .favouriteSounds[
                                                                    index]
                                                                .user !=
                                                            null
                                                        ? controller
                                                            .favouriteSounds[
                                                                index]
                                                            .user!
                                                            .avatar
                                                            .toString()
                                                        : ""),
                                                  ),
                                                  Obx(() => isPlayerPlaying
                                                              .value &&
                                                          selectedIndex.value ==
                                                              index
                                                      ? const Icon(
                                                          Icons
                                                              .pause_circle_filled_outlined,
                                                          size: 25,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )
                                                      : const Icon(
                                                          IconlyBold.play,
                                                          size: 25,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        ))
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          controller
                                                              .favouriteSounds[
                                                                  index]
                                                              .name
                                                              .toString(),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 18),
                                                        ),
                                                        Text(
                                                          controller
                                                                      .favouriteSounds[
                                                                          index]
                                                                      .user ==
                                                                  null
                                                              ? ""
                                                              : controller
                                                                  .favouriteSounds[
                                                                      index]
                                                                  .user!
                                                                  .username
                                                                  .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14),
                                                        ),
                                                      ]),
                                                ),
                                                onTap: () async {
                                                  var file = File(
                                                      saveCacheDirectory +
                                                          controller
                                                              .favouriteSounds[
                                                                  index]
                                                              .sound!);

                                                  duration = (await audioPlayer
                                                      .setUrl(RestUrl
                                                              .awsSoundUrl +
                                                          controller
                                                              .favouriteSounds[
                                                                  index]
                                                              .sound
                                                              .toString()))!;

                                                  if (duration.inSeconds < 61) {
                                                    cameraController
                                                        .animationController!
                                                        .duration = duration;
                                                  } else {
                                                    cameraController
                                                            .animationController!
                                                            .duration =
                                                        Duration(seconds: 60);
                                                  }
                                                  if (cameraController
                                                      .animationController!
                                                      .isAnimating) {
                                                    cameraController
                                                        .animationController!
                                                        .forward();
                                                  }
                                                  if (await file.exists()) {
                                                    //     .toString();
                                                    cameraController
                                                            .soundName.value =
                                                        controller
                                                            .favouriteSounds[
                                                                index]
                                                            .name!;
                                                    cameraController
                                                            .soundAuthorName
                                                            .value =
                                                        controller
                                                            .favouriteSounds[
                                                                index]
                                                            .user!
                                                            .username!;
                                                    cameraController
                                                            .selectedSound
                                                            .value =
                                                        file.uri.toString();

                                                    cameraController
                                                            .userUploadedSound
                                                            .value =
                                                        file.uri.toString();

                                                    animationController
                                                        ?.reset();

                                                    cameraController
                                                        .setupAudioPlayer(file
                                                            .path
                                                            .toString());

                                                    if (Get
                                                        .isBottomSheetOpen!) {
                                                      Get.back();
                                                    }
                                                  } else {
                                                    var currentProgress =
                                                        "0".obs;
                                                    Get.defaultDialog(
                                                        title:
                                                            "Downloading audio",
                                                        content: Obx(() => Text(
                                                            currentProgress
                                                                .value)));
                                                    await FileSupport()
                                                        .downloadCustomLocation(
                                                      url:
                                                          "${RestUrl.awsSoundUrl}${controller.favouriteSounds[index].sound}",
                                                      path: saveCacheDirectory,
                                                      filename:
                                                          basenameWithoutExtension(
                                                              controller
                                                                  .favouriteSounds[
                                                                      index]
                                                                  .sound
                                                                  .toString()),
                                                      extension: ".mp3",
                                                      progress:
                                                          (progress) async {
                                                        currentProgress.value =
                                                            progress;
                                                      },
                                                    )
                                                        .then((value) {
                                                      if (value != null) {
                                                        controller
                                                            .favouriteSounds[
                                                                index]
                                                            .userId!
                                                            .toString();

                                                        cameraController
                                                                .soundAuthorName
                                                                .value =
                                                            controller
                                                                .favouriteSounds[
                                                                    index]
                                                                .user!
                                                                .username!;
                                                        cameraController
                                                                .selectedSound
                                                                .value =
                                                            value.uri
                                                                .toString();

                                                        cameraController
                                                                .soundName
                                                                .value =
                                                            controller
                                                                .favouriteSounds[
                                                                    index]
                                                                .name!;
                                                        cameraController
                                                                .userUploadedSound
                                                                .value =
                                                            value.uri
                                                                .toString();

                                                        animationController
                                                            ?.reset();
                                                        cameraController
                                                                .soundOwner
                                                                .value =
                                                            controller
                                                                .favouriteSounds[
                                                                    index]
                                                                .userId
                                                                .toString();

                                                        cameraController
                                                            .setupAudioPlayer(
                                                                value.path
                                                                    .toString());

                                                        Get.back();
                                                        if (Get
                                                            .isBottomSheetOpen!) {
                                                          Get.back();
                                                        }
                                                      }

                                                      // Get.toNamed(Routes.CAMERA, arguments: {
                                                      //   "sound_url": value!.path,
                                                      //   "sound_name": soundName,
                                                      //   "sound_owner": userName
                                                      // });
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => {
                                                // controller.addSoundToFavourite(
                                                //     controller.searchList[0].sounds![index].id!,
                                                //     controller.searchList[0].sounds![index].isFavouriteSoundCount == 0
                                                //         ? "1"
                                                //         : "0")
                                              },
                                              icon: const Icon(
                                                IconlyBold.bookmark,
                                                color: ColorManager.colorAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                            VisibilityDetector(
                                key: Key("miniplayer"),
                                child: Obx(() => Visibility(
                                    visible: isPlayerVisible.value,
                                    child: SizedBox(
                                      height: 80,
                                      child: Card(
                                        margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 2,
                                                color: ColorManager.colorAccent
                                                    .withOpacity(0.4)),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: Obx(() =>
                                                        imgSound(avatar.value)),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Obx(() => Text(
                                                            cameraController
                                                                .soundName
                                                                .value,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          )),
                                                      Obx(() => Text(
                                                            cameraController
                                                                .soundOwner
                                                                .value,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          )),
                                                      Obx(() => ProgressBar(
                                                          thumbRadius: 5,
                                                          barHeight: 3,
                                                          baseBarColor: ColorManager
                                                              .colorAccentTransparent,
                                                          bufferedBarColor:
                                                              ColorManager
                                                                  .colorAccentTransparent,
                                                          timeLabelLocation:
                                                              TimeLabelLocation
                                                                  .none,
                                                          thumbColor:
                                                              ColorManager
                                                                  .colorAccent,
                                                          progressBarColor:
                                                              ColorManager
                                                                  .colorAccent,
                                                          buffered:
                                                              progressNotifier
                                                                  .value
                                                                  .buffered,
                                                          progress:
                                                              audioDuration
                                                                  .value,
                                                          onSeek: (duration) =>
                                                              audioPlayer.seek(
                                                                  duration),
                                                          total:
                                                              audioTotalDuration
                                                                  .value))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (audioDuration.value >=
                                                          audioTotalDuration
                                                              .value &&
                                                      audioTotalDuration
                                                              .value !=
                                                          Duration.zero) {
                                                    audioPlayer
                                                        .seek(Duration.zero)
                                                        .then((value) {
                                                      if (audioPlayer.playing) {
                                                        audioPlayer.pause();
                                                      } else {
                                                        audioPlayer.play();
                                                      }
                                                    });
                                                  }
                                                  if (audioPlayer.playing) {
                                                    audioPlayer.pause();
                                                  } else {
                                                    audioPlayer.play();
                                                  }
                                                  isPlayerPlaying.value =
                                                      audioPlayer.playing;
                                                },
                                                child: Obx(() => isPlayerPlaying
                                                            .value &&
                                                        audioDuration.value <=
                                                            audioTotalDuration
                                                                .value &&
                                                        audioTotalDuration
                                                                .value !=
                                                            Duration.zero
                                                    ? const Icon(
                                                        Icons
                                                            .pause_circle_filled_outlined,
                                                        size: 50,
                                                        color: ColorManager
                                                            .colorAccent,
                                                      )
                                                    : audioDuration.value >=
                                                                audioTotalDuration
                                                                    .value &&
                                                            audioTotalDuration
                                                                    .value !=
                                                                Duration.zero &&
                                                            isPlayerPlaying
                                                                .value
                                                        ? const Icon(
                                                            Icons
                                                                .refresh_rounded,
                                                            size: 50,
                                                            color: ColorManager
                                                                .colorAccent,
                                                          )
                                                        : const Icon(
                                                            IconlyBold.play,
                                                            size: 50,
                                                            color: ColorManager
                                                                .colorAccent,
                                                          )),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))),
                                onVisibilityChanged: (info) => {
                                      if (info.visibleFraction < 0.9)
                                        {
                                          audioPlayer.stop(),
                                          isPlayerPlaying.value =
                                              audioPlayer.playing
                                        }
                                    })
                          ],
                        ),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  searchBarLayout() => Row(
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
                controller: _controller,
                onChanged: (value) {
                  if (selectedTab.value == 0) {
                    controller.searchHashtags(_controller.text);
                  } else {
                    controller.localSoundsList.forEach((element) {
                      if (element.displayNameWOExt
                              .toString()
                              .contains(_controller.text.toLowerCase()) &&
                          _controller.text.isNotEmpty) {
                        controller.localFilterList.value = controller
                            .localSoundsList
                            .where((p0) => p0.displayNameWOExt
                                .toLowerCase()
                                .contains(_controller.text.toLowerCase()))
                            .toList()
                            .obs;
                      }
                    });
                    if (value.isEmpty) {
                      controller.localFilterList.clear();
                      controller.getLocalSounds();
                    }
                  }
                },
                // onEditingComplete: () {
                //   controller.searchHashtags(_controller.text);
                // },

                onFieldSubmitted: (text) {
                  if (selectedTab.value == 0) {
                    controller.searchHashtags(_controller.text);
                  } else {
                    controller.localSoundsList.forEach((element) {
                      if (element.displayNameWOExt
                              .toString()
                              .contains(_controller.text.toLowerCase()) &&
                          _controller.text.isNotEmpty) {
                        controller.localFilterList.value = controller
                            .localSoundsList
                            .where((p0) => p0.displayNameWOExt
                                .toLowerCase()
                                .contains(_controller.text.toLowerCase()))
                            .toList()
                            .obs;
                      } else if (text.isEmpty) {
                        controller.localFilterList.clear();
                        controller.localFilterList = controller.localSoundsList;
                        controller.localFilterList.refresh();
                      }
                    });
                  }
                },
                // initialValue: user.username,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(2),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
          )
        ],
      );

  searchBarLayoutLocal() => Row(
        children: [
          Flexible(
            child: Container(
              height: 55,
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
                controller: _controllerLocalSounds,
                onChanged: (value) {},
                // onEditingComplete: () {
                //   controller.searchHashtags(_controller.text);
                // },

                onFieldSubmitted: (text) {
                  controller.localSoundsList.forEach((element) {
                    if (element.displayNameWOExt.toString().contains(
                            _controllerLocalSounds.text.toLowerCase()) &&
                        _controllerLocalSounds.text.isNotEmpty) {
                      controller.localFilterList.value = controller
                          .localSoundsList
                          .where((p0) => p0.displayNameWOExt
                              .toLowerCase()
                              .contains(
                                  _controllerLocalSounds.text.toLowerCase()))
                          .toList()
                          .obs;
                    } else {
                      controller.localFilterList = controller.localSoundsList;
                    }
                  });
                },
                // initialValue: user.username,
                decoration: const InputDecoration(
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
          )
        ],
      );
}
