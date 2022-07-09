import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_player/video_player.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../main.dart';
import '../../models/add_sound_model.dart';
import '../../models/post_data.dart';
import '../../models/video_model.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';

class RecordDuet extends StatefulWidget {
  const RecordDuet({Key? key, required this.videoModel}) : super(key: key);
  final VideoModel videoModel;

  @override
  State<RecordDuet> createState() => _RecordDuetState();

  static const String routeName = '/recordDuet';

  static Route route(VideoModel v) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => RecordDuet(videoModel: v,),
    );
  }
}


class _RecordDuetState extends State<RecordDuet> {

  CameraController? controller;
  File? _videoFile;
  VideoPlayerController? videoController;
  bool isCameraInitialized = false;
  bool _isPlayPause = false;
  bool _isRecordingInProgress = false;
  double sliderValue = 0;
  double sliderMaxValue = 100;
  String mainPath = "";
  String mainName = "";
  String mainNameFirst = "";
  Timer? autoStopRecordingTimer;
  String filterImage = "";
  List<String> effectsfirst = List<String>.empty(growable: true);
  AddSoundModel? addSoundModel;
  bool videoDownloaded = false;
  File? duetFile;

  @override
  initState(){
    super.initState();
    onNewCameraSelected(cameras[0]);
    downloadVideo();
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
    videoController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videoDownloaded?
      SafeArea(
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  thumbShape: SliderComponentShape.noThumb,
                  overlayShape: SliderComponentShape.noThumb,
                  trackHeight: 2,
                ),
                child: Slider(
                    value:sliderValue,
                    max: sliderMaxValue,
                    activeColor: ColorManager.cyan,
                    inactiveColor: Colors.transparent,
                    onChanged: (double val){}
                ),
              ),
              SizedBox(
                width: getWidth(context),
                height: getHeight(context)*.40,
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
              isCameraInitialized && _videoFile == null
                  ? SizedBox(
                  width: getWidth(context),
                  height: getHeight(context)*.40,
                  child: controller!.buildPreview())
                  : const SizedBox(),
              const SizedBox(height: 5,),
              _videoFile == null
                  ? GestureDetector(
                onTap: () async {
                  if (_isRecordingInProgress) {
                    XFile? rawVideo = await stopVideoRecording();
                    //await audioPlayer.stop();
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
                    //_startVideoPlayer(_videoFile!.path);
                    PostData m = PostData(filePath: _videoFile!.path, filterName: filterImage, addSoundModel: addSoundModel, isDuet: true, downloadedDuetFilePath: duetFile?.path);
                    Navigator.pushReplacementNamed(context, "/postVideo", arguments: m);
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
            ],
          )
      ):
          const Center(
            child: CircularProgressIndicator(),
          )
    );
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
        isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      // if(addSoundModel!=null){
      //   await audioPlayer.play(addSoundModel!.sound, isLocal: true);
      // }
      videoController!.seekTo(const Duration(seconds: 0));
      videoController!.play();
      await cameraController!.startVideoRecording();
      autoStopRecordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if(sliderValue>=videoController!.value.duration.inSeconds){
          autoStopRecordingTimer?.cancel();
          XFile? rawVideo = await stopVideoRecording();
          //await audioPlayer.stop();
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
          //_startVideoPlayer(_videoFile!.path);
          PostData m = PostData(filePath: _videoFile!.path, filterName: filterImage, addSoundModel: addSoundModel, isDuet: true, downloadedDuetFilePath: duetFile?.path);
          Navigator.pushReplacementNamed(context, "/postVideo",arguments: m);
        } else {
          //videoDuration+=const Duration(seconds: 1);
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

  downloadVideo()async{
    String randomString = '${Random().nextInt(9999)}${Random().nextInt(9999)}';
    duetFile = File('$saveCacheDirectory$randomString.mp4');
    try{
      await FileSupport().downloadCustomLocation(
        url: '${RestUrl.videoUrl}${widget.videoModel.video}',
        path: saveCacheDirectory,
        filename: randomString,
        extension: ".mp4",
        progress: (progress) async {},
      );
      videoController = VideoPlayerController.network(
          '${RestUrl.videoUrl}${widget.videoModel.video}')
        ..initialize().then((value) {
          if (videoController!.value.isInitialized) {
            videoController!.play();
            videoController!.setLooping(true);
            videoController!.setVolume(1);
            sliderMaxValue = videoController!.value.duration.inSeconds.toDouble();
            videoDownloaded = true;
            if (mounted) setState(() {});
          }
        });
    } catch(e){
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }
}
