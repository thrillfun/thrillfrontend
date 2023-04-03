import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/page_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
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
              title: searchBarLayout(),
              bottom: TabBar(
                  indicatorColor: ColorManager.colorAccent,
                  labelColor: ColorManager.colorAccent,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                  automaticIndicatorColorAdjustment: true,
                  onTap: (int index) {
                    selectedTab.value = index;
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(text: "All"),
                    Tab(text: "Videos"),
                    Tab(text: "Sounds"),
                    Tab(text: "Hashtags"),
                    Tab(text: "Users")
                  ]),
            ),
            body: controller.obx((state) => TabBarView(children: [
                  searchOverview(),
                  searchVideos(),
                  searchSounds(),
                  searchHashtags(),
                  searchUsers()
                ]))));
  }

  searchBarLayout() => Row(
        children: [
          Flexible(
            child: Container(
              height: 55,
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
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
                decoration: InputDecoration(
                  filled: true,
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
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.person_off_sharp)],
            )
          : Container(
              height: Get.height,
              child: ListView(
                shrinkWrap: true,
                children: List.generate(
                    state![0].users!.length,
                    (index) => InkWell(
                          onTap: () async {
                            Get.toNamed(Routes.OTHERS_PROFILE,arguments: {"profileId":state[0].users![index].id});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    height: 50,
                                    width: 50,
                                    imageUrl: state[0]
                                                .users![index]
                                                .avatar
                                                .toString()
                                                .isEmpty ||
                                            state[0]
                                                    .users![index]
                                                    .avatar
                                                    .toString() ==
                                                "null"
                                        ? RestUrl.placeholderImage
                                        : RestUrl.profileUrl +
                                            state[0]
                                                .users![index]
                                                .avatar
                                                .toString(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state[0].users![index].name.toString() ==
                                              "null"
                                          ? state[0]
                                              .users![index]
                                              .username
                                              .toString()
                                          : state[0]
                                              .users![index]
                                              .name
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 18,
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
                                          style: TextStyle(
                                              fontSize: 14,
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
                                          style: TextStyle(
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
                                        state[0].users![index].isfollow == 0
                                            ? "follow"
                                            : "unfollow",
                                        searchQuery: _controller.text)
                                  },
                                  child: state[0].users![index].isfollow == 0
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: ColorManager.colorAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(
                                            "Follow",
                                            style: TextStyle(
                                              fontSize: 14,
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
                                                fontSize: 14,
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
      onEmpty: emptyListWidget(),
      onLoading: loader());

  searchVideos() => controller.obx(
      (state) => state!.isEmpty || state[0].videos!.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.fiber_smart_record_sharp)],
            )
          : GridView.count(
              crossAxisCount: 2,
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
                                                state[0]
                                                    .videos![index]
                                                    .views
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
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: state[0]
                                                .videos![index]
                                                .user!
                                                .avatar
                                                .toString()
                                                .isEmpty ||
                                            state[0]
                                                    .videos![index]
                                                    .user!
                                                    .avatar
                                                    .toString() ==
                                                "null"
                                        ? RestUrl.placeholderImage
                                        : RestUrl.profileUrl +
                                            state[0]
                                                .videos![index]
                                                .user!
                                                .avatar
                                                .toString(),
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  state[0].videos![index].user!.name.toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            )
                          ],
                        ),
                        onTap: () {
                          Get.toNamed(Routes.SEARCH_VIDEOS_PLAYER, arguments: {
                            "search_videos": state[0].videos,
                            "init_page": index
                          });
                        },
                      )),
            ),
      onEmpty: emptyListWidget(),
      onLoading: Column(
        children: [Expanded(child: loader())],
      ));

  searchHashtags() => controller.obx(
      (state) => state![0].hashtags!.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.confirmation_num)],
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
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
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )),
            ),
      onEmpty: emptyListWidget(),
      onLoading: loader());

  searchSounds() => controller.obx(
      (state) => state![0].sounds!.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.volume_mute)],
            )
          : Container(
              height: Get.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state![0].sounds!.length,
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
                                        child: imgProfile(state[0]
                                                    .sounds![index]
                                                    .soundOwner !=
                                                null
                                            ? state[0]
                                                .sounds![index]
                                                .soundOwner!
                                                .avtars
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
                                        state[0]
                                            .sounds![index]
                                            .sound
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        state[0].sounds![index].soundOwner ==
                                                null
                                            ? ""
                                            : state[0]
                                                .sounds![index]
                                                .soundOwner!
                                                .name
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        state[0].sounds![index].soundOwner ==
                                                null
                                            ? ""
                                            : state[0]
                                                .sounds![index]
                                                .soundOwner!
                                                .name
                                                .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                state[0]
                                    .sounds![index]
                                    .sound_used_inweek_count
                                    .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              )
                            ],
                          ),
                        ),
                        onTap: () async {
                          await GetStorage().write(
                              "profileId", state[0].sounds![index].userId);

                          Get.toNamed(Routes.SOUNDS, arguments: {
                            "sound_name":
                                state[0].sounds![index].name.toString(),
                            "sound_url":
                                state[0].sounds![index].sound.toString(),
                          });
                        },
                      )),
            ),
      onEmpty: Expanded(child: emptyListWidget()),
      onLoading: Expanded(child: loader()));

  searchOverview() => controller.obx(
      (state) => state![0].sounds!.isEmpty &&
              state![0].videos!.isEmpty &&
              state![0].hashtags!.isEmpty &&
              state![0].users!.isEmpty
          ? Column(
              children: [emptyListWidget()],
            )
          : ListView(
              shrinkWrap: true,
              children: [
                Visibility(
                  visible: state[0].users!.isNotEmpty,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      "Users",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                            itemCount: state![0].users!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => InkWell(
                                  onTap: () async {
                                    await GetStorage()
                                        .write("profileId",
                                            state[0].users![index].id)
                                        .then((value) {
                                      Get.toNamed(Routes.OTHERS_PROFILE);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            height: 50,
                                            width: 50,
                                            imageUrl: state[0]
                                                        .users![index]
                                                        .avatar
                                                        .toString()
                                                        .isEmpty ||
                                                    state[0]
                                                            .users![index]
                                                            .avatar
                                                            .toString() ==
                                                        "null"
                                                ? RestUrl.placeholderImage
                                                : RestUrl.profileUrl +
                                                    state[0]
                                                        .users![index]
                                                        .avatar
                                                        .toString(),
                                          ),
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
                                              state[0]
                                                          .users![index]
                                                          .name
                                                          .toString() ==
                                                      "null"
                                                  ? state[0]
                                                      .users![index]
                                                      .username
                                                      .toString()
                                                  : state[0]
                                                      .users![index]
                                                      .name
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
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
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  state[0]
                                                              .users![index]
                                                              .followers
                                                              .toString()
                                                              .isEmpty ||
                                                          controller
                                                                  .searchList[0]
                                                                  .users![index]
                                                                  .followers ==
                                                              null
                                                      ? "0 Followers"
                                                      : state[0]
                                                              .users![index]
                                                              .followers
                                                              .toString() +
                                                          " Followers",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                        InkWell(
                                          onTap: () => {
                                            controller.followUnfollowUser(
                                                state[0].users![index].id!,
                                                state[0]
                                                            .users![index]
                                                            .isfollow ==
                                                        0
                                                    ? "follow"
                                                    : "unfollow")
                                          },
                                          child: state[0]
                                                      .users![index]
                                                      .isfollow ==
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
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Text(
                                                    "Follow",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: const Text(
                                                    "Following",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                    child: Text(
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
                                              margin: const EdgeInsets.all(10),
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
                                                      style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      text: "  " +
                                                          state[0]
                                                              .videos![index]
                                                              .views
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
                                          "search_videos": state[0].videos,
                                          "init_page": index
                                        });
                                  },
                                )),
                      ),
                    )),
                Visibility(
                    visible: state[0].hashtags!.isNotEmpty,
                    child: Container(
                      child: Text(
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        73, 204, 201, 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: const Icon(
                                                  Icons.numbers,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              state[0].hashtags![index].name ==
                                                      null
                                                  ? ""
                                                  : state[0]
                                                      .hashtags![index]
                                                      .name!,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
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
                                          style: TextStyle(
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
                      child: Text(
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
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state[0].sounds!.take(4).length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
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
                                                child: imgProfile(state[0]
                                                            .sounds![index]
                                                            .soundOwner !=
                                                        null
                                                    ? state[0]
                                                        .sounds![index]
                                                        .soundOwner!
                                                        .avtars
                                                        .toString()
                                                    : RestUrl.placeholderImage),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                state[0]
                                                    .sounds![index]
                                                    .sound
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                state[0]
                                                            .sounds![index]
                                                            .soundOwner !=
                                                        null
                                                    ? state[0]
                                                        .sounds![index]
                                                        .soundOwner!
                                                        .name
                                                        .toString()
                                                    : "",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                state[0]
                                                            .sounds![index]
                                                            .soundOwner !=
                                                        null
                                                    ? state[0]
                                                        .sounds![index]
                                                        .soundOwner!
                                                        .name
                                                        .toString()
                                                    : "",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )
                                            ],
                                          ))
                                        ],
                                      ),
                                    ),
                                    Text(
                                      state[0]
                                          .sounds![index]
                                          .sound_used_inweek_count
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                await GetStorage().write(
                                    "sound_url", state[0].sounds![index].sound);
                                await GetStorage().write("sound_name",
                                    state[0].sounds![index].sound);
                                await GetStorage().write("is_follow",
                                    state[0].users![index].isfollow);
                                await GetStorage().write(
                                    "soundId", state[0].sounds![index].id);
                                await GetStorage().write("profileId",
                                    state[0].sounds![index].userId);

                                await GetStorage().write(
                                    "profileId", state[0].sounds![index].userId);

                                Get.toNamed(Routes.SOUNDS, arguments: {
                                  "sound_name":
                                  state[0].sounds![index].name.toString(),
                                  "sound_url":
                                  state[0].sounds![index].sound.toString(),
                                });
                                // Get.to(SoundDetails(map: {
                                //   "sound": state[0].sounds![index].sound,
                                //   "user":
                                //   state[0].sounds![index].soundOwner != null
                                //       ? state[0]
                                //       .sounds![index]
                                //       .soundOwner!
                                //       .name!
                                //       : "",
                                //   "soundName": state[0].sounds![index].sound,
                                //   "title":
                                //   state[0].sounds![index].soundOwner != null
                                //       ? state[0]
                                //       .sounds![index]
                                //       .soundOwner!
                                //       .username
                                //       : "",
                                //   "id": state[0].sounds![index].soundOwner !=
                                //       null
                                //       ? state[0].sounds![index].soundOwner!.id
                                //       : 0,
                                //   "sound_id": state[0].sounds![index].id,
                                //   "profile":
                                //   state[0].sounds![index].soundOwner != null
                                //       ? state[0]
                                //       .sounds![index]
                                //       .soundOwner!
                                //       .avtars
                                //       : RestUrl.placeholderImage,
                                //   "name": state[0].sounds![index].soundOwner !=
                                //       null
                                //       ? state[0].sounds![index].soundOwner!.name
                                //       : "",
                                //   "username":
                                //   state[0].sounds![index].soundOwner != null
                                //       ? state[0]
                                //       .sounds![index]
                                //       .soundOwner!
                                //       .username
                                //       : "",
                                //   "isFollow": 0,
                                // }));
                              },
                            )))
              ],
            ),
      onLoading: Expanded(
          child: Center(
        child: loader(),
        heightFactor: 10,
      )));
}
