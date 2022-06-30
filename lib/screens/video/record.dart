import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/models/post_data.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../main.dart';
import '../../utils/util.dart';

class Record extends StatefulWidget {
  const Record({Key? key, required this.soundMap}) : super(key: key);
  final Map? soundMap;

  @override
  State<Record> createState() => _RecordState();

  static const String routeName = '/record';

  static Route route({Map? soundMap_}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => Record(soundMap: soundMap_,),
    );
  }
}

class _RecordState extends State<Record> with WidgetsBindingObserver {
  int selectedDuration = 35;

  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = false;
  bool _isRecordingInProgress = false;
  File? _videoFile;
  VideoPlayerController? videoController;
  bool _isPlayPause = false;
  String mainPath = "";
  String mainName = "";
  String mainNameFirst = "";
  String filterImage = "";
  List<String> effectsfirst = List<String>.empty(growable: true);
  String? selectedSound;
  //AddSoundModel? addSoundModel;
  String? pickedSoundPath;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? autoStopRecordingTimer;
  Duration videoDuration = const Duration();

  /*final deepArController = CameraDeepArController(config);
  String _platformVersion = 'Unknown';
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;

  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return masks;
      case CameraMode.effect:
        return effects;
      case CameraMode.filter:
        return filters;
      default:
        return masks;
    }
  }

  List masks = [
    "none",
    "assets/aviators",
    "assets/bigmouth",
    "assets/lion",
    "assets/dalmatian",
    "assets/bcgseg",
    "assets/look2",
    "assets/fatify",
    "assets/flowers",
    "assets/grumpycat",
    "assets/koala",
    "assets/mudmask",
    "assets/obama",
    "assets/pug",
    "assets/slash",
    "assets/sleepingmask",
    "assets/smallface",
    "assets/teddycigar",
    "assets/tripleface",
    "assets/twistedface",
  ];
  List effects = [
    "none",
    "assets/fire",
    "assets/heart",
    "assets/blizzard",
    "assets/rain",
  ];
  List filters = [
    "none",
    "assets/drawingmanga",
    "assets/sepia",
    "assets/bleachbypass",
    "assets/realvhs",
    "assets/filmcolorperfection"
  ];*/

  double sliderValue = 0;

  @override
  void initState() {
    if(widget.soundMap!=null){
      selectedSound = widget.soundMap?["soundName"];
      pickedSoundPath = widget.soundMap?["soundPath"];
    }
    onNewCameraSelected(cameras[0]);
    super.initState();

   // CameraDeepArController.checkPermissions();
  /*  deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      _platformVersion = "onCameraReady $v";
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      _platformVersion = "onSnapPhotoCompleted $v";
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      _platformVersion = "onVideoRecordingComplete $v";
      setState(() {});
    }, onSwitchEffect: (v) {
      _platformVersion = "onSwitchEffect $v";
      setState(() {});
    }));*/

    effectsfirst.addAll({
      'assets/filter0.gif',
      'assets/filter1.gif',
      'assets/filter2.gif',
      'assets/filter3.gif',
      'assets/filter4.gif',
      'assets/filter5.gif',
      'assets/filter7.gif'
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    if(videoController!=null){videoController!.dispose();}
    audioPlayer.stop();
    audioPlayer.dispose();
    autoStopRecordingTimer?.cancel();
  //  deepArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          _isCameraInitialized && _videoFile == null
              ? controller!.buildPreview()
              : Stack(
                  children: [
                    SizedBox(
                      width: getWidth(context),
                      height: getHeight(context),
                      child: videoController != null &&
                              videoController!.value.isInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: AspectRatio(
                                aspectRatio: videoController!.value.aspectRatio,
                                child: VideoPlayer(videoController!),
                              ),
                            )
                          : Container(),
                    ),
                    filterImage.isEmpty
                        ? const SizedBox(width: 5)
                        : Image.asset(
                            filterImage,
                            fit: BoxFit.cover,
                            width: getWidth(context),
                            height: getHeight(context),
                          ),
                  ],
                ),
        //  DeepArPreview(deepArController),

      /*    Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              //height: 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Response >>> : $_platformVersion\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              if (null == deepArController) return;
                              if (isRecording) return;
                              deepArController.snapPhoto();
                            },
                            child: Icon(Icons.camera_enhance_outlined),
                            color: Colors.white,
                            padding: EdgeInsets.all(15),
                          ),
                        ),
                        if (displayMode == DisplayMode.image)
                          Expanded(
                            child: FlatButton(
                              onPressed: () async {
                                String path = "assets/testImage.png";
                                final file = await deepArController
                                    .createFileFromAsset(path, "test");

                                // final file = await ImagePicker()
                                //     .pickImage(source: ImageSource.gallery);
                                await Future.delayed(Duration(seconds: 1));

                                deepArController.changeImage(file.path);
                                print("DAMON - Calling Change Image Flutter");
                              },
                              child: Icon(Icons.image),
                              color: Colors.orange,
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        if (isRecording)
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                if (null == deepArController) return;
                                deepArController.stopVideoRecording();
                                isRecording = false;
                                setState(() {});
                              },
                              child: Icon(Icons.videocam_off),
                              color: Colors.red,
                              padding: EdgeInsets.all(15),
                            ),
                          )
                        else
                          Expanded(
                            child: FlatButton(
                              onPressed: () {
                                if (null == deepArController) return;
                                deepArController.startVideoRecording();
                                isRecording = true;
                                setState(() {});
                              },
                              child: Icon(Icons.videocam),
                              color: Colors.green,
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(15),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(effectList.length, (p) {
                        bool active = currentEffect == p;
                        String imgPath = effectList[p];
                        return GestureDetector(
                          onTap: () async {
                            if (!deepArController.value.isInitialized) return;
                            currentEffect = p;
                            deepArController.switchEffect(
                                cameraMode, imgPath);
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.all(6),
                            width: active ? 70 : 55,
                            height: active ? 70 : 55,
                            alignment: Alignment.center,
                            child: Text(
                              "$p",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: active ? FontWeight.bold : null,
                                  fontSize: active ? 16 : 14,
                                  color:
                                  active ? Colors.white : Colors.black),
                            ),
                            decoration: BoxDecoration(
                                color: active ? Colors.orange : Colors.white,
                                border: Border.all(
                                    color:
                                    active ? Colors.orange : Colors.white,
                                    width: active ? 2 : 0),
                                shape: BoxShape.circle),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: List.generate(CameraMode.values.length, (p) {
                      CameraMode mode = CameraMode.values[p];
                      bool active = cameraMode == mode;

                      return Expanded(
                        child: Container(
                          height: 40,
                          margin: EdgeInsets.all(2),
                          child: TextButton(
                            onPressed: () async {
                              cameraMode = mode;
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              primary: Colors.black,
                              // shape: CircleBorder(
                              //     side: BorderSide(
                              //         color: Colors.white, width: 3))
                            ),
                            child: Text(
                              describeEnum(mode),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: active ? FontWeight.bold : null,
                                  fontSize: active ? 16 : 14,
                                  color: Colors.white
                                      .withOpacity(active ? 1 : 0.6)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: List.generate(DisplayMode.values.length, (p) {
                      DisplayMode mode = DisplayMode.values[p];
                      bool active = displayMode == mode;

                      return Expanded(
                        child: Container(
                          height: 40,
                          margin: EdgeInsets.all(2),
                          child: TextButton(
                            onPressed: () async {
                              displayMode = mode;
                              await deepArController.setDisplayMode(
                                  mode: mode);
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.purple,
                              primary: Colors.black,
                              // shape: CircleBorder(
                              //     side: BorderSide(
                              //         color: Colors.white, width: 3))
                            ),
                            child: Text(
                              describeEnum(mode),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: active ? FontWeight.bold : null,
                                  fontSize: active ? 16 : 14,
                                  color: Colors.white
                                      .withOpacity(active ? 1 : 0.6)),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
          ),

*/


          Positioned(
            top: 2, left: 0, right: 0,
            child: SliderTheme(
              data: SliderThemeData(
                thumbShape: SliderComponentShape.noThumb,
                overlayShape: SliderComponentShape.noThumb,
                trackHeight: 2,
              ),
              child: Slider(
                  value: sliderValue,
                  max: selectedDuration.toDouble(),
                  activeColor: ColorManager.cyan,
                  inactiveColor: Colors.transparent,
                  onChanged: (double val){}
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 60,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      if(_videoFile?.existsSync()??false){
                        _videoFile?.deleteSync();
                      }
                      Navigator.pop(context);
                    },
                    iconSize: 35,
                    color: Colors.white,
                    icon: const Icon(Icons.close)),
                const Spacer(),
                TextButton(
                    onPressed: () async {
                      // await Navigator.pushNamed(context, "/addSound").then((value) {
                      //   if(value!=null){
                      //     AddSoundModel? addSoundModelTemp = value as AddSoundModel?;
                      //     setState((){
                      //       addSoundModel = addSoundModelTemp;
                      //       selectedSound = addSoundModelTemp?.name;
                      //     });
                      //   }
                      // });
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3'], allowMultiple: false);
                      if(result!=null){
                        File file = File(result.files.single.path!);
                        double size = file.lengthSync()/1000000;
                        String name = file.path.split('/').last.split('.').first;
                        if(size < 6){
                          if(size > 0.2){
                            setState(() {
                              pickedSoundPath = file.path;
                              selectedSound = name;
                            });
                          } else {
                            showErrorToast(context, "File Size too Small!!");
                          }
                        } else {
                          showErrorToast(context, "Max File Size is 5 MB");
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/music.svg'),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          selectedSound==null?addSound:selectedSound!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
              top: 200,
              right: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (!_isRecordingInProgress) {
                        setState(() {
                          _isCameraInitialized = false;
                        });
                        onNewCameraSelected(
                          cameras[_isRearCameraSelected ? 0 : 1],
                        );
                        setState(() {
                          _isRearCameraSelected = !_isRearCameraSelected;
                        });
                      }
                    },
                    iconSize: 40,
                    icon: Icon(
                      _isRearCameraSelected
                          ? Icons.camera_front
                          : Icons.camera_rear,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      iconSize: 40,
                      icon: SvgPicture.asset('assets/flash_on.svg')),
                  IconButton(
                      onPressed: () {},
                      iconSize: 40,
                      icon: SvgPicture.asset('assets/stopwatch.svg')),
                  IconButton(
                      onPressed: () {},
                      iconSize: 45,
                      icon: SvgPicture.asset('assets/woman-makeup.svg'))
                ],
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                color: Colors.black,
                child: Visibility(
                  visible: !_isRecordingInProgress && _videoFile==null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedDuration = 60;
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text(
                                '60s',
                                style: TextStyle(
                                    color: selectedDuration == 60
                                        ? Colors.white
                                        : Colors.white60),
                              )),
                          selectedDuration == 60 ? dot() : const SizedBox()
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedDuration = 45;
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text(
                                '45s',
                                style: TextStyle(
                                    color: selectedDuration == 45
                                        ? Colors.white
                                        : Colors.white60),
                              )),
                          selectedDuration == 45 ? dot() : const SizedBox()
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedDuration = 35;
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text(
                                '35s',
                                style: TextStyle(
                                    color: selectedDuration == 35
                                        ? Colors.white
                                        : Colors.white60),
                              )),
                          selectedDuration == 35 ? dot() : const SizedBox()
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedDuration = 25;
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text(
                                '25s',
                                style: TextStyle(
                                    color: selectedDuration == 25
                                        ? Colors.white
                                        : Colors.white60),
                              )),
                          selectedDuration == 25 ? dot() : const SizedBox()
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedDuration = 15;
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text(
                                '15s',
                                style: TextStyle(
                                    color: selectedDuration == 15
                                        ? Colors.white
                                        : Colors.white60),
                              )),
                          selectedDuration == 15 ? dot() : const SizedBox()
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          Positioned(
              bottom: 70,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: !_isRecordingInProgress && _videoFile==null,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: InkWell(
                      onTap: ()async{
                        var xFile = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));
                        if(xFile!=null){
                          File file = File(xFile.path);
                          int size = file.lengthSync()~/1000000;
                          if(size < 31){
                            if (_isPlayPause) {
                              videoController!.pause();
                            }
                            PostData m = PostData(filePath: mainPath, filterName: filterImage, pickedSoundPath: pickedSoundPath);
                            Navigator.pushNamed(context, "/preview",arguments: m);

                          } else {
                            showErrorToast(context, "Max File Size is 30 MB");
                          }
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images.svg',
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          const Text(
                            upload,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                  _videoFile == null
                      ? const SizedBox(width: 10)
                      : const SizedBox(height: 1),
                  _videoFile == null
                      ? GestureDetector(
                          onTap: () async {
                            if (_isRecordingInProgress) {
                              XFile? rawVideo = await stopVideoRecording();
                              await audioPlayer.stop();
                              autoStopRecordingTimer?.cancel();
                              File videoFile = File(rawVideo!.path);

                              int currentUnix =
                                  DateTime.now().millisecondsSinceEpoch;

                              Directory? directory;
                              try {
                                if (Platform.isIOS) {
                                  directory =
                                      await getApplicationDocumentsDirectory();
                                } else {
                                  directory =
                                      Directory('/storage/emulated/0/Download');
                                }
                              } catch (_) {}
                              String fileFormat =
                                  videoFile.path.split('.').last;

                              _videoFile = await videoFile.copy(
                                  '${directory!.path}/$currentUnix.$fileFormat');
                              setState(() {
                                sliderValue=0;
                                mainNameFirst = '$currentUnix.$fileFormat';
                              });
                              _startVideoPlayer(_videoFile!.path);
                            } else {
                               await startVideoRecording();
                            }
                          },
                          child: VxCircle(
                            radius: 70,
                            backgroundColor: _isRecordingInProgress
                                ? Colors.red
                                : Colors.white,
                            border: Border.all(
                                color: _isRecordingInProgress
                                    ? Colors.white
                                    : Colors.black,
                                width: 5),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            if (_isPlayPause) {
                              videoController!.pause();
                            } else {
                              videoController!.play();
                            }
                            setState(() {
                              _isPlayPause = !_isPlayPause;
                            });
                          },
                          child: VxCircle(
                            radius: 70,
                            backgroundColor: Colors.white,
                            child: Icon(
                                _isPlayPause ? Icons.pause : Icons.play_arrow),
                            border: Border.all(color: Colors.black, width: 5),
                          ),
                        ),
                  _videoFile == null
                      ? const SizedBox(height: 10)
                      : GestureDetector(
                          onTap: () async {
                            if (_isPlayPause) {
                              videoController!.pause();
                            }
                            PostData m = PostData(filePath: mainPath, filterName: filterImage, pickedSoundPath: pickedSoundPath);
                            Navigator.pushNamed(context, "/preview",arguments: m);
                          },
                          child: VxCircle(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.check),
                            border: Border.all(color: Colors.black, width: 5),
                          ),
                        ),
                  IconButton(
                      onPressed: () async {
                        if (_videoFile != null) {
                          await imagePickerSheet(context);
                        }
                        if (videoController!=null && _isPlayPause) {
                          videoController!.pause();
                        }
                        setState(() {
                          _isPlayPause = !_isPlayPause;
                        });
                      },
                      icon: SvgPicture.asset('assets/Filter-Icon.svg'))
                ],
              ))
        ],
      )),
    );
  }

  imagePickerSheet(BuildContext context) async {
    String? type = await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            height: 90,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:effectsfirst.length
                itemBuilder: (context,index){
                  return InkWell(
                  onTap: () {
                     if(index==0){
                         filterImage = "";
                      }else{
                         filterImage = effectsfirst[index];
                      }
                      setState(() {});
                      Navigator.pop(context);
                      },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image:DecorationImage(
                      image: AssetImage(effectsfirst[index]),
                      fit: BoxFit.cover)),
                    ),
                  );
             },
            ),
          );
        },);
    return type;
  }

  Widget dot() {
    return VxCircle(
      backgroundColor: ColorManager.cyan,
      radius: 7,
    );
  }

  Future<void> _startVideoPlayer(String path) async {
    if (path.isNotEmpty) {
      videoController = VideoPlayerController.file(File(path));
      await videoController!.initialize().then((_) {
        setState(() {});
        mainPath = path;
        _isPlayPause = true;
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }
  static Future<File> _loadFile(String path, String name) async {
    final ByteData data = await rootBundle.load(path);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$name');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException {
      // print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      if(pickedSoundPath!=null){
        await audioPlayer.play(pickedSoundPath!, isLocal: true);
      }
      await cameraController!.startVideoRecording();
      autoStopRecordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if(videoDuration.inSeconds>=selectedDuration){
          autoStopRecordingTimer?.cancel();
          XFile? rawVideo = await stopVideoRecording();
          await audioPlayer.stop();
          File videoFile = File(rawVideo!.path);

          int currentUnix =
              DateTime.now().millisecondsSinceEpoch;

          Directory? directory;
          try {
            if (Platform.isIOS) {
              directory =
              await getApplicationDocumentsDirectory();
            } else {
              directory =
                  Directory('/storage/emulated/0/Download');
            }
          } catch (_) {}
          String fileFormat =
              videoFile.path.split('.').last;

          _videoFile = await videoFile.copy(
              '${directory!.path}/$currentUnix.$fileFormat');
          setState(() {
            mainNameFirst='$currentUnix.$fileFormat';
            sliderValue=0;
          });
          _startVideoPlayer(_videoFile!.path);
        } else {
          videoDuration+=const Duration(seconds: 1);
          setState(() {
            sliderValue+=1;
          });
        }
      });
      setState(() {
        _isRecordingInProgress = true;
        //  print(_isRecordingInProgress);
      });
    } on CameraException {
      // print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        //  print(_isRecordingInProgress);
      });
      return file;
    } on CameraException {
      // print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller!.pauseVideoRecording();
    } on CameraException {
      // print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller!.resumeVideoRecording();
    } on CameraException {
      // print('Error resuming video recording: $e');
    }
  }
}
