import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/octicon.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/strings.dart';
import '../../rest/rest_url.dart';

var videosController = Get.find<VideosController>();

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  var selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: SvgPicture.asset(
              "assets/background_2.svg",
              fit: BoxFit.fill,
              height: Get.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          User.fromJson(GetStorage().read("user")).id != null
              ? GetX<UserController>(
                  builder: (usersController) => usersController
                          .isProfileLoading.value
                      ?  Center(
                          child: loader(),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              child: SvgPicture.asset(
                                "assets/background_2.svg",
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 50, left: 10, right: 10),
                                      child: SvgPicture.asset(
                                        "assets/background_profile_1.svg",
                                        fit: BoxFit.fill,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 60),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      Get.to(SettingAndPrivacy(
                                                        avatar: User.fromJson(GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                    .avatar !=
                                                                null
                                                            ? User.fromJson(
                                                                    GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                .avatar!
                                                            : RestUrl
                                                                .placeholderImage,
                                                        name: User.fromJson(GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                    .name !=
                                                                null
                                                            ? User.fromJson(
                                                                    GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                .name!
                                                            : "",
                                                        userName: User.fromJson(
                                                                        GetStorage().read(
                                                                            "user"))
                                                                    .username !=
                                                                null
                                                            ? User.fromJson(
                                                                    GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                .username!
                                                            : "",
                                                      ));
                                                      //       Navigator.pushNamed(context, "/setting");
                                                    },
                                                    icon: const Iconify(
                                                      Carbon
                                                          .overflow_menu_vertical,
                                                      color: Colors.white,
                                                    ))
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.transparent,
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                200))),
                                                width: 170,
                                                height: 170,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SvgPicture.network(
                                                      RestUrl.assetsUrl +
                                                          "profile_circle.svg",
                                                      fit: BoxFit.fill,
                                                      height: Get.height,
                                                      width: Get.width,
                                                    ),
                                                    SvgPicture.network(
                                                      RestUrl.assetsUrl +
                                                          "profile_circle_2.svg",
                                                      width: 130,
                                                      height: 130,
                                                      fit: BoxFit.fill,
                                                    ),
                                                    Container(
                                                        height: 100,
                                                        width: 100,
                                                        child: User.fromJson(GetStorage()
                                                                        .read(
                                                                            "user"))
                                                                    .avatar !=
                                                                null
                                                            ? ClipOval(
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: User.fromJson(GetStorage().read("user"))
                                                                              .avatar!
                                                                              .isEmpty ||
                                                                          User.fromJson(GetStorage().read("user")).avatar ==
                                                                              null
                                                                      ? "https://ttensports.com/wp-content/uploads/1982/02/person-placeholder.jpg"
                                                                      : '${RestUrl.profileUrl}${User.fromJson(GetStorage().read("user")).avatar}',
                                                                  placeholder: (a,
                                                                          b) =>
                                                                       Center(
                                                                    child:
                                                                        loader(),
                                                                  ),
                                                                ),
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  'assets/profile.svg',
                                                                  width: 10,
                                                                  height: 10,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )),
                                                    // Container(
                                                    //   height: 120,
                                                    //   width: 120,
                                                    //   child: CircularProgressIndicator(
                                                    //     value: double.parse(
                                                    //         usersController.userModel.value.levels!.current
                                                    //         .toString()),
                                                    //     backgroundColor:
                                                    //     Colors.transparent,
                                                    //     valueColor:
                                                    //     AlwaysStoppedAnimation<Color>(
                                                    //         Colors.purple),
                                                    //     color: Colors.green,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              )
                                              // Expanded(
                                              //   child:
                                              // )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 5, top: 5),
                                                child: Text(
                                                  User.fromJson(GetStorage()
                                                                  .read("user"))
                                                              .username !=
                                                          null
                                                      ? "@" +
                                                          User.fromJson(
                                                                  GetStorage()
                                                                      .read(
                                                                          "user"))
                                                              .username!
                                                      : "",
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              User.fromJson(GetStorage()
                                                              .read("user"))
                                                          .isVerified !=
                                                      null
                                                  ? User.fromJson(GetStorage()
                                                              .read("user"))
                                                          .isVerified!
                                                          .contains('1')
                                                      ? SvgPicture.asset(
                                                          'assets/verified.svg',
                                                        )
                                                      : const SizedBox(width: 2)
                                                  : Container(),
                                            ],
                                          ),
                                          Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(
                                                  bottom: 20, top: 10),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                        path:
                                                            "${User.fromJson(GetStorage().read("user")).websiteUrl}",
                                                      );
                                                      launchUrl(openInBrowser,
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    },
                                                    child: Text(
                                                      User.fromJson(GetStorage()
                                                                      .read(
                                                                          "user"))
                                                                  .websiteUrl !=
                                                              null
                                                          ? User.fromJson(
                                                                  GetStorage()
                                                                      .read(
                                                                          "user"))
                                                              .websiteUrl!
                                                          : "",
                                                      maxLines: 3,
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors
                                                              .blue.shade300),
                                                    ),
                                                  )
                                                ],
                                              )),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    usersController!
                                                        .isMyProfile!
                                                        .value = true;
                                                    selectedTabIndex.value = 1;

                                                    Get.to(
                                                        FollowingAndFollowers(
                                                      isProfile: true,
                                                    ));
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          '${User.fromJson(GetStorage().read("user")).following == null || User.fromJson(GetStorage().read("user")).following!.isEmpty ? 0 : User.fromJson(GetStorage().read("user")).following}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(following,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, right: 15),
                                                height: 40,
                                                width: 1,
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    usersController!
                                                        .isMyProfile!
                                                        .value = true;
                                                    selectedTabIndex.value = 0;

                                                    Get.to(
                                                        FollowingAndFollowers(
                                                      isProfile: true,
                                                    ));
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          '${User.fromJson(GetStorage().read("user")).followers == null || User.fromJson(GetStorage().read("user")).followers!.isEmpty ? 0 : User.fromJson(GetStorage().read("user")).followers}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(followers,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, right: 15),
                                                height: 40,
                                                width: 1,
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                      '${User.fromJson(GetStorage().read("user")).likes == null || User.fromJson(GetStorage().read("user")).likes!.isEmpty ? 0 : User.fromJson(GetStorage().read("user")).likes}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(likes,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      User.fromJson(GetStorage()
                                                              .read("user"))
                                                          .name
                                                          .toString(),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 20),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      User.fromJson(GetStorage()
                                                                      .read(
                                                                          "user"))
                                                                  .bio ==
                                                              null
                                                          ? ""
                                                          : User.fromJson(
                                                                  GetStorage()
                                                                      .read(
                                                                          "user"))
                                                              .bio!,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.5)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Obx(() => DefaultTabController(
                                              length: 3,
                                              initialIndex: selectedTab.value,
                                              child: TabBar(
                                                  unselectedLabelColor:
                                                      Color(0xff333742),
                                                  onTap: (int index) {
                                                    selectedTab.value = index;
                                                  },
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 0,
                                                      vertical: 0),
                                                  indicatorColor: Colors.white,
                                                  indicatorPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                  tabs: [
                                                    Tab(
                                                      icon: SvgPicture.asset(
                                                        'assets/feedTab.svg',
                                                        color:
                                                            selectedTab.value ==
                                                                    0
                                                                ? Colors.white
                                                                : const Color(
                                                                    0XffB2E3E3),
                                                      ),
                                                    ),
                                                    Tab(
                                                      icon: Icon(Icons.lock,
                                                          color: selectedTab
                                                                      .value ==
                                                                  1
                                                              ? Colors.white
                                                              : const Color(
                                                                  0XffB2E3E3)),
                                                    ),
                                                    Tab(
                                                      icon: Icon(Icons.favorite,
                                                          color: selectedTab
                                                                      .value ==
                                                                  2
                                                              ? Colors.white
                                                              : const Color(
                                                                  0XffB2E3E3)),
                                                    )
                                                  ]))),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Obx(() => tabview())
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                )
              : Center(
                  child: loader(),
                )
        ],
      ),
    );
  }

  tabview() {
    if (selectedTab.value == 0) {
      videosController.getUserVideos();
      return feed();
    } else if (selectedTab.value == 1) {
      videosController.getUserPrivateVideos();

      return lock();
    } else {
      videosController.getUserLikedVideos();

      return fav();
    }
  }

  feed() {
    return GetX<VideosController>(
        builder: ((videoModelsController) => videoModelsController
                .isUserVideosLoading.value
            ?  Center(
                child: loader(),
              )
            : videoModelsController.userVideosList.isEmpty
                ? RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(children: [
                      TextSpan(
                          text: '\n\n\n' "User's Public Video",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: '\n\n'
                              "Public Videos are currently not available",
                          style: TextStyle(fontSize: 16, color: Colors.grey))
                    ]))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemCount: videoModelsController.userVideosList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(VideoPlayerScreen(
                            isFav: false,
                            isFeed: true,
                            isLock: false,
                            position: index,
                            userVideos: videoModelsController.userVideosList,
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
                            //     imageUrl:publicList[index].gif_image.isEmpty
                            //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                            //         : '${RestUrl.gifUrl}${publicList[index].gif_image}'),
                            imgNet(
                                '${RestUrl.gifUrl}${videoModelsController.userVideosList[index].gifImage}'),
                            Positioned(
                                bottom: 5,
                                left: 5,
                                right: 5,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Iconify(
                                      Octicon.eye,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      videoModelsController
                                          .userVideosList[index].views
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                    const Icon(
                                      IconlyBold.heart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      videoModelsController
                                          .userVideosList[index].likes
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                )),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                  onPressed: () {
                                    showDeleteVideoDialog(
                                        videoModelsController
                                            .userVideosList[index].id!,
                                        videoModelsController.userVideosList,
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
                      );
                    })));
  }

  lock() => GetX<VideosController>(
      builder: (videosController) => videosController.privateVideosList.isEmpty
          ? RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(children: [
                TextSpan(
                    text: '\n\n\n' "User's Private Video",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '\n\n'
                        "Private Videos are currently not available",
                    style: TextStyle(fontSize: 17, color: Colors.white))
              ]))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: videosController.privateVideosList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(VideoPlayerScreen(
                      isFav: false,
                      isFeed: false,
                      isLock: true,
                      position: index,
                      privateVideos: videosController.privateVideosList!,
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
                          '${RestUrl.gifUrl}${videosController.privateVideosList[index].gifImage}'),
                      Positioned(
                          bottom: 5,
                          left: 5,
                          right: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                videosController.privateVideosList[index].views
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              const Icon(
                                IconlyBold.heart,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                videosController.privateVideosList[index].likes
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          )),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                            onPressed: () {
                              showDeleteVideoDialog(
                                  videosController
                                      .privateVideosList![index].id!,
                                  videosController.privateVideosList,
                                  index);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.red,
                            icon: const Icon(Icons.delete_forever_outlined)),
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
                );
              }));

  fav() {
    return GetX<VideosController>(
        builder: (videosController) =>videosController.isLikedVideosLoading.value ?Center(child: loader(),): videosController.likedVideos.isEmpty
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
            : GridView.builder(
                padding: const EdgeInsets.all(10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: videosController.likedVideos.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(VideoPlayerScreen(
                        isFav: true,
                        isFeed: false,
                        isLock: false,
                        position: index,
                        likedVideos: videosController.likedVideos,
                      ));
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imgNet(
                            '${RestUrl.gifUrl}${videosController.likedVideos[index].gifImage}'),
                        Positioned(
                            bottom: 5,
                            left: 5,
                            right: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Iconify(
                                  Octicon.eye,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  videosController.likedVideos[index].views
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                const Icon(
                                  IconlyBold.heart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  videosController.likedVideos[index].likes
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ))
                      ],
                    ),
                  );
                }));
  }

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

                                    videosController.getUserVideos();
                                    videosController.getAllVideos();
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
