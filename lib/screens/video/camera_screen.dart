import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/utils/custom_timer_painter.dart';
import 'package:thrill/utils/util.dart';

import '../../controller/Favourites/favourites_controller.dart';
import '../../controller/videos_controller.dart';
import '../../main.dart';
import '../../widgets/sound_list_bottom_sheet.dart';

var timer = 60.obs;
Timer? time;
CameraController? _controller;
var usersController = Get.find<UserController>();
var videosController = Get.find<VideosController>();
var soundsController = Get.find<SoundsController>();
CarouselController buttonCarouselController = CarouselController();

File? file;

class CameraScreen extends StatefulWidget {
  CameraScreen(
      {required this.selectedSound, this.owner, this.id, this.soundName});

  String selectedSound = "";
  String? owner = "";
  int? id;
  String? soundName = "";

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraScreen> {
  var soundsController = Get.find<SoundsController>();
  var favouritesController = Get.find<FavouritesController>();

  File? _imageFile;
  File? _videoFile;
  var loaderWidth = 80.0;
  var loaderHeight = 80.0;
  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = true;
  bool _isRecordingInProgress = false;

  bool isRecordingComplete = false;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  AnimationController? animationController;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.medium;

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
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: _controller!.value.isInitialized
              ? Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    CameraPreview(_controller!),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: _isRecordingInProgress
                                    ? () async {
                                        if (!_controller!
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
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.black38,
                                      size: 50,
                                    ),
                                    Icon(
                                      _isRearCameraSelected
                                          ? Icons.camera_front
                                          : Icons.camera_rear,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() => DropdownButton(
                                    value: defaultVideoSpeed.value,
                                    items: items
                                        .map((e) => DropdownMenuItem(
                                              child: Text(
                                                e.toString() + "x",
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText),
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
                                    } on CameraException catch (e) {
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
                                      duration:
                                          const Duration(milliseconds: 400),
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
                              InkWell(
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
                                            .then((value) {
                                          if (value != null) {
                                            int currentUnix = DateTime.now()
                                                .millisecondsSinceEpoch;

                                            videosController.openEditor(
                                                true,
                                                value.path,
                                                soundsController
                                                        .selectedSoundPath
                                                        .value
                                                        .isEmpty
                                                    ? widget.selectedSound
                                                    : soundsController
                                                        .selectedSoundPath
                                                        .value,
                                                userDetailsController.storage
                                                    .read("userId"),
                                                userDetailsController
                                                        .userProfile
                                                        .value
                                                        .username ??
                                                    userDetailsController
                                                        .userProfile.value.name
                                                        .toString());
                                          }
                                        });
                                      });
                                    } else {
                                      await ImagePicker()
                                          .pickVideo(
                                              source: ImageSource.gallery)
                                          .then((value) {
                                        if (value != null) {
                                          int currentUnix = DateTime.now()
                                              .millisecondsSinceEpoch;

                                          videosController.openEditor(
                                              true,
                                              value.path,
                                              soundsController.selectedSoundPath
                                                      .value.isEmpty
                                                  ? widget.selectedSound
                                                  : soundsController
                                                      .selectedSoundPath.value,
                                              userDetailsController.storage
                                                  .read("userId"),
                                              userDetailsController.userProfile
                                                      .value.username ??
                                                  userDetailsController
                                                      .userProfile.value.name
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
                              //preview button
                              !isRecordingComplete
                                  ? InkWell(
                                      onTap: () async {
                                        if (_currentFlashMode ==
                                            FlashMode.off) {
                                          setState(() {
                                            _currentFlashMode = FlashMode.torch;
                                            // _controller!.setFlashMode(
                                            //     FlashMode.torch);
                                          });
                                        } else {
                                          setState(() {
                                            _currentFlashMode = FlashMode.off;

                                            // _controller!.setFlashMode(
                                            //     FlashMode.off);
                                          });
                                        }
                                        //await openEditor();
                                        // Get.to(VideoEditor(
                                        //   file: _videoFile!,
                                        // ));
                                      },
                                      child: _currentFlashMode == FlashMode.off
                                          ? const Icon(
                                              Icons.flash_off_rounded,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.flash_on_rounded,
                                              color: Colors.white,
                                            ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isRecordingComplete = true;
                                        });
                                        try {
                                          videosController.openEditor(
                                              false,
                                              "",
                                              soundsController.selectedSoundPath
                                                      .value.isEmpty
                                                  ? widget.selectedSound
                                                  : soundsController
                                                      .selectedSoundPath.value,
                                              widget.id!,
                                              userDetailsController.userProfile
                                                      .value.username ??
                                                  userDetailsController
                                                      .userProfile.value.name
                                                      .toString());
                                        } catch (e) {
                                          errorToast(e.toString());
                                        }
                                      },
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.white,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () => favouritesController.getFavourites().then(
                              (_) async =>
                                  soundsController.getSoundsList().then((_) {
                                soundsController.getAlbums();
                                Get.bottomSheet(SoundListBottomSheet(),
                                    isScrollControlled: true);
                              }),
                            ),
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
                            GetX<SoundsController>(
                                builder: (controller) => Text(
                                      controller.selectedSoundPath.value
                                                  .isEmpty &&
                                              widget.selectedSound.isEmpty
                                          ? "Select Sound"
                                          : basename(controller
                                                  .selectedSoundPath
                                                  .value
                                                  .isEmpty
                                              ? widget.selectedSound
                                              : controller
                                                  .selectedSoundPath.value),
                                      style: TextStyle(color: Colors.white),
                                    ))
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : //loading layout
              const Center(
                  child: Text(
                    'LOADING',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
    );
  }

  @override
  void initState() {
    // Hide the status bar in Android
    _getAvailableCameras();

    setState(() {
      file = File(soundsController.selectedSoundPath.value.isEmpty
          ? widget.selectedSound
          : soundsController.selectedSoundPath.value);
    });
    _currentFlashMode = FlashMode.off;
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));

    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController!.reset();
        loaderWidth = 80;
        loaderHeight = 80;
        stopVideoRecording();
        setState(() {
          isRecordingComplete = true;
        });
        try {
          videosController.openEditor(
              false,
              "",
              soundsController.selectedSoundPath.value.isEmpty
                  ? widget.selectedSound
                  : soundsController.selectedSoundPath.value,
              widget.id!,
              userDetailsController.userProfile.value.username ??
                  userDetailsController.userProfile.value.name.toString());
        } catch (e) {
          errorToast(e.toString());
        }
      }
    });

    super.initState();
  }

  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _initCamera(cameras.first);
  }

  // init camera
  Future<void> _initCamera(CameraDescription description) async {
    _controller =
        CameraController(description, ResolutionPreset.max, enableAudio: true);

    try {
      await _controller!.initialize();
      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller!.description);
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
    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
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
    var status = await Permission.camera.status;

    if (status.isGranted && await Permission.storage.isGranted) {
      log('Camera Permission: GRANTED');
      log('Storage permission granted');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');

      await Permission.camera
          .request()
          .then((value) async => await Permission.storage.request());

      return;
    }
  }

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      // startTimer();
      await _controller!.startVideoRecording().then((value) => {
            setState(() {
              loaderWidth = 110;
              loaderHeight = 110;
              _isRecordingInProgress = true;
              isRecordingComplete = false;
            })
          });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller!.value.isInitialized &&
        _controller!.value.isRecordingVideo) {
      try {
        XFile file = await _controller!.stopVideoRecording();
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
      } on CameraException catch (e) {
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
      loaderHeight = 80;
      loaderWidth = 80;
      setState(() {});
      time?.cancel();
      // Video recording is not in progress
      return;
    }

    try {
      await _controller!.stopVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  //resume video recording
  Future<void> resumeVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    loaderHeight = 110;
    loaderWidth = 110;
    setState(() {});
    try {
      await _controller!.stopVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  // reset camera values to default
  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;

    final CameraController cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

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
        _isCameraInitialized = _controller!.value.isInitialized;
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

  loadUserModel() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');

    setState(() {});
    var status = await Permission.storage.isGranted;
    if (!status) {
      Permission.storage.request();
    }
  }
}
