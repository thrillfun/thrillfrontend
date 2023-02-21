import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as justAudio;
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/utils/page_manager.dart';
import 'package:thrill/utils/util.dart';

import '../common/color.dart';
import '../controller/Favourites/favourites_controller.dart';
import '../rest/rest_url.dart';
import '../screens/sound/sound_details.dart';

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
var favouritesController = Get.find<FavouritesController>();
final progressNotifier = ValueNotifier<ProgressBarState>(
  ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  ),
);

class SoundListBottomSheet extends StatelessWidget {
  SoundListBottomSheet({Key? key}) : super(key: key);
  var selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: ColorManager.dayNight,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              titleSpacing: 0,
              backgroundColor: ColorManager.dayNight,
              leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorManager.dayNightText,
                  )),
              title: searchBarLayout(discoverController),
              bottom: TabBar(
                  unselectedLabelColor: Get.isPlatformDarkMode
                      ? Colors.white
                      : const Color(0xff9E9E9E),
                  indicatorColor: ColorManager.colorAccent,
                  labelColor: ColorManager.colorAccent,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  automaticIndicatorColorAdjustment: true,
                  onTap: (int index) {
                    selectedTab.value = index;
                    if (index == 0) {
                      soundsController.getSoundsList();
                    }
                    if (index == 1) {
                      favouritesController.getFavourites();
                    }
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(
                      text: "Discover",
                    ),
                    Tab(
                      text: "Favourites",
                    ),
                    Tab(
                      text: "Local",
                    )
                    // Tab(
                    //   text: "Local",
                    // ),
                  ]),
            ),
            body: TabBarView(
              children: [
                SoundListLayout(),
                favouritesSoundsLayout(),
                localSoundsLayout(),
              ],
            )));
    // SingleChildScrollView(
    //   child:
    // )
  }

  sounds() => const SearchSounds();

  localSoundsLayout() => GetX<SoundsController>(
        builder: (soundsController) => soundsController.localSoundsList.isEmpty
            ? Container(
                height: Get.height,
                child: const Center(
                  child: Text(
                    "Nothing to show",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : Wrap(
                children: List.generate(
                    soundsController.localSoundsList.length,
                    (index) => InkWell(
                          onTap: () {
                            soundsController.selectedSoundPath.value =
                                soundsController.localSoundsList[index].uri!;
                            Get.back();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/spinning_disc.svg",
                                  fit: BoxFit.fill,
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      soundsController
                                          .localSoundsList[index].title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      soundsController
                                          .localSoundsList[index].artist
                                          .toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
              ),
      );

  favouritesSoundsLayout() => const FavouriteSounds();

  searchBarLayout(DiscoverController discoverController) => Row(
        children: [
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
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

class SoundListLayout extends GetView<SoundsController> {
  SoundListLayout({Key? key}) : super(key: key);
  var userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (_) => Container(
              height: Get.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.soundsList.length,
                  itemBuilder: (context, index) => InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/Image.png",
                                        height: 80,
                                        width: 80,
                                      ),
                                      Container(
                                        height: 40,
                                        width: 40,
                                        child: imgProfile(controller
                                                    .soundsList[index]
                                                    .soundOwner !=
                                                null
                                            ? controller.soundsList[index]
                                                .soundOwner!.avtars
                                                .toString()
                                            : RestUrl.placeholderImage),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.soundsList[index].name
                                            .toString(),
                                        style: TextStyle(
                                            color: ColorManager.dayNightText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        controller
                                            .soundsList[index].soundOwner!.name
                                            .toString(),
                                        style: TextStyle(
                                            color: ColorManager.dayNightText,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        controller
                                            .soundsList[index].soundOwner!.name
                                            .toString(),
                                        style: TextStyle(
                                          color: ColorManager.dayNightText,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              InkWell(
                                child: controller.soundsList[index]
                                            .isFavouriteSoundCount ==
                                        0
                                    ? const Icon(
                                        Icons.bookmark_add_outlined,
                                      )
                                    : const Icon(
                                        Icons.bookmark,
                                      ),
                                onTap: () => controller.soundsList[index]
                                            .isFavouriteSoundCount ==
                                        0
                                    ? userController.addToFavourites(
                                        controller.soundsList[index].id!,
                                        "sound",
                                        1)
                                    : userController
                                        .addToFavourites(
                                            controller.soundsList[index].id!,
                                            "sound",
                                            0)
                                        .then((value) {
                                        controller.getSoundsList();
                                      }),
                              )
                            ],
                          ),
                        ),
                        onTap: () => soundsController.downloadAudio(
                            controller.soundsList[index].sound.toString(),
                            controller.soundsList[index].soundOwner!.name
                                .toString(),
                            controller.soundsList[index].id!,
                            controller.soundsList[index].name.toString(),
                            true),
                      )),
            ),
        onEmpty: emptyListWidget(),
        onLoading: loader());
  }
}

class FavouriteSounds extends GetView<FavouritesController> {
  const FavouriteSounds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (_) => ListView.builder(
            shrinkWrap: true,
            itemCount: controller.favouriteSounds.length,
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
                            controller.favouriteSounds[index].name.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          Text(
                            controller.favouriteSounds[index].name.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          Text(
                            controller.favouriteSounds[index].name.toString(),
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
                onTap: () {
                  soundsController.downloadAudio(
                      controller.favouriteSounds[index].sound.toString(),
                      controller.favouriteSounds[index].user!.name.toString(),
                      controller.favouriteSounds[index].id!,
                      controller.favouriteSounds[index].name.toString(),
                      true);
                }

                // musicPlayerBottomSheet(discoverController
                //   .favouriteSounds[index].thumbnail
                //   .toString().obs, discoverController
                //   .favouriteSounds[index].name
                //   .toString().obs,discoverController
                //   .favouriteSounds[index].name
                //   .toString().obs),
                )),
        onLoading: loader(),
        onEmpty: emptyListWidget());
  }
}
