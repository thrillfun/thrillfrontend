import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/main.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/video/post.dart';
import 'package:thrill/screens/video/post_screen.dart';
import 'package:thrill/utils/custom_timer_painter.dart';
import 'package:thrill/utils/util.dart';

import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:video_player/video_player.dart';

import '../../common/color.dart';
import 'package:just_audio/just_audio.dart';

var timer = 60.obs;
Timer? time;
CameraController? _controller;

class CameraScreen extends StatefulWidget {
  CameraScreen({required this.selectedSound});

  String selectedSound = "";

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraScreen> {
  final player = AudioPlayer(); // Create a player

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

  ResolutionPreset currentResolutionPreset = ResolutionPreset.max;
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
      if (widget.selectedSound.isNotEmpty) {
        final duration = await player.setUrl(// Load a URL
            widget.selectedSound);
        timer.value = duration!.inSeconds;
      } // Schemes: (https: | file: | asset: )
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
      player.play();

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
      player.pause();

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
      await videoFile.copy('$directory/thrill/${rawVideo.name}');
      // FFmpegKit.execute(
      //     'ffmpeg -i ${videoFile.path} -filter:v "setpts=0.5*PTS" $directory/thrill/${rawVideo.name}')
      //     .then((value) => Get.snackbar('output', ''));

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
        } else {
          t.cancel();
          animationController?.stop();
          await stopVideoRecording();
          timer.value = 60;
          await player.stop();
        }

        // if (timer.value == 0 && _isRecordingInProgress) {
        //
        // }
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
    List<imgly.AudioClip> audioClips = [];
    if (widget.selectedSound!.isNotEmpty) {
      audioClips = [
        imgly.AudioClip("sample1", widget.selectedSound.toString()),
      ];
    } else {
      audioClips = [
        imgly.AudioClip("sample1", fileUrl),
        imgly.AudioClip("sample2",
            "https://thrillvideo.s3.amazonaws.com/sound/1660389291493.mp3"),
        imgly.AudioClip("sample3",
            "https://thrillvideo.s3.amazonaws.com/sound/1660388748807.mp3"),
        imgly.AudioClip("sample4",
            "https://thrillvideo.s3.amazonaws.com/sound/1660641003254.mp3")
      ];
    }

    var audioClipCategories = [
      imgly.AudioClipCategory("audio_cat_1", "AWS",
          thumbnailURI:
              "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1200px-Amazon_Web_Services_Logo.svg.png",
          items: audioClips),
    ];

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);
    var codec = imgly.VideoCodec.values;
    var exportOptions = imgly.ExportOptions(
        forceExport: true,
        video: imgly.VideoOptions(quality: 0.4, codec: codec[0]));

    imgly.WatermarkOptions waterMarkOptions = imgly.WatermarkOptions(
        RestUrl.assetsUrl + "logo.png",
        alignment: imgly.AlignmentMode.bottomRight);

    var stickerList = [
      imgly.StickerCategory.giphy(
          imgly.GiphyStickerProvider("Q1ltQCCxdfmLcaL6SpUhEo5OW6cBP6p0"))
    ];
    var themeOptions = imgly.ThemeOptions(imgly.Theme('',
        tintColor: ColorManager.colorAccent,
        primaryColor: ColorManager.colorAccent,
        backgroundColor: ColorManager.colorAccent,
        menuBackgroundColor: ColorManager.colorAccent,
        toolbarBackgroundColor: ColorManager.colorAccent));
    var trimOptions = imgly.TrimOptions(maximumDuration: 60);

    final configuration = imgly.Configuration(
      trim: trimOptions,
      theme: themeOptions,
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
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AspectRatio(
                          aspectRatio: .97 / _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 20, right: 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xff145158),
                                  Color(0xff193542),
                                  Color(0xff1A2C41)
                                ]),
                          ),
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
                                                _isRearCameraSelected ? 1 : 0]);
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
                                    child: Icon(
                                      Icons.speed,
                                      color: Colors.white,
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
                                        startTimer();
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
                                          size: 75,
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
                                          width: 80,
                                          height: 80,
                                          child: AnimatedBuilder(
                                            animation: DataController(),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return CustomPaint(
                                                  painter: CustomTimerPainter(
                                                animation: animationController!,
                                                backgroundColor: Colors.white,
                                                color: Colors.red,
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
                                  InkWell(
                                    onTap: () async {
                                      ImagePicker()
                                          .pickVideo(
                                              source: ImageSource.gallery)
                                          .then((value) => VESDK
                                                  .openEditor(
                                                      Video(value!.path))
                                                  .then((value) async {
                                                if (value != null) {
                                                  var addSoundModel =
                                                      AddSoundModel(
                                                          0,
                                                          userModel.id,
                                                          0,
                                                          "",
                                                          "",
                                                          '',
                                                          '',
                                                          false);
                                                  PostData postData = PostData(
                                                    speed: '1',
                                                    newPath: value.video,
                                                    filePath: value.video,
                                                    filterName: "",
                                                    addSoundModel:
                                                        addSoundModel,
                                                    isDuet: false,
                                                    isDefaultSound: widget
                                                            .selectedSound!
                                                            .isNotEmpty
                                                        ? false
                                                        : true,
                                                    isUploadedFromGallery: true,
                                                    trimStart: 0,
                                                    trimEnd: 0,
                                                  );
                                                  // Get.snackbar("path", value.video);

                                                  // await Get.to(PostVideo(
                                                  //     data: postData));
                                                  await Get.to(PostScreenGetx(
                                                    postData,
                                                  ));
                                                }
                                              }));
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
                        ))

                        //flash layout
                      ],
                    ),
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
        await Get.to(PostScreenGetx(
          postData,
        ));
        //await Get.to(PostVideo(data: postData));
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
