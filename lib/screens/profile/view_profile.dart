import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/controller/users/other_users_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';

import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../controller/users/followers_controller.dart';
import '../../controller/videos/UserVideosController.dart';
import '../../controller/videos/like_videos_controller.dart';
import '../../rest/rest_url.dart';

var usersController = Get.find<UserController>();

class ViewProfile extends StatelessWidget {
  var showFollowers = false.obs;
  var otherDetailsController = Get.find<UserDetailsController>();
  var usersController = Get.find<UserController>();
  var selectedTab = 0.obs;
  var videosController = Get.find<VideosController>();

  ViewProfile(this.userId, this.isFollow, this.profileName, this.avatar);

  String? userId = "";
  RxInt? isFollow = 0.obs;
  String? profileName;
  String? avatar = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      appBar: AppBar(
        title: Text(
          profileName!,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Get.isPlatformDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent.withOpacity(0),
        elevation: 0,
        iconTheme: IconThemeData(
            color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          OtherUserProfileDetails(isFollow!),
          Expanded(
              child: DefaultTabController(
                  initialIndex: selectedTab.value,
                  length: 2,
                  child: Scaffold(
                    backgroundColor: ColorManager.dayNight,
                    appBar: AppBar(
                        toolbarHeight: 10,
                        backgroundColor: ColorManager.dayNight,
                        bottom: TabBar(
                            onTap: (int index) {
                              selectedTab.value = index;
                            },
                            indicatorColor: ColorManager.colorAccent,
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: 30),
                            tabs: [
                              Obx(() => Tab(
                                    icon: Icon(
                                      Icons.dashboard,
                                      color: selectedTab.value == 0
                                          ? ColorManager.colorAccent
                                          : ColorManager.colorAccentTransparent,
                                    ),
                                  )),
                              Obx(() => Tab(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: selectedTab.value == 1
                                          ? ColorManager.colorAccent
                                          : ColorManager.colorAccentTransparent,
                                    ),
                                  ))
                            ])),
                    body: TabBarView(
                        children: [OtherUserVideos(), OtherLikedVideos()]),
                  )))
        ],
      ),
    );
  }

  tabview() {
    if (selectedTab.value == 0) {
      return OtherUserVideos();
    } else {
      return OtherLikedVideos();
    }
  }

  feed() {
    return Flexible(
        child: GetX<VideosController>(
      builder: (videosController) => videosController.isUserVideosLoading.isTrue
          ? loader()
          : videosController.otherUserVideos.isEmpty
              ? RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(children: [
                    TextSpan(
                        text: '\n\n\n' "User's liked Video",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '\n\n'
                            "Videos liked are currently not available",
                        style: TextStyle(fontSize: 17, color: Colors.grey))
                  ]))
              : GridView.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  padding: const EdgeInsets.all(10),
                  children: List.generate(
                      videosController.otherUserVideos.length,
                      (index) => GestureDetector(
                            onTap: () {
                              Get.to(VideoPlayerScreen(
                                isFav: false,
                                isFeed: true,
                                isLock: false,
                                position: index,
                                userVideos: videosController.otherUserVideos,
                              ));
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imgNet(
                                    '${RestUrl.gifUrl}${videosController.otherUserVideos.value[index].gifImage}'),
                                Positioned(
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.visibility,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          videosController
                                                  .otherUserVideos.isEmpty
                                              ? "0"
                                              : videosController.otherUserVideos
                                                  .value[index].views
                                                  .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          videosController
                                                  .otherUserVideos.value.isEmpty
                                              ? "0"
                                              : videosController.otherUserVideos
                                                  .value[index].likes
                                                  .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          )),
                ),
    ));
  }

  fav() {
    return Flexible(
        child: GetX<VideosController>(
      builder: (videosController) => videosController.isUserVideosLoading.isTrue
          ? loader()
          : videosController.othersLikedVideos.isEmpty
              ? RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(children: [
                    TextSpan(
                        text: '\n\n\n' "User's liked Video",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '\n\n'
                            "Videos liked are currently not available",
                        style: TextStyle(fontSize: 17, color: Colors.grey))
                  ]))
              : GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                  padding: const EdgeInsets.all(10),
                  children: List.generate(
                      videosController.othersLikedVideos.length,
                      (index) => GestureDetector(
                            onTap: () {
                              Get.to(VideoPlayerScreen(
                                isFav: true,
                                isFeed: false,
                                isLock: false,
                                position: index,
                                likedVideos: videosController.othersLikedVideos,
                              ));
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // CachedNetworkImage(
                                //     placeholder: (a, b) => const Center(
                                //       child: CircularProgressIndicator(),
                                //     ),
                                //     fit: BoxFit.cover,
                                //     imageUrl:favVideos[index].gif_image.isEmpty
                                //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                                //         : '${RestUrl.gifUrl}${favVideos[index].gif_image}'),
                                imgNet(
                                    '${RestUrl.gifUrl}${videosController.othersLikedVideos[index].gifImage}'),
                                Positioned(
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.visibility,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          videosController
                                              .othersLikedVideos[index].views
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          videosController
                                              .othersLikedVideos[index].likes
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          )),
                ),
    ));
  }
}

// ignore: must_be_immutable
class OtherUserVideos extends GetView<UserVideosController> {
  OtherUserVideos({Key? key}) : super(key: key);
  var videosController = Get.find<VideosController>();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (_) => GridView.count(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
        children: List.generate(
            controller.otherUserVideos.length,
            (index) => GestureDetector(
                  onTap: () {
                    Get.to(VideoPlayerScreen(
                      isFav: false,
                      isFeed: true,
                      isLock: false,
                      position: index,
                      userVideos: controller.otherUserVideos,
                    ));
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imgNet(
                          '${RestUrl.gifUrl}${controller.otherUserVideos[index].gifImage}'),
                      Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                children: [
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.play_circle,
                                      size: 18,
                                      color: ColorManager.colorAccent,
                                    ),
                                  ),
                                  TextSpan(
                                      text: " " +
                                          controller
                                              .otherUserVideos[index].views
                                              .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                ],
                              ))
                            ],
                          ))
                    ],
                  ),
                )),
      ),
      onLoading: loader(),
      onEmpty: emptyListWidget(),
    );
  }
}

// ignore: must_be_immutable
class OtherLikedVideos extends GetView<LikedVideosController> {
  OtherLikedVideos({Key? key}) : super(key: key);
  var videosController = Get.find<VideosController>();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => GridView.count(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        children: List.generate(
            controller!.othersLikedVideos.length,
            (index) => GestureDetector(
                  onTap: () {
                    Get.to(VideoPlayerScreen(
                      isFav: true,
                      isFeed: false,
                      isLock: false,
                      position: index,
                      likedVideos: controller!.likedVideos,
                    ));
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imgNet(
                          '${RestUrl.gifUrl}${controller!.othersLikedVideos[index].gifImage}'),
                      Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const WidgetSpan(
                                      child: Icon(
                                        Icons.play_circle,
                                        size: 18,
                                        color: ColorManager.colorAccent,
                                      ),
                                    ),
                                    TextSpan(
                                        text: " " +
                                            controller!
                                                .othersLikedVideos[index].views
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                )),
      ),
      onLoading: loader(),
      onEmpty: emptyListWidget(),
    );
  }
}

// ignore: must_be_immutable
class OtherUserProfileDetails extends GetView<OtherUsersController> {
  OtherUserProfileDetails(this.isFollow);

  var isFollow = 0.obs;
  var followersController = Get.find<FollowersController>();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                "assets/profile_background.svg",
                fit: BoxFit.contain,
                width: Get.width,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/23.svg",
                    height: 100,
                    width: 100,
                  ),
                  Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: state!.value.avatar.toString().isEmpty
                            ? RestUrl.placeholderImage
                            : '${RestUrl.profileUrl}${state.value.avatar}',
                        placeholder: (a, b) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.value.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                width: 5,
              ),
              Visibility(
                  visible: state.value.isVerified == 'true',
                  child: SvgPicture.asset(
                    'assets/verified.svg',
                  ))
            ],
          ),
          Text(
            '@${state.value.username}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  followersController.getUserFollowers(state.value.id!).then(
                      (value) => followersController
                          .getUserFollowing(state.value.id!)
                          .then((value) => Get.to(FollowingAndFollowers(
                              false.obs, state.value.id!.obs))));
                  // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                },
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: '${state.value.following}'
                              '\n',
                          style: TextStyle(
                              color: Get.isPlatformDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: following,
                          style: TextStyle(
                              color: Get.isPlatformDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ])),
              ),
              const SizedBox(
                height: 45,
                child: VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  followersController.getUserFollowers(state.value.id!).then(
                      (value) => followersController
                          .getUserFollowing(state.value.id!)
                          .then((value) => Get.to(FollowingAndFollowers(
                              false.obs, state.value.id!.obs))));

                  // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                },
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: '${state.value.followers}'
                              '\n',
                          style: TextStyle(
                              fontSize: 18,
                              color: Get.isPlatformDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: followers,
                          style: TextStyle(
                              fontSize: 14,
                              color: Get.isPlatformDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500)),
                    ])),
              ),
              Container(
                height: 45,
                child: const VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text:
                            '${state.value.likes!.isEmpty ? 0 : state.value.likes}'
                            '\n',
                        style: TextStyle(
                            color: Get.isPlatformDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: likes,
                        style: TextStyle(
                            color: Get.isPlatformDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ])),
            ],
          ).w(MediaQuery.of(context).size.width * .80),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorManager.colorAccent),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          userDetailsController.followUnfollowUser(
                              int.parse(controller.otherUserProfile.value.id
                                  .toString()),
                              isFollow!.value == 0 ? "follow" : "unfollow",
                              token: controller
                                  .otherUserProfile.value.firebaseToken
                                  .toString());
                          userDetailsController.getOtherUserProfile(userId);
                        },
                        child: Obx(() =>
                            Text(isFollow!.value == 0 ? "Follow" : "Following",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ))),
                      ))),
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorManager.colorAccent),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          Get.to(ChatScreen(
                              inboxModel: Inbox(
                                  id: controller.otherUserProfile.value.id,
                                  userImage:
                                      controller.otherUserProfile.value.avatar,
                                  name:
                                      controller.otherUserProfile.value.name)));
                        },
                        child: const Text("Message",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                      ))),
              ClipOval(
                child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/referral');
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: ColorManager.colorAccentTransparent),
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          Icons.camera,
                          size: 16,
                          color: ColorManager.dayNightIcon,
                        ))),
              ),
              ClipOval(
                child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/referral');
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: ColorManager.colorAccentTransparent),
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          Icons.bookmark,
                          size: 16,
                          color: ColorManager.dayNightIcon,
                        ))),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      onLoading: loader(),
      onEmpty: emptyListWidget(),
    );
  }
}
