import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_search_result.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/page_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  SearchView({Key? key}) : super(key: key);
  var searchValue = ''.obs;
  var selectedTab = 0.obs;
  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;
  FocusNode fieldNode = FocusNode();
  TextEditingController _controller = TextEditingController();
  var selectedIndex = 0.obs;
  final audioPlayer = AudioPlayer();
  final playerController = PlayerController();
  var duration = Duration.zero;
  var soundName = "".obs;
  var soundOwner = "".obs;
  var avatar = "".obs;
  var isPlayerVisible = false.obs;
  var isPlayerPlaying = false.obs;
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 45,
              title: searchBarLayout(),
            ),
            body: Column(
              children: [
                TabBar(
                    onTap: (int index) {
                      selectedTab.value = index;
                    },
                    isScrollable: true,
                    tabs: const [
                      Tab(text: "All"),
                      Tab(text: "Videos"),
                      Tab(text: "Sounds"),
                      Tab(text: "Hashtags"),
                      Tab(text: "Users")
                    ]),
                Expanded(
                    child: TabBarView(children: [
                  searchOverview(),
                  searchVideos(),
                  searchSounds(),
                  searchHashtags(),
                  searchUsers()
                ]))
              ],
            )));
  }

  searchBarLayout() => Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 40,
              margin: const EdgeInsets.only(
                  left: 0, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
                scrollPadding: EdgeInsets.zero,
                controller: _controller,
                onChanged: (value) {
                  controller.searchHashtags(_controller.text);
                },
                // onEditingComplete: () {
                //   controller.searchHashtags(_controller.text);
                // },

                onFieldSubmitted: (text) {
                  controller.searchHashtags(text);
                },
                // initialValue: user.username,
                decoration: const InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
          )
        ],
      );

  searchUsers() => controller.obx(
      (state) => state![0].users!.isEmpty
          ? NoSearchResult(
              text: "No Users!",
            )
          : Container(
              height: Get.height,
              child: ListView(
                shrinkWrap: true,
                children: List.generate(
                    state![0].users!.length,
                    (index) => InkWell(
                          onTap: () async {
                            Get.toNamed(Routes.OTHERS_PROFILE, arguments: {
                              "profileId": state[0].users![index].id
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: imgProfile(
                                      state[0].users![index].avatar ??
                                          state[0]
                                              .users![index]
                                              .avatars
                                              .toString()),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state[0].users![index].name ??
                                          state[0]
                                              .users![index]
                                              .username
                                              .toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "@" +
                                              state[0]
                                                  .users![index]
                                                  .username
                                                  .toString() +
                                              " | ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          state[0]
                                                      .users![index]
                                                      .followers
                                                      .toString()
                                                      .isEmpty ||
                                                  state[0]
                                                          .users![index]
                                                          .followers ==
                                                      null
                                              ? "0 Followers"
                                              : state[0]
                                                      .users![index]
                                                      .followers
                                                      .toString() +
                                                  " Followers",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                                InkWell(
                                  onTap: () => {
                                    controller.followUnfollowUser(
                                        state[0].users![index].id!,
                                        (state[0].users![index].isfollow ??
                                                    state[0]
                                                        .users![index]
                                                        .isFollowCount) ==
                                                0
                                            ? "follow"
                                            : "unfollow",
                                        searchQuery: _controller.text,
                                        fcmToken: state[0]
                                            .users![index]
                                            .firebaseToken!,
                                        image: state[0].users![index].avatar!)
                                  },
                                  child: (state[0].users![index].isfollow ??
                                              state[0]
                                                  .users![index]
                                                  .isFollowCount) ==
                                          0
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: ColorManager.colorAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Text(
                                            "Follow",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      ColorManager.colorAccent),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Text(
                                            "Following",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorManager.colorAccent),
                                          ),
                                        ),
                                )
                              ],
                            ),
                          ),
                        )),
              ),
            ),
      onEmpty: NoSearchResult(
        text: "No Users!",
      ),
      onLoading: searchUsersShimmer());

  searchVideos() => controller.obx(
      (state) => state![0].videos!.isEmpty
          ? NoSearchResult(
              text: "No Videos!",
            )
          : Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
                mainAxisSpacing: 10,
                children: List.generate(
                    state![0].videos!.length,
                    (index) => InkWell(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  fit: StackFit.loose,
                                  children: [
                                    imgNet(RestUrl.gifUrl +
                                        state[0].videos![index].gifImage!),
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              child: Icon(
                                                Icons.play_circle,
                                                size: 14,
                                                color: ColorManager.colorAccent,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "  " +
                                                  NumberFormat.compact()
                                                      .format(state[0]
                                                          .videos![index]
                                                          .views)
                                                      .toString(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    child: imgProfile(state[0]
                                        .videos![index]
                                        .user!
                                        .avatar
                                        .toString()),
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(
                                    state[0].videos![index].user!.name ??
                                        state[0].videos![index].user!.username!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ))
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            Get.toNamed(Routes.SEARCH_VIDEOS_PLAYER,
                                arguments: {
                                  "search_query": _controller.text,
                                  "init_page": index
                                });
                          },
                        )),
              ),
            ),
      onEmpty: NoSearchResult(
        text: "No Videos!",
      ),
      onLoading: searchVideosShimmer());

  searchHashtags() => controller.obx(
      (state) => state![0].hashtags!.isEmpty
          ? NoSearchResult(
              text: "No Hashtags!",
            )
          : Container(
              height: Get.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state![0].hashtags!.length,
                  itemBuilder: (context, index) => InkWell(
                        onTap: () async {
                          await GetStorage()
                              .write("hashtagId", state[0].hashtags![index].id);
                          Get.toNamed(Routes.HASH_TAGS_DETAILS, arguments: {
                            "hashtag_name": "${state[0].hashtags![index].name}"
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              73, 204, 201, 0.08),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: const Icon(
                                        Icons.numbers,
                                        color: ColorManager.colorAccent,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    state[0].hashtags![index].name == null
                                        ? ""
                                        : state[0].hashtags![index].name!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                state[0].hashtags![index].total == null
                                    ? ""
                                    : state[0]
                                        .hashtags![index]
                                        .total
                                        .toString()!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )),
            ),
      onEmpty: NoSearchResult(
        text: "No Hashtags!",
      ),
      onError: (error) => NoSearchResult(
            text: "No Hashtags!",
          ),
      onLoading: searchHastagShimmer());

  searchSounds() => controller.obx(
        (state) => state![0].sounds!.isEmpty
            ? NoSearchResult(
                text: "No Sounds!",
              )
            : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  controller.searchList[0].sounds!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          selectedIndex.value = index;
                                          soundName.value = controller
                                              .searchList[0]
                                              .sounds![index]
                                              .name!;
                                          soundOwner.value = controller
                                                      .searchList[0]
                                                      .sounds![index]
                                                      .soundOwner !=
                                                  null
                                              ? controller
                                                  .searchList[0]
                                                  .sounds![index]
                                                  .soundOwner!
                                                  .name!
                                              : "";

                                          avatar.value = controller
                                                      .searchList[0]
                                                      .sounds![index]
                                                      .soundOwner !=
                                                  null
                                              ? controller
                                                  .searchList[0]
                                                  .sounds![index]
                                                  .soundOwner!
                                                  .avtars!
                                              : "";
                                          duration = (await audioPlayer.setUrl(
                                              RestUrl.awsSoundUrl +
                                                  controller.searchList[0]
                                                      .sounds![index].sound
                                                      .toString()))!;
                                          audioTotalDuration.value = duration!;
                                          audioPlayer.positionStream
                                              .listen((position) async {
                                            final oldState =
                                                progressNotifier.value;
                                            audioDuration.value = position;
                                            progressNotifier.value =
                                                ProgressBarState(
                                              current: position,
                                              buffered: oldState.buffered,
                                              total: oldState.total,
                                            );

                                            if (position == oldState.total) {
                                              audioPlayer.playerStateStream
                                                  .drain();
                                              await playerController.seekTo(0);
                                              await audioPlayer
                                                  .seek(Duration.zero);
                                              audioDuration.value =
                                                  Duration.zero;
                                              // isPlaying.value = false;
                                            }
                                            print(position);
                                          });
                                          audioPlayer.bufferedPositionStream
                                              .listen((position) {
                                            final oldState =
                                                progressNotifier.value;
                                            audioBuffered.value = position;
                                            progressNotifier.value =
                                                ProgressBarState(
                                              current: oldState.current,
                                              buffered: position,
                                              total: oldState.total,
                                            );
                                          });

                                          playerController
                                              .onCurrentDurationChanged
                                              .listen((duration) async {
                                            audioDuration.value =
                                                Duration(seconds: duration);

                                            Duration playerDuration =
                                                Duration(seconds: duration);

                                            print(duration);

                                            if (Duration(seconds: duration) >=
                                                audioTotalDuration.value) {
                                              audioPlayer.seek(Duration.zero);
                                            }
                                          });

                                          audioPlayer.play();

                                          if (isPlayerVisible.isFalse) {
                                            isPlayerVisible.value = true;
                                          }
                                          isPlayerPlaying.value =
                                              audioPlayer.playing;
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              child: imgSound(controller
                                                          .searchList[0]
                                                          .sounds![index]
                                                          .soundOwner !=
                                                      null
                                                  ? controller
                                                      .searchList[0]
                                                      .sounds![index]
                                                      .soundOwner!
                                                      .avtars
                                                      .toString()
                                                  : ""),
                                            ),
                                            Obx(() => isPlayerPlaying.value &&
                                                    selectedIndex.value == index
                                                ? const Icon(
                                                    Icons
                                                        .pause_circle_filled_outlined,
                                                    size: 22,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  )
                                                : const Icon(
                                                    IconlyBold.play,
                                                    size: 22,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: InkWell(
                                        child: Container(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  controller.searchList[0]
                                                      .sounds![index].name
                                                      .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .soundOwner !=
                                                          null
                                                      ? controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .soundOwner!
                                                              .name ??
                                                          "@" +
                                                              controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner!
                                                                  .username!
                                                      : controller
                                                          .searchList[0]
                                                          .sounds![index]
                                                          .username
                                                          .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12),
                                                ),
                                              ]),
                                        ),
                                        onTap: () async {
                                          DeviceInfoPlugin deviceInfo =
                                              DeviceInfoPlugin();
                                          AndroidDeviceInfo androidInfo =
                                              await deviceInfo.androidInfo;
                                          Get.toNamed(Routes.SOUNDS,
                                              arguments: {
                                                "sound_id":
                                                    state[0].sounds![index].id,
                                                "sound_name": state[0]
                                                    .sounds![index]
                                                    .name,
                                                "sound_url": state[0]
                                                    .sounds![index]
                                                    .sound
                                                    .toString(),
                                              });
                                        },
                                      )),
                                      IconButton(
                                        onPressed: () => {
                                          controller.addSoundToFavourite(
                                              controller.searchList[0]
                                                  .sounds![index].id!,
                                              controller
                                                          .searchList[0]
                                                          .sounds![index]
                                                          .is_favourite_sound_count ==
                                                      0
                                                  ? "1"
                                                  : "0")
                                        },
                                        icon: Icon(
                                          controller
                                                          .searchList[0]
                                                          .sounds![index]
                                                          .isFavouriteSound ==
                                                      null ||
                                                  controller
                                                          .searchList[0]
                                                          .sounds![index]
                                                          .isFavouriteSound
                                                          ?.isFavorite ==
                                                      0
                                              ? IconlyBroken.bookmark
                                              : IconlyBold.bookmark,
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }))
                    ],
                  ),
                  VisibilityDetector(
                      key: const Key("miniplayer"),
                      child: Obx(() => Visibility(
                          visible: isPlayerVisible.value,
                          child: SizedBox(
                            height: 80,
                            child: Card(
                              margin: const EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 2,
                                      color: ColorManager.colorAccent
                                          .withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child:
                                              Obx(() => imgSound(avatar.value)),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Obx(
                                              () => Text(soundName.value,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                            Obx(() => Text(
                                                  soundOwner.value,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                            Obx(() => ProgressBar(
                                                thumbRadius: 5,
                                                barHeight: 3,
                                                baseBarColor: ColorManager
                                                    .colorAccentTransparent,
                                                bufferedBarColor: ColorManager
                                                    .colorAccentTransparent,
                                                timeLabelLocation:
                                                    TimeLabelLocation.none,
                                                thumbColor:
                                                    ColorManager.colorAccent,
                                                progressBarColor:
                                                    ColorManager.colorAccent,
                                                buffered: progressNotifier
                                                    .value.buffered,
                                                progress: audioDuration.value,
                                                onSeek: (duration) =>
                                                    audioPlayer.seek(duration),
                                                total:
                                                    audioTotalDuration.value))
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (audioDuration.value >=
                                                audioTotalDuration.value &&
                                            audioTotalDuration.value !=
                                                Duration.zero) {
                                          audioPlayer
                                              .seek(Duration.zero)
                                              .then((value) {
                                            if (audioPlayer.playing) {
                                              audioPlayer.pause();
                                            } else {
                                              audioPlayer.play();
                                            }
                                          });
                                        }
                                        if (audioPlayer.playing) {
                                          audioPlayer.pause();
                                        } else {
                                          audioPlayer.play();
                                        }
                                        isPlayerPlaying.value =
                                            audioPlayer.playing;
                                      },
                                      child: Obx(() => isPlayerPlaying.value &&
                                              audioDuration.value <=
                                                  audioTotalDuration.value &&
                                              audioTotalDuration.value !=
                                                  Duration.zero
                                          ? const Icon(
                                              Icons
                                                  .pause_circle_filled_outlined,
                                              size: 50,
                                              color: ColorManager.colorAccent,
                                            )
                                          : audioDuration.value >=
                                                      audioTotalDuration
                                                          .value &&
                                                  audioTotalDuration.value !=
                                                      Duration.zero &&
                                                  isPlayerPlaying.value
                                              ? const Icon(
                                                  Icons.refresh_rounded,
                                                  size: 50,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )
                                              : const Icon(
                                                  IconlyBold.play,
                                                  size: 50,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))),
                      onVisibilityChanged: (info) => {
                            if (info.visibleFraction < 0.9)
                              {
                                audioPlayer.stop(),
                                isPlayerPlaying.value = audioPlayer.playing
                              }
                          })
                ],
              ),
        onEmpty: NoSearchResult(
          text: "No Sounds!",
        ),
        onLoading: searchSoundShimmer(),
        onError: (error) => NoSearchResult(
          text: "No Sounds!",
        ),
      );

  searchOverview() => controller.obx(
      (state) => state![0].videos!.isEmpty &&
              state[0].hashtags!.isEmpty &&
              state[0].sounds!.isEmpty &&
              state[0].users!.isEmpty
          ? NoSearchResult(
              text: "No Search Results!",
            )
          : Stack(
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    Visibility(
                      visible: state[0].users!.isNotEmpty,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: const Text(
                          "Users",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: state[0].users!.isNotEmpty,
                        child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state![0].users!.take(4).length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => InkWell(
                                      onTap: () async {
                                        Get.toNamed(Routes.OTHERS_PROFILE,
                                            arguments: {
                                              "profileId":
                                                  state[0].users![index].id
                                            });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 35,
                                              width: 35,
                                              child: imgProfile(state[0]
                                                      .users![index]
                                                      .avatar ??
                                                  state[0]
                                                      .users![index]
                                                      .avatars ??
                                                  ""),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Flexible(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  state[0].users![index].name ??
                                                      state[0]
                                                          .users![index]
                                                          .username
                                                          .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                      "@" +
                                                          state[0]
                                                              .users![index]
                                                              .username
                                                              .toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )),
                                                    Expanded(
                                                        child: Text(
                                                      state[0]
                                                                  .users![index]
                                                                  .followers
                                                                  .toString()
                                                                  .isEmpty ||
                                                              controller
                                                                      .searchList[
                                                                          0]
                                                                      .users![
                                                                          index]
                                                                      .followers ==
                                                                  null
                                                          ? "0 Followers"
                                                          : state[0]
                                                                  .users![index]
                                                                  .followers
                                                                  .toString() +
                                                              " Followers",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ))
                                                  ],
                                                )
                                              ],
                                            )),
                                            InkWell(
                                              onTap: () => {
                                                controller.followUnfollowUser(
                                                    state[0].users![index].id!,
                                                    (state[0]
                                                                    .users![
                                                                        index]
                                                                    .isfollow ??
                                                                state[0]
                                                                    .users![
                                                                        index]
                                                                    .isFollowCount) ==
                                                            0
                                                        ? "follow"
                                                        : "unfollow")
                                              },
                                              child: (state[0]
                                                              .users![index]
                                                              .isfollow ??
                                                          state[0]
                                                              .users![index]
                                                              .isFollowCount) ==
                                                      0
                                                  ? Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: const Text(
                                                        "Follow",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: ColorManager
                                                                  .colorAccent),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: const Text(
                                                        "Following",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: ColorManager
                                                                .colorAccent),
                                                      ),
                                                    ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )))),
                    Visibility(
                      visible: state[0].videos!.isNotEmpty,
                      child: Container(
                        child: const Text(
                          "Videos",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                    ),
                    Visibility(
                        visible: state[0].videos!.isNotEmpty,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.8,
                            mainAxisSpacing: 10,
                            children: List.generate(
                                state[0].videos!.take(3).length,
                                (index) => InkWell(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Stack(
                                              alignment: Alignment.bottomLeft,
                                              fit: StackFit.loose,
                                              children: [
                                                imgNet(RestUrl.gifUrl +
                                                    state[0]
                                                        .videos![index]
                                                        .gifImage!),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        const WidgetSpan(
                                                          child: Icon(
                                                            Icons.play_circle,
                                                            size: 14,
                                                            color: ColorManager
                                                                .colorAccent,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          text: "  " +
                                                              NumberFormat
                                                                      .compact()
                                                                  .format(state[
                                                                          0]
                                                                      .videos![
                                                                          index]
                                                                      .views)
                                                                  .toString(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Get.toNamed(Routes.SEARCH_VIDEOS_PLAYER,
                                            arguments: {
                                              "search_query": _controller.text,
                                              "init_page": index
                                            });
                                      },
                                    )),
                          ),
                        )),
                    Visibility(
                        visible: state[0].hashtags!.isNotEmpty,
                        child: Container(
                          child: const Text(
                            "Hashtags",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        )),
                    Visibility(
                        visible: state[0].hashtags!.isNotEmpty,
                        child: Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state[0].hashtags!.take(4).length,
                                itemBuilder: (context, index) => InkWell(
                                      onTap: () async {
                                        await GetStorage().write("hashtagId",
                                            state[0].hashtags![index].id);
                                        Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                            arguments: {
                                              "hashtag_name":
                                                  "${state[0].hashtags![index].name}"
                                            });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                        color: const Color
                                                                .fromRGBO(
                                                            73, 204, 201, 0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    child: const Icon(
                                                      Icons.numbers,
                                                      color: ColorManager
                                                          .colorAccent,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  state[0]
                                                              .hashtags![index]
                                                              .name ==
                                                          null
                                                      ? ""
                                                      : state[0]
                                                          .hashtags![index]
                                                          .name!,
                                                  style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              state[0].hashtags![index].total ==
                                                      null
                                                  ? ""
                                                  : state[0]
                                                      .hashtags![index]
                                                      .total
                                                      .toString()!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )))),
                    Visibility(
                        visible: state[0].sounds!.isNotEmpty,
                        child: Container(
                          child: const Text(
                            "Sounds",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        )),
                    Visibility(
                        visible: state[0].sounds!.isNotEmpty,
                        child: controller.obx(
                            (state) => state![0].sounds!.isEmpty
                                ? Column(
                                    children: [emptyListWidget()],
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: controller.searchList[0].sounds!
                                        .take(4)
                                        .length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                selectedIndex.value = index;
                                                soundName.value = controller
                                                    .searchList[0]
                                                    .sounds![index]
                                                    .name!;
                                                soundOwner.value = controller
                                                            .searchList[0]
                                                            .sounds![index]
                                                            .soundOwner !=
                                                        null
                                                    ? controller
                                                        .searchList[0]
                                                        .sounds![index]
                                                        .soundOwner!
                                                        .name!
                                                    : "";

                                                avatar.value = controller
                                                            .searchList[0]
                                                            .sounds![index]
                                                            .soundOwner !=
                                                        null
                                                    ? controller
                                                        .searchList[0]
                                                        .sounds![index]
                                                        .soundOwner!
                                                        .avtars!
                                                    : "";
                                                duration =
                                                    (await audioPlayer.setUrl(
                                                        RestUrl.awsSoundUrl +
                                                            controller
                                                                .searchList[0]
                                                                .sounds![index]
                                                                .sound
                                                                .toString()))!;
                                                audioTotalDuration.value =
                                                    duration!;
                                                audioPlayer.positionStream
                                                    .listen((position) async {
                                                  final oldState =
                                                      progressNotifier.value;
                                                  audioDuration.value =
                                                      position;
                                                  progressNotifier.value =
                                                      ProgressBarState(
                                                    current: position,
                                                    buffered: oldState.buffered,
                                                    total: oldState.total,
                                                  );

                                                  if (position ==
                                                      oldState.total) {
                                                    audioPlayer
                                                        .playerStateStream
                                                        .drain();
                                                    await playerController
                                                        .seekTo(0);
                                                    await audioPlayer
                                                        .seek(Duration.zero);
                                                    audioDuration.value =
                                                        Duration.zero;
                                                    // isPlaying.value = false;
                                                  }
                                                  print(position);
                                                });
                                                audioPlayer
                                                    .bufferedPositionStream
                                                    .listen((position) {
                                                  final oldState =
                                                      progressNotifier.value;
                                                  audioBuffered.value =
                                                      position;
                                                  progressNotifier.value =
                                                      ProgressBarState(
                                                    current: oldState.current,
                                                    buffered: position,
                                                    total: oldState.total,
                                                  );
                                                });

                                                playerController
                                                    .onCurrentDurationChanged
                                                    .listen((duration) async {
                                                  audioDuration.value =
                                                      Duration(
                                                          seconds: duration);

                                                  Duration playerDuration =
                                                      Duration(
                                                          seconds: duration);

                                                  print(duration);

                                                  if (Duration(
                                                          seconds: duration) >=
                                                      audioTotalDuration
                                                          .value) {
                                                    audioPlayer
                                                        .seek(Duration.zero);
                                                  }
                                                });

                                                audioPlayer.play();

                                                if (isPlayerVisible.isFalse) {
                                                  isPlayerVisible.value = true;
                                                }
                                                isPlayerPlaying.value =
                                                    audioPlayer.playing;
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: imgSound(controller
                                                                .searchList[0]
                                                                .sounds![index]
                                                                .soundOwner !=
                                                            null
                                                        ? controller
                                                            .searchList[0]
                                                            .sounds![index]
                                                            .soundOwner!
                                                            .avtars
                                                            .toString()
                                                        : ""),
                                                  ),
                                                  Obx(() => isPlayerPlaying
                                                              .value &&
                                                          selectedIndex.value ==
                                                              index
                                                      ? const Icon(
                                                          Icons
                                                              .pause_circle_filled_outlined,
                                                          size: 22,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )
                                                      : const Icon(
                                                          IconlyBold.play,
                                                          size: 22,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        ))
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          controller
                                                              .searchList[0]
                                                              .sounds![index]
                                                              .name
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 16),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          controller
                                                                      .searchList[
                                                                          0]
                                                                      .sounds![
                                                                          index]
                                                                      .soundOwner ==
                                                                  null
                                                              ? controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .name!
                                                              : controller
                                                                  .searchList[0]
                                                                  .sounds![
                                                                      index]
                                                                  .soundOwner!
                                                                  .name
                                                                  .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14),
                                                        ),
                                                      ]),
                                                ),
                                                onTap: () async {
                                                  DeviceInfoPlugin deviceInfo =
                                                      DeviceInfoPlugin();
                                                  AndroidDeviceInfo
                                                      androidInfo =
                                                      await deviceInfo
                                                          .androidInfo;
                                                  if (androidInfo
                                                          .version.sdkInt >
                                                      31) {
                                                    if (await Permission
                                                        .audio.isGranted) {
                                                      Get.toNamed(Routes.SOUNDS,
                                                          arguments: {
                                                            "sound_id": state[0]
                                                                .sounds![index]
                                                                .id,
                                                            "sound_name": state[
                                                                    0]
                                                                .sounds![index]
                                                                .name,
                                                            "sound_url": state[
                                                                    0]
                                                                .sounds![index]
                                                                .sound
                                                                .toString(),
                                                          });
                                                      // refreshAlreadyCapturedImages();
                                                    } else {
                                                      await Permission.audio
                                                          .request()
                                                          .then((value) async {
                                                        Get.toNamed(
                                                            Routes.SOUNDS,
                                                            arguments: {
                                                              "sound_id":
                                                                  state[0]
                                                                      .sounds![
                                                                          index]
                                                                      .id,
                                                              "sound_name":
                                                                  state[0]
                                                                      .sounds![
                                                                          index]
                                                                      .name,
                                                              "sound_url": state[
                                                                      0]
                                                                  .sounds![
                                                                      index]
                                                                  .sound
                                                                  .toString(),
                                                            });
                                                      });
                                                    }
                                                  } else {
                                                    if (await Permission
                                                        .storage.isGranted) {
                                                      Get.toNamed(Routes.SOUNDS,
                                                          arguments: {
                                                            "sound_id": state[0]
                                                                .sounds![index]
                                                                .id,
                                                            "sound_name": state[
                                                                    0]
                                                                .sounds![index]
                                                                .name,
                                                            "sound_url": state[
                                                                    0]
                                                                .sounds![index]
                                                                .sound
                                                                .toString(),
                                                          });
                                                      // refreshAlreadyCapturedImages();
                                                    } else {
                                                      await Permission.storage
                                                          .request()
                                                          .then((value) =>
                                                              Get.toNamed(
                                                                  Routes.SOUNDS,
                                                                  arguments: {
                                                                    "sound_id": state[
                                                                            0]
                                                                        .sounds![
                                                                            index]
                                                                        .id,
                                                                    "sound_name": state[
                                                                            0]
                                                                        .sounds![
                                                                            index]
                                                                        .name,
                                                                    "sound_url": state[
                                                                            0]
                                                                        .sounds![
                                                                            index]
                                                                        .sound
                                                                        .toString(),
                                                                  }));
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => {
                                                controller.addSoundToFavourite(
                                                    controller.searchList[0]
                                                        .sounds![index].id!,
                                                    controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .isFavouriteSound ==
                                                                null ||
                                                            controller
                                                                    .searchList[
                                                                        0]
                                                                    .sounds![
                                                                        index]
                                                                    .isFavouriteSound
                                                                    ?.isFavorite ==
                                                                0
                                                        ? "1"
                                                        : "0")
                                              },
                                              icon: Icon(
                                                controller
                                                            .searchList[0]
                                                            .sounds![index]
                                                            .is_favourite_sound_count ==
                                                        0
                                                    ? IconlyBroken.bookmark
                                                    : IconlyBold.bookmark,
                                                color: ColorManager.colorAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                            onEmpty: Column(
                              children: [emptyListWidget()],
                            ),
                            onLoading: SizedBox(
                              child: loader(),
                              height: Get.height,
                              width: Get.width,
                            )))
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VisibilityDetector(
                        key: const Key("miniplayer"),
                        child: Obx(() => Visibility(
                            visible: isPlayerVisible.value,
                            child: SizedBox(
                              height: 80,
                              child: Card(
                                margin: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 2,
                                        color: ColorManager.colorAccent
                                            .withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            child: Obx(
                                                () => imgSound(avatar.value)),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(() => Text(
                                                    soundName.value,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )),
                                              Obx(() => Text(
                                                    soundOwner.value,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )),
                                              Obx(() => ProgressBar(
                                                  thumbRadius: 5,
                                                  barHeight: 3,
                                                  baseBarColor: ColorManager
                                                      .colorAccentTransparent,
                                                  bufferedBarColor: ColorManager
                                                      .colorAccentTransparent,
                                                  timeLabelLocation:
                                                      TimeLabelLocation.none,
                                                  thumbColor:
                                                      ColorManager.colorAccent,
                                                  progressBarColor:
                                                      ColorManager.colorAccent,
                                                  buffered: progressNotifier
                                                      .value.buffered,
                                                  progress: audioDuration.value,
                                                  onSeek: (duration) =>
                                                      audioPlayer
                                                          .seek(duration),
                                                  total:
                                                      audioTotalDuration.value))
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (audioDuration.value >=
                                                  audioTotalDuration.value &&
                                              audioTotalDuration.value !=
                                                  Duration.zero) {
                                            audioPlayer
                                                .seek(Duration.zero)
                                                .then((value) {
                                              if (audioPlayer.playing) {
                                                audioPlayer.pause();
                                              } else {
                                                audioPlayer.play();
                                              }
                                            });
                                          }
                                          if (audioPlayer.playing) {
                                            audioPlayer.pause();
                                          } else {
                                            audioPlayer.play();
                                          }
                                          isPlayerPlaying.value =
                                              audioPlayer.playing;
                                        },
                                        child: Obx(() => isPlayerPlaying
                                                    .value &&
                                                audioDuration.value <=
                                                    audioTotalDuration.value &&
                                                audioTotalDuration.value !=
                                                    Duration.zero
                                            ? const Icon(
                                                Icons
                                                    .pause_circle_filled_outlined,
                                                size: 50,
                                                color: ColorManager.colorAccent,
                                              )
                                            : audioDuration.value >=
                                                        audioTotalDuration
                                                            .value &&
                                                    audioTotalDuration.value !=
                                                        Duration.zero &&
                                                    isPlayerPlaying.value
                                                ? const Icon(
                                                    Icons.refresh_rounded,
                                                    size: 50,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  )
                                                : const Icon(
                                                    IconlyBold.play,
                                                    size: 50,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ))),
                        onVisibilityChanged: (info) => {
                              if (info.visibleFraction < 0.9)
                                {
                                  audioPlayer.stop(),
                                  isPlayerPlaying.value = audioPlayer.playing
                                }
                            })
                  ],
                )
              ],
            ),
      onLoading: searchOverviewShimmer(),
      onError: (error) => NoSearchResult(
            text: "No Search Results!",
          ),
      onEmpty: NoSearchResult(
        text: "No Search Results!",
      ));
}
