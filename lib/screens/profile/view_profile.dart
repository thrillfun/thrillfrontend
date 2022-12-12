import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/radix_icons.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_player_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';

var usersController = Get.find<UserController>();
class ViewProfile extends StatelessWidget {
  var showFollowers = false.obs;
  var userController = Get.find<UserController>();
  var usersController = Get.find<UserController>();
  var selectedTab = 0.obs;
  var videosController = Get.find<VideosController>();


  ViewProfile(this.userId,this.isFollow,this.profileName);

  String? userId = "";
  RxInt? isFollow=0.obs;
  String? profileName;

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
        body: GetX<UserController>(builder: (usersController)=>usersController.isProfileLoading.isTrue?Center(child: loader(),):
            ListView(
          children: [
            Container(
              height: Get.height,
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      imageUrl: usersController
                          .otherProfile.value.avatar!.isEmpty
                          ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                          : '${RestUrl.profileUrl}${usersController.otherProfile!.value.avatar}',
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
                        '@${usersController.otherProfile.value.username}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Visibility(
                          visible: usersController.otherProfile.value
                              .isVerified ==
                              'true',
                          child: SvgPicture.asset(
                            'assets/verified.svg',
                          ))
                    ],
                  ),
                  Text(
                    '@${usersController.otherProfile.value.name}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Visibility(
                    visible: showFollowers.value,
                    child: SizedBox(
                      height: 100,
                      child: usersController.followersModel.value!.isEmpty
                          ? Center(
                          child: Text(
                            "No Followers to Display!",
                            style: Theme.of(context)
                                .textTheme
                                .headline3,
                          ))
                          : ListView.builder(
                        itemCount:
                        usersController.followersModel.value!.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15),
                        itemBuilder:
                            (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              //Navigator.pushNamed(context, "/viewProfile", arguments: {"id":followerModelList[index].id, "getProfile":true});
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding:
                                    const EdgeInsets.all(2),
                                    margin:
                                    const EdgeInsets.only(
                                        right: 5, left: 5),
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: ColorManager
                                                .spinColorDivider)),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (a, b, c) =>
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(10.0),
                                              child:
                                              SvgPicture.asset(
                                                'assets/profile.svg',
                                                width: 10,
                                                height: 10,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                        imageUrl:
                                        '${RestUrl.profileUrl}${usersController.followersModel.value![index].avtars}',
                                        placeholder: (a, b) =>
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
                                      usersController.followersModel
                                          .value![index].name!,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign:
                                      TextAlign.center,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          usersController.isMyProfile.value = true;
                          usersController
                              .getUserFollowers(usersController
                              .otherProfile.value.id!)
                              .then((value) => usersController
                              .getUserFollowing(usersController
                              .otherProfile.value.id!)
                              .then((value) =>
                              Get.to(FollowingAndFollowers(
                                isProfile: false.obs,
                              ))));
                          // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                        },
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                  '${usersController.otherProfile.value.following}'
                                      '\n',
                                  style: TextStyle(
                                      color: Get.isPlatformDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 24,
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
                      SizedBox(
                        height: 53,
                        child: VerticalDivider(
                          thickness: 1,
                          width: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          usersController.userId.value =
                          usersController.otherProfile.value.id!;
                          usersController.isMyProfile.value = false;
                          usersController
                              .getUserFollowers(usersController
                              .otherProfile.value.id!)
                              .then((value) => usersController
                              .getUserFollowing(usersController
                              .otherProfile.value.id!)
                              .then((value) =>
                              Get.to(FollowingAndFollowers(
                                isProfile: false.obs,
                              ))));

                          // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                        },
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                  '${usersController.otherProfile.value.followers}'
                                      '\n',
                                  style: TextStyle(
                                      fontSize: 24,
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
                                '${usersController.otherProfile.value.likes!.isEmpty ? 0 : usersController.otherProfile.value.likes}'
                                    '\n',
                                style: TextStyle(
                                    color: Get.isPlatformDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 24,
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
                  const SizedBox(
                    height: 20,
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(left: 10, top: 10),
                  //   width: MediaQuery.of(context).size.width,
                  //   child: Text(
                  //     '${user.otherProfile.data!.user!.name!.isNotEmpty ? user.otherProfile.data!.user!.name! : 'anonymous'}',
                  //     style: const TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white),
                  //     textAlign: TextAlign.start,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  // Container(
                  //   margin: const EdgeInsets.only(
                  //       left: 10, top: 10, right: 10),
                  //   width: MediaQuery.of(context).size.width,
                  //   child: Text(
                  //     user.otherProfile.data!.user!.bio!
                  //             .isNotEmpty
                  //         ? user
                  //             .otherProfile.data!.user!.bio!
                  //         : '',
                  //     maxLines: 2,
                  //     style: const TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white),
                  //     textAlign: TextAlign.start,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
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
                  //                 "${user.otherProfile.data!.user!.websiteUrl}",
                  //           );
                  //           launchUrl(openInBrowser,
                  //               mode: LaunchMode
                  //                   .externalApplication);
                  //         },
                  //         child: Text(
                  //           user.otherProfile.data!.user!
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
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  color: ColorManager.colorAccent),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: InkWell(
                                onTap: () {
                                  usersController.followUnfollowUser(usersController.otherProfile.value.id!,isFollow!.value ==0?"follow":"unfollow");
                                },
                                child: const Text("Follow",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ))),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                    color: ColorManager.colorAccent),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: InkWell(
                                onTap: () {
                                  var inboxModel = Inbox(
                                      id:  userController
                                          .otherProfile
                                          .value
                                          .id!,
                                      userImage:  userController
                                          .otherProfile
                                          .value
                                          .avatar!,
                                      message: "",
                                      name: userController
                                          .otherProfile
                                          .value
                                          .name!);
                                  Get.to(ChatScreen(
                                      inboxModel:
                                      inboxModel));
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
                              Navigator.pushNamed(
                                  context, '/referral');
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(50),
                                    color: ColorManager.colorAccentTransparent),
                                padding: const EdgeInsets.all(15),
                                child:  Iconify(
                                  Carbon.logo_instagram,
                                  size: 16,
                                  color: ColorManager.dayNightIcon,
                                ))),
                      ),
                      ClipOval(
                        child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/referral');
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(50),
                                    color: ColorManager.colorAccentTransparent),
                                padding: const EdgeInsets.all(15),
                                child:  Iconify(
                                  Carbon.bookmark,
                                  size: 16,
                                  color: ColorManager.dayNightIcon,
                                ))),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DefaultTabController(
                      length: 2,
                      initialIndex: selectedTab.value,
                      child: TabBar(
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
                              icon: Iconify(
                                RadixIcons.dashboard,
                                color: selectedTab.value == 0
                                    ? ColorManager.colorAccent
                                    : Get.isPlatformDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Tab(
                              icon: Iconify(
                                Carbon.favorite,
                                color: selectedTab.value == 1
                                    ? ColorManager.colorAccent
                                    : Get.isPlatformDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )
                          ]))),
                  Obx(() => tabview()),
                ],
              ),
            )
          ],
        ),) );
  }

  tabview() {
    if (selectedTab.value == 0) {
      return feed();
    } else {
      return fav();
    }
  }

  feed() {
    return Flexible(

      child:GetX<VideosController>(builder: (videosController)=>
      videosController.isUserVideosLoading.isTrue?loader():
      videosController.otherUserVideos.isEmpty?RichText(
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
          ])):GridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: Get.width / Get.height,
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
                userVideos:
                videosController.otherUserVideos,
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
                              : videosController
                              .otherUserVideos
                              .value[index]
                              .views
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
                          videosController.otherUserVideos
                              .value.isEmpty
                              ? "0"
                              : videosController
                              .otherUserVideos
                              .value[index]
                              .likes
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
      child: GetX<VideosController>(builder: (videosController)=>
      videosController.isUserVideosLoading.isTrue?loader():
      videosController.othersLikedVideos.isEmpty?RichText(
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
                style:
                TextStyle(fontSize: 17, color: Colors.grey))
          ])) :
          GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: Get.width / Get.height,
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
                  likedVideos:
                  videosController.othersLikedVideos,
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
                                .othersLikedVideos[index]
                                .views
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
                                .othersLikedVideos[index]
                                .likes
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
      ),)
    );
  }
}
