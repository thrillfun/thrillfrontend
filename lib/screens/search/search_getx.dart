import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as justAudio;
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/hashtags/top_hashtags_controller.dart';
import 'package:thrill/controller/users/other_users_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/sound/sound_details.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';

import '../../controller/hashtags/search_hashtags_controller.dart';
import '../../controller/model/public_videosModel.dart';
import '../../controller/videos/hashtags_videos_controller.dart';
import '../../utils/page_manager.dart';
import '../profile/profile.dart';

FocusNode fieldNode = FocusNode();
TextEditingController _controller = TextEditingController();
var hashtagVideosController = Get.find<HashtagVideosController>();

final progressNotifier = ValueNotifier<ProgressBarState>(
  ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  ),
);

justAudio.AudioPlayer audioPlayer = justAudio.AudioPlayer();

class SearchGetx extends GetView<DiscoverController> {
  SearchGetx({Key? key}) : super(key: key);
  var searchValue = ''.obs;
  var selectedTab = 0.obs;
  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;
  var usersController = Get.find<UserController>();
  var searchHashtagsController = Get.find<SearchHashtagsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: Container(
          height: Get.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              searchBarLayout(controller),
              tabBarLayout(),
              Flexible(child: Obx(() => tabview()))
            ],
          ),
        ));
  }

  tabBarLayout() => Obx(() => DefaultTabController(
        length: 5,
        initialIndex: selectedTab.value,
        child: TabBar(
            unselectedLabelColor:
                Get.isPlatformDarkMode ? Colors.grey : Colors.black,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            labelColor: ColorManager.colorPrimaryLight,
            onTap: (int index) {
              selectedTab.value = index;
            },
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            indicatorColor: ColorManager.colorAccent,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: const [
              Tab(
                text: "Overview",
              ),
              Tab(
                text: "Videos",
              ),
              Tab(
                text: "Sounds",
              ),
              Tab(
                text: "Hashtags",
              ),
              Tab(
                text: "Users",
              )
            ]),
      ));

  tabview() {
    if (selectedTab.value == 0) {
      return overView();
    }
    if (selectedTab.value == 1) {
      return videos();
    } else if (selectedTab.value == 2) {
      return sounds();
    } else if (selectedTab.value == 3) {
      return hashTags();
    } else {
      return users();
    }
  }

  overView() => SearchData();
  videos() => const SearchVideos();
  sounds() => const SearchSounds();
  hashTags() => SearchHashtags();
  users() => SearchUsers();
  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  searchBarLayout(DiscoverController controller) => Row(
        children: [
          IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back,
                color: Get.isPlatformDarkMode ? Colors.white : Colors.black,
              )),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              child: TextFormField(
                controller: _controller,
                onEditingComplete: () {
                  searchHashtagsController.searchHashtags(_controller.text);
                },

                onFieldSubmitted: (text) {
                  searchHashtagsController.searchHashtags(text);
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

  emptyListWidget(String text) => Flexible(
          child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ));
}

class SearchUsers extends GetView<SearchHashtagsController> {
  var otherUsersController = Get.find<OtherUsersController>();
  SearchUsers({Key? key}) : super(key: key);
  var usersController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
        (state) => state!.isEmpty
            ? emptyListWidget()
            : Container(
                height: Get.height,
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(
                      state![0].users!.length,
                      (index) => InkWell(
                            onTap: () async {

                              state[0].users![index].id!.toInt()==usersController.storage.read("userId")?
                              await userVideosController.getUserVideos(
                                  ):await userVideosController.getOtherUserVideos(
                                  state[0].users![index].id!.toInt());
                              state[0].users![index].id!.toInt()==usersController.storage.read("userId")?  await likedVideosController.getUserLikedVideos(
                                  ):  await likedVideosController.getOthersLikedVideos(
                                  state[0].users![index].id!.toInt());

                              state[0].users![index].id!.toInt()==usersController.storage.read("userId")?
                                  await userDetailsController.getUserProfile().then((value) {
                                    Get.to(Profile(isProfile: true.obs));
                                  }):await otherUsersController.getOtherUserProfile(state[0].users![index].id!.toInt()).then((value) {
                                Get.to(ViewProfile(
                                    state[0].users![index].id!.toString(),
                                    state[0].users![index].isfollow ==
                                        null
                                        ? 0.obs
                                        : state[0]
                                        .users![index]
                                        .isfollow!
                                        .obs,
                                    state[0]
                                        .users![index]
                                        .username
                                        .toString(),
                                    state[0]
                                        .users![index]
                                        .avatar
                                        .toString()));
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
                                        state[0].users![index].name.toString(),
                                        style: const TextStyle(
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
                                            style: const TextStyle(
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
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                                  state[0].users![index].isfollow == 0
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
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
                                        )
                                ],
                              ),
                            ),
                          )),
                ),
              ),
        onEmpty: emptyListWidget(),
        onLoading: loader());
  }
}

class SearchHashtags extends GetView<SearchHashtagsController> {
  SearchHashtags({Key? key}) : super(key: key);

  var tophashtagsController = Get.find<TopHashtagsController>();
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? emptyListWidget()
            : Container(
                height: Get.height,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state![0].hashtags!.length,
                    itemBuilder: (context, index) => InkWell(
                          onTap: () async{
                            await hashtagVideosController
                                .getVideosByHashTags(controller.searchList[0]
                                .hashtags![index].id!)
                                .then((value) =>
                                Get.to(HashTagsScreen(
                                  tagName: controller.searchList[0]
                                      .hashtags![index].name
                                      .toString(),
                                  videosList: tophashtagsController
                                      .topHashtagsList[index].videos,
                                  videoCount: tophashtagsController
                                      .topHashtagsList[index]
                                      .hashtagId,
                                )));
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
                                          fontSize: 18),
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )),
              ),
        onEmpty: emptyListWidget(),
        onLoading: loader());
  }
}

class SearchSounds extends GetView<SearchHashtagsController> {
  const SearchSounds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? emptyListWidget()
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
                                              .soundOwner!
                                              .avtars
                                              .toString()),
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
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          state[0]
                                              .sounds![index]
                                              .soundOwner!
                                              .name
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          state[0]
                                              .sounds![index]
                                              .soundOwner!
                                              .name
                                              .toString(),
                                          style: const TextStyle(
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
                                      .soundOwner!
                                      .followersCount
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                          onTap: () => Get.to(SoundDetails(map: {
                            "sound": state[0].sounds![index].sound,
                            "user": state[0]
                                    .sounds![index]
                                    .soundOwner!
                                    .name!
                                    .isEmpty
                                ? ""
                                : state[0].sounds![index].soundOwner!.name!,
                            "soundName": state[0].sounds![index].sound,
                            "title":
                                state[0].sounds![index].soundOwner!.username,
                            "id": state[0].sounds![index].soundOwner!.id,
                            "sound_id": state[0].sounds![index].id,
                            "profile":
                                state[0].sounds![index].soundOwner!.avtars,
                            "name": state[0].sounds![index].soundOwner!.name,
                            "username":
                                state[0].sounds![index].soundOwner!.username,
                            "isFollow": 0,
                          })),
                        )),
              ),
        onEmpty: emptyListWidget(),
        onLoading: loader());
  }
}

class SearchVideos extends GetView<SearchHashtagsController> {
  const SearchVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isNotEmpty
            ? Flexible(
                child: Container(
                margin: const EdgeInsets.all(10),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  childAspectRatio: Get.width / Get.height,
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
                                                  color:
                                                      ColorManager.colorAccent,
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
                                      state[0]
                                          .videos![index]
                                          .user!
                                          .name
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )
                              ],
                            ),
                            onTap: () {
                              List<PublicVideos> videosList1 = [];
                              state[0].videos!.forEach((element) {
                                var user = PublicUser(
                                  id: element.user?.id,
                                  name: element.user?.name,
                                  facebook: element.user?.facebook,
                                  firstName: element.user?.firstName,
                                  lastName: element.user?.lastName,
                                  username: element.user?.username,
                                  isfollow: element.user?.isfollow,
                                );
                                videosList1.add(PublicVideos(
                                  id: element.id,
                                  video: element.video,
                                  description: element.description,
                                  sound: element.sound,
                                  soundName: element.soundName,
                                  soundCategoryName: element.soundCategoryName,
                                  soundOwner: element.soundOwner,
                                  filter: element.filter,
                                  likes: element.likes,
                                  views: element.views,
                                  gifImage: element.gifImage,
                                  speed: element.speed,
                                  comments: element.comments,
                                  isDuet: "no",
                                  duetFrom: "",
                                  isCommentable: "yes",
                                  videoLikeStatus: element.videoLikeStatus,
                                  user: user,
                                ));
                              });
                              Get.to(VideoPlayerItem(
                                videosList: videosList1,
                                position: index,
                              ));
                            },
                          )),
                ),
              ))
            : emptyListWidget(),
        onEmpty: emptyListWidget(),
        onLoading: loader());
  }
}

class SearchData extends GetView<SearchHashtagsController> {
  SearchData({Key? key}) : super(key: key);

  var usersController = Get.find<UserController>();
  var tophashtagsController = Get.find<TopHashtagsController>();
  var otherUsersController = Get.find<OtherUsersController>();
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? emptyListWidget()
            : ListView(
                shrinkWrap: true,
                children: [
                  Visibility(
                    visible: state[0].users!.isNotEmpty,
                    child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: const Text(
                      "Users",
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),),
                  const SizedBox(
                    height: 10,
                  ),
                 Visibility(
                   visible: state[0].users!.isNotEmpty,
                     child:  Container(
                     margin: const EdgeInsets.symmetric(
                         vertical: 10, horizontal: 10),
                     child: ListView.builder(
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: state![0].users!.length,
                         shrinkWrap: true,
                         itemBuilder: (context, index) => InkWell(
                           onTap: () async {
                             state[0].users![index].id!.toInt()==usersController.storage.read("userId")?
                             await userVideosController.getUserVideos(
                             ):await userVideosController.getOtherUserVideos(
                                 state[0].users![index].id!.toInt());
                             state[0].users![index].id!.toInt()==usersController.storage.read("userId")?  await likedVideosController.getUserLikedVideos(
                             ):  await likedVideosController.getOthersLikedVideos(
                                 state[0].users![index].id!.toInt());

                             state[0].users![index].id!.toInt()==usersController.storage.read("userId")?
                             await userDetailsController.getUserProfile().then((value) {
                               Get.to(Profile(isProfile: true.obs));
                             }):await otherUsersController.getOtherUserProfile(state[0].users![index].id!.toInt()).then((value) {
                               Get.to(ViewProfile(
                                   state[0].users![index].id!.toString(),
                                   state[0].users![index].isfollow ==
                                       null
                                       ? 0.obs
                                       : state[0]
                                       .users![index]
                                       .isfollow!
                                       .obs,
                                   state[0]
                                       .users![index]
                                       .username
                                       .toString(),
                                   state[0]
                                       .users![index]
                                       .avatar
                                       .toString()));
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
                                               .toString(),
                                           style: const TextStyle(
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
                                               style: const TextStyle(
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
                                               style: const TextStyle(
                                                   fontSize: 12,
                                                   fontWeight:
                                                   FontWeight.w400),
                                             )
                                           ],
                                         )
                                       ],
                                     )),
                                 InkWell(
                                   onTap: () =>
                                       usersController.followUnfollowUser(
                                           usersController.storage
                                               .read("userId"),
                                           state[0]
                                               .users![index]
                                               .isfollow ==
                                               0
                                               ? "follow"
                                               : "unfollow"),
                                   child: state[0]
                                       .users![index]
                                       .isfollow ==
                                       0
                                       ? Container(
                                     padding:
                                     const EdgeInsets.symmetric(
                                         horizontal: 20,
                                         vertical: 10),
                                     decoration: BoxDecoration(
                                         color: ColorManager
                                             .colorAccent,
                                         borderRadius:
                                         BorderRadius.circular(
                                             20)),
                                     child: const Text(
                                       "Follow",
                                       style: TextStyle(
                                           fontSize: 14,
                                           fontWeight:
                                           FontWeight.w600,
                                           color: Colors.white),
                                     ),
                                   )
                                       : Container(
                                     padding:
                                     const EdgeInsets.symmetric(
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
                    child: const Text(
                      "Videos",
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),),
                  const SizedBox(
                    height: 10,
                  ),
                 Visibility(
                   visible: state[0].videos!.isNotEmpty,
                     child:  Container(
                   margin: const EdgeInsets.all(5),
                   child: GridView.count(
                     physics: const NeverScrollableScrollPhysics(),
                     crossAxisCount: 3,
                     shrinkWrap: true,
                     crossAxisSpacing: 10,
                     childAspectRatio: Get.width / Get.height,
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
                                               style: const TextStyle(
                                                 overflow:
                                                 TextOverflow.ellipsis,
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
                             List<PublicVideos> videosList1 = [];
                             state[0].videos!.forEach((element) {
                               var user = PublicUser(
                                 id: element.user?.id,
                                 name: element.user?.name,
                                 facebook: element.user?.facebook,
                                 firstName: element.user?.firstName,
                                 lastName: element.user?.lastName,
                                 username: element.user?.username,
                                 isfollow: element.user?.isfollow,
                               );
                               videosList1.add(PublicVideos(
                                 id: element.id,
                                 video: element.video,
                                 description: element.description,
                                 sound: element.sound,
                                 soundName: element.soundName,
                                 soundCategoryName:
                                 element.soundCategoryName,
                                 soundOwner: element.soundOwner,
                                 filter: element.filter,
                                 likes: element.likes,
                                 views: element.views,
                                 gifImage: element.gifImage,
                                 speed: element.speed,
                                 comments: element.comments,
                                 isDuet: "no",
                                 duetFrom: "",
                                 isCommentable: "yes",
                                 videoLikeStatus: element.videoLikeStatus,
                                 user: user,
                               ));
                             });
                             Get.to(VideoPlayerItem(
                               videosList: videosList1,
                               position: index,
                             ));
                             // Get.to(VideoPlayerScreen(
                             //   isFav: false,
                             //   isFeed: false,
                             //   isLock: false,
                             // ));
                           },
                         )),
                   ),
                 )),
                  const SizedBox(
                    height: 10,
                  ),
                 Visibility(
                   visible: state[0].hashtags!.isNotEmpty,
                     child:  Container(
                   child: const Text(
                     "Hashtags",
                     style:
                     TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                            onTap: () async{
                              await hashtagVideosController
                                  .getVideosByHashTags(controller.searchList[0]
                                  .hashtags![index].id!)
                                  .then((value) =>
                                  Get.to(HashTagsScreen(
                                    tagName: controller.searchList[0]
                                        .hashtags![index].name
                                        .toString(),
                                    videosList: tophashtagsController
                                        .topHashtagsList[index].videos,
                                    videoCount: tophashtagsController
                                        .topHashtagsList[index]
                                        .hashtagId,
                                  )));
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
                                            color: ColorManager.colorAccent,
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
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
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
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ))))
                  ,
                  Visibility(
                    visible: state[0].sounds!.isNotEmpty,
                      child: Container(
                    child: const Text(
                      "Sounds",
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                                              .soundOwner!
                                              .avtars
                                              .toString()),
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
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              state[0]
                                                  .sounds![index]
                                                  .soundOwner!
                                                  .name
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              state[0]
                                                  .sounds![index]
                                                  .soundOwner!
                                                  .name
                                                  .toString(),
                                              style: const TextStyle(
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
                                    .soundOwner!
                                    .followersCount
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              )
                            ],
                          ),
                        ),
                        onTap: () =>Get.to(SoundDetails(map: {
                          "sound": state[0].sounds![index].sound,
                          "user": state[0]
                              .sounds![index]
                              .soundOwner!
                              .name!
                              .isEmpty
                              ? ""
                              : state[0].sounds![index].soundOwner!.name!,
                          "soundName": state[0].sounds![index].sound,
                          "title":
                          state[0].sounds![index].soundOwner!.username,
                          "id": state[0].sounds![index].soundOwner!.id,
                          "sound_id": state[0].sounds![index].id,
                          "profile":
                          state[0].sounds![index].soundOwner!.avtars,
                          "name": state[0].sounds![index].soundOwner!.name,
                          "username":
                          state[0].sounds![index].soundOwner!.username,
                          "isFollow": 0,
                        })),
                      )))
                ],
              ),
        onLoading: Center(
          child: loader(),
          heightFactor: 10,
        ));
  }
}
