import 'dart:convert';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:ffmpeg_kit_flutter_full/statistics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/model.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:io';
import 'package:simple_s3/simple_s3.dart';
import '../../blocs/video/video_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_api.dart';

class PostVideo extends StatefulWidget {
  const PostVideo({Key? key, required this.data}) : super(key: key);

  @override
  State<PostVideo> createState() => _PostVideoState();
  final PostData data;

  static const String routeName = '/postVideo';
  static Route route({required PostData videoData}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => PostVideo(data: videoData),
    );
  }
}

class _PostVideoState extends State<PostVideo> {

  String dropDownLanguageValue = '1', dropDownCategoryValue = '1';
  TextEditingController desCtr = TextEditingController();
  bool commentsSwitch = true, duetSwitch = true;
  late VideoPlayerController videoPlayerController;
  final SimpleS3 _simpleS3 = SimpleS3();
  List<HashtagModel> hashTags = List<HashtagModel>.empty(growable: true);
  List<String> hashTagsSelected = List<String>.empty(growable: true);
  List<CategoryModel> videoCategory = List<CategoryModel>.empty(growable: true);
  List<LanguagesModel> videoLanguage = List<LanguagesModel>.empty(growable: true);
  bool isLoading = true, isProcessing = false, wasSuccess = false;
  String newName = '';
  double percentage = 0;
  int radioGroupValue = 0;

  @override
  void initState() {
    super.initState();
    FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    if(widget.data.addSoundModel!=null){
      radioGroupValue = 1;
    }
    createGIF();
    loadVideoFields();
    videoPlayerController =
    VideoPlayerController.file(
        File(widget.data.filePath))
          ..initialize().then((value) {
            videoPlayerController.play();
            videoPlayerController.setLooping(true);
            videoPlayerController.setVolume(1);
            setState(() {});
          });

  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  statisticsCallback(Statistics statistics){
    final int time = statistics.getTime();
    final int seconds = videoPlayerController.value.duration.inMilliseconds;
    final double percent = (time/seconds)*100;
    //print("Progress ====>>> ${percent.toStringAsFixed(0)}%");
    setState(()=>percentage=percent);
  }

  startProcessing(String draftORpost)async{
    String outputPath = '$saveDirectory$newName.mp4';
    String audioFilePath = "$saveCacheDirectory${widget.data.addSoundModel?.sound}";
    File videoFile = File(widget.data.filePath);
    // print(outputPath);
    // print(audioFilePath);
    // print(videoFile.path);

    if(widget.data.addSoundModel==null || radioGroupValue==0){
      FFmpegKit.execute("-y -i ${videoFile.path} -qscale 5 -shortest -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -c copy -t ${widget.data.map!["end"]} -c:a aac $outputPath").then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          print("============================> Success!!!!");
          setState(() {
            isProcessing = false;
            wasSuccess = true;
            draftORpost=='draft'?draftUpload():postUpload();
          });
        } else {
          print("============================> Failed!!!!");
          closeDialogue(context);
          showErrorToast(context, "Video processing failed!");
          setState(()=>isProcessing = false);
          Navigator.pop(context);
        }
      });
    } else {
      FFmpegKit.execute(
          //"-y -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a $outputPath"
          //"-ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -qscale 5 -c:a aac $outputPath"
          //"-y -i ${videoFile.path} -i $audioFilePath -map 0:v -qscale 5 -map 1:a -ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${widget.data.map!["end"]} -shortest $outputPath"
          "-ss ${Duration(seconds: widget.data.map!["start"]).toString().split('.').first} -t ${Duration(seconds: widget.data.map!["end"]).toString().split('.').first} -i ${videoFile.path} -i $audioFilePath -c:v copy -c:a aac $outputPath"
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
          //print("============================> Success!!!!");
          setState(() {
            isProcessing = false;
            wasSuccess = true;
            draftORpost=='draft'?draftUpload():postUpload();
          });
        } else {
          //print("============================> Failed!!!!");
          closeDialogue(context);
          showErrorToast(context, "Video processing failed!");
          setState(()=>isProcessing = false);
          Navigator.pop(context);
        }
      });
    }
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
          post,
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              isProcessing?
              showErrorToast(context, "Please wait while video processing..."):
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 160,
                        width: 120,
                        child: !videoPlayerController.value.isInitialized
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : VideoPlayer(videoPlayerController),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: desCtr,
                        minLines: 6,
                        maxLines: 6,
                        maxLength: 150,
                        decoration: const InputDecoration(
                            counterStyle: TextStyle(color: Colors.grey),
                            hintText: describeYourVideo,
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      childAspectRatio: 2.6,
                    ),
                    itemCount: hashTags.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          addAndRemove(hashTags[index].id.toString());
                        },
                        child: Wrap(
                          children: <Widget>[
                            SizedBox(
                              width: 135.0,
                              height: 50.0,
                              child: Card(
                                color: hashTagsSelected
                                        .contains(hashTags[index].id.toString())
                                    ? Colors.cyanAccent
                                    : Colors.white,
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.all(4),
                                child: Center(
                                  child: Text(
                                    hashTags[index].name,
                                    style: TextStyle(
                                      color: hashTagsSelected.contains(
                                              hashTags[index].id.toString())
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * .90,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: DropdownButton<LanguagesModel>(
                      value: videoLanguage[0],
                      underline: Container(),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 35,
                      ),
                      onChanged: (LanguagesModel? value) {
                        setState(() {
                          dropDownLanguageValue = value!.id.toString();
                        });
                      },
                      items: videoLanguage.map((LanguagesModel item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * .90,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: DropdownButton<CategoryModel>(
                      value: videoCategory[0],
                      underline: Container(),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 35,
                      ),
                      onChanged: (CategoryModel? value) {
                        setState(() {
                          dropDownCategoryValue = value!.id.toString();
                        });
                      },
                      items: videoCategory.map((CategoryModel item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.title),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Radio(
                          value: 0,
                          groupValue: radioGroupValue,
                          onChanged: (int? val)=>setState(()=>radioGroupValue=val??0),
                      ),
                      Text("Default Sound", style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.grey),),
                      const Spacer(),
                      Radio(
                        value: 1,
                        groupValue: radioGroupValue,
                        onChanged: (int? val) {
                          if(widget.data.addSoundModel==null){
                            showErrorToast(context, "You did not chosen any sound!!");
                          } else {
                            setState(() => radioGroupValue = val ?? 1);
                          }
                        },
                      ),
                      Text("Chosen Sound", style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.grey),),
                    ],
                  ).w(MediaQuery.of(context).size.width*.90),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                      ),
                      const Icon(Icons.lock, color: Colors.grey, size: 28,),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          whoCanViewThisVideo,
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade700),
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                public,
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 18),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade700,
                              )
                            ],
                          )),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                      ),
                      const Icon(Icons.comment, color: Colors.grey, size: 28,),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          allowComments,
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade700),
                        ),
                      ),
                      FlutterSwitch(
                        onToggle: (bool value) {
                          setState(() {
                            commentsSwitch = value;
                          });
                        },
                        width: 45,
                        height: 20,
                        padding: 0,
                        activeColor: ColorManager.cyan.withOpacity(0.40),
                        toggleColor: ColorManager.cyan,
                        inactiveToggleColor: Colors.black,
                        inactiveColor: Colors.grey,
                        value: commentsSwitch,
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                      ),
                      const Icon(Icons.video_camera_front_sharp, color: Colors.grey, size: 28,),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          allowDuets,
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade700),
                        ),
                      ),
                      FlutterSwitch(
                        onToggle: (bool value) {
                          setState(() {
                            duetSwitch = value;
                          });
                        },
                        width: 45,
                        height: 20,
                        padding: 0,
                        activeColor: ColorManager.cyan.withOpacity(0.40),
                        toggleColor: ColorManager.cyan,
                        inactiveToggleColor: Colors.black,
                        inactiveColor: Colors.grey,
                        value: duetSwitch,
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              FocusScope.of(context).requestFocus(FocusNode());
                              videoPlayerController.pause();
                              if (desCtr.text.isEmpty) {
                                showErrorToast(context, "Describe your video");
                              } else {
                                if (dropDownCategoryValue.isEmpty) {
                                  showErrorToast(context, "Select Category");
                                } else {
                                  if (dropDownLanguageValue.isEmpty) {
                                    showErrorToast(context, "Select Language");
                                  } else {
                                    progressDialogue(context);
                                    startProcessing('draft');
                                  }
                                }
                              }
                            } catch (e) {
                              closeDialogue(context);
                              showErrorToast(context, e.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: ColorManager.deepPurple,
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width * .40, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/draft.png'),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                draft,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              FocusScope.of(context).requestFocus(FocusNode());
                              videoPlayerController.pause();
                              if (desCtr.text.isEmpty) {
                                showErrorToast(context, "Describe your video");
                              } else {
                                if (dropDownCategoryValue.isEmpty) {
                                  showErrorToast(context, "Select Category");
                                } else {
                                  if (dropDownLanguageValue.isEmpty) {
                                    showErrorToast(context, "Select Language");
                                  } else {
                                    progressDialogue(context);
                                    startProcessing('post');
                                  }
                                }
                              }
                            } catch (e) {
                              closeDialogue(context);
                              showErrorToast(context, e.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: ColorManager.cyan,
                              fixedSize: Size(getWidth(context) * .40, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/post.svg'),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                postVideo,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              ).h(getHeight(context) - kToolbarHeight),
      ),
    );
  }

  void addAndRemove(String tag) {
    if (hashTagsSelected.contains(tag)) {
      hashTagsSelected.remove(tag);
    } else {
      hashTagsSelected.add(tag);
    }
    setState(() {});
  }

  void loadVideoFields() async {
    try {
      var result = await RestApi.getVideoFields();
      var json = jsonDecode(result.body);
      if (json['status']) {
        hashTags.clear();
        videoCategory.clear();
        videoLanguage.clear();

        hashTags = List<HashtagModel>.from(
                json['data']['hashtags'].map((i) => HashtagModel.fromJson(i)))
            .toList(growable: true);

        videoCategory = List<CategoryModel>.from(json['data']['categories']
            .map((i) => CategoryModel.fromJson(i))).toList(growable: true);

        videoLanguage = List<LanguagesModel>.from(json['data']['languages']
            .map((i) => LanguagesModel.fromJson(i))).toList(growable: true);
      }
      setState(() {
        isLoading = false;
      });
    } catch (_) {}
  }

  createGIF() async {
    final dateTime = DateTime.now();
    newName = "Thrill-${dateTime.day}-${dateTime.month}-${dateTime.year}-${dateTime.hour}-${dateTime.minute}";
    String outputPath = '$saveCacheDirectory$newName.gif';
    FFmpegKit.execute("-i ${widget.data.filePath} -r 3 -filter:v scale=280:480 -t 5 $outputPath").then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print("============================> GIF Success!!!!");
      } else {
        print("============================> GIF Error!!!!");
      }
    });
  }

  draftUpload()async{
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    String videoId = '$currentUnix.mp4';

    await _simpleS3.uploadFile(
      wasSuccess?
      File('$saveDirectory$newName.mp4'):
      File(widget.data.filePath),
      "thrillvideo",
      "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
      AWSRegions.usEast1,
      debugLog: true,
      fileName: videoId,
      s3FolderPath: "test",
      accessControl: S3AccessControl.publicRead,
    ).then((value) async {
      await _simpleS3.uploadFile(
        File('$saveCacheDirectory$newName.gif'),
        "thrillvideo",
        "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
        AWSRegions.usEast1,
        debugLog: true,
        s3FolderPath: "gif",
        fileName: '$currentUnix.gif',
        accessControl: S3AccessControl.publicRead,
      ).then((value) async {
        String tagList =
        jsonEncode(hashTagsSelected);
        var result = await RestApi.postVideo(
            videoId,
            "${radioGroupValue==0?0:widget.data.addSoundModel?.id??0}",
            dropDownCategoryValue,
            tagList,
            "Private",
            commentsSwitch ? 1 : 0,
            desCtr.text,
            widget.data.filterName.isEmpty
                ? ''
                : widget.data.filterName,
            dropDownLanguageValue,
            '$currentUnix.gif'
        );
        var json = jsonDecode(result.body);
        closeDialogue(context);
        if (json['status']) {
          File recordedVideoFile = File(widget.data.filePath);
          File processedVideoFile = File('$saveDirectory$newName.mp4');
          recordedVideoFile.delete();
          processedVideoFile.delete();
          BlocProvider.of<VideoBloc>(context)
              .add(const VideoLoading());
          showSuccessToast(context,
              "Video has been saved successfully");
          await Future.delayed(
              const Duration(milliseconds: 200));
          Navigator.pushNamedAndRemoveUntil(
              context, '/', (route) => false);
        } else {
          showErrorToast(
              context, json['message']);
        }
      });
    });
  }

  postUpload()async{
    int currentUnix =
        DateTime.now().millisecondsSinceEpoch;
    String videoId = '$currentUnix.mp4';

    await _simpleS3
        .uploadFile(
      wasSuccess?
      File('$saveDirectory$newName.mp4'):
      File(widget.data.filePath),
      "thrillvideo",
      "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
      AWSRegions.usEast1,
      debugLog: true,
      fileName: videoId,
      s3FolderPath: "test",
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) async {
      await _simpleS3.uploadFile(
        File('$saveCacheDirectory$newName.gif'),
        "thrillvideo",
        "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
        AWSRegions.usEast1,
        debugLog: true,
        s3FolderPath: "gif",
        fileName: '$currentUnix.gif',
        accessControl: S3AccessControl.publicRead,
      ).then((value) async {
        String tagList =
        jsonEncode(hashTagsSelected);
        var result = await RestApi.postVideo(
            videoId,
            "${radioGroupValue==0?0:widget.data.addSoundModel?.id??0}",
            dropDownCategoryValue,
            tagList,
            "Public",
            commentsSwitch ? 1 : 0,
            desCtr.text,
            widget.data.filterName.isEmpty
                ? ''
                : widget.data.filterName,
            dropDownLanguageValue,
            '$currentUnix.gif');
        var json = jsonDecode(result.body);
        closeDialogue(context);
        if (json['status']) {
          BlocProvider.of<VideoBloc>(context)
              .add(const VideoLoading());
          showSuccessToast(context,
              "Video has been posted successfully");
          await Future.delayed(
              const Duration(milliseconds: 200));
          File recordedVideoFile = File(widget.data.filePath);
          File processedVideoFile = File('$saveDirectory$newName.mp4');
          recordedVideoFile.delete();
          processedVideoFile.delete();
          Navigator.pushNamedAndRemoveUntil(
              context, '/', (route) => false);
        } else {
          showErrorToast(
              context, json['message']);
        }
      });
    });
  }

  processVideoWithoutSound(String draftORpost)async{}
  processVideoWithSound(String draftORpost)async{}
}
