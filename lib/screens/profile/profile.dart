import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/PrivateVideosController.dart';
import 'package:thrill/controller/videos/UserVideosController.dart';
import 'package:thrill/controller/videos/like_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/strings.dart';
import '../../controller/users/followers_controller.dart';
import '../../rest/rest_url.dart';

var selectedTab = 0.obs;

class Profile extends StatelessWidget {
  var likedVideosController = Get.find<LikedVideosController>();

  var userDetailController = Get.find<UserDetailsController>();
  Profile({Key? key, this.isProfile}) : super(key: key);

  RxBool? isProfile = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: ListView(
            shrinkWrap: true,
            children: [
              UserProfileDetails(),
              SizedBox(
                  height: Get.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => DefaultTabController(
                          length: 3,
                          initialIndex: selectedTab.value,
                          child: TabBar(
                              onTap: (int index) {
                                selectedTab.value = index;
                              },
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              indicatorColor: const Color(0XffB2E3E3),
                              indicatorPadding:
                                  const EdgeInsets.symmetric(horizontal: 30),
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
            ],
          ),
        ));
  }

  tabview() {
    if (selectedTab.value == 0) {
      return feed();
    } else if (selectedTab.value == 1) {
      Get.find<PrivateVideosController>().getUserPrivateVideos();
      return lock();
    } else {
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

  showDeleteVideoDialog(int videoID, List list, int index) {
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
                          "Are you sure you want to delete this video ?",
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
                          "This action will delete this video permanently and it cant be undone!",
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
                                try {
                                  Get.back();
                                  //       progressDialogue(context);
                                  var response =
                                      await RestApi.deleteVideo(videoID);
                                  var json = jsonDecode(response.body);
                                  //  closeDialogue(context);
                                  if (json['status']) {
                                    list.removeAt(index);
                                    showSuccessToast(Get.context!,
                                        json['message'].toString());
                                    await Get.find<VideosController>()
                                        .getUserVideos();
                                    await Get.find<VideosController>()
                                        .getAllVideos();
                                  } else {
                                    showErrorToast(Get.context!,
                                        json['message'].toString());
                                  }
                                } catch (e) {
                                  closeDialogue(Get.context!);
                                  showErrorToast(Get.context!, e.toString());
                                }
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
        (state) => Flexible(
              child: GridView.count(
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: Get.width / Get.height,
                children: List.generate(
                    state!.value.length,
                    (index) => GestureDetector(
                          onTap: () {
                            Get.to(VideoPlayerScreen(
                              isFav: false,
                              isFeed: true,
                              isLock: false,
                              position: index,
                              userVideos: state,
                            ));
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              imgNet(
                                  '${RestUrl.gifUrl}${state.value[index].gifImage}'),
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
                                                  state.value[index].views
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
            ),
        onLoading: loader(),
        onEmpty: SizedBox(
          height: Get.height / 2,
          child: Center(
            child: loader(),
          ),
        ),
        onError: (error) => emptyListWidget());
  }
}

class PrivateVideos extends GetView<PrivateVideosController> {
  const PrivateVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
        (state) => Flexible(
              child: GridView.count(
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: Get.width / Get.height,
                children: List.generate(
                    state!.length,
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
        onEmpty: emptyListWidget(),
        onError: (error) => emptyListWidget());
  }
}

class LikedVideos extends GetView<LikedVideosController> {
  LikedVideos({Key? key}) : super(key: key);
  var videosController = Get.find<VideosController>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx(
        (state) => Flexible(
                child: GridView.count(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              childAspectRatio: Get.width / Get.height,
              children: List.generate(
                  state!.value.length,
                  (index) => GestureDetector(
                        onTap: () {
                          Get.to(VideoPlayerScreen(
                            isFav: true,
                            isFeed: false,
                            isLock: false,
                            position: index,
                            likedVideos: state,
                          ));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imgNet('${RestUrl.gifUrl}${state[index].gifImage}'),
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
                                                  state[index].views.toString(),
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
                                    //     state!.value[index].id!,
                                    //     state!.value,
                                    //     index);
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
            )),
        onLoading: loader(),
        onEmpty: emptyListWidget(),
        onError: (error) => emptyListWidget());
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.person,
                            color: ColorManager.dayNightText,
                          )),
                      IconButton(
                          onPressed: () => Get.to(SettingAndPrivacy(
                              avatar: state!.value.avatar!,
                              name: state.value.name!,
                              userName: state.value.username!)),
                          icon: Icon(
                            Icons.settings,
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
                    imageUrl: state!.value.avatar.toString().isEmpty
                        ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                        : '${RestUrl.profileUrl}${state.value.avatar}',
                    placeholder: (a, b) => const Center(
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
                            .then((value) => followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) => Get.to(FollowingAndFollowers(
                                      isProfile: false.obs,
                                    ))));

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
                            .then((value) => followersController
                                .getUserFollowing(state.value.id!)
                                .then((value) => Get.to(FollowingAndFollowers(
                                      isProfile: false.obs,
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
                                  '${state.value.likes == null || state.value.likes!.isEmpty ? 0 : state.value.likes}'
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
                ).w(MediaQuery.of(context).size.width * .80),
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
        onEmpty: emptyListWidget(),
        onError: (error) => emptyListWidget());
  }
}
