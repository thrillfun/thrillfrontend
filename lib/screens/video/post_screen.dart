import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/model/video_fields_model.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/seperator.dart';
import 'package:video_player/video_player.dart';

var lastChangedWord = "".obs;

class PostScreenGetx extends StatelessWidget {
  PostScreenGetx(this.postData, this.selectedSound);

  PostData? postData;
  String? selectedSound;
  VideoPlayerController? videoPlayerController;
  var isHashtag = false.obs;
  var descriptionText = "".obs;
  var discoverController = Get.find<DiscoverController>();
  var isPlaying = false.obs;
  var selectedItem = 'English'.obs;
  var selectedPrivacy = "Public".obs;
  var languages = ["English", "Hindi"].obs;
  var types = ["Funny", "boring "].obs;
  var allowComments = false.obs;
  var allowDuets = false.obs;
  var selectedChip = 0.obs;
  var selectedItems = [].obs;
  var privacy = ["Public", "Private"].obs;
  var selectedCategory = 'Funny'.obs;
  var searchItems = [].obs;
  var videosController = Get.find<VideosController>();
  final SimpleS3 _simpleS3 = SimpleS3();

  var currentText = "".obs;
  var userHashtagsList = [];

  TextEditingController searchController = TextEditingController();

  late BuildContext? buildContext;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    initPlayer();
    getFields();

    buildContext = context;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: processGradient),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: videoLayout(),
          )
        ],
      ),
    );
  }

  getFields() => {
        videosController.getVideoFields(),
      };

  initPlayer() => videoPlayerController =
      VideoPlayerController.file(File(postData!.newPath!.toString()))
        ..initialize()
        ..setLooping(true)
        ..play().then((value) => isPlaying.value = true);

  videoLayout() => Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 220,
              decoration: const BoxDecoration(
                  color: Color(0xff353841),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: InkWell(
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        child: Container(
                          height: 220,
                          child: VideoPlayer(videoPlayerController!),
                        )),
                    onTap: () {
                      if (isPlaying.value) {
                        videoPlayerController!.pause();
                        isPlaying.value = false;
                      } else {
                        videoPlayerController!.play();
                        isPlaying.value = true;
                      }
                    },
                  )),
                  descriptionLayout(),
                ],
              )),
          Obx(() => searchItems.isNotEmpty
              ? Obx(() => Visibility(
                  child: ListView.builder(
                      itemCount: searchItems.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              var words = textEditingController.text
                                  .split(" "); // uses an array
                              lastChangedWord.value = words[words.length - 1];

                              textEditingController.text =
                                  textEditingController.text.replaceAll(
                                      words[words.length - 1],
                                      searchItems[index].toString());

                              searchItems.clear();
                            },
                            child: Text(
                              "#" +
                                  searchItems[index]
                                      .toString()
                                      .replaceAll(RegExp("#"), ''),
                              style: TextStyle(color: Colors.white),
                            ),
                          )))))
              : Column(
                  children: [
                    hashTagLayout(),
                    chipSelectionLayout(),
                    const SizedBox(
                      height: 10,
                    ),
                    const MySeparator(
                      color: Color(0xff353841),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // dropDownLanguage(),
                    // dropDownVideoType(),
                    videoSettingsLayout(),
                    InkWell(
                      onTap: () {
                        if (textEditingController.text.isEmpty) {
                          Get.snackbar("error", "fieldEmpty").show();
                        } else {
                          postUpload();
                        }
                      },
                      child: Container(
                        width: Get.width,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ColorManager.colorPrimaryLight,
                                  ColorManager.colorAccent
                                ])),
                        child: const Text(
                          "Post Video",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ))
        ],
      );

  descriptionLayout() => Expanded(
          child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                child: HashTagTextField(
              controller: textEditingController,
              maxLines: 10,
              onChanged: (String txt) {
                currentText.value = txt;

                searchItems.clear();

                if (txt.isEmpty) {
                  searchItems.value = [];
                } else {
                  discoverController.hashTagsList.forEach((element) {
                    if (element.name!.toLowerCase().contains(
                        extractHashTags(txt)
                            .last
                            .toString()
                            .replaceAll(RegExp("#"), '')
                            .toLowerCase())) {
                      print(extractHashTags(txt).last.toString());
                      searchItems.add(element.name);
                    }
                  });
                  lastChangedWord.value = txt;
                }
              },
              basicStyle: const TextStyle(color: Colors.white),
              decoratedStyle:
                  const TextStyle(color: ColorManager.colorPrimaryLight),
              decoration: InputDecoration.collapsed(
                  hintText: "Describe your video",
                  hintStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.6))),
            )),
          ],
        ),
        alignment: Alignment.topLeft,
      ));

  hashTagLayout() => InkWell(
        onTap: () {
          discoverController.getHashTagsList();
          Get.defaultDialog(
              title: "Select Hashtag",
              middleText: "",
              content: InkWell(
                child: Column(
                  children: [
                    TextFormField(
                      maxLength: 20,
                      controller: searchController,
                      onChanged: (String txt) {
                        searchItems.clear();
                        if (txt.isEmpty) {
                          searchItems.value = [];
                        } else {
                          discoverController.hashTagsList.forEach((element) {
                            if (element.name!
                                .toLowerCase()
                                .contains(txt.toLowerCase())) {
                              searchItems.add(element.name);
                            }
                          });
                        }
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        discoverController.hashTagsList.forEach((element) {
                          if (element.name.toString().toLowerCase() ==
                              textEditingController.text.toLowerCase()) {
                            searchItems.add(element.name);
                          } else {
                            selectedItems.clear();
                            selectedItems.add(value);
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Input Hashtag",
                        isDense: true,
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    hashTagsDialogLayout()
                  ],
                ),
              ));
        },
        child: Container(
          width: Get.width,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xff353841)),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: const [
              Icon(
                Icons.add,
                color: ColorManager.colorPrimaryLight,
              ),
              Expanded(
                child: Text(
                  "Add Hashtag",
                  style: TextStyle(color: ColorManager.colorPrimaryLight),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      );

  chipSelectionLayout() => GetX<DiscoverController>(
      builder: (discoverController) => Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                children: List.generate(
                    selectedItems.length,
                    (index) => Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: FilterChip(
                              selectedColor: ColorManager.colorAccent,
                              elevation: 10,
                              label: Text(selectedItems[index].toString(),
                                  style: const TextStyle(color: Colors.white)),
                              onSelected: (value) =>
                                  selectedItems.removeAt(index)),
                        )),
              ),
            ),
          ));

  dropDownLanguage() => GetX<VideosController>(
      builder: (videosController) => videosController.isLoading.value
          ? Container()
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: const Color(0xff353841)),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Theme(
                data: Theme.of(buildContext!)
                    .copyWith(canvasColor: const Color(0xff353841)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    icon: const Icon(
                      Icons.keyboard_double_arrow_down,
                      color: Colors.white,
                    ),
                    value: selectedItem.value,
                    items: videosController.languageList
                        .map((Languages element) => DropdownMenuItem(
                            value: element.name,
                            child: Text(element.name.toString(),
                                style: TextStyle(color: Colors.white))))
                        .toList(growable: true),
                    onChanged: (value) {
                      selectedItem.value = value!.toString();
                    },
                  ),
                ),
              )));

  dropDownPrivacy() => Obx(() => selectedPrivacy.value == ""
      ? Container()
      : PopupMenuButton(
          itemBuilder: (context) => privacy
              .map((element) => PopupMenuItem(
                  value: element,
                  child: Text(element.toString(),
                      style:
                          const TextStyle(color: Colors.black, fontSize: 14))))
              .toList(growable: true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                selectedPrivacy.value,
                style: const TextStyle(color: ColorManager.colorPrimaryLight),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: ColorManager.colorPrimaryLight,
              ),
            ],
          ),
          onSelected: (value) => {selectedPrivacy.value = value.toString()},
        ));

  dropDownVideoType() => GetX<VideosController>(
      builder: (videosController) => videosController.isLoading.value
          ? Container()
          : Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: const Color(0xff353841)),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Theme(
                data: Theme.of(buildContext!)
                    .copyWith(canvasColor: const Color(0xff353841)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    icon: const Icon(
                      Icons.keyboard_double_arrow_down,
                      color: Colors.white,
                    ),
                    value: selectedCategory.value,
                    items: videosController.categoriesList
                        .map((Categories element) => DropdownMenuItem(
                              child: Text(
                                element.title.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              value: element.title,
                            ))
                        .toList(growable: true),
                    onChanged: (value) {
                      selectedCategory.value = value!.toString();
                    },
                  ),
                ),
              )));

  videoSettingsLayout() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: RichText(
                        text: const TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Icons.lock_open,
                        size: 20,
                        color: Colors.white,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  TextSpan(
                      text: " Who can view this video",
                      style: TextStyle(color: Colors.white, fontSize: 14))
                ]))),
                dropDownPrivacy()
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: const TextSpan(children: <InlineSpan>[
                  WidgetSpan(
                    child: Icon(
                      Icons.message_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                      text: " Allow Comments",
                      style: TextStyle(color: Colors.white, fontSize: 14))
                ])),
                Obx(
                  () => Switch(
                      onChanged: (val) => allowComments.toggle(),
                      value: allowComments.value,
                      activeColor: Colors.white,
                      activeTrackColor: ColorManager.colorPrimaryLight,
                      inactiveThumbColor: ColorManager.colorPrimaryLight,
                      inactiveTrackColor: Color(0xff353841)),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: const TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  TextSpan(
                      text: " Allow Duets",
                      style: TextStyle(color: Colors.white, fontSize: 14))
                ])),
                Obx(() => Switch(
                    onChanged: (value) => allowDuets.toggle(),
                    value: allowDuets.value,
                    activeColor: Colors.white,
                    activeTrackColor: ColorManager.colorPrimaryLight,
                    inactiveThumbColor: ColorManager.colorPrimaryLight,
                    inactiveTrackColor: const Color(0xff353841)))
              ],
            ),
          ],
        ),
      );

  hashTagsDialogLayout() => GetX<DiscoverController>(
      builder: (discoverController) => discoverController
              .isHashTagsListLoading.value
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SizedBox(
              height: 250,
              width: Get.width,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: searchItems.isNotEmpty
                    ? Wrap(
                        children: List.generate(
                            searchItems.length,
                            (index) => Obx(
                                  () => Padding(
                                      padding: EdgeInsets.all(5),
                                      child: FilterChip(
                                          selected: selectedItems.contains(
                                              discoverController
                                                  .hashTagsList[index].name
                                                  .toString()),
                                          onSelected: (value) {
                                            value
                                                ? selectedItems.add(
                                                    discoverController
                                                        .hashTagsList[index]
                                                        .name
                                                        .toString())
                                                : selectedItems.removeWhere(
                                                    (element) =>
                                                        element ==
                                                        discoverController
                                                            .hashTagsList[index]
                                                            .name
                                                            .toString());
                                            selectedItems.refresh();

                                            textEditingController.text =
                                                textEditingController.text +
                                                    " #" +
                                                    searchItems[index]
                                                        .toString()
                                                        .replaceAll(
                                                            RegExp("#"), '');
                                          },
                                          selectedColor:
                                              ColorManager.colorAccent,
                                          elevation: 10,
                                          label: Text(
                                            searchItems[index].toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ))),
                                )),
                      )
                    : Wrap(
                        children: List.generate(
                            discoverController.hashTagsList.length,
                            (index) => Obx(
                                  () => Padding(
                                      padding: EdgeInsets.all(5),
                                      child: FilterChip(
                                          selected: selectedItems.contains(
                                              discoverController
                                                  .hashTagsList[index].name
                                                  .toString()),
                                          onSelected: (value) => {
                                                value
                                                    ? selectedItems.add(
                                                        discoverController
                                                            .hashTagsList[index]
                                                            .name
                                                            .toString())
                                                    : selectedItems.removeWhere(
                                                        (element) =>
                                                            element ==
                                                            discoverController
                                                                .hashTagsList[
                                                                    index]
                                                                .name
                                                                .toString()),
                                                selectedItems.refresh(),
                                                textEditingController.text =
                                                    textEditingController.text +
                                                        " #" +
                                                        selectedItems.last
                                                            .toString()
                                                            .replaceAll(
                                                                RegExp("#"), '')
                                              },
                                          selectedColor:
                                              ColorManager.colorAccent,
                                          elevation: 10,
                                          label: Text(
                                            discoverController
                                                .hashTagsList[index].name
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ))),
                                )),
                      ),
              )
              // ListView.builder(
              //     physics: const BouncingScrollPhysics(),
              //     scrollDirection: Axis.horizontal,
              //     itemCount: discoverController.hashTagsList.length,
              //     shrinkWrap: true,
              //     itemBuilder: (context, index) => Obx(() => FilterChip(
              //         selected: selectedItems.contains(discoverController
              //             .hashTagsList[index].name
              //             .toString()),
              //         onSelected: (value) => value
              //             ? selectedItems.add(discoverController
              //                 .hashTagsList[index].name
              //                 .toString())
              //             : selectedItems.removeWhere((element) =>
              //                 element ==
              //                 discoverController.hashTagsList[index].name
              //                     .toString()),
              //         selectedColor: ColorManager.colorAccent,
              //         elevation: 10,
              //         label: Text(
              //           discoverController.hashTagsList[index].name.toString(),
              //           style: const TextStyle(color: Colors.white),
              //         )))),
              ));

  postUpload() async {
    String tagList = jsonEncode(extractHashTags(textEditingController.text));

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    String videoId = 'Thrill-$currentUnix.mp4';
    videoPlayerController!.pause();
    var file =
        File(selectedSound!.isEmpty?postData!.filePath!.substring(7, postData!.filePath.length):postData!.filePath!);

    try {
      GetStorage().write("videoPrivacy", selectedPrivacy.value);
      await videosController.createGIF(currentUnix, postData!.newPath!).then(
              (value) async =>
              { await videosController.awsUploadThumbnail(currentUnix).then((value)async{

      })});
    await  videosController
          .awsUploadVideo(file, currentUnix);
      var audioFile = File(saveCacheDirectory + "originalAudio.mp3");

      if(postData!.addSoundModel!.sound.isNotEmpty){
        audioFile = File(postData!.addSoundModel!.sound);
      }
      if (selectedSound!.isEmpty) {

        await videosController
            .awsUploadSound(audioFile, currentUnix.toString())
            .then((value) => {
          videosController.postVideo(
              User.fromJson(GetStorage().read("user"))
                  .id
                  .toString(),
              videoId,
              postData!.isDuet
                  ? postData!.duetSound ?? ""
                  : postData!.addSoundModel == null
                  ? ""
                  : postData!
                  .addSoundModel!.isSoundFromGallery
                  ? "Thrill-$currentUnix.mp3"
                  : postData!.addSoundModel!.sound
                  .split('/')
                  .last,
              postData!.addSoundModel?.name ?? "",
              "1",
              tagList,
              selectedPrivacy.value,
              allowComments.value ? 1 : 0,
              textEditingController.text,
              postData!.filterName.isEmpty
                  ? ''
                  : postData!.filterName,
              "1",
              'Thrill-$currentUnix.png',
              postData!.speed,
              allowDuets.value,
              allowComments.value,
              postData!.duetFrom ?? '',
              postData!.isDuet,
              postData!.addSoundModel?.userId ?? 0)
        });
      }
      else {
        videosController.postVideo(
            User.fromJson(GetStorage().read("user")).id.toString(),
            videoId,
            postData!.isDuet
                ? postData!.duetSound ?? ""
                : postData!.addSoundModel == null
                ? ""
                : postData!.addSoundModel!.isSoundFromGallery
                ? "Thrill-$currentUnix.mp3"
                : postData!.addSoundModel!.sound
                .split('/')
                .last,
            postData!.addSoundModel?.name ?? "",
            "1",
            tagList,
            selectedPrivacy.value,
            allowComments.value ? 1 : 0,
            textEditingController.text,
            postData!.filterName.isEmpty ? '' : postData!.filterName,
            "1",
            'Thrill-$currentUnix.png',
            postData!.speed,
            allowDuets.value,
            allowComments.value,
            postData!.duetFrom ?? '',
            postData!.isDuet,
            postData!.addSoundModel?.userId ?? 0);
      }
      // Get.offAll(BottomNavigation());
    //  videosController.getAllVideos();

    } catch (e) {
      errorToast(e.toString());
    }
  }

  Future<void> createGIF(int currentUnix) async {
    String outputPath = '$saveCacheDirectory${postData!.newName}.png';
    String filePath = postData!.isDuet
        ? postData!.newPath!.substring(7, postData!.newPath!.length)
        : postData!.newPath!.substring(7, postData!.newPath!.length);
    FFmpegKit.execute(
            "-y -i $filePath -r 3 -filter:v scale=${Get.width}:${Get.height} -t 5 $outputPath")
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        await _simpleS3
            .uploadFile(
          File('$saveCacheDirectory${postData!.newName}.png'),
          "thrillvideo",
          "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
          AWSRegions.usEast1,
          debugLog: true,
          s3FolderPath: "gif",
          fileName: 'Thrill-$currentUnix.png',
          accessControl: S3AccessControl.publicRead,
        )
            .then((value) async {
          var file = File(postData!.addSoundModel!.sound);
        });
        // print("============================> GIF Success!!!!");
      } else {
        // print("============================> GIF Error!!!!");
      }
    });
  }
}
