import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/main.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/video/post_screen.dart';
import 'package:thrill/utils/custom_timer_painter.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import '../../common/color.dart';

var timer = 60.obs;
Timer? time;
CameraController? _controller;

class CameraScreen extends StatefulWidget {
  CameraScreen({required this.selectedSound, this.owner, this.id});

  String selectedSound = "";
  String? owner = "";
  int? id;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin<CameraScreen> {
  var soundsController = Get.find<SoundsController>();

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

  //start video recording
  Future<void> startVideoRecording() async {
    if (_controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      // startTimer();
      await _controller!.startVideoRecording().then((value) =>
      {
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
    if (_controller!.value.isInitialized &&
        _controller!.value.isRecordingVideo) {
      try {
        var file = await _controller!.stopVideoRecording();
        File videoFile = File(file.path);

        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_PICTURES);

        if (await Directory('$directory/thrill').exists() == true) {
          print('Yes this directory Exists');
        } else {
          print('creating new Directory');
          Directory('$directory/thrill').create();
        }
        await videoFile.copy('$directory/thrill/${file.name}');
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
    soundsController.getSoundsList();
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
        openEditor(false, "");
      }
    });

    super.initState();
  }

  imgly.Configuration setConfig(List<SongInfo> albums) {
    var fileUrl = "https://samplelib.com/lib/preview/mp3/sample-15s.mp3";
    List<imgly.AudioClip> audioClips = [];

    albums.forEach((element) {
      audioClips.add(imgly.AudioClip(element.title, element.filePath,
          title: element.title,
          artist: element.artist,
          duration: double.parse(element.duration)));
    });
    late imgly.AudioClipCategory onlineCategory;

    if (soundsController.soundsList.isNotEmpty) {
      List<imgly.AudioClip> onlineAudioClips = [];
      soundsController.soundsList.forEach((element) {
        onlineAudioClips.add(imgly.AudioClip(element.name.toString(),
            RestUrl.soundUrl + element.sound.toString(),
            title: element.name));
      });
      onlineCategory = imgly.AudioClipCategory("online_cat", "online",
          thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png",
          items: onlineAudioClips);
    }


    var audioClipCategories = [

      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png",
          items: audioClips),
      onlineCategory
    ];

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);
    var codec = imgly.VideoCodec.values;
    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 0.9, codec: codec[0]),
    );

    imgly.WatermarkOptions waterMarkOptions = imgly.WatermarkOptions(
        RestUrl.assetsUrl + "transparent_logo.png",
        alignment: imgly.AlignmentMode.topLeft);

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
    var trimOptions = imgly.TrimOptions(
        maximumDuration: 60, forceMode: imgly.ForceTrimMode.always);

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
    animationController!.dispose();

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
            ? Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              context.isTablet
                  ? AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              )
                  : AspectRatio(
                aspectRatio: 9 / 16,
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
                                    if (animationController!
                                        .isAnimating &&
                                        animationController!.value <
                                            0.1) {
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
                                      animation: animationController!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return CustomPaint(
                                            painter: CustomTimerPainter(
                                              animation: animationController!,
                                              backgroundColor: Colors.white,
                                              color: Colors.red,
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
                                    .pickVideo(
                                    source: ImageSource.gallery)
                                    .then((value) async =>
                                    openEditor(true, value!.path));
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
                                openEditor(false, "");
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

  Future<void> openEditor(bool isGallery, String path) async {
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
    final dir = Directory("$directory/thrill");
    final List<FileSystemEntity> entities = await dir.list().toList();

    List<String> videosList = <String>[];

    entities.forEach((element) {
      videosList.add("${element.path}");
    });

    List<SongInfo> albums = [];
    try {
      FlutterAudioQuery flutterAudioQuery = FlutterAudioQuery();
      albums = await flutterAudioQuery.getSongs();
    } catch (e) {
      errorToast(e.toString());
    } finally {
      if (!isGallery) {
        await VESDK
            .openEditor(Video.composition(videos: videosList),
            configuration: setConfig(albums))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;

          print("data=>" + serializationData.toString());

          List<dynamic> operationData =
          serializationData['operations'].toList();

          if (value == null) {
            dir.exists().then((value) => dir.delete(recursive: true));
          }

          // await dir.delete(recursive: true);

          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          operationData.forEach((element) {
            Map<dynamic, dynamic> data = element['options'];
            if (data.containsKey("clips")) {
              isOriginal.value = false;
            }
          });
          if (!isOriginal.value) {
            operationData.forEach((operation) {
              albums.forEach((element) {
                if (operation['options']['type'] == 'audio') {
                  if (element.title.contains(operation['options']['clips'][0]
                  ['identifier']
                      .toString())) {
                    songPath = element.filePath;
                    songName = element.title;
                  }
                }
              });
            });

            if (value != null) {
              var addSoundModel = AddSoundModel(
                  0,
                 widget.id!,
                  0,
                  songPath.isNotEmpty ? songPath : path,
                  songName.isNotEmpty ? "$songName by ${widget.owner}" : "original by ${widget.owner}",
                  '',
                  '',
                  true);
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
              Get.to(() =>
                  PostScreenGetx(
                      postData,
                      widget.selectedSound
                  ));
            }
          } else {
            if (widget.selectedSound.isNotEmpty) {
              await FFmpegKit.execute(
                'ffmpeg -i ${value!.video} -i ${widget.selectedSound} -c:v copy -c:a aac $dir/selectedVideo.mp4'
                  )
                  .then((ffmpegValue)async  {
                   var data = await ffmpegValue.getOutput();
                   print(ffmpegValue);
                var addSoundModel = AddSoundModel(
                    0,
                    widget.id!,
                    0,
                    songPath.isNotEmpty ? songPath : path,
                    songName.isNotEmpty ? songName : "original by ${widget
                        .owner}",
                    '',
                    '',
                    true);
                PostData postData = PostData(
                  speed: '1',
                  newPath: "$dir/selectedVideo.mp4",
                  filePath: "$dir/selectedVideo.mp4",
                  filterName: "",
                  addSoundModel: addSoundModel,
                  isDuet: false,
                  isDefaultSound: true,
                  isUploadedFromGallery: true,
                  trimStart: 0,
                  trimEnd: 0,
                );
                Get.to(() =>
                    PostScreenGetx(
                        postData,
                        widget.selectedSound

                    ));
              });
            } else {
              await FFmpegKit.execute(
                  "-y -i ${value!
                      .video} -map 0:a -acodec libmp3lame $saveCacheDirectory/originalAudio.mp3")
                  .then((audio) async {
                if (value != null) {
                  var addSoundModel = AddSoundModel(
                      0,
                      widget.id!,
                      0,
                      songPath.isNotEmpty
                          ? songPath
                          : "$saveCacheDirectory/originalAudio.mp3",
                      songName.isNotEmpty ? songName : "original by ${widget.owner}",
                      '',
                      '',
                      true);
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
                  await Get.to(() =>
                      PostScreenGetx(
                          postData,
                          widget.selectedSound

                      ));
                }
              });
            }
          }
        });
      } else {
        await VESDK
            .openEditor(Video(path), configuration: setConfig(albums))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;

          print("data=>" + serializationData.toString());

          List<dynamic> operationData =
          serializationData['operations'].toList();

          if (value == null) {
            final dir = Directory("$directory/thrill");
            dir.exists().then((value) => dir.delete(recursive: true));
          }

          // await dir.delete(recursive: true);

          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          operationData.forEach((element) {
            Map<dynamic, dynamic> data = element['options'];
            if (data.containsKey("clips")) {
              isOriginal.value = false;
            }
          });
          if (!isOriginal.value) {
            operationData.forEach((operation) {
              albums.forEach((element) {
                if (operation['options']['type'] == 'audio') {
                  if (element.title.contains(operation['options']['clips'][0]
                  ['identifier']
                      .toString())) {
                    songPath = element.filePath;
                    songName = element.title;
                  }
                }
              });
            });

            if (value != null) {
              var addSoundModel = AddSoundModel(
                  0,
                  widget.id!,
                  0,
                  songPath.isNotEmpty
                      ? songPath
                      : "$saveCacheDirectory/originalAudio.mp3",
                  songName.isNotEmpty ? songName : "original by ${widget.owner}",
                  '',
                  '',
                  true);
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
              Get.to(() =>
                  PostScreenGetx(
                      postData, widget.selectedSound

                  ));
            }
          } else {
            await FFmpegKit.execute(
                "-y -i ${value!.video} -map 0:a -acodec libmp3lame $path")
                .then((audio) async {
              var addSoundModel = AddSoundModel(
                  0,
                  widget.id!,
                  0,
                  songPath.isNotEmpty
                      ? songPath
                      : "$saveCacheDirectory/originalAudio.mp3",
                  songName.isNotEmpty ? songName : "original by ${widget.owner}",
                  '',
                  '',
                  true);
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
              await Get.to(() =>
                  PostScreenGetx(
                      postData, widget.selectedSound

                  ));
            });
          }
        });
      }
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
