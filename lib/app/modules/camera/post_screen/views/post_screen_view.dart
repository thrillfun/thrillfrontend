import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/rest/models/video_field_model.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/post_screen_controller.dart';
import 'package:hashtagable/hashtagable.dart';

class PostScreenView extends GetView<PostScreenController> {
  PostScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Post",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: videoLayout(),
    );
  }

  videoLayout() => Column(
        children: [
          Container(
              margin: EdgeInsets.all(10),
              height: Get.height / 5,
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: ColorManager.dayNightIcon),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        margin: const EdgeInsets.only(right: 10),
                        child: descriptionLayout(),
                      )),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xff353841),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      margin: const EdgeInsets.only(right: 10),
                      child: VisibilityDetector(
                          key: Key("post"),
                          child: InkWell(
                            child: ClipRRect(
                              child: AspectRatio(
                                aspectRatio: controller.videoPlayerController!
                                        .value.aspectRatio /
                                    Get.height,
                                child: VideoPlayer(
                                    controller.videoPlayerController!),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onTap: () {
                              if (controller.isPlaying.value) {
                                controller.videoPlayerController!.pause();
                                controller.isPlaying.value = false;
                              } else {
                                controller.videoPlayerController!.play();
                                controller.isPlaying.value = true;
                              }
                            },
                          ),
                          onVisibilityChanged: (VisibilityInfo info) {
                            info.visibleFraction == 0
                                ? controller.videoPlayerController!.pause
                                : controller.videoPlayerController!.play;
                          }),
                    ),
                  ),
                ],
              )),
          Obx(() => controller.searchItems.isNotEmpty
              ? Obx(() => Visibility(
                  child: ListView.builder(
                      itemCount: controller.searchItems.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              var words = controller.textEditingController.text
                                  .split(" "); // uses an array
                              controller.lastChangedWord.value =
                                  words[words.length - 1];

                              controller.textEditingController.text = controller
                                  .textEditingController.text
                                  .replaceAll(words[words.length - 1],
                                      controller.searchItems[index].toString());

                              controller.searchItems.clear();
                            },
                            child: Text(
                              "#" +
                                  controller.searchItems[index]
                                      .toString()
                                      .replaceAll(RegExp("#"), ''),
                              style: TextStyle(
                                color: ColorManager.dayNightText,
                              ),
                            ),
                          )))))
              : Column(
                  children: [
                    hashTagLayout(),
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
                          Get.snackbar("error", "fieldEmpty").show();
                        } else {
                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;
                          await controller.createGIF(currentUnix,controller.textEditingController.text);
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
                        child: Text(
                          "Post Video",
                          style: TextStyle(
                              color: ColorManager.dayNightText, fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ))
        ],
      );

  chipSelectionLayout() => Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            children: List.generate(
                controller.selectedItems.length,
                (index) => Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: FilterChip(
                          selectedColor: ColorManager.colorAccent,
                          elevation: 10,
                          label:
                              Text(controller.selectedItems[index].toString(),
                                  style: TextStyle(
                                    color: ColorManager.dayNightText,
                                  )),
                          onSelected: (value) =>
                              controller.selectedItems.removeAt(index)),
                    )),
          ),
        ),
      );

  descriptionLayout() => Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
           Expanded(child:  HashTagTextField(
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
             basicStyle: TextStyle(
               color: ColorManager.dayNightText,
             ),
             decoratedStyle: TextStyle(
               color: ColorManager.dayNightText,
             ),
             decoration: InputDecoration.collapsed(
                 hintText: "Describe your video",
                 hintStyle: TextStyle(
                     fontStyle: FontStyle.italic,
                     color: ColorManager.dayNightText)),
           )),
          ],
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
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              border: Border.all(color: ColorManager.dayNightIcon),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: ColorManager.dayNightIcon,
              ),
              Expanded(
                child: Text(
                  "Add Hashtag",
                  style: TextStyle(
                    color: ColorManager.dayNightText,
                  ),
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
            icon: Icon(
              Icons.keyboard_double_arrow_down,
              color: ColorManager.dayNightText,
            ),
            value: controller.selectedItem.value,
            items: controller.languagesList
                .map((Languages element) => DropdownMenuItem(
                    value: element.name,
                    child: Text(element.name.toString(),
                        style: TextStyle(
                          color: ColorManager.dayNightText,
                        ))))
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
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18))))
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
                        style: TextStyle(
                          color: ColorManager.dayNightText,
                        ),
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
                    child: RichText(
                        text: TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Icons.lock_open,
                        size: 20,
                        color: ColorManager.dayNightIcon,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  TextSpan(
                      text: " Visible to ",
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18))
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
                    text: TextSpan(children: <InlineSpan>[
                  WidgetSpan(
                    child: Icon(
                      Icons.message_outlined,
                      color: ColorManager.dayNightIcon,
                      size: 20,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                      text: " Allow Comments",
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18))
                ])),
                Obx(
                  () => Switch(
                    onChanged: (val) => controller.allowComments.toggle(),
                    value: controller.allowComments.value,
                    activeColor: Colors.white,
                    activeTrackColor: ColorManager.colorPrimaryLight,
                    inactiveThumbColor: ColorManager.colorPrimaryLight,
                    inactiveTrackColor: ColorManager.dayNightText,
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: TextSpan(children: [
                  WidgetSpan(
                      child: Icon(
                        Icons.videocam_outlined,
                        color: ColorManager.dayNightIcon,
                        size: 25,
                      ),
                      alignment: PlaceholderAlignment.middle),
                  TextSpan(
                      text: " Allow Duets",
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18))
                ])),
                Obx(() => Switch(
                    onChanged: (value) => controller.allowDuets.toggle(),
                    value: controller.allowDuets.value,
                    activeColor: Colors.white,
                    activeTrackColor: ColorManager.colorPrimaryLight,
                    inactiveThumbColor: ColorManager.colorPrimaryLight,
                    inactiveTrackColor: const Color(0xff353841)))
              ],
            ),
          ],
        ),
      );
}
