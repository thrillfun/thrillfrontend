import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_player/video_player.dart';
import '../../models/post_data.dart';

class Preview extends StatefulWidget {
  const Preview({Key? key, required this.data}) : super(key: key);
  final PostData data;

  static const String routeName = '/preview';
  static Route route({required PostData videoData}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => Preview(data: videoData),
    );
  }

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {

  late VideoPlayerController videoPlayerController;
  List<FileSystemEntity> thumbList = List.empty(growable: true);
  RangeController rangeController = RangeController(start: 0, end: 100);
  SfRangeValues sfRangeValues = const SfRangeValues(0,100);
  bool isVidInit = false;
  Directory directory = Directory('');

  @override
  void initState() {
    videoPlayerController =
    VideoPlayerController.file(
        File(widget.data.filePath))
      ..initialize().then((value) {
        createThumbs();
        videoPlayerController.play();
        videoPlayerController.setLooping(true);
        videoPlayerController.setVolume(1);
        sfRangeValues = SfRangeValues(0,videoPlayerController.value.duration.inSeconds);
        rangeController= RangeController(start: 0, end: videoPlayerController.value.duration.inSeconds);
        isVidInit = true;
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    directory.deleteSync(recursive: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        centerTitle: true,
        title: const Text(
          "Preview",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              // isProcessing?
              // showErrorToast(context, "Please wait while video processing..."):
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: VideoPlayer(videoPlayerController),
          ),
          Positioned(
              bottom: 10,
              child: ElevatedButton(
                  onPressed:
                  rangeController.end-rangeController.start<15?
                  null:rangeController.end-rangeController.start>60?null:continuePressed,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(getWidth(context)*.60, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)
                    )
                  ),
                  child: const Text("Continue")
              )),
          Positioned(
            bottom: 70,
              left: 5, right: 5,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1
                  )
                ),
                child: thumbList.isEmpty?
                Center(child: Text("Loading Preview...", style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white),)):
                ListView.builder(
                  itemCount: thumbList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width/thumbList.length,
                        child: Image.file(File(thumbList[index].path),fit: BoxFit.fill,));
                  },
                ),
              )
          ),
          Positioned(
            bottom: 45,
              left:-20,right: -20,
              child: isVidInit?SfRangeSelector(
                max: videoPlayerController.value.duration.inSeconds,
                min: 0,
                initialValues: sfRangeValues,
                activeColor: Colors.transparent,
                startThumbIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(decoration: const BoxDecoration(color: Colors.white,shape: BoxShape.circle),),
                ),
                endThumbIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(decoration: const BoxDecoration(color: Colors.white,shape: BoxShape.circle),),
                ),
                onChanged: (SfRangeValues val){
                  setState(() {});
                },
                controller: rangeController,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorManager.cyan,
                          width: 2.5
                      )
                  ),
                  height: 50,
                ),
              ):const SizedBox()
          ),
          Positioned(
            top: 100, left: 30, right: 30,
              child: Text(
                rangeController.end-rangeController.start<15?
                  "Error: Minimum video duration is\n15 seconds!":
                rangeController.end-rangeController.start>60?
                "Error: Maximum video duration is\n60 seconds!":"",
                style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              )),

          Positioned(
            bottom: 130,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getStartDuration(), style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),),
                  Text(getEndDuration(), style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),),
                ],
              )
          )
        ],
      ),

    );
  }

  createThumbs()async{
    double frameRate = 5/videoPlayerController.value.duration.inSeconds;
    DateTime dateTime = DateTime.now();
    String outputPath = "$saveCacheDirectory${dateTime.day}${dateTime.month}${dateTime.year}${dateTime.hour}${dateTime.minute}${dateTime.second}/";
    directory = Directory(outputPath);
    if(!directory.existsSync()){
      directory.createSync();
    }
    FFmpegKit.execute("-i ${widget.data.filePath} -r $frameRate -f image2 ${outputPath}image-%3d.png").then((session) async {
      final returnCode = await session.getReturnCode();
      // final logs = await session.getLogsAsString();
      // final logList = logs.split('\n');
      // print("============================> LOG STARTED!!!!");
      // for(var e in logList){
      //   print(e);
      // }
      //print("============================> LOG ENDED!!!!");

      if (ReturnCode.isSuccess(returnCode)) {
        //MediaInformationSession info = await FFprobeKit.getMediaInformation(outputPath);
        //Map? _gifInfo = info.getMediaInformation()?.getAllProperties()?["streams"][0];
        //print("============================> Success!!!!");
        setState((){
          thumbList.addAll(directory.listSync());
        });
      } else {
        //print("============================> Failed!!!!");
        setState((){
        });
      }
    });

  }
  continuePressed()async{
    videoPlayerController.pause();
    PostData newPostData = PostData(
        filePath: widget.data.filePath,
        filterName: widget.data.filterName,
        addSoundModel: widget.data.addSoundModel,
        isDuet: false,
        map: {"start": rangeController.start.toInt().toInt(), "end":rangeController.end.toInt()}
    );
    await Navigator.pushNamed(context, "/postVideo",arguments: newPostData);
    videoPlayerController.play();
  }
  String getStartDuration(){
    Duration duration = Duration(seconds: rangeController.start.toInt());
    String string = '';
    if(duration.inHours!=0){
      string = duration.toString().split('.').first;
    } else {
      string = duration.toString().substring(2, 7);
    }
    return string;
  }
  String getEndDuration(){
    Duration duration = Duration(seconds: rangeController.end.toInt());
    String string = '';
    if(duration.inHours!=0){
      string = duration.toString().split('.').first;
    } else {
      string = duration.toString().substring(2, 7);
    }
    return string;
  }
}