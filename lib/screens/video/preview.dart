import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:thrill/common/color.dart';
import 'package:video_player/video_player.dart';
import '../../common/strings.dart';
import '../../models/post_data.dart';
import '../../utils/util.dart';

class Preview extends StatefulWidget {
  const Preview({Key? key, required this.data}) : super(key: key);
  final PostData data;

  @override
  State<Preview> createState() => _PreviewState();
  static const String routeName = '/preview';
  static Route route({required PostData videoData}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => Preview(data: videoData),
    );
  }
}

class _PreviewState extends State<Preview> {

  bool isProcessing = true, wasSuccess = false;
  String percentage = "50%", newName = '';
  VideoPlayerController? videoPlayerController;
  bool isVControllerInitialized = false;
  int completed = 0;

  @override
  void initState() {
    startVideoProcessing();
    FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    super.initState();
  }

  statisticsCallback(Statistics statistics){
    final int time = statistics.getTime();
    //final int seconds = videoPlayerController.value.duration.inMilliseconds;
    //final double percent = (time/seconds)*100;
    //print("Progress ====>>> ${percent.toStringAsFixed(0)}%");
    print("Progress ====>>> $time");
    // percentage = percent;
    // if (mounted) setState((){});
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
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
            "Preview",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
              onPressed: () {
                showCloseDialog();
              },
              color: Colors.black,
              icon: const Icon(Icons.arrow_back_ios)
          ),
        ),
        body: getLayout()
      ),
    );
  }
  Widget getLayout(){
    if(isProcessing){
      return processingLayout();
    } else {
      if(wasSuccess){
        if(isVControllerInitialized){
          return processedLayout();
        } else {
          return processingLayout();
        }
      } else {
        return failedLayout();
      }
    }
  }
  Widget processingLayout(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Processing Video", style: Theme.of(context).textTheme.headline3!.copyWith(color: ColorManager.cyan),),
          Text("Please Wait...", style: Theme.of(context).textTheme.headline5,),
          const SizedBox(height: 10,),
          //Text(percentage, style: Theme.of(context).textTheme.headline2!.copyWith(color: ColorManager.cyan),),
          const CircularProgressIndicator(color: ColorManager.cyan,)
        ],
      ),
    );
  }
  Widget processedLayout(){
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(height: getHeight(context),width: getWidth(context),color: Colors.black87,),
        isVControllerInitialized?
        AspectRatio(
          aspectRatio: videoPlayerController!.value.aspectRatio,
          child: VideoPlayer(videoPlayerController!),
        ): Container(),
        Positioned(
          bottom: 140,
          child: isVControllerInitialized?
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: IconButton(
                onPressed: (){
                  videoPlayerController!.value.isPlaying?
                  videoPlayerController!.pause():
                  videoPlayerController!.play();
                  setState((){});
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 50,
                color: Theme.of(context).primaryColor,
                icon: Icon(videoPlayerController!.value.isPlaying?Icons.pause_circle_filled_rounded:Icons.play_circle_fill_rounded)),
          ): Container(),
        ),
        Positioned(
            bottom: 70,
            left: 10,
            right: 10,
            child: isVControllerInitialized?
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Row(
                children: [
                  Text(getDurationString(videoPlayerController!.value.position), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: videoPlayerController!.value.duration.inSeconds.toDouble(),
                      value: videoPlayerController!.value.position.inSeconds.toDouble(),
                      onChanged: (double val) => videoPlayerController!.seekTo(Duration(seconds: val.toInt())),
                      thumbColor: ColorManager.cyan,
                    ),
                  ),
                  Text(getDurationString(videoPlayerController!.value.duration), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                ],
              ),
            ): Container(),
        ),
        Positioned(
            bottom: 10,
            child: ElevatedButton(
                onPressed: () async {
                  videoPlayerController!.pause();
                  PostData postDate = PostData(
                      speed: widget.data.speed,
                      filePath: widget.data.filePath,
                      filterName: widget.data.filterName,
                      trimStart: widget.data.trimStart,
                      trimEnd: widget.data.trimEnd,
                      isDuet: widget.data.isDuet,
                      isDefaultSound: widget.data.isDefaultSound,
                      isUploadedFromGallery: widget.data.isUploadedFromGallery,
                      newPath: '$saveDirectory$newName.mp4',
                      newName: newName
                  );
                  await Navigator.pushNamed(context, "/postVideo", arguments: postDate);
                  videoPlayerController!.play();
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(getWidth(context)*.60, 45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                    )
                ),
                child: const Text("Continue")
            )),
      ],
    );
  }
  Widget failedLayout(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Video Processing Failed!", style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.red),),
          const SizedBox(height: 25,),
          IconButton(
              onPressed: (){
                setState(() {
                  isProcessing = true;
                  wasSuccess = false;
                });
                startVideoProcessing();
              },
              iconSize: 40,
              icon: const Icon(Icons.refresh_rounded)
          ),
          const Text("Retry")
        ],
      ),
    );
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
          child: isProcessing?
          Column(
            mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.warning_amber, size: 40, color: Colors.red,),
                 const SizedBox(height: 10,),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 30),
                   child: Text("Please wait until processing finishes!", style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                 ),
                 const SizedBox(height: 15,),
                 ElevatedButton(
                     onPressed: (){
                       Navigator.pop(context);
                     },
                     style: ElevatedButton.styleFrom(
                       primary: ColorManager.cyan,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       fixedSize: Size(getWidth(context)*.50, 45)
                     ),
                     child: const Text("OK")
                 )
               ],
             ):
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(closeDialog, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text("The processed video will be discarded!", style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
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
                        Navigator.pop(context);
                        Navigator.pop(context);
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
  startVideoProcessing()async{
    DateTime dateTime = DateTime.now();
    newName = "Thrill-${dateTime.day}-${dateTime.month}-${dateTime.year}-${dateTime.hour}-${dateTime.minute}";
    String outputPath = '$saveDirectory$newName.mp4';
    String? audioFilePath = widget.data.addSoundModel?.sound;
    File videoFile = File(widget.data.filePath);

    if(widget.data.isDuet && widget.data.duetPath!=null){
            FFmpegKit.execute(
                "-i ${widget.data.duetPath} -i ${widget.data.filePath} -filter_complex: vstack=inputs=2 $outputPath" //stretched
                //" -n -i $zero -i $one -filter_complex: [0:v][1:v]vstack=inputs=2[v] $op" //stretched
              //"-i ${widget.data.duetPath} -i ${widget.data.filePath} -filter_complex: vstack=inputs=2 $outputPath" //stretched
              //"-i ${widget.data.duetPath} -i ${widget.data.filePath} -filter_complex '[0:v]crop=720:840:[v0];[1:v]crop=720:840:[v1];[v0][v1]vstack=inputs=2' -s 720X1280 -vcodec libx264 -preset veryfast $outputPath" //cropped+stretched
              //"-i ${widget.data.duetPath} -i ${widget.data.filePath} -filter_complex '[0:v]crop=720:840:[v0];[1:v]crop=720:840:[v1];[v0][v1]vstack=inputs=2' $outputPath" //cropped+stretched
              //"-i ${widget.data.duetPath} -i ${widget.data.filePath} -filter_complex '[1][0]scale2ref=iw:ow/mdar[2nd][ref];[ref][2nd]vstack[vid]' -map [vid] $outputPath"
            ).then((session) async {
              final returnCode = await session.getReturnCode();
              final logs = await session.getLogsAsString();
              final logList = logs.split('\n');
              print("============================> LOG STARTED!!!!");
              for(var e in logList){
                print(e);
              }
              print("============================> LOG ENDED!!!!");
              if (ReturnCode.isSuccess(returnCode)) {
                // print("============================> Success!!!!");
                setState(() {
                  wasSuccess = true;
                  isProcessing = false;
                  initPreview();
                });
              } else {
                print("============================> Failed!!!!");
                //Navigator.pop(context);
                setState(() {
                  wasSuccess = false;
                  isProcessing = false;
                });
                //showErrorToast(context, "Video processing failed!");
                //setState(()=>isProcessing = false);
              }
            });
    } else {
      if(widget.data.addSoundModel==null || widget.data.isDefaultSound){
        if(widget.data.isUploadedFromGallery){
          try{
            FFmpegKit.execute(
                "-y -i ${videoFile.path} -ss ${Duration(seconds: widget.data.trimStart).toString().split('.').first} -to ${widget.data.trimEnd} -vcodec libx264 $outputPath"
              //"-y -i ${videoFile.path} -qscale 5 -shortest -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -to ${widget.data.map!["end"]} -c copy -c:a aac $outputPath"
            ).then((session) async {
              final returnCode = await session.getReturnCode();
              // final logs = await session.getLogsAsString();
              // final logList = logs.split('\n');
              // print("============================> LOG STARTED!!!!");
              // for(var e in logList){
              //   print(e);
              // }
              // print("============================> LOG ENDED!!!!");

              if (ReturnCode.isSuccess(returnCode)) {
                // print("============================> Success!!!!");
                setState(() {
                  isProcessing = false;
                  wasSuccess = true;
                  initPreview();
                });
              } else {
                // print("============================> Failed!!!!");
                closeDialogue(context);
                Navigator.pop(context);
                showErrorToast(context, "Video processing failed!");
                //setState(()=>isProcessing = false);
              }
            });
          } catch(e){
            closeDialogue(context);
            //print(e.toString());
            Navigator.pop(context);
            showErrorToast(context, "Video Processing Failed");
          }
        } else {
          try{
            print("-s 720X1280 -vcodec libx264");
            FFmpegKit.execute(
                "-y -i ${videoFile.path} -ss ${Duration(seconds: widget.data.trimStart).toString().split('.').first} -to ${widget.data.trimEnd} $outputPath"
              //"-y -i ${videoFile.path} -qscale 5 -shortest -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -to ${widget.data.map!["end"]} -c copy -c:a aac $outputPath"
            ).then((session) async {
              final returnCode = await session.getReturnCode();
              // final logs = await session.getLogsAsString();
              // final logList = logs.split('\n');
              // print("============================> LOG STARTED!!!!");
              // for(var e in logList){
              //   print(e);
              // }
              // print("============================> LOG ENDED!!!!");

              if (ReturnCode.isSuccess(returnCode)) {
                // print("============================> Success!!!!");
                setState(() {
                  isProcessing = false;
                  wasSuccess = true;
                  initPreview();
                });
              } else {
                // print("============================> Failed!!!!");
                closeDialogue(context);
                Navigator.pop(context);
                showErrorToast(context, "Video processing failed!");
                //setState(()=>isProcessing = false);
              }
            });
          } catch(e){
            closeDialogue(context);
            //print(e.toString());
            Navigator.pop(context);
            showErrorToast(context, "Video Processing Failed");
          }
        }
      } else {
        if(widget.data.isUploadedFromGallery){
          try{
            String start = Duration(seconds: widget.data.trimStart).toString().split('.').first;
            String end = Duration(seconds: widget.data.trimEnd).toString().split('.').first;
            String time = (int.parse(widget.data.trimEnd.toString())-int.parse(widget.data.trimStart.toString())).toString();
            FFmpegKit.execute(
              //"-y -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a $outputPath"
              //"-ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -qscale 5 -c:a aac $outputPath"
              //"-y -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${widget.data.map!["end"]} -shortest $outputPath"
              //"-i ${videoFile.path} -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -to ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i $audioFilePath -c:v copy -c:a aac $outputPath"
              //"-ss $start -to $end -i ${videoFile.path} -i $audioFilePath -t $time -c:a aac -qscale 5 -vcodec libx264 $outputPath"
                "-y -ss $start -to $end -i ${videoFile.path} -i \"$audioFilePath\" -map 0:v -qscale 5 -t $time -map 1:a $outputPath"
            ).then((session) async {
              final returnCode = await session.getReturnCode();
              // final logs = await session.getLogsAsString();
              // final logList = logs.split('\n');
              // print("============================> LOG STARTED!!!!");
              // for(var e in logList){
              // print(e);
              // }
              // print("============================> LOG ENDED!!!!");
              if (ReturnCode.isSuccess(returnCode)) {
                //print("============================> Success!!!!");
                setState(() {
                  wasSuccess = true;
                  isProcessing = false;
                  initPreview();
                });
              } else {
                //print("============================> Failed!!!!");
                closeDialogue(context);
                Navigator.pop(context);
                showErrorToast(context, "Video processing failed!");
                //setState(()=>isProcessing = false);
              }
            });
          } catch(e){
            closeDialogue(context);
            //print(e.toString());
            showErrorToast(context, "Video Processing Failed");
          }
        } else {
          try{
            String start = Duration(seconds: widget.data.trimStart).toString().split('.').first;
            String end = Duration(seconds: widget.data.trimEnd).toString().split('.').first;
            String time = (int.parse(widget.data.trimEnd.toString())-int.parse(widget.data.trimStart.toString())).toString();
            FFmpegKit.execute(
              //"-y -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a $outputPath"
              //"-ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -qscale 5 -c:a aac $outputPath"
              //"-y -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${widget.data.map!["end"]} -shortest $outputPath"
              //"-i ${videoFile.path} -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -to ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i $audioFilePath -c:v copy -c:a aac $outputPath"
              //"-ss $start -to $end -i ${videoFile.path} -i $audioFilePath -t $time -c:a aac -qscale 5 -vcodec libx264 $outputPath"
                "-y -ss $start -to $end -i ${videoFile.path} -i \"$audioFilePath\" -map 0:v -s 720X1280 -qscale 5 -t $time -map 1:a $outputPath"
            ).then((session) async {
              final returnCode = await session.getReturnCode();
              // final logs = await session.getLogsAsString();
              // final logList = logs.split('\n');
              // print("============================> LOG STARTED!!!!");
              // for(var e in logList){
              // print(e);
              // }
              // print("============================> LOG ENDED!!!!");
              if (ReturnCode.isSuccess(returnCode)) {
                //print("============================> Success!!!!");
                setState(() {
                  wasSuccess = true;
                  isProcessing = false;
                  initPreview();
                });
              } else {
                //print("============================> Failed!!!!");
                closeDialogue(context);
                Navigator.pop(context);
                showErrorToast(context, "Video processing failed!");
                //setState(()=>isProcessing = false);
              }
            });
          } catch(e){
            closeDialogue(context);
            //print(e.toString());
            showErrorToast(context, "Video Processing Failed");
          }
        }
      }
    }
  }
  initPreview()async{
    videoPlayerController = VideoPlayerController.file(File('$saveDirectory$newName.mp4'));
    await videoPlayerController!.initialize().then((_) {
      videoPlayerController!.setPlaybackSpeed(double.parse(widget.data.speed));
      isVControllerInitialized = true;
      videoPlayerController!.setPlaybackSpeed(double.parse(widget.data.speed));
      setState(() {});
      videoPlayerController!.addListener(() {
        if(videoPlayerController!.value.isPlaying) setState((){});
      });
    });
    await videoPlayerController!.setLooping(true);
    await videoPlayerController!.play();
  }
  String getDurationString(Duration duration){
    String string = '';
    if(duration.inHours!=0){
      string = duration.toString().split('.').first;
    } else {
      string = duration.toString().substring(2, 7);
    }
    return string;
  }
}
