import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as justAudio;
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/page_manager.dart';
import 'package:thrill/utils/util.dart';

import '../common/color.dart';
import '../controller/Favourites/favourites_controller.dart';

var selectedTab = 0.obs;

justAudio.AudioPlayer audioPlayer = justAudio.AudioPlayer();
var isPlaying = false.obs;
var isAudioLoading = true.obs;
var audioDuration = const Duration().obs;
var audioTotalDuration = const Duration().obs;
var audioBuffered = const Duration().obs;
var usersController = Get.find<UserController>();
FocusNode fieldNode = FocusNode();
var discoverController = Get.find<DiscoverController>();
var soundsController = Get.find<SoundsController>();
final progressNotifier = ValueNotifier<ProgressBarState>(
  ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  ),
);

class SoundListBottomSheet extends StatelessWidget {
  SoundListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: Container(
            height: Get.height,
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close)),
                      Text(
                        "Sounds",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Get.isPlatformDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.menu)
                    ],
                  ),
                ),
                searchBarLayout(discoverController),
                tabBarLayout(),
                Obx(() => tabview())
              ],
            ),
          ),
        ));

    // SingleChildScrollView(
    //   child:
    // )
  }

  tabBarLayout() => DefaultTabController(
        length: 2,
        initialIndex: selectedTab.value,
        child: TabBar(
            unselectedLabelColor:
                Get.isPlatformDarkMode ? Colors.white : const Color(0xff9E9E9E),
            indicatorColor: ColorManager.colorAccent,
            labelColor: ColorManager.colorAccent,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            automaticIndicatorColorAdjustment: true,
            onTap: (int index) {
              selectedTab.value = index;
            },
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: const [
              Tab(
                text: "Discover",
              ),
              Tab(
                text: "Favourites",
              ),
              // Tab(
              //   text: "Local",
              // ),
            ]),
      );

  tabview() {
    if (selectedTab.value == 0) {
      return Expanded(child: sounds());
    }
    if (selectedTab.value == 1) {
      return Expanded(child: favouritesSoundsLayout());
    }
    // else {
    //   return localSoundsLayout();
    // }
  }

  sounds() => const SearchSounds();
  // localSoundsLayout() => GetX<SoundsController>(
  //       builder: (soundsController) =>soundsController.localSoundsList.isEmpty?Container(
  //         height: Get.height,
  //         child: const Center(child: Text("Nothing to show",style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),),),): Wrap(
  //         children: List.generate(
  //             soundsController.localSoundsList.length,
  //             (index) => Container(
  //                   margin: const EdgeInsets.all(10),
  //                   padding: const EdgeInsets.all(10),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SvgPicture.asset(
  //                         "assets/spinning_disc.svg",
  //                         fit: BoxFit.fill,
  //                         width: 50,
  //                         height: 50,
  //                       ),
  //                       const SizedBox(
  //                         width: 10,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             soundsController.localSoundsList[index].title,
  //                             style: const TextStyle(fontWeight: FontWeight.bold),
  //                           ),
  //                           Text(
  //                             soundsController.localSoundsList[index].artist,
  //                             style: const TextStyle(fontWeight: FontWeight.w400),
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 )),
  //       ),
  //     );

  favouritesSoundsLayout() => const Flexible(child: FavouriteSounds());
  searchBarLayout(DiscoverController discoverController) => Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
                onFieldSubmitted: (text) {
                  discoverController.searchHashtags(text);
                },
                // initialValue: user.username,
                decoration: InputDecoration(
                  focusColor: ColorManager.colorAccent,
                  fillColor: fieldNode.hasFocus
                      ? ColorManager.colorAccentTransparent
                      : Colors.grey.withOpacity(0.1),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: fieldNode.hasFocus
                        ? const BorderSide(
                            color: Color(0xff2DCBC8),
                          )
                        : const BorderSide(
                            color: Color(0xffFAFAFA),
                          ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: fieldNode.hasFocus
                        ? const BorderSide(
                            color: Color(0xff2DCBC8),
                          )
                        : BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: fieldNode.hasFocus
                        ? ColorManager.colorAccent
                        : Colors.grey.withOpacity(0.3),
                  ),
                  hintText: "Search",
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 14),
                ),
              ),
            ),
          )
        ],
      );

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  emptyListWidget(String text) => Flexible(
          child: Center(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ));
}

class FavouriteSounds extends GetView<FavouritesController> {
  const FavouriteSounds({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (_) => Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.favouriteHashtags.length,
                itemBuilder: (context, index) => InkWell(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/Image.png",
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.favouriteHashtags[index].name
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              Text(
                                controller.favouriteHashtags[index].name
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              Text(
                                controller.favouriteHashtags[index].name
                                    .toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          )),
                          const Text(
                            "0",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                    onTap: () {}

                    // musicPlayerBottomSheet(discoverController
                    //   .favouriteSounds[index].thumbnail
                    //   .toString().obs, discoverController
                    //   .favouriteSounds[index].name
                    //   .toString().obs,discoverController
                    //   .favouriteSounds[index].name
                    //   .toString().obs),
                    ))),
        onLoading: loader(),
        onEmpty: emptyListWidget());
  }
}
