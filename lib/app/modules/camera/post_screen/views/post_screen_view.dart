import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';
import 'package:thrill/app/modules/camera/controllers/camera_controller.dart';
import 'package:thrill/app/rest/models/video_field_model.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:thrill/app/widgets/focus_detector.dart';
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
  var hello = ["hello", "hi", "bye"];
  var isSuggestionVisible = false.obs;
  var lastChangedText = ''.obs;
  var textsoundName = "".obs;
  var textEditingController = TextEditingController();

  var isEditable = false.obs;
  @override
  Widget build(BuildContext context) {
    textsoundName.value = controller.soundName;
    textEditingController.text = controller.soundName;
    return WillPopScope(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("Post Video"),
            backgroundColor: Colors.transparent.withOpacity(0.0),
          ),
          body: Portal(
            child: SingleChildScrollView(
              child: videoLayout(),
            ),
          ),
        ),
        onWillPop: controller.onBackPressed);
  }

  videoLayout() => Obx(() => PortalTarget(
        visible: isSuggestionVisible.value,
        anchor:
            const Aligned(follower: Alignment.center, target: Alignment.center),
        portalFollower: Container(
            decoration: BoxDecoration(
                color: Theme.of(Get.context!).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: MediaQuery.removePadding(
                context: Get.context!,
                removeTop: true,
                child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    width: Get.width,
                    height: Get.height / 3,
                    child: Obx(
                      () => controller.searchList.isEmpty
                          ? Container()
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  controller.searchList[0].hashtags!.length,
                              itemBuilder: (context, index) => InkWell(
                                    onTap: () {
                                      controller.textEditingController.value.text = controller
                                              .textEditingController.value.text
                                              .replaceAll(
                                                  lastChangedText.value, ' ') +
                                          (controller.textEditingController
                                                      .value.text
                                                      .substring(controller
                                                          .textEditingController
                                                          .value
                                                          .selection
                                                          .baseOffset) +
                                                  controller.searchList[0]
                                                      .hashtags![index].name
                                                      .toString())
                                              .toString()
                                              .replaceAll(RegExp(" " + controller.textEditingController.value.text.substring(controller.textEditingController.value.selection.extentOffset)), '');

                                      final List<String> hashTags =
                                          extractHashTags(controller
                                              .textEditingController
                                              .value
                                              .text);

                                      controller.textEditingController.value
                                              .selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: controller
                                                      .textEditingController
                                                      .value
                                                      .text
                                                      .length));
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "#",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              controller.searchList[0]
                                                      .hashtags![index].name
                                                      .toString()
                                                      .replaceAll(
                                                          RegExp("#"), '') ??
                                                  "Hello",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        )),
                                  )),
                    )))),
        child: Column(
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
                  linearGradient: const LinearGradient(
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
                  borderGradient: const LinearGradient(
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
                    margin: const EdgeInsets.only(
                        left: 10, right: 10, top: 60, bottom: 10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.obx(
                            (state) => SizedBox(
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                            gradient:
                                                ColorManager.postGradient),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: Get.height,
                                        width: Get.width / 2.5,
                                        child: Obx(() => Image.file(
                                              File(controller
                                                      .customSelectedThumbnail
                                                      .isNotEmpty
                                                  ? controller
                                                      .customSelectedThumbnail
                                                      .value
                                                  : controller
                                                      .selectedThumbnail.value),
                                              fit: BoxFit.fill,
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Get.bottomSheet(
                                              Stack(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {},
                                                    child: Obx(() => Image.file(
                                                          File(controller
                                                                  .customSelectedThumbnail
                                                                  .isNotEmpty
                                                              ? controller
                                                                  .customSelectedThumbnail
                                                                  .value
                                                              : controller
                                                                  .selectedThumbnail
                                                                  .value),
                                                          height: Get.height,
                                                          width: Get.width,
                                                          fit: BoxFit.cover,
                                                        )),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Container(
                                                        height: Get.height / 12,
                                                        child: Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () => ImagePicker()
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .gallery,
                                                                      imageQuality:
                                                                          50)
                                                                  .then(
                                                                      (value) async {
                                                                if (value !=
                                                                    null) {
                                                                  var compressedFile = await FileSupport()
                                                                      .compressImage(
                                                                          File(
                                                                            value.path,
                                                                          ),
                                                                          quality:
                                                                              20);
                                                                  controller
                                                                          .customSelectedThumbnail
                                                                          .value =
                                                                      compressedFile!
                                                                          .path;
                                                                }
                                                              }),
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: ColorManager
                                                                        .colorAccent),
                                                                width: 50,
                                                                height:
                                                                    Get.height,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                      scrollDirection:
                                                                          Axis
                                                                              .horizontal,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount: controller
                                                                          .thumbnailEntities
                                                                          .length,
                                                                      itemBuilder: (context,
                                                                              index) =>
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              controller.customSelectedThumbnail.value = "";
                                                                              controller.currentSelectedFrame.value = index;
                                                                              controller.selectedThumbnail.value = controller.thumbnailEntities[index].path ?? "";
                                                                            },
                                                                            child: Obx(() =>
                                                                                Container(
                                                                                  decoration: BoxDecoration(border: Border.all(width: 1.5, color: controller.currentSelectedFrame.value == index ? ColorManager.colorAccent : Colors.transparent.withOpacity(0.0)), borderRadius: BorderRadius.circular(10)),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    child: Image.file(File(controller.thumbnailEntities[index].path), fit: BoxFit.cover),
                                                                                  ),
                                                                                )),
                                                                          )),
                                                            )
                                                          ],
                                                        )),
                                                  ),
                                                  Obx(() => Visibility(
                                                      visible: controller
                                                                      .currentSelectedFrame
                                                                      .value >=
                                                                  0 &&
                                                              controller
                                                                  .currentSelectedFrame
                                                                  .value
                                                                  .isLowerThan(
                                                                      60) ||
                                                          controller
                                                              .customSelectedThumbnail
                                                              .isNotEmpty,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: InkWell(
                                                          onTap: () =>
                                                              Get.back(),
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: ColorManager
                                                                        .colorAccent),
                                                                color: ColorManager
                                                                    .colorAccent
                                                                    .withOpacity(
                                                                        0.2)),
                                                            child: const Icon(
                                                              FontAwesome.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ))),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: InkWell(
                                                      onTap: () {
                                                        controller
                                                                .selectedThumbnail
                                                                .value =
                                                            controller
                                                                .thumbnailEntities[
                                                                    0]
                                                                .path;
                                                        controller
                                                            .currentSelectedFrame
                                                            .value = 999;
                                                        controller
                                                            .customSelectedThumbnail
                                                            .value = '';
                                                        Get.back();
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(20),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: ColorManager
                                                                    .colorAccent),
                                                            color: ColorManager
                                                                .colorAccent
                                                                .withOpacity(
                                                                    0.2)),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              isScrollControlled: true);
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: ColorManager.colorAccent),
                                          child: const Text(
                                            'Select Cover',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            onLoading: Align(
                              child: loader(),
                              alignment: Alignment.center,
                            )),
                        Flexible(
                            child: SizedBox(
                                child: Obx(() => HashTagTextField(
                                      controller: controller
                                          .textEditingController.value,
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          isSuggestionVisible.value = false;
                                        }
                                        if (controller.textEditingController
                                                .value.text
                                                .substring(controller
                                                        .textEditingController
                                                        .value
                                                        .selection
                                                        .baseOffset -
                                                    1) ==
                                            "#") {}
                                        if (controller.textEditingController
                                                    .value.text
                                                    .substring(controller
                                                            .textEditingController
                                                            .value
                                                            .selection
                                                            .baseOffset -
                                                        1) ==
                                                ' ' ||
                                            value.isEmpty) {
                                          isSuggestionVisible.value = false;
                                        }
                                        controller.searchHashtags(value
                                            .toString()
                                            .replaceAll(RegExp('#'), ' '));
                                      },
                                      onDetectionTyped: (text) {
                                        isSuggestionVisible.value = true;

                                        if (text.contains(RegExp('#'))) {}
                                        lastChangedText.value = text;

                                        controller.searchHashtags(text
                                            .toString()
                                            .replaceAll(RegExp('#'), ''));
                                      },
                                      decoratedStyle: const TextStyle(
                                          color: ColorManager.colorAccent),
                                      maxLines: 10,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          hintText: "Write a caption......",
                                          hintStyle: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          )),
                                    )))),
                        // Expanded(child: descriptionLayout()),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
                                        .textEditingController.value.text
                                        .split(" "); // uses an array

                                    controller.lastChangedWord.value =
                                        words[words.length - 1];

                                    controller
                                            .textEditingController.value.text =
                                        controller
                                            .textEditingController.value.text
                                            .replaceAll(
                                                controller.textEditingController
                                                    .value.text,
                                                controller.textEditingController
                                                        .value.text +
                                                    "${controller.searchItems[index].toString().replaceAll(RegExp("#"), '')}");

                                    controller.textEditingController.value
                                            .selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: controller
                                                .textEditingController
                                                .value
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
                if (controller.textEditingController.value.text.isEmpty) {
                  errorToast("Please write a description to continue");
                } else {
                  await controller.uploadGif(
                      controller.textEditingController.value.text,
                      controller.soundName,
                      controller.soundOwner);
                }
              },
              child: Container(
                width: Get.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        ),
      ));
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
          controller: controller.textEditingController.value,
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
                              controller.textEditingController.value.text
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
                          fontWeight: FontWeight.w600, fontSize: 14))))
              .toList(growable: true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                controller.selectedPrivacy.value,
                style: const TextStyle(
                    color: ColorManager.colorPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
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
            InkWell(
              onTap: () => Get.bottomSheet(
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: MediaQuery.of(Get.context!).padding.top),
                    child: Column(children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(Icons.close)),
                          Text(
                            'Audio Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          IconButton(
                              onPressed: () {
                                textsoundName.value =
                                    textEditingController.text;
                                controller.soundName =
                                    textEditingController.text;
                                Get.back();
                              },
                              icon: Icon(
                                Icons.done,
                                color: ColorManager.colorAccent,
                              ))
                        ],
                      ),
                      TextFormField(
                        controller: textEditingController,
                        onChanged: (value) {},
                        onFieldSubmitted: (text) {
                          textsoundName.value = text;
                          controller.soundName = text;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          prefixIcon: Icon(
                            Icons.music_note_outlined,
                          ),
                        ),
                      ),
                      Divider(),
                      Text(
                        'Give your audio an unique name. You can only rename your audio once.',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12),
                      ),
                    ]),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor:
                      Theme.of(Get.context!).scaffoldBackgroundColor,
                  isScrollControlled: true),
              child: Row(
                children: [
                  Icon(
                    Iconsax.music,
                    size: 20,
                    color: ColorManager.dayNightIcon,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Rename Audio',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                      child: Obx(() => Text(
                            textsoundName.value,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ))),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: ColorManager.colorAccent,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Text.rich(TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Iconsax.lock,
                        size: 20,
                        color: ColorManager.dayNightIcon,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  const TextSpan(
                      text: " Who can view this video ",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
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
                      size: 20,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const TextSpan(
                      text: " Allow Comments",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
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
                        size: 20,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  const TextSpan(
                      text: " Allow Downloads",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
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

class PostScreenVideoPlayer extends StatefulWidget {
  PostScreenVideoPlayer(this.videoFile);
  File? videoFile;
  @override
  State<PostScreenVideoPlayer> createState() => _PostScreenVideoPlayerState();
}

class _PostScreenVideoPlayerState extends State<PostScreenVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  var isVisible = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.videoFile!)
      ..initialize().then((value) {
        setState(() {});
      });
    videoPlayerController!.addListener(() {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        if (Get.isOverlaysOpen || isVisible.isFalse) {
          videoPlayerController!.pause();
        } else if (!Get.isBottomSheetOpen! && isVisible.isTrue) {
          videoPlayerController!.play();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
        onVisibilityGained: () {
          videoPlayerController!.play();
          isVisible.value = true;
          if (mounted) {
            setState(() {});
          }
        },
        onVisibilityLost: () {
          videoPlayerController!.pause();
          isVisible.value = false;
          if (mounted) {
            setState(() {});
          }
        },
        onForegroundLost: () {
          videoPlayerController!.pause();
          isVisible.value = false;
          if (mounted) {
            setState(() {});
          }
        },
        onForegroundGained: () {
          videoPlayerController!.play();
          isVisible.value = true;
          if (mounted) {
            setState(() {});
          }
        },
        onFocusLost: () {
          if (mounted) {
            videoPlayerController!.pause();
            isVisible.value = false;
            setState(() {});
          }
        },
        onFocusGained: () {
          videoPlayerController!.play();
          isVisible.value = true;
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          height: Get.height,
          width: Get.width / 2.5,
          child: AspectRatio(
            aspectRatio: Get.size.aspectRatio,
            child: InkWell(
                onTap: () {
                  if (videoPlayerController!.value.isPlaying) {
                    videoPlayerController!.pause();
                    isVisible.value = false;
                  } else {
                    videoPlayerController!.play();
                    isVisible.value = true;
                  }
                  setState(() {});
                },
                child: VideoPlayer(videoPlayerController!)),
          ),
        ));
  }
}
