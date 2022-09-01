import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/gradient_elevated_button.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import '../../models/add_sound_model.dart';
import '../../models/post_data.dart';
import '../../widgets/video_item.dart';

class Editing extends StatefulWidget {
  const Editing({Key? key, required this.data}) : super(key: key);
  final PostData data;

  static const String routeName = '/trim';
  static Route route({required PostData videoData}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => Editing(data: videoData),
    );
  }

  @override
  State<Editing> createState() => _EditingState();
}

class _EditingState extends State<Editing> {

  late VideoPlayerController videoPlayerController;
  List<FileSystemEntity> thumbList = List.empty(growable: true);
  RangeController rangeController = RangeController(start: 0, end: 100);
  SfRangeValues sfRangeValues = const SfRangeValues(0,100);
  bool isVidInit = false;
  Directory directory = Directory('');
  int radioGroupValue = 0;

  @override
  void initState() {
    if(widget.data.addSoundModel!=null){
      radioGroupValue = 1;
    }
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
    try{
      reelsPlayerController?.pause();
    }catch(_){}
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
    return WillPopScope(
      onWillPop: ()async{
        showCloseDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          centerTitle: true,
          title: const Text(
            "Editing",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF2F8897),
                    Color(0xff1F2A52),
                    Color(0xff1F244E)]),
            ),
          ),
          leading: IconButton(
              onPressed: () {
                showCloseDialog();
              },
              color: Colors.white,
              icon: const Icon(Icons.arrow_back)),
        ),
        body: isVidInit?
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: VideoPlayer(videoPlayerController),
            ),
            Positioned(
              bottom: 115,
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
                          child: Image.file(File(thumbList[index].path),fit: BoxFit.cover,));
                    },
                  ),
                )
            ),
            Positioned(
              bottom: 90,
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
              left: 15, right: 15, bottom: 61,
                child: Container(
                  margin: EdgeInsets.only(top: 5,bottom: 5),
                  padding: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Row(
                    children: [
                      Radio(
                        value: 0,
                        groupValue: radioGroupValue,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (int? val)=>setState(()=>radioGroupValue=val??0),
                        activeColor: ColorManager.cyan,
                      ),
                      Text("Default Sound",
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                          fontSize: 13,
                            color: Colors.black),),
                      const Spacer(),
                      Radio(
                        value: 1,
                        groupValue: radioGroupValue,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: ColorManager.cyan,
                        onChanged: (int? val) {
                          if(widget.data.addSoundModel==null){
                            showErrorToast(context, "You did not chosen any sound!!");
                          } else {
                            setState(() => radioGroupValue = val ?? 1);
                          }
                        },
                      ),
                      Text("Chosen Sound",
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 13,
                            color: Colors.black),),
                    ],
                  ),
                )
            ),
            Positioned(
                bottom: 10,
                child: GradientElevatedButton(
                    onPressed: continuePressed,
                    child: const Text("Continue")
                )),
            // Positioned(
            //   top: 100, left: 30, right: 30,
            //     child: Text(
            //       rangeController.end-rangeController.start<15?
            //         "Error: Minimum video duration is\n15 seconds!":
            //       rangeController.end-rangeController.start>60?
            //       "Error: Maximum video duration is\n60 seconds!":"",
            //       style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.red),
            //       textAlign: TextAlign.center,
            //     )),

            Positioned(
              bottom: 170,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getStartDuration(), style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),),
                    Text(getEndDuration(), style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),),
                  ],
                )
            ),
            Positioned(
              top: 10,
              left: 0, right: 0,
              child: TextButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, "/newSong").then((value) {
                      if(value!=null){
                        AddSoundModel? addSoundModelTemp = value as AddSoundModel?;
                        setState((){
                          widget.data.addSoundModel = addSoundModelTemp;
                        });
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/music.svg', height: 16.5,),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          widget.data.addSoundModel==null?addSound:widget.data.addSoundModel!.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ):
        const Center(child: CircularProgressIndicator(),),

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

    videoPlayerController.dispose();
    setState(()=>isVidInit=false);
    await VESDK.openEditor(Video(widget.data.filePath)).then((value) async {
      PostData newPostData = PostData(
        speed: widget.data.speed,
        filePath: value!.video,
        filterName: value!.video,
        addSoundModel: widget.data.addSoundModel,
        isDuet: false,
        trimStart: rangeController.end-rangeController.start<15?0:rangeController.end-rangeController.start>60?0:rangeController.start.toInt(),
        trimEnd: rangeController.end-rangeController.start<15?15:rangeController.end-rangeController.start>60?60:rangeController.end.toInt(),
        isDefaultSound: radioGroupValue==0?true:false,
        isUploadedFromGallery: widget.data.isUploadedFromGallery,
      );
      await Navigator.pushNamed(context, "/preview", arguments: newPostData);

    });
    videoPlayerController =
    VideoPlayerController.file(
        File(widget.data.filePath))
      ..initialize().then((value) {
        videoPlayerController.play();
        videoPlayerController.setLooping(true);
        videoPlayerController.setVolume(1);
        sfRangeValues = SfRangeValues(0,videoPlayerController.value.duration.inSeconds);
        rangeController= RangeController(start: 0, end: videoPlayerController.value.duration.inSeconds);
        isVidInit = true;
        setState(() {});
      });
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
  showCloseDialog(){
    showDialog(context: context, builder: (_)=> Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: getWidth(context)*.80,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(closeDialog, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text(discardDialog, style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          fixedSize: Size(getWidth(context)*.26, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text(no)
                  ),
                  const SizedBox(width: 15,),
                  ElevatedButton(
                      onPressed: (){
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          fixedSize: Size(getWidth(context)*.26, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text(yes)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    )
    );
  }
}