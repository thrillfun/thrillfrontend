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
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/main.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/post_data.dart';
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

var timer = 10.obs;
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
  late User userModel;

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
    loadUserModel();
    getPermissionStatus();
    _currentFlashMode = FlashMode.off;
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));

    super.initState();
  }

  imgly.Configuration setConfig(List<SongInfo> albums) {
    var fileUrl = "https://samplelib.com/lib/preview/mp3/sample-15s.mp3";
    List<imgly.AudioClip> audioClips = [];

    albums.forEach((element) {
      audioClips.add(imgly.AudioClip(
        element.title,
        element.filePath,
      ));
    });

    var audioClipCategories = [
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI:
              "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1200px-Amazon_Web_Services_Logo.svg.png",
          items: audioClips),
    ];

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);
    var codec = imgly.VideoCodec.values;
    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 0.4, codec: codec[0]),
    );

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
                        AspectRatio(
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
                                          await stopVideoRecording();
                                          isRecordingRunning();
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
                                          .then((value) async => await VESDK
                                                  .openEditor(
                                                      Video(value!.path))
                                                  .then((value) async {
                                                if (value != null) {
                                                  var addSoundModel =
                                                      AddSoundModel(
                                                          0,
                                                          userModel.id!,
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
    if (animationController!.isAnimating) {
      animationController!.stop();
    } else {
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
    List<SongInfo> albums = [];
    try {
      FlutterAudioQuery flutterAudioQuery = FlutterAudioQuery();
      albums = await flutterAudioQuery.getSongs();
    } catch (e) {
      errorToast(e.toString());
    } finally {
      await VESDK
          .openEditor(Video.composition(videos: videosList),
              configuration: setConfig(albums))
          .then((value) async {
        Map<dynamic, dynamic> serializationData = await value?.serialization;

        print("data=>" + serializationData.toString());

        List<dynamic> operationData = serializationData['operations'].toList();

        if (value == null) {
          final dir = Directory("$directory/thrill");
          dir.exists().then((value) => dir.delete(recursive: true));
        }

        await dir.delete(recursive: true);

        var isOriginal = true.obs;
        var path = '/storage/emulated/0/download/originalaudio.mp3';
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
              if(operation['options']['type'] =='audio'){
                if (element.title.contains(operation
                ['options']['clips'][0]['identifier']
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
                userModel.id!,
                0,
                songPath.isNotEmpty ? songPath : path,
                songName.isNotEmpty ? songName : "original",
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
            Get.to(() => PostScreenGetx(
              postData,
            ))?.then((value) async {
              File audioFile = File(path);
              await audioFile.delete(recursive: true);
            });
          }
        } else {
          await FFmpegKit.execute(
                  "-i ${value!.video} -map 0:a -acodec libmp3lame $path")
              .then((audio) async {
            if (value != null) {
              var addSoundModel = AddSoundModel(
                  0,
                  userModel.id!,
                  0,
                  songPath.isNotEmpty ? songPath : path,
                  songName.isNotEmpty ? songName : "original",
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
              await Get.to(() => PostScreenGetx(
                    postData,
                  ));
              File audioFile = File(path);
              await audioFile.delete(recursive: true);
            }
          });
        }
      });
    }
  }

  loadUserModel() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    userModel = User.fromJson(jsonDecode(currentUser!));

    setState(() {});
    var status = await Permission.storage.isGranted;
    if (!status) {
      Permission.storage.request();
    }
  }
}
