import 'dart:io';
import 'dart:convert';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/model.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:simple_s3/simple_s3.dart';
import '../../blocs/video/video_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_api.dart';
import '../../widgets/video_item.dart';

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
  List<CategoryModel> videoCategory = List<CategoryModel>.empty(growable: true);
  List<LanguagesModel> videoLanguage = List<LanguagesModel>.empty(growable: true);
  bool isLoading = true;
  double percentage = 0;
  List<HashtagModel> hashtagsList = List<HashtagModel>.empty(growable: true);
  List<String> selectedHashtags = List<String>.empty(growable: true);
  TextEditingController hashtagTextFieldController = TextEditingController();
  bool isPublic = true;

  @override
  void initState() {
    super.initState();
    //FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    createGIF();
    loadVideoFields();
    getHashtags();
    videoPlayerController =
    VideoPlayerController.file(
        File(widget.data.newPath!))
          ..initialize().then((value) {
            videoPlayerController.play();
            videoPlayerController.setLooping(true);
            videoPlayerController.setVolume(1);
            setState(() {});
          });
    try{
      reelsPlayerController?.pause();
    }catch(_){}
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  // statisticsCallback(Statistics statistics){
  //   final int time = statistics.getTime();
  //   final int seconds = videoPlayerController.value.duration.inMilliseconds;
  //   final double percent = (time/seconds)*100;
  //   //print("Progress ====>>> ${percent.toStringAsFixed(0)}%");
  //   percentage = percent;
  //   if (mounted) setState((){});
  // }

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
            post,
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
              onPressed: () {
                // isProcessing?
                // showErrorToast(context, "Please wait while video processing..."):
                // Navigator.pop(context);
                showCloseDialog();
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
                        GestureDetector(
                          onTap: (){
                            try{
                              videoPlayerController.value.isPlaying?
                              videoPlayerController.pause():
                              videoPlayerController.play();
                            }catch(_){}
                          },
                          child: SizedBox(
                            height: 160,
                            width: 120,
                            child: !videoPlayerController.value.isInitialized
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : VideoPlayer(videoPlayerController),
                          ),
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
                    // GridView.builder(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   gridDelegate:
                    //       const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3,
                    //     mainAxisSpacing: 1,
                    //     crossAxisSpacing: 1,
                    //     childAspectRatio: 2.6,
                    //   ),
                    //   itemCount: hashTags.length,
                    //   itemBuilder: (BuildContext context, int index) {
                    //     return GestureDetector(
                    //       onTap: () {
                    //         addAndRemove(hashTags[index].id.toString());
                    //       },
                    //       child: Wrap(
                    //         children: <Widget>[
                    //           SizedBox(
                    //             width: 135.0,
                    //             height: 50.0,
                    //             child: Card(
                    //               color: hashTagsSelected
                    //                       .contains(hashTags[index].id.toString())
                    //                   ? Colors.cyanAccent
                    //                   : Colors.white,
                    //               semanticContainer: true,
                    //               clipBehavior: Clip.antiAliasWithSaveLayer,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(50.0),
                    //               ),
                    //               elevation: 3,
                    //               margin: const EdgeInsets.all(4),
                    //               child: Center(
                    //                 child: Text(
                    //                   hashTags[index].name,
                    //                   style: TextStyle(
                    //                     color: hashTagsSelected.contains(
                    //                             hashTags[index].id.toString())
                    //                         ? Colors.white
                    //                         : Colors.grey,
                    //                     fontSize: 14.0,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 10,
                      spacing: 10,
                      children: [
                        Visibility(
                          visible: selectedHashtags.length<3?true:false,
                          child: GestureDetector(
                            onTap: ()async{
                              addNewTagDialog();

                            },
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.all(4),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Add Hashtag",
                                  style: TextStyle(
                                    color: ColorManager.cyan,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        for(var element in selectedHashtags)
                        Chip(
                          backgroundColor: Colors.white,
                          elevation: 3,
                          deleteIcon: const Icon(Icons.delete_forever, size: 18, color: Colors.red,),
                          onDeleted: (){
                            setState(() {
                              selectedHashtags.remove(element);
                            });
                            },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          useDeleteButtonTooltip: true,
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              element,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .90,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
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
                            onPressed: () {
                              setState(() {
                                isPublic =  !isPublic;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isPublic?
                                  public:private,
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     ElevatedButton(
                    //         onPressed: () async {
                    //           try {
                    //             FocusScope.of(context).requestFocus(FocusNode());
                    //             videoPlayerController.pause();
                    //             if (desCtr.text.isEmpty) {
                    //               showErrorToast(context, "Describe your video");
                    //             } else {
                    //               if (dropDownCategoryValue.isEmpty) {
                    //                 showErrorToast(context, "Select Category");
                    //               } else {
                    //                 if (dropDownLanguageValue.isEmpty) {
                    //                   showErrorToast(context, "Select Language");
                    //                 } else {
                    //                   progressDialogue(context);
                    //                   startProcessing('draft');
                    //                 }
                    //               }
                    //             }
                    //           } catch (e) {
                    //             closeDialogue(context);
                    //             showErrorToast(context, e.toString());
                    //           }
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //             primary: ColorManager.deepPurple,
                    //             fixedSize: Size(
                    //                 MediaQuery.of(context).size.width * .40, 50),
                    //             shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(50))),
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Image.asset('assets/draft.png'),
                    //             const SizedBox(
                    //               width: 10,
                    //             ),
                    //             const Text(
                    //               draft,
                    //               style: TextStyle(fontSize: 15),
                    //             )
                    //           ],
                    //         )),
                    //     const SizedBox(
                    //       width: 15,
                    //     ),
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
                                      isPublic? postUpload():draftUpload();
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
                  //   ),
                  // ],
                ).h(getHeight(context) - kToolbarHeight),
        ),
      ),
    );
  }

  void loadVideoFields() async {
    try {
      var result = await RestApi.getVideoFields();
      var json = jsonDecode(result.body);
      if (json['status']) {
        videoCategory.clear();
        videoLanguage.clear();

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
    String outputPath = '$saveCacheDirectory${widget.data.newName}.gif';
    String filePath = widget.data.isDuet?widget.data.newPath!:widget.data.filePath;
    FFmpegKit.execute("-i $filePath -r 3 -filter:v scale=280:480 -t 5 $outputPath").then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // print("============================> GIF Success!!!!");
      } else {
        // print("============================> GIF Error!!!!");
      }
    });
  }

  draftUpload()async{
    int currentUnix =
        DateTime.now().millisecondsSinceEpoch;
    String videoId = '$currentUnix.mp4';

    await _simpleS3.uploadFile(
      File(widget.data.newPath!),
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
        File('$saveCacheDirectory${widget.data.newName}.gif'),
        "thrillvideo",
        "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
        AWSRegions.usEast1,
        debugLog: true,
        s3FolderPath: "gif",
        fileName: '$currentUnix.gif',
        accessControl: S3AccessControl.publicRead,
      ).then((value) async {
        if(widget.data.addSoundModel==null || !widget.data.addSoundModel!.isSoundFromGallery){
          String tagList =
          jsonEncode(selectedHashtags);
          var result = await RestApi.postVideo(
              videoId,
              widget.data.isDuet?widget.data.duetSound??"":widget.data.addSoundModel==null?"":widget.data.addSoundModel!.isSoundFromGallery?"$currentUnix.mp3":widget.data.addSoundModel!.sound.split('/').last,
              widget.data.isDuet?widget.data.duetSoundName??"":widget.data.addSoundModel?.name??"Original Sound",
              dropDownCategoryValue,
              tagList,
              "Private",
              commentsSwitch ? 1 : 0,
              desCtr.text,
              widget.data.filterName.isEmpty
                  ? ''
                  : widget.data.filterName,
              dropDownLanguageValue,
              '$currentUnix.gif',
              widget.data.speed,
            duetSwitch,
            commentsSwitch,
            widget.data.duetFrom??'',
            widget.data.isDuet,
            widget.data.addSoundModel?.userId??0
          );
          var json = jsonDecode(result.body);
          closeDialogue(context);
          if (json['status']) {
            BlocProvider.of<VideoBloc>(context)
                .add(const VideoLoading(selectedTabIndex: 1));
            showSuccessToast(context,
                "Video has been saved successfully");
            await Future.delayed(const Duration(milliseconds: 200));
            File recordedVideoFile = File(widget.data.filePath);
            File processedVideoFile = File(widget.data.newPath!);
            recordedVideoFile.delete();
            processedVideoFile.delete();
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
          } else {
            showErrorToast(
                context, json['message']);
          }
        } else {
          await _simpleS3
              .uploadFile(
            File(widget.data.addSoundModel!.sound),
            "thrillvideo",
            "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
            AWSRegions.usEast1,
            debugLog: true,
            fileName: '$currentUnix.mp3',
            s3FolderPath: "sound",
            accessControl: S3AccessControl.publicRead,
          ).then((value) async {
            String tagList =
            jsonEncode(selectedHashtags);
            var result = await RestApi.postVideo(
                videoId,
                widget.data.isDuet?widget.data.duetSound??"":widget.data.addSoundModel==null?"":widget.data.addSoundModel!.isSoundFromGallery?"$currentUnix.mp3":widget.data.addSoundModel!.sound.split('/').last,
                widget.data.addSoundModel?.name??"",
                dropDownCategoryValue,
                tagList,
                "Private",
                commentsSwitch ? 1 : 0,
                desCtr.text,
                widget.data.filterName.isEmpty ? '' : widget.data.filterName,
                dropDownLanguageValue,
                '$currentUnix.gif',
                widget.data.speed,
                duetSwitch,
                commentsSwitch,
                widget.data.duetFrom??'',
                widget.data.isDuet,
                widget.data.addSoundModel?.userId??0
            );
            var json = jsonDecode(result.body);
            closeDialogue(context);
            if (json['status']) {
              BlocProvider.of<VideoBloc>(context)
                  .add( const VideoLoading(selectedTabIndex: 1));
              showSuccessToast(context,
                  "Video has been saved successfully");
              await Future.delayed(
                  const Duration(milliseconds: 200));
              File recordedVideoFile = File(widget.data.filePath);
              File processedVideoFile = File(widget.data.newPath!);
              recordedVideoFile.delete();
              processedVideoFile.delete();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
            } else {
              showErrorToast(
                  context, json['message']);
            }
          });
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
      File(widget.data.newPath!),
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
        File('$saveCacheDirectory${widget.data.newName}.gif'),
        "thrillvideo",
        "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
        AWSRegions.usEast1,
        debugLog: true,
        s3FolderPath: "gif",
        fileName: '$currentUnix.gif',
        accessControl: S3AccessControl.publicRead,
      ).then((value) async {
        if(widget.data.addSoundModel==null || !widget.data.addSoundModel!.isSoundFromGallery){
          String tagList =
          jsonEncode(selectedHashtags);
          var result = await RestApi.postVideo(
              videoId,
              widget.data.isDuet?widget.data.duetSound??"":widget.data.addSoundModel==null?"":widget.data.addSoundModel!.isSoundFromGallery?"$currentUnix.mp3":widget.data.addSoundModel!.sound.split('/').last,
              widget.data.isDuet?widget.data.duetSoundName??"":widget.data.addSoundModel?.name??"Original Sound",
              dropDownCategoryValue,
              tagList,
              "Public",
              commentsSwitch ? 1 : 0,
              desCtr.text,
              widget.data.filterName.isEmpty
                  ? ''
                  : widget.data.filterName,
              dropDownLanguageValue,
              '$currentUnix.gif',
              widget.data.speed,
            duetSwitch,
            commentsSwitch,
              widget.data.duetFrom??'',
            widget.data.isDuet,
              widget.data.addSoundModel?.userId??0
          );
          var json = jsonDecode(result.body);
          closeDialogue(context);
          if (json['status']) {
            BlocProvider.of<VideoBloc>(context).add( const VideoLoading(selectedTabIndex: 1));
            showSuccessToast(context,
                "Video has been posted successfully");
            await Future.delayed(const Duration(milliseconds: 200));
            File recordedVideoFile = File(widget.data.filePath);
            File processedVideoFile = File(widget.data.newPath!);
            recordedVideoFile.delete();
            processedVideoFile.delete();
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
          } else {
            showErrorToast(
                context, json['message']);
          }
        } else {
          await _simpleS3
              .uploadFile(
            File(widget.data.addSoundModel!.sound),
            "thrillvideo",
            "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
            AWSRegions.usEast1,
            debugLog: true,
            fileName: '$currentUnix.mp3',
            s3FolderPath: "sound",
            accessControl: S3AccessControl.publicRead,
          ).then((value) async {
            String tagList =
            jsonEncode(selectedHashtags);
            var result = await RestApi.postVideo(
                videoId,
                widget.data.isDuet?widget.data.duetSound??"":widget.data.addSoundModel==null?"":widget.data.addSoundModel!.isSoundFromGallery?"$currentUnix.mp3":widget.data.addSoundModel!.sound.split('/').last,
                widget.data.addSoundModel?.name??"",
                dropDownCategoryValue,
                tagList,
                "Public",
                commentsSwitch ? 1 : 0,
                desCtr.text,
                widget.data.filterName.isEmpty
                    ? ''
                    : widget.data.filterName,
                dropDownLanguageValue,
                '$currentUnix.gif',
                widget.data.speed,
              duetSwitch,
              commentsSwitch,
                widget.data.duetFrom??'',
              widget.data.isDuet,
                widget.data.addSoundModel?.userId??0
            );
            var json = jsonDecode(result.body);
            closeDialogue(context);
            if (json['status']) {
              BlocProvider.of<VideoBloc>(context).add( const VideoLoading(selectedTabIndex: 1));
              showSuccessToast(context, "Video has been posted successfully");
              await Future.delayed(const Duration(milliseconds: 200));
              File recordedVideoFile = File(widget.data.filePath);
              File processedVideoFile = File(widget.data.newPath!);
              recordedVideoFile.delete();
              processedVideoFile.delete();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } else {
              showErrorToast(
                  context, json['message']);
            }
          });
        }
      });
    });
  }

  getHashtags()async{
    try{
      var response = await RestApi.getHashtagList();
      var json = jsonDecode(response.body);
      if(json['status']){
        List jsonList = json['data'] as List;
        hashtagsList = jsonList.map((e) => HashtagModel.fromJson(e)).toList();
        setState((){});
      }
    } catch(e){
      showErrorToast(context, e.toString());
    }
  }

  addNewTagDialog(){
    hashtagTextFieldController.clear();
    List<HashtagModel> suggestedHashtags = List<HashtagModel>.empty(growable: true);
    showDialog(context: context, builder: (_)=>StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              height: getHeight(context)*.60,
              width: getWidth(context)*.90,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextFormField(
                        maxLength: 10,
                        controller: hashtagTextFieldController,
                        onChanged: (String txt){
                          if(txt.isEmpty){
                            setState(() => suggestedHashtags = List.empty(growable: true));
                          } else {
                            for(var element in hashtagsList){
                              if(element.name.toLowerCase().contains(txt.toLowerCase())){
                                setState(()=>suggestedHashtags.add(element));
                              }
                            }
                          }
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: "Input Hashtag",
                          isDense: true,
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),),
                      IconButton(
                          onPressed: (){
                            if(hashtagTextFieldController.text.trim().isNotEmpty){
                              selectedHashtags.add(hashtagTextFieldController.text);
                            }
                            Navigator.pop(context);
                          }, icon: Icon(hashtagTextFieldController.text.isEmpty?Icons.close:Icons.check))
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestedHashtags.length,
                        itemBuilder: (BuildContext context, int index){
                          return ListTile(
                            title: Text(suggestedHashtags[index].name),
                            trailing: IconButton(onPressed: (){
                              selectedHashtags.add(suggestedHashtags[index].name);
                              Navigator.pop(context);
                            }, icon: const Icon(Icons.check)),
                          );
                        }
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    )).then((value) => setState((){}));
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
}
