import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';

class ViewProfile extends StatelessWidget {
  var showFollowers = false.obs;
  var userController = Get.find<UserController>();
  var videosController = Get.find<VideosController>();
  var usersController = Get.find<UserController>();
  var selectedTab = 0.obs;

  User userModel = User.fromJson(GetStorage().read("user"));

  ViewProfile(this.userId);

  String? userId = "";

  @override
  Widget build(BuildContext context) {
    userController.getUserProfile(int.parse(userId.toString()));
    userController.getUserFollowers(int.parse(userId.toString()));
    userController.getUserFollowing(int.parse(userId.toString()));
    videosController.getOtherUserVideos(int.parse(userId.toString()));
    videosController.getOthersLikedVideos(int.parse(userId.toString()));

    return GetX<UserController>(
        builder: (user) => user.isProfileLoading.value ||
                user.isFollowingLoading.value ||
                user.isProfileLoading.value
            ? Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/splash_animation.gif',
                          ),
                          fit: BoxFit.cover)),
                  child: Center(
                    child: SizedBox(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        width: 200,
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                body: Stack(
                  alignment: Alignment.topLeft,
                  fit: StackFit.expand,
                  children: [
                    loadSvgCacheImage("background_2.svg"),
                    Container(
                      alignment: Alignment.topCenter,
                      margin:
                          const EdgeInsets.only(top: 40, left: 10, right: 10),
                      child: SvgPicture.asset(
                        "assets/background_profile_1.svg",
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            backgroundColor: Colors.transparent,
                            expandedHeight: Get.height/1.3,
                            bottom:  TabBar(
                              controller: TabController(length: 2, vsync: Scaffold.of(context)),
                                onTap: (int index) {
                                  selectedTab.value = index;
                                },
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50),
                                indicatorColor: Color(0XffB2E3E3),
                                indicatorPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 30),
                                tabs: [
                                  Tab(
                                    icon: SvgPicture.asset(
                                      'assets/feedTab.svg',
                                      color: selectedTab.value == 0
                                          ? Colors.white
                                          : Color(0XffB2E3E3),
                                    ),
                                  ),
                                  Tab(
                                    icon: SvgPicture.asset(
                                        'assets/favTab.svg',
                                        color: selectedTab.value == 1
                                            ? Colors.white
                                            : Color(0XffB2E3E3)),
                                  )
                                ]),
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.centerLeft,
                                            colors: [
                                              Color.fromARGB(25, 0, 204, 201),
                                              Color.fromARGB(10, 31, 33, 40)
                                            ]),
                                        border: Border.all(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(200))),
                                    width: 140,
                                    height: 140,
                                    child: Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      height: 100,
                                      width: 100,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: user.userProfile.value.data!
                                            .user!.avatar.isEmpty
                                            ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                                            : '${RestUrl.profileUrl}${user.userProfile.value.data!.user!.avatar}',
                                        placeholder: (a, b) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
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
                                        user.isProfileLoading.value
                                            ? "loading"
                                            : '@${user.userProfile.value.data!.user!.username}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Visibility(
                                          visible: user.userProfile.value.data!
                                              .user?.isVerified ==
                                              'true',
                                          child: SvgPicture.asset(
                                            'assets/verified.svg',
                                          ))
                                    ],
                                  ),
                                  Visibility(
                                    visible: showFollowers.value,
                                    child: SizedBox(
                                      height: 100,
                                      child: user.followersModel.value!.isEmpty
                                          ? Center(
                                          child: Text(
                                            "No Followers to Display!",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ))
                                          : ListView.builder(
                                        itemCount: user
                                            .followersModel.value!.length,
                                        scrollDirection: Axis.horizontal,
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          return GestureDetector(
                                            onTap: () {
                                              //Navigator.pushNamed(context, "/viewProfile", arguments: {"id":followerModelList[index].id, "getProfile":true});
                                            },
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(2),
                                                    margin: const EdgeInsets
                                                        .only(
                                                        right: 5,
                                                        left: 5),
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape
                                                            .circle,
                                                        border: Border.all(
                                                            color: ColorManager
                                                                .spinColorDivider)),
                                                    child: ClipOval(
                                                      child:
                                                      CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        errorWidget:
                                                            (a, b, c) =>
                                                            Padding(
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
                                                            ),
                                                        imageUrl:
                                                        '${RestUrl.profileUrl}${user.followersModel.value![index].avtars}',
                                                        placeholder: (a,
                                                            b) =>
                                                        const Center(
                                                          child:
                                                          CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                    width: 70,
                                                    child: Text(
                                                      user
                                                          .followersModel
                                                          .value![index]
                                                          .name!,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      textAlign: TextAlign
                                                          .center,
                                                    ))
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          usersController.isMyProfile.value =
                                          true;
                                          Get.to(FollowingAndFollowers(
                                            isProfile: false,
                                          ));
                                          // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                                        },
                                        child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: user.isProfileLoading
                                                      .value
                                                      ? "0"
                                                      : '${user.userProfile.value.data!.user!.following}'
                                                      '\n',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17)),
                                              const TextSpan(
                                                  text: following,
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ])),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          userController.userId.value = user
                                              .userProfile
                                              .value
                                              .data!
                                              .user!
                                              .id!;
                                          userController.isMyProfile.value =
                                          false;
                                          Get.to(FollowingAndFollowers(
                                            isProfile: false,
                                          ));

                                          // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                                        },
                                        child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: user.isProfileLoading
                                                      .value
                                                      ? ""
                                                      : '${user.userProfile.value.data!.user!.followers}'
                                                      '\n',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17)),
                                              const TextSpan(
                                                  text: followers,
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ])),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text:
                                                '${user.userProfile.value.data!.user!.likes!.isEmpty ? 0 : user.userProfile.value.data!.user!.likes}'
                                                    '\n',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17)),
                                            const TextSpan(
                                                text: likes,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ])),
                                    ],
                                  ).w(MediaQuery.of(context).size.width * .80),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, top: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      '${user.userProfile.value.data!.user!.name!.isNotEmpty ? user.userProfile.value.data!.user!.name! : 'anonymous'}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, top: 10, right: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      user.userProfile.value.data!.user!.bio!
                                          .isNotEmpty
                                          ? user.userProfile.value.data!.user!
                                          .bio!
                                          : '',
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
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
                                              path:
                                              "${user.userProfile.value.data!.user!.websiteUrl}",
                                            );
                                            launchUrl(openInBrowser,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          },
                                          child: Text(
                                            user.userProfile.value.data!.user!
                                                .websiteUrl,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue.shade300),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  userModel.id.toString() == userId
                                      ? Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 25,
                                            horizontal: 20),
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                50, 31, 33, 40),
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    200))),
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: InkWell(
                                                onTap: () async {
                                                  var pref =
                                                  await SharedPreferences
                                                      .getInstance();

                                                  var currentUser =
                                                  pref.getString(
                                                      'currentUser');

                                                  User current =
                                                  User.fromJson(
                                                      jsonDecode(
                                                          currentUser!));

                                                  Get.to(ManageAccount(
                                                      ));
                                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfile(user: userModel)));

                                                  // Navigator.pushNamed(
                                                  //     context, '/editProfile',
                                                  //     arguments:
                                                  //     current);
                                                },
                                                child: Container(
                                                    decoration:
                                                    const BoxDecoration(
                                                        gradient:
                                                        LinearGradient(
                                                            colors: [
                                                              Color(
                                                                  0xff5FAFFC),
                                                              Color(
                                                                  0xff2464D2)
                                                            ])),
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        15,
                                                        vertical: 15),
                                                    height: 60,
                                                    width: 60,
                                                    child: const Iconify(
                                                      Carbon.edit,
                                                      color: Colors.white,
                                                      size: 10,
                                                    )),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text("Edit Profile",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 25, horizontal: 20),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                50, 31, 33, 40),
                                            border: Border.all(
                                              color: Colors.transparent,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(
                                                    200))),
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                Referral()));
                                                  },
                                                  child: Container(
                                                      decoration: const BoxDecoration(
                                                          gradient:
                                                          LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xff9B67FB),
                                                                Color(
                                                                    0xff6E1DE9)
                                                              ])),
                                                      height: 60,
                                                      width: 60,
                                                      padding:
                                                      const EdgeInsets
                                                          .all(15),
                                                      child:
                                                      const Iconify(
                                                        Carbon.share,
                                                        color:
                                                        Colors.white,
                                                        size: 15,
                                                      ))),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text("Invite User",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 25, horizontal: 20),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                50, 31, 33, 40),
                                            border: Border.all(
                                              color: Colors.transparent,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(
                                                    200))),
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                decoration:
                                                const BoxDecoration(
                                                    gradient:
                                                    LinearGradient(
                                                        colors: [
                                                          Color(0xffFF87CF),
                                                          Color(0xffE968D9)
                                                        ])),
                                                width: 60,
                                                height: 60,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                Favourites()));
                                                  },
                                                  child: Container(
                                                      padding:
                                                      const EdgeInsets
                                                          .all(15),
                                                      child:
                                                      const Iconify(
                                                        Carbon.star,
                                                        color:
                                                        Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                              "Favourite",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          ClipOval(
                                            child: InkWell(
                                              onTap: () {
                                                // Inbox inboxModel = InboxModel(
                                                //     id: user.isProfileLoading
                                                //         .value
                                                //         ? 0
                                                //         : user
                                                //         .userProfile
                                                //         .value
                                                //         .data!
                                                //         .user!
                                                //         .id!,
                                                //     userImage: user
                                                //         .isProfileLoading
                                                //         .value
                                                //         ? ""
                                                //         : user
                                                //         .userProfile
                                                //         .value
                                                //         .data!
                                                //         .user!
                                                //         .avatar,
                                                //     message: "",
                                                //     msgDate: "",
                                                //     name: user
                                                //         .isProfileLoading
                                                //         .value
                                                //         ? ""
                                                //         : user
                                                //         .userProfile
                                                //         .value
                                                //         .data!
                                                //         .user!
                                                //         .name!);
                                                // Get.to(ChatScreen(
                                                //     inboxModel:
                                                //     inboxModel));
                                              },
                                              child: Container(
                                                  decoration:
                                                  const BoxDecoration(
                                                      gradient:
                                                      LinearGradient(
                                                          colors: [
                                                            Color(0xff5FAFFC),
                                                            Color(0xff2464D2)
                                                          ])),
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 15),
                                                  height: 60,
                                                  width: 60,
                                                  child: const Iconify(
                                                    Carbon.chat,
                                                    color: Colors.white,
                                                    size: 10,
                                                  )),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text("Message",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ClipOval(
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context,
                                                      '/referral');
                                                },
                                                child: Container(
                                                    decoration:
                                                    const BoxDecoration(
                                                        gradient:
                                                        LinearGradient(
                                                            colors: [
                                                              Color(
                                                                  0xff9B67FB),
                                                              Color(
                                                                  0xff6E1DE9)
                                                            ])),
                                                    height: 60,
                                                    width: 60,
                                                    padding:
                                                    const EdgeInsets
                                                        .all(15),
                                                    child: const Iconify(
                                                      Carbon.share,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ))),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text("Share Profile",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white))
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),

                            ),
                          )
                        ];
                      },
                      body: SizedBox(
                        height: getHeight(context),
                        width: getWidth(context),
                        child: Column(
                          children: [
                            DefaultTabController(
                              length: 2,
                              initialIndex: selectedTab.value,
                              child: DecoratedBox(
                                decoration: BoxDecoration(),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            tabview()
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   width: Get.width,
                    //   height: Get.height,
                    //   alignment: Alignment.topLeft,
                    //   child: IconButton(
                    //       onPressed: () {
                    //         Get.back(closeOverlays: true);
                    //       },
                    //       color: Colors.white,
                    //       icon: const Icon(Icons.arrow_back)),
                    // )
                    //
                  ],
                ),
              ));
  }

  tabview() {
    if (selectedTab.value == 0) {
      return feed();
    } else {
      return fav();
    }
  }

  feed() {
    return GetX<VideosController>(
        builder: (videosController) => videosController.videosLoading.value
            ? const Flexible(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : Flexible(
                child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemCount: videosController.otherUserVideos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
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
                                      videosController.otherUserVideos.isEmpty
                                          ? "0"
                                          : videosController.otherUserVideos
                                              .value[index].views
                                              .toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
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
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      );
                    }),
              ));
  }

  fav() {
    return GetX<VideosController>(
        builder: (videosController) => videosController.isLoading.value
            ? const Flexible(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : videosController.othersLikedVideos.isEmpty
                ? GetX<UserController>(
                    builder: (userController) => RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          const TextSpan(
                              text: '\n\n\n'
                                  "This user's liked videos or private",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '\n\n'
                                  "Videos liked by @${userController.userProfile.value.data!.user!.username!.isNotEmpty ? userController.userProfile.value.data!.user!.username! : 'anonymous'} are currently hidden",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.grey))
                        ])))
                : Flexible(
                    child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        itemCount: videosController.likedVideos.value.length,
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
                                // CachedNetworkImage(
                                //     placeholder: (a, b) => const Center(
                                //       child: CircularProgressIndicator(),
                                //     ),
                                //     fit: BoxFit.cover,
                                //     imageUrl:favVideos[index].gif_image.isEmpty
                                //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                                //         : '${RestUrl.gifUrl}${favVideos[index].gif_image}'),
                                imgNet(
                                    '${RestUrl.gifUrl}${videosController.likedVideos.value[index].gifImage}'),
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
                                              .likedVideos.value[index].views
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
                                              .likedVideos.value[index].likes
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          );
                        }),
                  ));
  }
}
