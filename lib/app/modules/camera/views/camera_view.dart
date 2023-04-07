import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart' as camera;
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/camera/select_sound/views/select_sound_view.dart';
import 'package:thrill/app/modules/settings/favourites/views/favourites_view.dart';
import 'package:thrill/app/modules/supercontroller/video_editing_controller.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import '../../../../main.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/custom_timer_painter.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';
import '../controllers/camera_controller.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

import '../select_sound/controllers/select_sound_controller.dart';

var selectedSound = "".obs;

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraState();
}

class _CameraState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraView> {
  var timer = 60.obs;
  Timer? time;
  late camera.CameraController _controller;
  CameraController cameraController = Get.find<CameraController>();
  var videoEditingController = Get.find<VideoEditingController>();
  File? file;
  File? _imageFile;
  File? _videoFile;
  var loaderWidth = 80.0;
  var loaderHeight = 80.0;

  // Initial values
  var _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = true;
  bool _isRecordingInProgress = false;

  bool isRecordingComplete = false;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  camera.FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = camera.ResolutionPreset.values;

  AnimationController? animationController;

  camera.ResolutionPreset currentResolutionPreset = camera.ResolutionPreset.max;

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
    return Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraInitialized
            ? Stack(
                alignment: Alignment.topCenter,
                children: [
                  AspectRatio(
                    aspectRatio: Get.size.aspectRatio,
                    child: camera.CameraPreview(_controller),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorManager.colorAccent),
                                    shape: BoxShape.circle,
                                    color: ColorManager.colorAccent
                                        .withOpacity(0.3)),
                                child: InkWell(
                                  onTap: _isRecordingInProgress
                                      ? () async {
                                          if (!_controller
                                              .value.isRecordingVideo) {
                                            await resumeVideoRecording();
                                          } else {
                                            await pauseVideoRecording();
                                          }
                                        }
                                      : () async {
                                          _toggleCameraLens();
                                          setState(() {
                                            _isCameraInitialized = false;
                                          });
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
                                        ? Icons.camera_front
                                        : Icons.camera_rear,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )),
                            Obx(() => DropdownButton(
                                  value: defaultVideoSpeed.value,
                                  items: items
                                      .map((e) => DropdownMenuItem(
                                            child: Text(
                                              e.toString() + "x",
                                              style: TextStyle(),
                                            ),
                                            value: e,
                                          ))
                                      .toList(),
                                  onChanged: (newValue) => {
                                    defaultVideoSpeed.value =
                                        double.parse(newValue.toString())
                                  },
                                )),
                            //video recording button click listener
                            InkWell(
                              onTap: () async {
                                if (_isRecordingInProgress) {
                                  try {
                                    if (animationController!.isAnimating &&
                                        animationController!.value < 0.05) {
                                      errorToast(
                                          "Please Record Atleast 10 seconds");
                                    } else {
                                      await stopVideoRecording();
                                      isRecordingRunning();
                                    }
                                  } on camera.CameraException catch (e) {
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
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [
                                          Colors.red.withOpacity(0.5),
                                          ColorManager.colorAccentTransparent
                                        ])),
                                    height: 75,
                                    width: 75,
                                  ),
                                  // Icon(
                                  //   Icons.circle,
                                  //   color: _isVideoCameraSelected
                                  //       ? Colors.transparent.withOpacity(0.0)
                                  //       : Colors.transparent.withOpacity(0.0),
                                  //   size: 75,
                                  // ),
                                  const Icon(
                                    Icons.circle,
                                    color: ColorManager.colorPrimaryLight,
                                    size: 35,
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
                                    duration: const Duration(milliseconds: 400),
                                    child: SizedBox(
                                      child: AnimatedBuilder(
                                        animation: animationController!,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return CustomPaint(
                                              painter: CustomTimerPainter(
                                            animation: animationController!,
                                            backgroundColor: ColorManager
                                                .colorAccentTransparent,
                                            color: ColorManager.colorAccent,
                                          ));
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: ColorManager.colorAccent),
                                  color: ColorManager.colorAccent
                                      .withOpacity(0.3)),
                              child: InkWell(
                                onTap: () async {
                                  try {
                                    if (await Permission.photos.isGranted ==
                                        false) {
                                      await Permission.photos
                                          .request()
                                          .then((value) async {
                                        await ImagePicker()
                                            .pickVideo(
                                                source: ImageSource.gallery)
                                            .then((value) async {
                                          if (value != null) {
                                            int currentUnix = DateTime.now()
                                                .millisecondsSinceEpoch;

                                            await cameraController.openEditor(
                                                true,
                                                value.path,
                                                selectedSound.value.isEmpty
                                                    ? Get
                                                        .arguments["sound_path"]
                                                        .toString()
                                                    : selectedSound.value,
                                                GetStorage().read("userId"),
                                                Get.arguments["sound_owner"]
                                                    .toString());
                                          }
                                        });
                                      });
                                    } else {
                                      await ImagePicker()
                                          .pickVideo(
                                              source: ImageSource.gallery)
                                          .then((value) async {
                                        if (value != null) {
                                          int currentUnix = DateTime.now()
                                              .millisecondsSinceEpoch;

                                          await cameraController.openEditor(
                                              true,
                                              value.path,
                                              selectedSound.value.isEmpty
                                                  ? Get.arguments["sound_path"]
                                                      .toString()
                                                  : selectedSound.value,
                                              GetStorage().read("userId"),
                                              Get.arguments["sound_owner"]
                                                  .toString());
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    errorToast(e.toString());
                                  }
                                },
                                child: const Icon(
                                  Icons.browse_gallery_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            //preview button
                            !isRecordingComplete
                                ? Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: ColorManager.colorAccent),
                                        color: ColorManager.colorAccent
                                            .withOpacity(0.3)),
                                    child: InkWell(
                                      onTap: () async {
                                        if (_currentFlashMode ==
                                            camera.FlashMode.off) {
                                          setState(() {
                                            _currentFlashMode =
                                                camera.FlashMode.torch;
                                            // _controller!.setFlashMode(
                                            //     FlashMode.torch);
                                          });
                                        } else {
                                          setState(() {
                                            _currentFlashMode =
                                                camera.FlashMode.off;

                                            // _controller!.setFlashMode(
                                            //     FlashMode.off);
                                          });
                                        }
                                        //await openEditor();
                                        // Get.to(VideoEditor(
                                        //   file: _videoFile!,
                                        // ));
                                      },
                                      child: _currentFlashMode ==
                                              camera.FlashMode.off
                                          ? const Icon(
                                              Icons.flash_off_rounded,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.flash_on_rounded,
                                              color: Colors.white,
                                            ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: ColorManager.colorAccent),
                                        color: ColorManager.colorAccent
                                            .withOpacity(0.3)),
                                    child: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isRecordingComplete = true;
                                        });
                                        try {
                                          await cameraController.openEditor(
                                              false,
                                              "",
                                              selectedSound.value.isEmpty
                                                  ? Get.arguments["sound_url"]
                                                      .toString()
                                                  : selectedSound.value,
                                              GetStorage().read("userId"),
                                              Get.arguments["sound_owner"] ??
                                                  GetStorage()
                                                      .read("username")
                                                      .toString());
                                          // cameraController.openEditor(
                                          //     false,
                                          //     "",
                                          //     soundsController.selectedSoundPath
                                          //         .value.isEmpty
                                          //         ? widget.selectedSound
                                          //         : soundsController
                                          //         .selectedSoundPath.value,
                                          //     widget.id!,
                                          //     userDetailsController.userProfile
                                          //         .value.username ??
                                          //         userDetailsController
                                          //             .userProfile.value.name
                                          //             .toString());
                                        } catch (e) {
                                          errorToast(e.toString());
                                        }
                                      },
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: InkWell(
                      onTap: () {
                        Get.bottomSheet(SelectSoundView(),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)));
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
                          Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Obx(() => Text(
                                selectedSound.value.isNotEmpty
                                    ? basename(selectedSound.value)
                                    : Get.arguments["sound_name"] ??
                                        "Select Sound",
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.center,
                child: Text(
                  "loading",
                  style: TextStyle(color: Colors.white),
                ),
              ));
  }

  @override
  void initState() {
    _getAvailableCameras();

    setState(() {});

    _currentFlashMode = camera.FlashMode.off;
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));

    animationController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        animationController!.reset();
        loaderWidth = 80;
        loaderHeight = 80;
        stopVideoRecording();
        setState(() {
          isRecordingComplete = true;
        });
        try {
          await cameraController.openEditor(
              false,
              "",
              selectedSound.value.isEmpty
                  ? Get.arguments["sound_path"].toString()
                  : selectedSound.value,
              GetStorage().read("userId"),
              Get.arguments["sound_owner"].toString());
        } catch (e) {
          errorToast(e.toString());
        }
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
    _controller = camera.CameraController(
        description, camera.ResolutionPreset.max,
        enableAudio: true);

    try {
      await _controller.initialize();
      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller.description);
    }
  }

  //dispose camera controller and timer
  @override
  void dispose() {
    _controller?.dispose();
    animationController!.dispose();
    time?.cancel();
    super.dispose();
  }

  void _toggleCameraLens() {
    // get current lens direction (front / rear)
    final lensDirection = _controller.description.lensDirection;
    camera.CameraDescription newDescription;
    if (lensDirection == camera.CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == camera.CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == camera.CameraLensDirection.front);
    }

    if (newDescription != null) {
      onNewCameraSelected(newDescription);
    } else {
      print('Asked camera not available');
    }
  }

  void isRecordingRunning() async {
    if (animationController!.isAnimating) {
      animationController!.stop();
    } else {
      animationController!.forward();
      // animationController!.reverse(
      //     from: animationController?.value == 0.0
      //         ? 1.0
      //         : animationController?.value);
    }
  }

  getPermissionStatus() async {
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
      // refreshAlreadyCapturedImages();
    } else {
      await Permission.camera.request().then((value) async =>
          await Permission.storage.request().then((value) async {
            await Permission.microphone.request();
          }));
    }
  }

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      // startTimer();
      await _controller.startVideoRecording().then((value) => {
            setState(() {
              loaderWidth = 110;
              loaderHeight = 110;
              _isRecordingInProgress = true;
              isRecordingComplete = false;
            })
          });
    } on camera.CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller.value.isInitialized && _controller.value.isRecordingVideo) {
      try {
        XFile file = await _controller.stopVideoRecording();
        var videoFile = File(file.path);
        var tempPath = await getTemporaryDirectory();
        loaderHeight = 80;
        loaderWidth = 80;
        setState(() {
          _isRecordingInProgress = false;
          isRecordingComplete = true;
        });
        if (defaultVideoSpeed.value != 1.0) {
          Get.defaultDialog(
              title: "Please wait....", middleText: "", content: loader());
          await FFmpegKit.execute(
                  '-y -i ${file.path} -filter_complex "[0:v]setpts=${defaultVideoSpeed.value}*PTS[v]" -map "[v]" ${tempPath.path}output.mp4')
              .then((session) async {
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              print("============================> GIF Success!!!!");
              Get.back();
            } else {
              print("============================> GIF Failed!!!!");
              Get.back();
            }
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
    if (!_controller.value.isRecordingVideo) {
      loaderHeight = 80;
      loaderWidth = 80;
      setState(() {});
      time?.cancel();
      // Video recording is not in progress
      return;
    }

    try {
      await _controller.stopVideoRecording();
    } on camera.CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  //resume video recording
  Future<void> resumeVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    loaderHeight = 110;
    loaderWidth = 110;
    setState(() {});
    try {
      await _controller.stopVideoRecording();
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

    // Update UI if _controller updated

    // try {
    //   await cameraController.initialize();
    //   await Future.wait([
    //     cameraController
    //         .getMinExposureOffset()
    //         .then((value) => _minAvailableExposureOffset = value),
    //     cameraController
    //         .getMaxExposureOffset()
    //         .then((value) => _maxAvailableExposureOffset = value),
    //     cameraController
    //         .getMaxZoomLevel()
    //         .then((value) => _maxAvailableZoom = value),
    //     cameraController
    //         .getMinZoomLevel()
    //         .then((value) => _minAvailableZoom = value),
    //   ]);
    //
    //   // _currentFlashMode = _controller!.value.flashMode;
    // } on CameraException catch (e) {
    //   print('Error initializing camera: $e');
    // }

    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller.value.isInitialized;
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
    // _controller!.setExposurePoint(offset);
    // _controller!.setFocusPoint(offset);
  }
}

class SelectSoundView extends GetView<SelectSoundController> {
  const SelectSoundView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.obx(
          (state) => state!.isEmpty
              ? Column(
                  children: [emptyListWidget()],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: state!.length,
                  itemBuilder: (context, index) => InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/Image.png",
                                        height: 80,
                                        width: 80,
                                      ),
                                      Container(
                                        height: 40,
                                        width: 40,
                                        child: imgProfile(
                                            state[index].soundOwner != null
                                                ? state[index]
                                                    .soundOwner!
                                                    .avtars
                                                    .toString()
                                                : RestUrl.placeholderImage),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        state[index].sound.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        state[index].soundOwner == null
                                            ? ""
                                            : state[index]
                                                .soundOwner!
                                                .name
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        state[index].soundOwner == null
                                            ? ""
                                            : state[index]
                                                .soundOwner!
                                                .name
                                                .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                state[index].soundOwner == null
                                    ? "0"
                                    : state[index]
                                        .soundOwner!
                                        .followersCount
                                        .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              )
                            ],
                          ),
                        ),
                        onTap: () async {
                          var fileSupport = FileSupport();
                          var currentProgress = "0".obs;
                          Get.defaultDialog(
                              title: "Downloading audio",
                              content: Obx(() => Text(currentProgress.value)));
                          await fileSupport
                              .downloadCustomLocation(
                            url: "${RestUrl.awsSoundUrl}${state[index].sound}",
                            path: saveCacheDirectory,
                            filename: basenameWithoutExtension(
                                state[index].sound.toString()),
                            extension: ".mp3",
                            progress: (progress) async {
                              currentProgress.value = progress;
                            },
                          )
                              .then((value) {
                            selectedSound.value = value!.path;
                            Get.back();
                            // Get.toNamed(Routes.CAMERA, arguments: {
                            //   "sound_url": value!.path,
                            //   "sound_name": soundName,
                            //   "sound_owner": userName
                            // });
                          }).onError((error, stackTrace) {
                            Get.back();
                            errorToast(error.toString());
                          });
                        },
                      )),
          onEmpty: Column(
            children: [emptyListWidget()],
          ),
          onLoading: Container(
            child: loader(),
            height: Get.height,
            width: Get.width,
          )),
    );
  }
}
