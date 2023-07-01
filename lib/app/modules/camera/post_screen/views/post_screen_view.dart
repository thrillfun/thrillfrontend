import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/modules/camera/controllers/camera_controller.dart';
import 'package:thrill/app/rest/models/video_field_model.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/post_screen_controller.dart';
import 'package:hashtagable/hashtagable.dart';

class PostScreenView extends GetView<PostScreenController> {
  PostScreenView({Key? key}) : super(key: key);

  var isPLayerPlaying = true.obs;
  var isPlayerVisible = true.obs;
  var cameraController = Get.find<CameraController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Post Video"),
        backgroundColor: Colors.transparent.withOpacity(0.0),
      ),
      body: SingleChildScrollView(
        child: videoLayout(),
      ),
    );
  }

  videoLayout() => Column(
        children: [
          Stack(
            children: [
              GlassmorphicContainer(
                width: Get.width,
                height: 250,
                borderRadius: 0,
                blur: 0,
                alignment: Alignment.bottomCenter,
                border: 1,
                linearGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0,
                      1,
                      1
                    ],
                    colors: [
                      ColorManager.colorAccent,
                      Colors.black,
                      ColorManager.colorAccent,
                    ]),
                borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: []),
                child: null,
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(Get.context!).viewPadding.top),
                child: GlassmorphicContainer(
                  width: Get.width,
                  height: 250,
                  borderRadius: 10,
                  blur: 10,
                  margin:
                      EdgeInsets.only(left: 10, right: 10, top: 60, bottom: 10),
                  alignment: Alignment.bottomCenter,
                  border: 1,
                  linearGradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.5),
                      ]),
                  borderGradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.3)
                      ]),
                  child: Row(
                    children: [
                      SizedBox(
                        child: VisibilityDetector(
                            key: const Key("post"),
                            child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: ColorManager.postGradient),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      isPlayerVisible.value = true;
                                      if (controller.videoPlayerController!
                                          .value.isPlaying) {
                                        controller.videoPlayerController!
                                            .pause();
                                      } else {
                                        controller.videoPlayerController!
                                            .play();
                                      }
                                      isPLayerPlaying.value = controller
                                          .videoPlayerController!
                                          .value
                                          .isPlaying;

                                      if (isPLayerPlaying.isTrue) {
                                        Future.delayed(Duration(seconds: 3))
                                            .then((value) {
                                          isPlayerVisible.value = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: Get.height,
                                      width: Get.width / 2.5,
                                      child: AspectRatio(
                                        aspectRatio: Get.size.aspectRatio,
                                        child: VideoPlayer(
                                            controller.videoPlayerController!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (isPLayerPlaying.value) {
                                  controller.videoPlayerController!.pause();
                                } else {
                                  controller.videoPlayerController!.play();
                                }
                                isPLayerPlaying.value = controller
                                    .videoPlayerController!.value.isPlaying;
                              },
                            ),
                            onVisibilityChanged: (VisibilityInfo info) {
                              info.visibleFraction == 0
                                  ? controller.videoPlayerController!.pause
                                  : controller.videoPlayerController!.play;
                            }),
                      ),
                      Expanded(child: descriptionLayout()),
                    ],
                  ),
                ),
              ),
            ],
          )
          // Container(
          //   height: 200,
          //   margin: EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //       border: Border.all(color: ColorManager.colorAccent),
          //       borderRadius: BorderRadius.circular(10)),
          //   child: ,
          // )
          // Align(
          //   alignment: Alignment.bottomLeft,
          //   child: InkWell(
          //     child: Container(
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(10),
          //           color: Colors.white.withOpacity(0.3)),
          //       child: Text("Edit video"),
          //     ),
          //     onTap: () async {
          //       List<imgly.AudioClip> audioClips = [];
          //       List<imgly.AudioClip> selectedAudioClips = [];
          //       List<imgly.AudioClipCategory> audioClipCategories = [];
          //       final serializationString = GetStorage().read("serialization");
          //       final serialization = jsonDecode(serializationString);

          //       if (cameraController.selectedSound.isNotEmpty ||
          //           cameraController.userUploadedSound.isNotEmpty) {
          //         selectedAudioClips.add(imgly.AudioClip(
          //             cameraController.selectedSound.value.isEmpty
          //                 ? cameraController.userUploadedSound.value
          //                 : cameraController.selectedSound.value,
          //             cameraController.selectedSound.value.isEmpty
          //                 ? cameraController.userUploadedSound.value
          //                 : cameraController.selectedSound.value,
          //             title: cameraController.selectedSound.value.isEmpty
          //                 ? cameraController.userUploadedSound.value
          //                 : cameraController.selectedSound.value,
          //             thumbnailURI:
          //                 "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png"));

          //         audioClipCategories.add(imgly.AudioClipCategory(
          //             "", "selected sound",
          //             thumbnailURI: null, items: selectedAudioClips));
          //       }

          //       var audioOptions = imgly.AudioOptions(
          //         categories: audioClipCategories,
          //       );

          //       var codec = imgly.VideoCodec.values;

          //       var exportOptions = imgly.ExportOptions(
          //         serialization: imgly.SerializationOptions(
          //             enabled: true,
          //             exportType: imgly.SerializationExportType.object),
          //         video: imgly.VideoOptions(quality: 1.0, codec: codec[1]),
          //       );

          //       await VESDK
          //           .openEditor(
          //               controller.videosList.isNotEmpty
          //                   ? Video.composition(videos: controller.videosList)
          //                   : Video(controller.videoFile.value.path),
          //               serialization: serialization,
          //               configuration: imgly.Configuration(
          //                   audio: audioOptions,
          //                   theme: imgly.ThemeOptions(imgly.Theme(
          //                     "default_editor_theme",
          //                   ))))
          //           .then((value) =>
          //               controller.videoFile = File(value!.video).obs);
          //     },
          //   ),
          // ),
          ,
          const Divider(
            thickness: 2,
          ),

          Obx(() => Visibility(
              visible: controller.searchItems.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                          controller.searchItems.length,
                          (index) => Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorManager.colorAccent),
                                  borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () {
                                  var words = controller
                                      .textEditingController.text
                                      .split(" "); // uses an array

                                  controller.lastChangedWord.value =
                                      words[words.length - 1];

                                  controller.textEditingController.text =
                                      controller
                                          .textEditingController.text
                                          .replaceAll(
                                              words[words.length - 1],
                                              controller.searchItems[index]
                                                  .toString()
                                                  .removeAllWhitespace);

                                  controller.textEditingController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: controller
                                              .textEditingController
                                              .text
                                              .length));

                                  controller.searchItems.clear();
                                },
                                child: Text(
                                  "#" +
                                      controller.searchItems[index]
                                          .toString()
                                          .replaceAll(RegExp("#"), ''),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ))),
                    ),
                  )
                ],
              ))),
          chipSelectionLayout(),
          const SizedBox(
            height: 10,
          ),
          // MySeparator(
          //   color: ColorManager.dayNightText,
          // ),
          const SizedBox(
            height: 10,
          ),
          // dropDownLanguage(),
          // dropDownVideoType(),
          videoSettingsLayout(),
          InkWell(
            onTap: () async {
              if (controller.textEditingController.text.isEmpty) {
                errorToast("Please write a to continue");
              } else {
                await controller.createGIF();
              }
            },
            child: Container(
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  gradient: ColorManager.postGradient),
              child: const Text(
                "Post Video",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      );

  chipSelectionLayout() => Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            children: List.generate(
                controller.selectedItems.length,
                (index) => Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: FilterChip(
                          selectedColor: ColorManager.colorAccent,
                          elevation: 10,
                          label: Text(
                              controller.selectedItems[index].toString(),
                              style: const TextStyle()),
                          onSelected: (value) =>
                              controller.selectedItems.removeAt(index)),
                    )),
          ),
        ),
      );

  descriptionLayout() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
        child: HashTagTextField(
          decoratedStyle: const TextStyle(color: ColorManager.colorAccent),
          controller: controller.textEditingController,
          maxLines: 10,
          onChanged: (String txt) {
            controller.currentText.value = txt;

            controller.searchItems.clear();

            if (txt.isEmpty) {
              controller.searchItems.value = [];
            } else {
              controller.tophashtagvideosList.forEach((element) {
                if (element.hashtagName!.toLowerCase().contains(
                    extractHashTags(txt)
                        .last
                        .toString()
                        .replaceAll(RegExp("#"), '')
                        .toLowerCase())) {
                  print(extractHashTags(txt).last.toString());
                  controller.searchItems.add(element.hashtagName);
                }
              });
              controller.lastChangedWord.value = txt;
            }
          },
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Write a caption......",
              hintStyle: TextStyle(
                fontStyle: FontStyle.italic,
              )),
        ),
        alignment: Alignment.topLeft,
      );

  hashTagLayout() => InkWell(
        onTap: () {
          //discoverController.getHashTagsList();
          Get.defaultDialog(
              title: "Select Hashtag",
              middleText: "",
              content: InkWell(
                child: Column(
                  children: [
                    TextFormField(
                      maxLength: 20,
                      controller: controller.searchController,
                      onChanged: (String txt) {
                        controller.searchItems.clear();
                        if (txt.isEmpty) {
                          controller.searchItems.value = [];
                        } else {
                          controller.tophashtagvideosList.forEach((element) {
                            if (element.hashtagName!
                                .toLowerCase()
                                .contains(txt.toLowerCase())) {
                              controller.searchItems.add(element.hashtagName);
                            }
                          });
                        }
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        controller.tophashtagvideosList.forEach((element) {
                          if (element.hashtagName.toString().toLowerCase() ==
                              controller.textEditingController.text
                                  .toLowerCase()) {
                            controller.searchItems.add(element.hashtagName);
                          } else {
                            controller.selectedItems.clear();
                            controller.selectedItems.add(value);
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
                  ],
                ),
              ));
        },
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              border: Border.all(color: ColorManager.dayNightIcon),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: ColorManager.dayNightIcon,
              ),
              const Expanded(
                child: Text(
                  "Add Hashtag",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      );

  dropDownLanguage() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: Get.width,
      decoration: BoxDecoration(
          color: const Color(0xff353841),
          border: Border.all(color: const Color(0xff353841)),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Theme(
        data: Theme.of(Get.context!)
            .copyWith(canvasColor: const Color(0xff353841)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: const Icon(
              Icons.keyboard_double_arrow_down,
            ),
            value: controller.selectedItem.value,
            items: controller.languagesList
                .map((Languages element) => DropdownMenuItem(
                    value: element.name,
                    child: Text(element.name.toString(),
                        style: const TextStyle())))
                .toList(growable: true),
            onChanged: (value) {
              controller.selectedItem.value = value!.toString();
            },
          ),
        ),
      ));

  dropDownPrivacy() => Obx(() => controller.selectedPrivacy.value == ""
      ? Container()
      : PopupMenuButton(
          itemBuilder: (context) => controller.privacy
              .map((element) => PopupMenuItem(
                  value: element,
                  child: Text(element.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18))))
              .toList(growable: true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                controller.selectedPrivacy.value,
                style: const TextStyle(
                    color: ColorManager.colorPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: ColorManager.colorPrimaryLight,
              ),
            ],
          ),
          onSelected: (value) =>
              {controller.selectedPrivacy.value = value.toString()},
        ));

  dropDownVideoType() => Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: Get.width,
      decoration: BoxDecoration(
          color: const Color(0xff353841),
          border: Border.all(color: const Color(0xff353841)),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Theme(
        data: Theme.of(Get.context!)
            .copyWith(canvasColor: const Color(0xff353841)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.keyboard_double_arrow_down,
              color: ColorManager.dayNightIcon,
            ),
            value: controller.selectedCategory.value,
            items: controller.categoriesList
                .map((Categories element) => DropdownMenuItem(
                      child: Text(
                        element.title.toString(),
                        style: const TextStyle(),
                      ),
                      value: element.title,
                    ))
                .toList(growable: true),
            onChanged: (value) {
              controller.selectedCategory.value = value!.toString();
            },
          ),
        ),
      ));

  videoSettingsLayout() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Text.rich(TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Iconsax.lock,
                        size: 26,
                        color: ColorManager.dayNightIcon,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  const TextSpan(
                      text: " Who can view this video ",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18))
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
                Text.rich(TextSpan(children: <InlineSpan>[
                  WidgetSpan(
                    child: Icon(
                      Iconsax.message,
                      color: ColorManager.dayNightIcon,
                      size: 26,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const TextSpan(
                      text: " Allow Comments",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18))
                ])),
                Obx(
                  () => Switch(
                    onChanged: (val) => controller.allowComments.toggle(),
                    value: controller.allowComments.value,
                    activeColor: Colors.white,
                    activeTrackColor: ColorManager.colorPrimaryLight,
                    inactiveThumbColor: ColorManager.colorPrimaryLight,
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Iconsax.video,
                        color: ColorManager.dayNightIcon,
                        size: 26,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  const TextSpan(
                      text: " Allow Duets",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18))
                ])),
                Obx(() => Switch(
                    onChanged: (value) => controller.allowDuets.toggle(),
                    value: controller.allowDuets.value,
                    activeColor: Colors.white,
                    activeTrackColor: ColorManager.colorPrimaryLight,
                    inactiveThumbColor: ColorManager.colorPrimaryLight,
                    inactiveTrackColor: Colors.grey))
              ],
            ),
          ],
        ),
      );
}
