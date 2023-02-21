import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/PrivateVideosController.dart';
import 'package:thrill/controller/videos/UserVideosController.dart';
import 'package:thrill/controller/videos/like_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/strings.dart';
import '../../controller/users/followers_controller.dart';
import '../../rest/rest_api.dart';
import '../../rest/rest_url.dart';
import '../../widgets/better_video_player.dart';

var selectedTab = 0.obs;

class Profile extends StatelessWidget {
  var userDetailController = Get.find<UserDetailsController>();
  var privateVideosController = Get.find<PrivateVideosController>();

  Profile({Key? key, this.isProfile}) : super(key: key);

  RxBool? isProfile = true.obs;

  @override
  Widget build(BuildContext context) {
    print(userDetailController.storage.read("userId"));

    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Get.width, maxHeight: Get.height),
          child: Column(children: [
            UserProfileDetails(),
            Expanded(
                child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      backgroundColor: ColorManager.dayNight,
                      appBar: AppBar(
                        toolbarHeight: 10,
                        backgroundColor: ColorManager.dayNight,
                        bottom: TabBar(
                            onTap: (int index) {
                              if (index == 1) {
                                userVideosController.getUserVideos();
                              } else if (index == 1) {
                                privateVideosController.getUserPrivateVideos();
                              } else {
                                likedVideosController.getUserLikedVideos();
                              }
                              selectedTab.value = index;
                            },
                            indicatorColor: ColorManager.colorAccent,
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
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
                                      Icons.lock,
                                      color: selectedTab.value == 1
                                          ? ColorManager.colorAccent
                                          : ColorManager.colorAccentTransparent,
                                    ),
                                  )),
                              Obx(() => Tab(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: selectedTab.value == 2
                                          ? ColorManager.colorAccent
                                          : ColorManager.colorAccentTransparent,
                                    ),
                                  ))
                            ]),
                      ),
                      body: TabBarView(children: [feed(), lock(), fav()]),
                    )))
          ]),
        ));
  }

  feed() {
    return UserVideos();
  }

  lock() {
    return const PrivateVideos();
  }

  fav() => LikedVideos();

  showPrivate2PublicDialog(int videoID) {
    showDialog(
        context: Get.context!,
        builder: (_) => Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: getWidth(Get.context!) * .80,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Are you sure you want to make this video public?",
                          style: Theme.of(Get.context!).textTheme.headline3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "Everyone can see this video if you make it public",
                          style: Theme.of(Get.context!)
                              .textTheme
                              .headline5!
                              .copyWith(fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(Get.context!);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  fixedSize:
                                      Size(getWidth(Get.context!) * .26, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text("No")),
                          const SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                // try {
                                //   Navigator.pop(Get.context!);
                                //   progressDialogue(Get.context!);
                                //   var response =
                                //       await RestApi.publishPrivateVideo(
                                //           videoID);
                                //   var json = jsonDecode(response.body);
                                //   if (json['status']) {
                                //     BlocProvider.of<VideoBloc>(Get.context!).add(
                                //         const VideoLoading(
                                //             selectedTabIndex: 1));
                                //     await Future.delayed(
                                //         const Duration(milliseconds: 500));
                                //     closeDialogue(Get.context!);
                                //     Navigator.pushNamedAndRemoveUntil(
                                //         Get.context!, '/', (route) => true);
                                //     showSuccessToast(
                                //         Get.context!, json['message'].toString());
                                //   } else {
                                //     closeDialogue(Get.context!);
                                //     showErrorToast(
                                //         Get.context!, json['message'].toString());
                                //   }
                                // } catch (e) {
                                //   closeDialogue(Get.context!);
                                //   showErrorToast(Get.context!, e.toString());
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  fixedSize:
                                      Size(getWidth(Get.context!) * .26, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text("Yes"))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}

class UserVideos extends GetView<UserVideosController> {
  UserVideos({Key? key}) : super(key: key);

  var videosController = Get.find<VideosController>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
      (_) => controller.userVideos.isEmpty
          ? Column(
              children: [emptyListWidget()],
            )
          : Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      itemCount: controller.userVideos.length,
                      itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              Get.to(VideoPlayerScreen(
                                isFav: false,
                                isFeed: true,
                                isLock: false,
                                position: index,
                                userVideos: controller.userVideos,
                              ));
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imgNet(
                                    '${RestUrl.gifUrl}${controller.userVideos.value[index].gifImage}'),
                                Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                    controller.userVideos
                                                        .value[index].views
                                                        .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16)),
                                          ],
                                        ))
                                      ],
                                    )),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: IconButton(
                                      onPressed: () {
                                        showDeleteVideoDialog(
                                            controller
                                                .userVideos.value[index].id!,
                                            controller.userVideos.value,
                                            index);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Colors.red,
                                      icon: const Icon(
                                          Icons.delete_forever_outlined)),
                                )
                              ],
                            ),
                          )),
                ))
              ],
            ),
      onLoading: Column(
        children: [
          Expanded(
            child: loader(),
          )
        ],
      ),
      onError: (error) => Column(
        children: [emptyListWidget()],
      ),
      onEmpty: Column(
        children: [emptyListWidget()],
      ),
    );
  }

  showDeleteVideoDialog(int videoID, List list, int index) {
    Get.defaultDialog(
      content: const Text("Are you sure you want to delete this video ?"),
      cancel: ElevatedButton(
          onPressed: () {
            Navigator.pop(Get.context!);
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              fixedSize: Size(getWidth(Get.context!) * .26, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text("No")),
      confirm: ElevatedButton(
          onPressed: () async {
            Get.back();
            controller.deleteVideo(videoID);
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.red,
              fixedSize: Size(getWidth(Get.context!) * .26, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text("Yes")),
    );
  }
}

class PrivateVideos extends GetView<PrivateVideosController> {
  const PrivateVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
        (state) => state!.isEmpty
            ? Column(
                children: [emptyListWidget()],
              )
            : Column(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: GridView.count(
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                      children: List.generate(
                          state.length,
                          (index) => GestureDetector(
                                onTap: () {
                                  Get.to(VideoPlayerScreen(
                                    isFav: false,
                                    isFeed: false,
                                    isLock: true,
                                    position: index,
                                    privateVideos: state.value,
                                  ));
                                  // Navigator.pushReplacementNamed(context, '/',
                                  //     arguments: {'videoModel': privateList[index]});
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // CachedNetworkImage(
                                    //     placeholder: (a, b) => const Center(
                                    //       child: CircularProgressIndicator(),
                                    //     ),
                                    //     fit: BoxFit.cover,
                                    //     imageUrl:privateList[index].gif_image.isEmpty
                                    //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                                    //         : '${RestUrl.gifUrl}${privateList[index].gif_image}'),
                                    imgNet(
                                        '${RestUrl.gifUrl}${state[index].gifImage}'),
                                    Positioned(
                                        bottom: 5,
                                        left: 5,
                                        right: 5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                    child: Icon(
                                                      Icons.play_circle,
                                                      size: 18,
                                                      color: ColorManager
                                                          .colorAccent,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text: " " +
                                                          state[index]
                                                              .views
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16)),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: IconButton(
                                          onPressed: () {
                                            // showDeleteVideoDialog(
                                            //     videosController
                                            //         .privateVideosList![index].id!,
                                            //     videosController.privateVideosList,
                                            //     index);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: Colors.red,
                                          icon: const Icon(
                                              Icons.delete_forever_outlined)),
                                    ),
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: IconButton(
                                          onPressed: () {
                                            // showPrivate2PublicDialog(privateList[index].id);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: Colors.green,
                                          icon: const Icon(Icons
                                              .published_with_changes_outlined)),
                                    )
                                  ],
                                ),
                              )),
                    ),
                  ))
                ],
              ),
        onLoading: Column(
          children: [Expanded(child: loader())],
        ),
        onEmpty: Column(
          children: [Expanded(child: emptyListWidget())],
        ));
  }
}

class LikedVideos extends GetView<LikedVideosController> {
  LikedVideos({Key? key}) : super(key: key);
  var videosController = Get.find<VideosController>();
  var current = 0.obs;
  var isOnPageTurning = false.obs;
  PageController preloadPageController = PageController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
      (state) => controller.likedVideos.isEmpty
          ? Column(
              children: [emptyListWidget()],
            )
          : Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: GridView.count(
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    children: List.generate(
                        controller.likedVideos.length,
                        (index) => GestureDetector(
                              onTap: () {
                                PublicUser publicUser = PublicUser(
                                    id: controller.likedVideos[index].user!.id,
                                    name: controller
                                        .likedVideos[index].user?.name
                                        .toString(),
                                    username: controller
                                        .likedVideos[index].user?.username,
                                    email: controller
                                        .likedVideos[index].user?.email,
                                    dob:
                                        controller.likedVideos[index].user?.dob,
                                    phone: controller
                                        .likedVideos[index].user?.phone,
                                    avatar: controller
                                        .likedVideos[index].user!.avatar,
                                    socialLoginType: controller
                                        .likedVideos[index]
                                        .user
                                        ?.socialLoginType,
                                    socialLoginId: controller
                                        .likedVideos[index].user?.socialLoginId,
                                    firstName: controller
                                        .likedVideos[index].user?.firstName,
                                    lastName: controller
                                        .likedVideos[index].user?.lastName,
                                    gender: controller
                                        .likedVideos[index].user?.gender,
                                    isFollow:
                                        controller.likedVideos[index].isfollow);

                                Get.to(VideoPlayerScreen(
                                  isFeed: false,
                                  isFav: true,
                                  isLock: false,
                                  likedVideos: controller.likedVideos,
                                  position: index,
                                  hashTagVideos: [],
                                  videosList: [],
                                  privateVideos: [],
                                ));
                                // Get.to(UserLikedVideoPlayer({
                                //   strings.gifImage:
                                //   controller.likedVideos[index].gifImage,
                                //   strings.videoLikeStatus:
                                //   controller.likedVideos[index].videoLikeStatus,
                                //   strings.sound:
                                //   controller.likedVideos[index].sound,
                                //   strings.soundOwner:
                                //   controller.likedVideos[index].soundOwner,
                                //   strings.videoUrl:
                                //   controller.likedVideos[index].video,
                                //   strings.isCommentAllowed:
                                //   controller.likedVideos[index].isCommentable ==
                                //       "yes"
                                //       ? true.obs
                                //       : false.obs,
                                //   strings.publicUser: publicUser,
                                //   strings.videoId: controller.likedVideos[index].id,
                                //   strings.soundName:
                                //   controller.likedVideos[index].soundName,
                                //   strings.isDuetable:
                                //   controller.likedVideos[index].isDuetable ==
                                //       "yes"
                                //       ? true.obs
                                //       : false.obs,
                                //   //   strings.publicVideos:controller.likedVideos
                                //   //   PublicVideos publicVideos;
                                //   strings.description:
                                //   controller.likedVideos[index].description,
                                //   strings.hashtagsList: (controller
                                //       .likedVideos[index]
                                //       .hashtags as List<dynamic>),
                                //   strings.likes:
                                //   controller.likedVideos[index].likes,
                                //   strings.isFollow:
                                //   controller.likedVideos[index].isfollow,
                                //   strings.commentsCount:
                                //   controller.likedVideos[index].comments
                                // }));
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  imgNet(
                                      '${RestUrl.gifUrl}${controller.likedVideos[index].gifImage}'),
                                  Positioned(
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                const WidgetSpan(
                                                  child: Icon(
                                                    Icons.play_circle,
                                                    size: 18,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: " " +
                                                        controller
                                                            .likedVideos[index]
                                                            .views
                                                            .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                ))
              ],
            ),
      onLoading: Column(
        children: [
          Expanded(child: loader()),
        ],
      ),
      onEmpty: Column(
        children: [emptyListWidget()],
      ),
    );
  }

  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController.page ==
            preloadPageController.page!.roundToDouble()) {
      current.value = preloadPageController.page!.toInt();
      isOnPageTurning.value = false;
    } else if (!isOnPageTurning.value &&
        current.toDouble() != preloadPageController.page) {
      if ((current.toDouble() - preloadPageController.page!.toDouble()).abs() >
          0.1) {
        isOnPageTurning.value = true;
      }
    }
  }
}

class UserProfileDetails extends GetView<UserDetailsController> {
  UserProfileDetails({Key? key}) : super(key: key);
  var usersController = Get.find<UserController>();
  var userVideosController = Get.find<UserVideosController>();
  var followersController = Get.find<FollowersController>();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () => Get.to(SettingAndPrivacy(
                              avatar: state!.value.avatar!,
                              name: state.value.name!,
                              userName: state.value.username!)),
                          icon: Icon(
                            Icons.more_vert_outlined,
                            color: ColorManager.dayNightText,
                          ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
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
                  style: TextStyle(
                      color: ColorManager.dayNightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        followersController
                            .getUserFollowers(state.value.id!)
                            .then((value) => followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) => Get.to(FollowingAndFollowers(
                                    true.obs, state.value.id!.obs))));

                        // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                      },
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${state.value.following}'
                                    '\n',
                                style: TextStyle(
                                    color: ColorManager.dayNightText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: following,
                                style: TextStyle(
                                    color: ColorManager.dayNightText,
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
                        followersController
                            .getUserFollowers(state.value.id!)
                            .then((value) => followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) => Get.to(FollowingAndFollowers(
                                    true.obs, state.value.id!.obs))));

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
                                    color: ColorManager.dayNightText,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: followers,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorManager.dayNightText,
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
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '${state.value.likes == null || state.value.likes!.isEmpty ? 0 : state.value.likes}'
                                  '\n',
                              style: TextStyle(
                                  color: ColorManager.dayNightText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: likes,
                              style: TextStyle(
                                  color: ColorManager.dayNightText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ])),
                  ],
                ).w(MediaQuery.of(context).size.width * .80),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: state.value.bio.toString().isNotEmpty ||
                      state.value.bio.toString() != "null",
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            Uri openInBrowser = Uri(
                              scheme: 'https',
                              path: "${state.value.bio}",
                            );
                            launchUrl(openInBrowser,
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text(
                            state.value.bio.toString(),
                            maxLines: 3,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.dayNightText),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        Get.to(ManageAccount());
                      },
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColorManager.colorAccent),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.music_note,
                                    size: 18,
                                    color: ColorManager.dayNightIcon,
                                  ),
                                ),
                                const TextSpan(
                                    text: "  Edit Profile",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: ColorManager.colorAccent,
                                        fontSize: 18)),
                              ],
                            ),
                          )),
                    )),
                    // Expanded(child: Container(
                    //     margin: EdgeInsets.symmetric(horizontal: 10),
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //       borderRadius:
                    //       BorderRadius.circular(20),
                    //       border: Border.all(color: ColorManager.colorAccent),
                    //     ),
                    //     padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    //
                    //     child: InkWell(
                    //       onTap: () {
                    //         // Inbox inboxModel = InboxModel(
                    //         //     id: user.isProfileLoading
                    //         //         .value
                    //         //         ? 0
                    //         //         : user
                    //         //         .userProfile
                    //         //         .value
                    //         //         .data!
                    //         //         .user!
                    //         //         .id!,
                    //         //     userImage: user
                    //         //         .isProfileLoading
                    //         //         .value
                    //         //         ? ""
                    //         //         : user
                    //         //         .userProfile
                    //         //         .value
                    //         //         .data!
                    //         //         .user!
                    //         //         .avatar,
                    //         //     message: "",
                    //         //     msgDate: "",
                    //         //     name: user
                    //         //         .isProfileLoading
                    //         //         .value
                    //         //         ? ""
                    //         //         : user
                    //         //         .userProfile
                    //         //         .value
                    //         //         .data!
                    //         //         .user!
                    //         //         .name!);
                    //         // Get.to(ChatScreen(
                    //         //     inboxModel:
                    //         //     inboxModel));
                    //       },
                    //       child: const Text("Message",
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600,
                    //           )),
                    //     ))),
                    // ClipOval(
                    //   child: InkWell(
                    //       onTap: () {
                    //         Navigator.pushNamed(
                    //             context, '/referral');
                    //       },
                    //       child: Container(
                    //           margin: EdgeInsets.symmetric(horizontal: 10),
                    //           decoration:
                    //           BoxDecoration(
                    //               borderRadius: BorderRadius.circular(50),
                    //               color: Color.fromRGBO(73, 204, 201, 0.08)
                    //           ),
                    //
                    //           padding:
                    //           const EdgeInsets.all(15),
                    //           child: const Iconify(
                    //             Carbon.logo_instagram,
                    //             size: 16,
                    //           ))),
                    // ),
                    // ClipOval(
                    //   child: InkWell(
                    //       onTap: () {
                    //         Navigator.pushNamed(
                    //             context, '/referral');
                    //       },
                    //       child: Container(
                    //           margin: EdgeInsets.symmetric(horizontal: 10),
                    //           decoration:
                    //           BoxDecoration(
                    //               borderRadius: BorderRadius.circular(50),
                    //               color: Color.fromRGBO(73, 204, 201, 0.08)
                    //           ),
                    //
                    //           padding:
                    //           const EdgeInsets.all(15),
                    //           child: const Iconify(
                    //             Carbon.bookmark,
                    //             size: 16,
                    //           ))),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
        onLoading: loader(),
        onEmpty: Column(
          children: [emptyListWidget()],
        ),
        onError: (error) => SizedBox(
              width: Get.width,
              child: Center(
                child: Text(
                  "Oops nothing found",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.dayNightText),
                ),
              ),
            ));
  }
}

showComments({
  int? videoId,
  int? userId,
  RxBool? isCommentAllowed,
  int? isfollow,
  String? userName,
  String? avatar,
}) {
  Get.bottomSheet(
      CommentsScreen(
        videoId: videoId,
        userId: userId,
        isCommentAllowed: isCommentAllowed,
        isfollow: isfollow,
        userName: userName,
        avatar: avatar,
      ),
      backgroundColor: ColorManager.dayNight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
}

showReportDialog(int videoId, String name, int id) async {
  String dropDownValue = "Reason";
  List<String> dropDownValues = [
    "Reason",
  ];
  try {
    var response = await RestApi.getSiteSettings();
    var json = jsonDecode(response.body);
    if (json['status']) {
      List jsonList = json['data'] as List;
      for (var element in jsonList) {
        if (element['name'] == 'report_reason') {
          List reasonList = element['value'].toString().split(',');
          for (String reason in reasonList) {
            dropDownValues.add(reason);
          }
          break;
        }
      }
    } else {
      errorToast(json['message'].toString());
      return;
    }
  } catch (e) {
    Get.back();
    errorToast(e.toString());
    return;
  }
  showDialog(
      context: Get.context!,
      builder: (_) => StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      width: getWidth(context) * .80,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              "Report $name's Video ?",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            margin: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5)),
                            child: DropdownButton(
                              value: dropDownValue,
                              underline: Container(),
                              isExpanded: true,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: 35,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  dropDownValue = value ?? dropDownValues.first;
                                });
                              },
                              items: dropDownValues.map((String item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                              onPressed: dropDownValue == "Reason"
                                  ? null
                                  : () async {
                                      try {
                                        var response =
                                            await RestApi.reportVideo(
                                                videoId, id, dropDownValue);
                                        var json = jsonDecode(response.body);
                                        closeDialogue(context);
                                        if (json['status']) {
                                          //Navigator.pop(context);
                                          showSuccessToast(context,
                                              json['message'].toString());
                                        } else {
                                          //Navigator.pop(context);
                                          showErrorToast(context,
                                              json['message'].toString());
                                        }
                                      } catch (e) {
                                        closeDialogue(context);
                                        showErrorToast(context, e.toString());
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 5)),
                              child: const Text("Report"))
                        ],
                      )),
                ),
              );
            },
          ));
}
