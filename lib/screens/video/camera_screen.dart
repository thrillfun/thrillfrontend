import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../widgets/sound_list_bottom_sheet.dart';

var timer = 60.obs;
Timer? time;
DeepArController? _controller;
var usersController = Get.find<UserController>();
var videosController = Get.find<VideosController>();
var soundsController = Get.find<SoundsController>();

File? file;

class CameraScreen extends StatefulWidget {
  CameraScreen({required this.selectedSound, this.owner, this.id,this.soundName});

  String selectedSound = "";
  String? owner = "";
  int? id;
  String? soundName="";

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraScreen> {
  var soundsController = Get.find<FavouritesController>();

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = true;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

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
  getPermissionStatus() async {
    await Permission.storage.request();
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      log('Storage permission granted');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      // onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller!.isRecording) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      // startTimer();
      await _controller!.startVideoRecording().then((value) => {
            setState(() {
              _isRecordingInProgress = true;
              isRecordingComplete = false;
            })
          });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller!.isInitialized && _controller!.isRecording) {
      try {
        var file = await _controller!.stopVideoRecording();
        File videoFile = File(file.path);
        successToast(videoFile.path);
        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_PICTURES);

        if (await Directory('$directory/thrill').exists() == true) {
          print('Yes this directory Exists');
        } else {
          print('creating new Directory');
          Directory('$directory/thrill').create();
        }
        await videoFile.copy('$directory/thrill/${basename(file.path)}');
        setState(() {
          _isRecordingInProgress = false;
          isRecordingComplete = true;
        });
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

  Future<Directory> checkDirectory(String path) async {
    if (await Directory(path).exists() == true) {
      print('Yes this directory Exists');
      return Directory(path);
    } else {
      print('creating new Directory');
      return Directory(path).create();
    }
  }

  //pause video recording and cancel timer
  Future<void> pauseVideoRecording() async {
    if (!_controller!.isRecording) {
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
    if (!_controller!.isRecording) {
      // No video recording was in progress
      return;
    }

    try {
      await _controller!.stopVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  //reset camera values to default
  // void resetCameraValues() async {
  //   _currentZoomLevel = 1.0;
  //   _currentExposureOffset = 0.0;
  // }

  // void onNewCameraSelected(CameraDescription cameraDescription) async {
  //   final previousCameraController = _controller;
  //
  //   final DeepArController cameraController = DeepArController(
  //
  //   );
  //
  //   await previousCameraController?.destroy();
  //
  //   // resetCameraValues();
  //
  //   if (mounted) {
  //     setState(() {
  //       _controller = cameraController;
  //     });
  //   }
  //
  //   // Update UI if _controller updated
  //
  //
  //   // try {
  //   //   await cameraController.initialize();
  //   //   await Future.wait([
  //   //     cameraController
  //   //         .getMinExposureOffset()
  //   //         .then((value) => _minAvailableExposureOffset = value),
  //   //     cameraController
  //   //         .getMaxExposureOffset()
  //   //         .then((value) => _maxAvailableExposureOffset = value),
  //   //     cameraController
  //   //         .getMaxZoomLevel()
  //   //         .then((value) => _maxAvailableZoom = value),
  //   //     cameraController
  //   //         .getMinZoomLevel()
  //   //         .then((value) => _minAvailableZoom = value),
  //   //   ]);
  //   //
  //   //   // _currentFlashMode = _controller!.value.flashMode;
  //   // } on CameraException catch (e) {
  //   //   print('Error initializing camera: $e');
  //   // }
  //
  //   if (mounted) {
  //     setState(() {
  //       _isCameraInitialized = _controller!.isInitialized;
  //     });
  //   }
  // }

  // void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
  //   if (_controller == null) {
  //     return;
  //   }
  //
  //   final offset = Offset(
  //     details.localPosition.dx / constraints.maxWidth,
  //     details.localPosition.dy / constraints.maxHeight,
  //   );
  //   // _controller!.setExposurePoint(offset);
  //   // _controller!.setFocusPoint(offset);
  // }

  // //check permission
  final List<String> _effectsList = [];

  @override
  void initState() {
    // Hide the status bar in Android
    _controller = DeepArController()
      ..initialize(
        androidLicenseKey:
            "776ad3d8bd64b9451697e4640fc4552fb8956c6253d5dab714851ddebb4e387749a8b70ce2feffdb",
        iosLicenseKey: "",
      ).then((value) async {
        setState(() {
          _controller!.switchEffect("assets/effects/horns.deepar");
        });
      });
    _effectsList.add("assets/effects/" + 'burning_effect.deepar');
    _effectsList.add("assets/effects/" + 'flower_face.deepar');
    _effectsList.add("assets/effects/" + 'Hope.deepar');
    _effectsList.add("assets/effects/" + 'viking_helmet.deepar');
    _effectsList.add("assets/effects/" + 'burning_effect.deepar');
    _effectsList.add("assets/effects/" + 'flower_face.deepar');
    _effectsList.add("assets/effects/" + 'Hope.deepar');
    _effectsList.add("assets/effects/" + 'viking_helmet.deepar');

    soundsController.selectedSoundPath.value = widget.soundName??"";

    file = File(soundsController.selectedSoundPath.value);
    getPermissionStatus();
    _currentFlashMode = FlashMode.off;
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));

    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController!.reset();
        stopVideoRecording();
        setState(() {
          isRecordingComplete = true;
        });
        try {
          videosController.openEditor(
              false,
              "",
              soundsController.selectedSoundPath.value,
              widget.id!,
              userDetailsController.userProfile.value.username.toString());
        } catch (e) {
          errorToast(e.toString());
        }
      }
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller!
        .initialize(
      androidLicenseKey:
          "776ad3d8bd64b9451697e4640fc4552fb8956c6253d5dab714851ddebb4e387749a8b70ce2feffdb",
      iosLicenseKey: "",
    )
        .then((value) async {
      setState(() {
        _controller!.switchEffect("assets/effects/horns.deepar");
      });
    });
  }

  //dispose camera controller and timer
  @override
  void dispose() {
    _controller?.destroy();
    animationController!.dispose();

    time?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: _controller!.isInitialized
              ? Container(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Column(
                        children: [
                          DeepArPreview(_controller!)

                          //flash layout
                        ],
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 50),
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // // timer picker layout
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: _isRecordingInProgress
                                      ? () async {
                                          if (!_controller!.isRecording) {
                                            await resumeVideoRecording();
                                          } else {
                                            await pauseVideoRecording();
                                          }
                                        }
                                      : () {
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
                                InkWell(
                                  onTap: () async {},
                                  child: const Icon(
                                    Icons.speed,
                                    color: Colors.white,
                                  ),
                                ),
                                //video recording button click listener
                                InkWell(
                                  onTap: () async {
                                    if (_isRecordingInProgress) {
                                      try {
                                        if (animationController!.isAnimating &&
                                            animationController!.value < 0.1) {
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
                                              ColorManager
                                                  .colorAccentTransparent
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
                                        color:ColorManager.colorPrimaryLight,
                                        size: 35,
                                      ),
                                      _isRecordingInProgress
                                          ? const Icon(
                                              Icons.stop_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            )
                                          : Container(),
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: AnimatedBuilder(
                                          animation: animationController!,
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return CustomPaint(
                                                painter: CustomTimerPainter(
                                              animation: animationController!,
                                              backgroundColor: ColorManager.colorAccentTransparent,
                                              color: ColorManager.colorAccent,
                                            ));
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    ImagePicker()
                                        .pickVideo(source: ImageSource.gallery)
                                        .then((value) {
                                      if (value != null) {
                                        int currentUnix = DateTime.now()
                                            .millisecondsSinceEpoch;

                                        // videosController
                                        //     .awsUploadVideo(
                                        //         File(value.path),
                                        //         currentUnix)
                                        //     .then((_) => videosController
                                        //         .postVideo(
                                        //             userDetailsController.storage.read("userId"),
                                        //             basename(value.path),
                                        //             "",
                                        //             "original",
                                        //             "",
                                        //             "testing",
                                        //             'yes',
                                        //             1,
                                        //             "testing",
                                        //             "",
                                        //             "english",
                                        //             "",
                                        //             "1",
                                        //             true,
                                        //             true,
                                        //             "",
                                        //             true,
                                        //             widget.id!));
                                        videosController.openEditor(
                                            true,
                                            value.path,
                                            soundsController
                                                .selectedSoundPath.value,
                                            userDetailsController.storage
                                                .read("userId"),
                                            userDetailsController.userProfile.value.name.toString());
                                      }
                                    });
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
                                              _currentFlashMode =
                                                  FlashMode.torch;
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
                                        child:
                                            _currentFlashMode == FlashMode.off
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
                                                soundsController
                                                    .selectedSoundPath.value,
                                                widget.id!,
                                                userDetailsController.userProfile.value.name.toString());
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
                          onTap: () => soundsController.getFavourites().then(
                                (value) async => Get.bottomSheet(
                                    SoundListBottomSheet(),
                                    isScrollControlled: true),
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
                              Obx(() => Text(
                                    soundsController
                                            .selectedSoundPath.value.isEmpty
                                        ? "Select Sound"
                                        : basename(soundsController
                                            .selectedSoundPath.value),
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            _effectsList.length,
                                (index) => InkWell(
                              onTap: () => _controller!
                                  .switchEffect(_effectsList[index]),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: NetworkImage(index == 0
                                            ? "https://play-lh.googleusercontent.com/FwEmMaNepm9BO8dh9KHLDVPpcEMfzQy7SLHVFVHnx-UTG9JbYmFRpjQPtK9MjkSsCw"
                                            : index == 1
                                            ? "https://i.pinimg.com/originals/18/78/58/18785808bf8a3b8dde95fa9e23786800.jpg"
                                            : index == 2
                                            ? "https://static.dezeen.com/uploads/2019/05/ar-designers-filters_dezeen_hero-852x479.jpg"
                                            : index == 3
                                            ? "https://cdn.vox-cdn.com/thumbor/3V_JJTbP9jnleWKVHsFq9Yf38ok=/0x48:3556x2715/1400x1400/filters:focal(0x48:3556x2715):format(jpeg)/cdn.vox-cdn.com/uploads/chorus_image/image/49435979/GettyImages-159392065.0.0.jpg"
                                            : RestUrl
                                            .placeholderImage),fit: BoxFit.cover)),
                              ),
                            )),
                      ),),
                    ],
                  ),
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
