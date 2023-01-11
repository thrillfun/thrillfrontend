import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart' as strings;
import 'package:thrill/controller/comments/comments_controller.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users/other_users_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/PrivateVideosController.dart';
import 'package:thrill/controller/videos/UserVideosController.dart';
import 'package:thrill/controller/videos/like_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../common/strings.dart';
import '../../controller/users/followers_controller.dart';
import '../../controller/videos/related_videos_controller.dart';
import '../../rest/rest_api.dart';
import '../../rest/rest_url.dart';
import '../../widgets/better_video_player.dart';
import '../auth/login_getx.dart';
import '../sound/sound_details.dart';

var selectedTab = 0.obs;

class Profile extends StatelessWidget {
  var likedVideosController = Get.find<LikedVideosController>();

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
          child: SingleChildScrollView(
            child: Flexible(
                child: Column(children: [
                  UserProfileDetails(),
                  SizedBox(
                      height: Get.height,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() =>
                              DefaultTabController(
                                  length: 3,
                                  initialIndex: selectedTab.value,
                                  child: TabBar(
                                      onTap: (int index) {
                                        selectedTab.value = index;
                                      },
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      indicatorColor: const Color(0XffB2E3E3),
                                      indicatorPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      tabs: [
                                        Tab(
                                          icon: Icon(
                                            Icons.dashboard,
                                            color: selectedTab.value == 0
                                                ? ColorManager.colorAccent
                                                : Get.isPlatformDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Tab(
                                          icon: Icon(
                                            Icons.lock,
                                            color: selectedTab.value == 1
                                                ? ColorManager.colorAccent
                                                : Get.isPlatformDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Tab(
                                          icon: Icon(
                                            Icons.favorite,
                                            color: selectedTab.value == 2
                                                ? ColorManager.colorAccent
                                                : Get.isPlatformDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        )
                                      ]))),
                          Obx(() => tabview()),
                        ],
                      ))
                ])),
          ),
        ));
  }

  tabview() {
    if (selectedTab.value == 0) {
      return feed();
    } else if (selectedTab.value == 1) {
      return lock();
    } else if (selectedTab.value == 2) {
      return fav();
    }
  }

  feed() {
    return UserVideos();
  }

  lock() {
    return PrivateVideos();
  }

  fav() => LikedVideos();

  showPrivate2PublicDialog(int videoID) {
    showDialog(
        context: Get.context!,
        builder: (_) =>
            Center(
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
                          style: Theme
                              .of(Get.context!)
                              .textTheme
                              .headline3,
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
                          style: Theme
                              .of(Get.context!)
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
            (_) =>
        controller.userVideos.isEmpty
            ? Flexible(
          child: Center(
            heightFactor: Get.height / 2,
            child: Text(
              "No videos yet",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.dayNightText),
            ),
          ),
        )
            : Flexible(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: Get.width / Get.height,
            children: List.generate(
                controller.userVideos!.length,
                    (index) =>
                    GestureDetector(
                      onTap: () {
                        Get.to(UserVideosScreen());
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imgNet(
                              '${RestUrl.gifUrl}${controller.userVideos
                                  .value[index].gifImage}'),
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
                                          .userVideos!.value[index].id!,
                                      controller.userVideos!.value,
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
          ),
        ),
        onLoading: loader(),
        onEmpty: Center(
          child: Text(
            "No videos yet",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColorManager.dayNightText),
          ),
        ),
        onError: (error) =>
            Center(
              child: Text(
                "$error",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.dayNightText),
              ),
            ));
    ;
  }

  showDeleteVideoDialog(int videoID, List list, int index) {
    showDialog(
        context: Get.context!,
        builder: (_) =>
            Center(
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
                          "Are you sure you want to delete this video ?",
                          style: Theme
                              .of(Get.context!)
                              .textTheme
                              .headline3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "This action will delete this video permanently and it cant be undone!",
                          style: Theme
                              .of(Get.context!)
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
                                Get.back();
                                controller.deleteVideo(videoID);
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

class PrivateVideos extends GetView<PrivateVideosController> {
  const PrivateVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
          (state) =>
      state!.isEmpty
          ? Flexible(
          child: Center(
            heightFactor: Get.height / 2,
            child: Text(
              "No private videos",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.dayNightText),
            ),
          ))
          : Flexible(
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: Get.width / Get.height,
          children: List.generate(
              state!.length,
                  (index) =>
                  GestureDetector(
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
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                      TextSpan(
                                          text: " " +
                                              state[index]
                                                  .views
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
                              icon: const Icon(
                                  Icons.published_with_changes_outlined)),
                        )
                      ],
                    ),
                  )),
        ),
      ),
      onLoading: loader(),
      onEmpty: Flexible(child: emptyListWidget()),
    );
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
            (state) =>
        controller.likedVideos.isEmpty
            ? Center(
          heightFactor: Get.height / 2,
          child: Text(
            "No videos yet",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColorManager.dayNightText),
          ),
        )
            : Flexible(
            child: GridView.count(
              padding: const EdgeInsets.all(10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              childAspectRatio: Get.width / Get.height,
              children: List.generate(
                  controller!.likedVideos.length,
                      (index) =>
                      GestureDetector(
                        onTap: () {
                          PublicUser publicUser = PublicUser(
                              id: controller.likedVideos[index].user!.id,
                              name: controller.likedVideos[index].user?.name
                                  .toString(),
                              username: controller
                                  .likedVideos[index].user?.username,
                              email:
                              controller.likedVideos[index].user?.email,
                              dob: controller.likedVideos[index].user?.dob,
                              phone:
                              controller.likedVideos[index].user?.phone,
                              avatar:
                              controller.likedVideos[index].user!.avatar,
                              socialLoginType: controller
                                  .likedVideos[index].user?.socialLoginType,
                              socialLoginId: controller
                                  .likedVideos[index].user?.socialLoginId,
                              firstName: controller
                                  .likedVideos[index].user?.firstName,
                              lastName: controller
                                  .likedVideos[index].user?.lastName,
                              gender:
                              controller.likedVideos[index].user?.gender,
                              isfollow:
                              controller.likedVideos[index].isfollow);

                          Get.to(VideoPlayerScreen(
                            isFeed:false,
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
                                '${RestUrl.gifUrl}${controller!
                                    .likedVideos[index].gifImage}'),
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
                                                      .likedVideos[index]
                                                      .views
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
            )),
        onLoading: loader(),
        onEmpty: Center(
          child: Text(
            "No videos yet",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColorManager.dayNightText),
          ),
        ),
        onError: (error) =>
            Center(
              child: Text(
                "$error",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.dayNightText),
              ),
            ));
  }

  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      current.value = preloadPageController!.page!.toInt();
      isOnPageTurning.value = false;
    } else if (!isOnPageTurning.value &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!.toDouble()).abs() >
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
            (state) =>
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () =>
                              Get.to(SettingAndPrivacy(
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
                  height: 20,
                ),
                Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: state!
                        .value.avatar
                        .toString()
                        .isEmpty
                        ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                        : '${RestUrl.profileUrl}${state.value.avatar}',
                    placeholder: (a, b) =>
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '@${state.value.username}',
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
                  '@${state.value.name}',
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
                            .then((value) =>
                            followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) =>
                                Get.to(FollowingAndFollowers(true.obs))));

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
                                    fontSize: 24,
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
                      height: 53,
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        followersController
                            .getUserFollowers(state.value.id!)
                            .then((value) =>
                            followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) =>
                                Get.to(FollowingAndFollowers(
                                  true.obs,
                                ))));

                        // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                      },
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${state.value.followers}'
                                    '\n',
                                style: TextStyle(
                                    fontSize: 24,
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
                      height: 53,
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
                              '${state.value.likes == null ||
                                  state.value.likes!.isEmpty ? 0 : state.value
                                  .likes}'
                                  '\n',
                              style: TextStyle(
                                  color: ColorManager.dayNightText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: likes,
                              style: TextStyle(
                                  color: ColorManager.dayNightText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ])),
                  ],
                ).w(MediaQuery
                    .of(context)
                    .size
                    .width * .80),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Container(
                //   margin: EdgeInsets.only(left: 10),
                //   alignment: Alignment.centerLeft,
                //   width: MediaQuery.of(context).size.width,
                //   child: Row(
                //     children: [
                //       const Icon(
                //         Icons.link,
                //         color: Colors.white,
                //       ),
                //       const SizedBox(
                //         width: 5,
                //       ),
                //       InkWell(
                //         onTap: () {
                //           Uri openInBrowser = Uri(
                //             scheme: 'https',
                //             path:
                //                 "${user.userProfile.data!.user!.websiteUrl}",
                //           );
                //           launchUrl(openInBrowser,
                //               mode: LaunchMode
                //                   .externalApplication);
                //         },
                //         child: Text(
                //           user.userProfile.data!.user!
                //               .websiteUrl,
                //           maxLines: 3,
                //           textAlign: TextAlign.start,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //               fontSize: 15,
                //               color: Colors.blue.shade300),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.to(ManageAccount());
                          },
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: ColorManager.colorAccent),
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
        onEmpty: emptyListWidget(),
        onError: (error) =>
            SizedBox(
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

class UserLikedVideoPlayer extends StatefulWidget {
  UserLikedVideoPlayer(this.dataMap);

  Map<String, dynamic>? dataMap;


  @override
  State<UserLikedVideoPlayer> createState() => _UserLikedVideoPlayerState();
}

class _UserLikedVideoPlayerState extends State<UserLikedVideoPlayer> {
  var likedVideosController = Get.find<LikedVideosController>();
  PageController? preloadPageController;
  var current = 0.obs;
  var related = 0.obs;
  var popular = 0.obs;
  var isOnPageTurning = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    preloadPageController = PageController();
    preloadPageController!.addListener(scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: likedVideosController.likedVideos.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          widget.dataMap![strings.pageIndex] = index;
          widget.dataMap![strings.currentPageIndex] = current.value;
          widget.dataMap![strings.isPaused] = isOnPageTurning.value;
          return UserLikedVideosScreen(widget.dataMap);
        });
  }

  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      setState(() {
        current.value = preloadPageController!.page!.toInt();
        isOnPageTurning.value = false;
      });
    } else if (!isOnPageTurning.value &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!.toDouble()).abs() >
          0.1) {
        setState(() {
          isOnPageTurning.value = true;
        });
      }
    }
  }
}

class UserLikedVideosScreen extends StatefulWidget {
  UserLikedVideosScreen(this.dataMap);

  Map<String, dynamic>? dataMap;

  @override
  State<UserLikedVideosScreen> createState() => _UserLikedVideosScreenState();
}

class _UserLikedVideosScreenState extends State<UserLikedVideosScreen> {
  VideoPlayerController? userLikedVideosController;
  var controller = Get.find<LikedVideosController>();
  var commentsController = Get.find<CommentsController>();
  var initialized = false.obs;
  var volume = 1.0.obs;
  var comment = "".obs;
  var isVideoPaused = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    userLikedVideosController = VideoPlayerController.network(
        RestUrl.videoUrl + widget.dataMap![strings.videoUrl])
      ..setLooping(false)
      ..initialize().then((value) {
        setState(() {
          initialized.value = true;
        });
      });
    super.initState();
  }
  @override
  void dispose() {
    if (initialized.value) {
      userLikedVideosController!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VisibilityDetector(
          key: const Key("key"),
          child: Stack(
            children: [
              GestureDetector(
                  onDoubleTap: () {},
                  onLongPressEnd: (_) {
                    widget.dataMap![strings.isPaused] = false.obs;
                  },
                  onTap: () {
                    if (volume.value == 1) {
                      volume.value = 0;
                    } else {
                      volume.value = 1;
                    }
                    userLikedVideosController!.setVolume(volume.value);
                  },
                  onLongPressStart: (_) {
                    widget.dataMap![strings.isPaused] = true.obs;
                  },
                  child: Stack(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          color: Colors.black,
                          child: AspectRatio(
                            aspectRatio: userLikedVideosController!
                                .value.aspectRatio,
                            child: ValueListenableBuilder(
                              valueListenable:
                              userLikedVideosController!,
                              builder: (context, VideoPlayerValue value,
                                  child) {
                                if (value.position == value.duration) {
                                  VideosController().postVideoView(
                                      widget.dataMap![strings.videoId]);
                                }
                                return VideoPlayer(
                                    VideoPlayerController.network(
                                        RestUrl.videoUrl +
                                            controller
                                                .likedVideos[widget.dataMap![strings
                                                .currentPageIndex]]
                                                .video
                                                .toString())
                                      ..initialize()
                                      ..play()!);
                              },
                            ),
                          )),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10, right: 20),
                              child: Column(
                                children: [
                                  LikeButton(
                                    countPostion: CountPostion.bottom,
                                    size: 28,
                                    circleColor: CircleColor(
                                        start: Colors.red.shade200,
                                        end: Colors.red),
                                    bubblesColor: BubblesColor(
                                      dotPrimaryColor: Colors.red.shade200,
                                      dotSecondaryColor: Colors.red,
                                    ),
                                    likeBuilder: (bool isLiked) {
                                      widget.dataMap![strings.videoLikeStatus] == "0"
                                          ? isLiked = false
                                          : isLiked = true;
                                      return Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_outline,
                                        color:
                                        isLiked ? Colors.red : Colors.white,
                                        size: 25,
                                      );
                                    },
                                    likeCount: widget.dataMap![strings.likeCounts],
                                    countBuilder: (int? count, bool isLiked,
                                        String text) {
                                      var color =
                                      isLiked ? Colors.white : Colors.white;
                                      Widget result;
                                      if (count == 0) {
                                        result = Text(
                                          "0",
                                          style: TextStyle(color: color),
                                        );
                                      } else
                                        result = Text(
                                          text,
                                          style: TextStyle(color: color),
                                        );
                                      return result;
                                    },
                                    onTap: (_) async =>
                                    await Get.find<
                                        RelatedVideosController>()
                                        .likeVideo(
                                        widget.dataMap![strings.videoLikeStatus] ==
                                            "0"
                                            ? 1
                                            : 0,
                                        widget.dataMap![strings.videoId]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        commentsController
                                            .getComments(
                                            widget.dataMap![strings.videoId])
                                            .then((value) {
                                          showComments();
                                        });
                                      },
                                      icon: const Icon(
                                        IconlyLight.chat,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                  Text(
                                    widget.dataMap![strings.commentsCount] != null
                                        ? "${widget.dataMap![strings.commentsCount]}"
                                        : "0",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 10, top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Share.share(
                                            'You need to watch this awesome video only on Thrill!!!');
                                      },
                                      icon: const Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 22,
                                      )),
                                  const Text(
                                    "Share",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 10, top: 10, bottom: 90),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Get.bottomSheet(
                                            Flexible(
                                                child: Container(
                                                  height: 300,
                                                  margin: const EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  child: Column(children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                          child: Column(
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  // VideoModel videModel = VideoModel(
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .id!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .comments!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .video!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .description!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .likes!,
                                                                  //     null,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .filter!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .gifImage!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .sound!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .soundName!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .soundCategoryName!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .views!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .speed!,
                                                                  //     [],
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .isDuet!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .duetFrom!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .isDuetable!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .isCommentable!,
                                                                  //     widget
                                                                  //         .publicVideos
                                                                  //         .soundOwner!);
                                                                  // Get.to(RecordDuet(
                                                                  //     videoModel:
                                                                  //     videModel));
                                                                },
                                                                icon: const Icon(
                                                                  IconlyLight
                                                                      .plus,
                                                                  color: ColorManager
                                                                      .colorAccent,
                                                                  size: 30,
                                                                ),
                                                              ),
                                                              const Text(
                                                                "Duet",
                                                                style: TextStyle(
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                          child: Column(
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () {
                                                                    if (widget.dataMap![strings
                                                                        .userId] ==
                                                                        GetStorage()
                                                                            .read(
                                                                            "user")[
                                                                        'id']) {
                                                                      //showDeleteDialog();
                                                                    }
                                                                  },
                                                                  icon: widget.dataMap![strings
                                                                      .userId] ==
                                                                      UserDetailsController()
                                                                          .userProfile
                                                                          .value
                                                                          .id
                                                                      ? const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: ColorManager
                                                                        .red,
                                                                  )
                                                                      : const Icon(
                                                                    Icons
                                                                        .save,
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                  )),
                                                              widget.dataMap![strings
                                                                  .userId] ==
                                                                  UserDetailsController()
                                                                      .userProfile
                                                                      .value
                                                                      .id
                                                                  ? const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                    color: ColorManager
                                                                        .red,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              )
                                                                  : const Text(
                                                                "Save",
                                                                style: TextStyle(
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                          child: Column(
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () async {
                                                                    var publicUser =
                                                                    widget.dataMap![strings
                                                                        .publicUser]
                                                                    as PublicUser;
                                                                    var deepLink = await userDetailsController
                                                                        .createDynamicLink(
                                                                        "${publicUser
                                                                            .id}",
                                                                        'profile',
                                                                        "${publicUser!
                                                                            .name}",
                                                                        "${publicUser!
                                                                            .avatar}");
                                                                    //         +
                                                                    // widget.publicUser!
                                                                    //         .name
                                                                    //         .toString() +
                                                                    // widget
                                                                    //     .publicUser!
                                                                    //     .avatar
                                                                    //     .toString()
                                                                    GetStorage()
                                                                        .write(
                                                                        "deeplink",
                                                                        deepLink
                                                                            .toString());
                                                                    Clipboard
                                                                        .setData(
                                                                        ClipboardData(
                                                                            text: deepLink
                                                                                .toString()));
                                                                    successToast(
                                                                        "Link copied!");
                                                                    //     widget.videoUrl));
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons.link,
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                  )),
                                                              const Text(
                                                                "Link",
                                                                style: TextStyle(
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                          child: Column(
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () {
                                                                    Get.back(
                                                                        closeOverlays:
                                                                        true);
                                                                    GallerySaver
                                                                        .saveVideo(
                                                                        RestUrl
                                                                            .videoUrl +
                                                                            widget.dataMap![strings
                                                                                .videoUrl])
                                                                        .then((
                                                                        value) =>
                                                                        showSuccessToast(
                                                                            context,
                                                                            "Video Saved Successfully"));
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .download,
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                  )),
                                                              const Text(
                                                                "Download",
                                                                style: TextStyle(
                                                                    color: ColorManager
                                                                        .colorAccent,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Divider(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () =>
                                                      GetStorage()
                                                          .read("token") !=
                                                          null
                                                          ? showReportDialog(
                                                          widget.dataMap![
                                                          strings.videoId],
                                                          widget.dataMap![
                                                          strings.userName],
                                                          widget.dataMap![
                                                          strings.userId])
                                                          : showLoginAlert(),
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.chat,
                                                            color:
                                                            Color(0xffFF2400),
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "Report...",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Color(
                                                                    0xffFF2400)),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (GetStorage()
                                                            .read("token")
                                                            .toString()
                                                            .isNotEmpty &&
                                                            GetStorage().read(
                                                                "token") !=
                                                                null) {
                                                          UserController()
                                                              .isUserBlocked(
                                                              widget.dataMap![strings
                                                                  .userId]);
                                                          Future
                                                              .delayed(
                                                              const Duration(
                                                                  seconds:
                                                                  1))
                                                              .then((value) =>
                                                          UserController()
                                                              .userBlocked
                                                              .value
                                                              ? UserController()
                                                              .blockUnblockUser(
                                                              widget.dataMap![
                                                              strings
                                                                  .userId],
                                                              "Unblock")
                                                              : UserController()
                                                              .blockUnblockUser(
                                                              widget.dataMap![
                                                              strings
                                                                  .userId],
                                                              "Block"));
                                                        } else {
                                                          showLoginAlert();
                                                        }
                                                      },
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.block,
                                                            color: ColorManager
                                                                .colorAccent,
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "Block User...",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: ColorManager
                                                                    .colorAccent),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        userDetailsController
                                                            .followUnfollowUser(
                                                            widget.dataMap![
                                                            strings.userId],
                                                            widget.dataMap![strings
                                                                .isFollow] ==
                                                                0
                                                                ? "follow"
                                                                : "unfollow");
                                                      },
                                                      child: Row(
                                                        children: [
                                                          widget.dataMap![strings
                                                              .isFollow] ==
                                                              0
                                                              ? const Icon(
                                                            Icons.add,
                                                            color: ColorManager
                                                                .colorAccent,
                                                            size: 30,
                                                          )
                                                              : const Icon(
                                                            Icons.add,
                                                            color: ColorManager
                                                                .colorAccent,
                                                            size: 30,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            widget.dataMap![strings
                                                                .isFollow] ==
                                                                0
                                                                ? "Follow"
                                                                : "Following",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: ColorManager
                                                                    .colorAccent),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                                )),
                                            backgroundColor:
                                            ColorManager.dayNight,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(15)),
                                            persistent: false);
                                      },
                                      icon: const Icon(
                                        IconlyBold.more_circle,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                  const Text(
                                    "More",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 90),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (GetStorage().read("token") != null) {
                                  var publicUser = widget.dataMap![strings.publicUser]
                                  as PublicUser;
                                  publicUser!.id ==
                                      UserDetailsController()
                                          .storage
                                          .read("userId")
                                      ? await UserVideosController()
                                      .getUserVideos()
                                      : await UserVideosController()
                                      .getOtherUserVideos(publicUser!.id!);
                                  publicUser!.id ==
                                      UserDetailsController()
                                          .storage
                                          .read("userId")
                                      ? await controller.getUserLikedVideos()
                                      : await controller.getOthersLikedVideos(
                                      publicUser!.id!);
                                  publicUser!.id ==
                                      UserDetailsController()
                                          .storage
                                          .read("userId")
                                      ? await userDetailsController
                                      .getUserProfile()
                                      .then((value) {
                                    Get.to(Profile(isProfile: true.obs));
                                  })
                                      : await OtherUsersController()
                                      .getOtherUserProfile(
                                      publicUser!.id!.obs)
                                      .then((value) {
                                    Get.to(ViewProfile(
                                        widget.dataMap![strings.userId]
                                            .toString(),
                                        widget.dataMap![strings.isFollow]!,
                                        widget.dataMap![strings.userName]
                                            .toString(),
                                        publicUser!.avatar.toString()));
                                  });
                                } else {
                                  Get.to(LoginGetxScreen());
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    alignment: Alignment.bottomLeft,
                                    width: 60,
                                    height: 60,
                                    child: CachedNetworkImage(
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                      imageUrl: (widget.dataMap![strings.publicUser]
                                      as PublicUser)
                                          .avatar ==
                                          null ||
                                          (widget.dataMap![strings.publicUser]
                                          as PublicUser)!
                                              .avatar!
                                              .isEmpty
                                          ? RestUrl.placeholderImage
                                          : RestUrl.profileUrl +
                                          (widget.dataMap![strings.publicUser]
                                          as PublicUser)!
                                              .avatar
                                              .toString(),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            (widget.dataMap![strings.publicUser]
                                            as PublicUser)
                                                .username ??
                                                "",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                            width: 10,
                                          ),
                                          Visibility(
                                            child: InkWell(
                                                onTap: () {
                                                  if (userDetailsController
                                                      .storage
                                                      .read("token") ==
                                                      null) {
                                                    errorToast(
                                                        "login to continue");
                                                  } else {
                                                    userDetailsController
                                                        .followUnfollowUser(
                                                        (widget.dataMap![strings
                                                            .publicUser]
                                                        as PublicUser)
                                                            .id!,
                                                        widget.dataMap![strings
                                                            .isFollow] ==
                                                            0
                                                            ? "follow"
                                                            : "unfollow");
                                                    Get.find<
                                                        LikedVideosController>()
                                                        .getUserLikedVideos();
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  child: Text(
                                                    widget.dataMap![strings
                                                        .isFollow] ==
                                                        0
                                                        ? "Follow"
                                                        : "Following",
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: ColorManager
                                                              .colorAccent),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5)),
                                                )),
                                            visible: widget.dataMap![strings.userId] !=
                                                UserDetailsController()
                                                    .storage
                                                    .read("userId"),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        (widget.dataMap![strings.publicUser]
                                        as PublicUser)
                                            .name
                                            .toString() ??
                                            "",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                widget.dataMap![strings.description],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Visibility(
                              visible: (widget.dataMap![strings.hashtagsList]
                              as List<dynamic>)
                                  .isNotEmpty,
                              child: Container(
                                height: 35,
                                margin:
                                const EdgeInsets.symmetric(horizontal: 10),
                                child: ListView.builder(
                                    itemCount: (widget.dataMap![strings.hashtagsList]
                                    as List<dynamic>)
                                        .length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) =>
                                        InkWell(
                                          onTap: () async {
                                            // await HashtagVideosController()
                                            //     .getVideosByHashTags((dataMap![strings.hashtagsList] as List<dynamic>)[index])
                                            //     .then((value) =>
                                            //     Get.to(() => HashTagsScreen(
                                            //       tagName: (dataMap![strings.hashtagsList])[index],
                                            //       videoCount: (dataMap![strings.hashtagsList] as List<dynamic>).length
                                            //           ,
                                            //     )));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: ColorManager.colorAccent,
                                                border: Border.all(
                                                    color: Colors.transparent),
                                                borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                            margin: const EdgeInsets.only(
                                                right: 5, top: 5, bottom: 5),
                                            padding: const EdgeInsets.all(5),
                                            alignment: Alignment.center,
                                            child: Text(
                                              (widget.dataMap![strings.hashtagsList]
                                              as List<dynamic>)[index]
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.to(SoundDetails(
                                    map: {
                                      "sound": widget.dataMap![strings.sound],
                                      "user": widget.dataMap![strings.soundOwner]
                                          .toString()
                                          .isEmpty
                                          ? widget.dataMap![strings.userName]
                                          : widget.dataMap![strings.soundOwner],
                                      "soundName": widget.dataMap![strings.soundName],
                                      "title": widget.dataMap![strings.soundOwner],
                                      "id": widget.dataMap![strings.videoId],
                                      "profile": (widget.dataMap![strings.publicUser]
                                      as PublicUser)
                                          .avatar,
                                      "name": (widget.dataMap![strings.publicUser]
                                      as PublicUser)
                                          .name,
                                      "sound_id": (widget.dataMap![strings
                                          .publicVideos]
                                      as PublicVideos)
                                          .id,
                                      "username": (widget.dataMap![strings.publicUser]
                                      as PublicUser)
                                          .username,
                                      "isFollow": widget.dataMap![strings.isFollow],
                                      "userProfile": (widget.dataMap![strings
                                          .publicUser]
                                      as PublicUser)
                                          .avatar ??
                                          RestUrl.placeholderImage
                                    },
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Lottie.network(
                                        "https://assets2.lottiefiles.com/packages/lf20_e3odbuvw.json",
                                        height: 50),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.dataMap![strings.soundName].isEmpty
                                        ? "Original Sound"
                                        : widget.dataMap![strings.soundName],
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              IgnorePointer(
                child: Visibility(
                  visible: userLikedVideosController!.value.volume <= 0,
                  child: Center(
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: ColorManager.colorAccent.withOpacity(0.5),
                          child: const Icon(
                            IconlyLight.volume_off,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ),
              IgnorePointer(
                child: Visibility(
                  visible: false,

                  ///isVideoPaused.value
                  child: Center(
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: ColorManager.colorAccent.withOpacity(0.5),
                          child: const Icon(
                            IconlyLight.play,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              )
            ],
          ),
          onVisibilityChanged: (VisibilityInfo info) {
            info.visibleFraction == 0
                ? userLikedVideosController!.setVolume(0)
                : userLikedVideosController!.setVolume(1);
          }),
    );
  }
}


showComments({int? videoId, int? userId,
  RxBool? isCommentAllowed,
  int? isfollow,
  String? userName, String? avatar,}) {
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
      builder: (_) =>
          StatefulBuilder(
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              "Report $name's Video ?",
                              style: Theme
                                  .of(context)
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
                                  dropDownValue =
                                      value ?? dropDownValues.first;
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
                                      borderRadius:
                                      BorderRadius.circular(10)),
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

class UserVideosScreen extends GetView<UserVideosController> {
  VideoPlayerController? userVideosController;

  @override
  Widget build(BuildContext context) {
    controller.userVideos.forEach((element) {
      userVideosController = VideoPlayerController.network(
          RestUrl.videoUrl + element.video.toString())
        ..initialize();
    });
    return ListView.builder(
        shrinkWrap: true,
        itemCount: controller.userVideos.length,
        itemBuilder: (context, index) => VideoPlayer(userVideosController!));
  }
}
