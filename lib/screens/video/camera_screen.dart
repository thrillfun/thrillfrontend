import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/main.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/screens/video/post.dart';
import 'package:thrill/utils/custom_timer_painter.dart';
import 'package:thrill/utils/util.dart';

import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:video_player/video_player.dart';

var timer = 30.obs;
Timer? time;
CameraController? _controller;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraScreen> {
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
  late UserModel userModel;

  //get camera permission status and start camera
  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  //referesh gallery to check new videos or images
  // refreshAlreadyCapturedImages() async {
  //   //get directory
  //   final directory = await getApplicationDocumentsDirectory();
  //   //get directory media list
  //   List<FileSystemEntity> fileList = await directory.list().toList();
  //   allFileList.clear();
  //   //get file names
  //   List<Map<int, dynamic>> fileNames = [];

  //   // loop through files lists containing video or audio
  //   fileList.forEach((file) {
  //     if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
  //       allFileList.add(File(file.path));

  //       String name = file.path.split('/').last.split('.').first;
  //       fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
  //     }
  //   });

  //   if (fileNames.isNotEmpty) {
  //     //get recent file
  //     final recentFile =
  //         fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
  //     String recentFileName = recentFile[1];

  //     //check if recent file is audio or video
  //     if (recentFileName.contains('.mp4')) {
  //       _videoFile = File('${directory.path}/$recentFileName');
  //       _imageFile = null;
  //       //   _startVideoPlayer();
  //     } else {
  //       _imageFile = File('${directory.path}/$recentFileName');
  //       _videoFile = null;
  //     }

  //     setState(() {});
  //   }
  // }

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        isRecordingComplete = false;
        // startTimer();
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile? rawVideo = await _controller!.stopVideoRecording();
      File videoFile = File(rawVideo.path);

      setState(() {
        _isRecordingInProgress = false;
      });

      File file = File(rawVideo.path);

      final directory = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_PICTURES);

      String fileFormat = videoFile.path.split('.').last;

      await checkDirectory('$directory/thrill');
      await videoFile.copy(
        '$directory/thrill/${rawVideo.name}',
      );

      // final dir = Directory("$directory/thrill");
      // final List<FileSystemEntity> entities = await dir.list().toList();

      // List<String> videosList = <String>[];

      // entities.forEach((element) {
      //   videosList.add("${element.path}");
      // });

      // await VESDK
      //     .openEditor(Video.composition(videos: videosList),
      //         configuration: setConfig("$directory/thrill"))
      //     .then((value) {
      //   print(value!.video);
      // });

      // _downloadImage(filterUrl);\
      setState(() {
        isRecordingComplete = true;
      });
      return rawVideo;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<Directory> checkDirectory(String path) async {
    var directory = await Directory(path).exists();
    if (directory) {
      print('Yes this directory Exists');
      return Directory(path);
    } else {
      print('creating new Directory');
      return Directory(path).create();
    }
  }

  //pause video recording and cancel timer
  Future<void> pauseVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      time?.cancel();
      // Video recording is not in progress
      return;
    }

    try {
      await _controller!.pauseVideoRecording();
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

    try {
      await _controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  //reset camera values to default
  // void resetCameraValues() async {
  //   _currentZoomLevel = 1.0;
  //   _currentExposureOffset = 0.0;
  // }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    // resetCameraValues();

    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if _controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      // _currentFlashMode = _controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }

  // void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
  //   if (_controller == null) {
  //     return;
  //   }

  //   final offset = Offset(
  //     details.localPosition.dx / constraints.maxWidth,
  //     details.localPosition.dy / constraints.maxHeight,
  //   );
  //   _controller!.setExposurePoint(offset);
  //   _controller!.setFocusPoint(offset);
  // }

  // //check permission
  @override
  void initState() {
    // Hide the status bar in Android
    loadUserModel();
    getPermissionStatus();
    _currentFlashMode = FlashMode.off;
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));
    super.initState();
  }

  //start timer for video recording to be ended on timer end
  void startTimer() async {
    //check if permission granted
    var status = await Permission.storage.status;
    if (status.isGranted) {
      time = Timer.periodic(Duration(seconds: 1), (t) async {
        if (timer.value > 0) {
          timer.value--;
        }

        if (timer.value == 0 && _isRecordingInProgress) {
          t.cancel();
          await stopVideoRecording();
        }
      });
    } else {
      //ask for permission
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  imgly.Configuration setConfig() {
    var fileUrl = "https://samplelib.com/lib/preview/mp3/sample-15s.mp3";

    var audioClips = [
      imgly.AudioClip("sample1", fileUrl),
      imgly.AudioClip("sample2",
          "https://thrillvideo.s3.amazonaws.com/sound/1660389291493.mp3"),
      imgly.AudioClip("sample3",
          "https://thrillvideo.s3.amazonaws.com/sound/1660388748807.mp3"),
      imgly.AudioClip("sample4",
          "https://thrillvideo.s3.amazonaws.com/sound/1660641003254.mp3")
    ];

    var audioClipCategories = [
      imgly.AudioClipCategory("audio_cat_1", "AWS",
          thumbnailURI:
              "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1200px-Amazon_Web_Services_Logo.svg.png",
          items: audioClips),
    ];

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);

    var exportOptions = imgly.ExportOptions(
        forceExport: true, video: imgly.VideoOptions(quality: 0.4));

    imgly.WatermarkOptions waterMarkOptions = imgly.WatermarkOptions(
        "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1200px-Amazon_Web_Services_Logo.svg.png",
        alignment: imgly.AlignmentMode.center);

    var stickerList = [
      imgly.StickerCategory.giphy(
          imgly.GiphyStickerProvider("Q1ltQCCxdfmLcaL6SpUhEo5OW6cBP6p0"))
    ];
    final configuration = imgly.Configuration(
      sticker:
          imgly.StickerOptions(personalStickers: true, categories: stickerList),
      audio: audioOptions,
      export: exportOptions,
      watermark: waterMarkOptions,
    );
    return configuration;
  }

  // manage life cycle changes for camera controller
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    // if app state is inactive dispose controller else create new instance
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  //dispose camera controller and timer
  @override
  void dispose() {
    _controller?.dispose();
    time?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.bottomCenter,
                        children: [
                          //camera preview layout
                          Container(
                            width: Get.width,
                            height: Get.height,
                            child: CameraPreview(
                              _controller!,
                            ),
                          ),
                          //filter overlay layout
                          Container(
                            height: 80,
                            margin: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                                gradient: profile_gradient,
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(25))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // // timer picker layout

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: _isRecordingInProgress
                                          ? () async {
                                              if (_controller!
                                                  .value.isRecordingPaused) {
                                                await resumeVideoRecording();
                                              } else {
                                                await pauseVideoRecording();
                                              }
                                            }
                                          : () {
                                              setState(() {
                                                _isCameraInitialized = false;
                                              });
                                              onNewCameraSelected(cameras[
                                                  _isRearCameraSelected
                                                      ? 1
                                                      : 0]);
                                              setState(() {
                                                _isRearCameraSelected =
                                                    !_isRearCameraSelected;
                                              });
                                            },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            color: Colors.black38,
                                            size: 50,
                                          ),
                                          _isRecordingInProgress
                                              ? _controller!
                                                      .value.isRecordingPaused
                                                  ? const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 20,
                                                    )
                                                  : const Icon(
                                                      Icons.pause,
                                                      color: Colors.white,
                                                      size: 20,
                                                    )
                                              : Icon(
                                                  _isRearCameraSelected
                                                      ? Icons.camera_front
                                                      : Icons.camera_rear,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                        ],
                                      ),
                                    ),
                                    //video recording button click listener
                                    InkWell(
                                      onTap: () async {
                                        if (_isRecordingInProgress) {
                                          isRecordingRunning();
                                          await stopVideoRecording();
                                        } else {
                                          isRecordingRunning();
                                          await startVideoRecording();
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: _isVideoCameraSelected
                                                ? Colors.white
                                                : Colors.white38,
                                            size: 50,
                                          ),
                                          const Icon(
                                            Icons.circle,
                                            color: Colors.red,
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
                                            width: 50,
                                            height: 50,
                                            child: AnimatedBuilder(
                                              animation: DataController(),
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return CustomPaint(
                                                    painter: CustomTimerPainter(
                                                  animation:
                                                      animationController!,
                                                  backgroundColor: Colors.white,
                                                  color:
                                                      Colors.blueGrey.shade900,
                                                ));
                                              },

                                              // return CountDownProgressIndicator(
                                              //   controller:
                                              //       countDownController,
                                              //   valueColor: Colors.red,
                                              //   autostart: false,
                                              //   backgroundColor: Colors.white,
                                              //   initialPosition: 0,
                                              //   duration: timer.value,
                                              //   onComplete:
                                              //       (timerValue) async {
                                              //         timer.value = timerValue;
                                              //     if (_isRecordingInProgress ||
                                              //         timer.value == 0) {
                                              //       await stopVideoRecording();
                                              //       openEditor();
                                              //     }
                                              //   },
                                              // );
                                            ),
                                          )
                                        ],
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
                                                  _controller!.setFlashMode(
                                                      FlashMode.torch);
                                                });
                                              } else {
                                                setState(() {
                                                  _currentFlashMode =
                                                      FlashMode.off;

                                                  _controller!.setFlashMode(
                                                      FlashMode.off);
                                                });
                                              }
                                              //await openEditor();
                                              // Get.to(VideoEditor(
                                              //   file: _videoFile!,
                                              // ));
                                            },
                                            child: _currentFlashMode ==
                                                    FlashMode.off
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
                                              openEditor();
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
                          )
                        ],
                      ),

                      //flash layout
                    ],
                  )
                : //loading layout
                const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : //permission denied layout
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  const Text(
                    'Permission denied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Give permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void isRecordingRunning() {
    if (animationController!.isAnimating)
      animationController?.stop();
    else {
      animationController!.reverse(
          from: animationController?.value == 0.0
              ? 1.0
              : animationController?.value);
    }
  }

  Future<void> openEditor() async {
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);

    final dir = Directory("$directory/thrill");
    final List<FileSystemEntity> entities = await dir.list().toList();

    List<String> videosList = <String>[];

    entities.forEach((element) {
      videosList.add("${element.path}");
    });

    return await VESDK
        .openEditor(Video.composition(videos: videosList),
            configuration: setConfig())
        .then((value) async {
      if (value == null) {
        final dir = Directory("$directory/thrill");
        dir.exists().then((value) => dir.delete(recursive: true));
      }
      await dir.delete(recursive: true);

      if (value != null) {
        var addSoundModel =
            AddSoundModel(0, userModel.id, 0, "", "", '', '', false);
        PostData postData = PostData(
          speed: '1',
          newPath: value.video,
          filePath: value.video,
          filterName: "",
          addSoundModel: addSoundModel,
          isDuet: false,
          isDefaultSound: true,
          isUploadedFromGallery: true,
          trimStart: 0,
          trimEnd: 0,
        );
        // Get.snackbar("path", value.video);
        await Get.to(PostVideo(data: postData));
      }

      print(value!.video);
    });
  }

  loadUserModel() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    userModel = UserModel.fromJson(jsonDecode(currentUser!));

    setState(() {});
    var status = await Permission.storage.isGranted;
    if (!status) {
      Permission.storage.request();
    }
  }
}
