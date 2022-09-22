import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/follower_model.dart';
import '../../models/user.dart';
import '../../models/video_model.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

class ViewProfile extends StatelessWidget {
  var showFollowers = false.obs;
  var userController = Get.find<UserController>();

  var selectedTab = 0.obs;
  ViewProfile({Key? key, required this.mapData, this.userId}) : super(key: key);
  final Map mapData;
  String? userId = "";
  @override
  Widget build(BuildContext context) {
    userController.getUserProfile(usersController.userId.value);
    userController.getUserFollowers(usersController.userId.value);
    userController.getUserFollowing(usersController.userId.value);
    videosController.getUserLikedVideos(usersController.userId.value);
    videosController.getOtherUserVideos(usersController.userId.value);

    return GetX<UserController>(
        builder: (user) => user.isProfileLoading.value
            ? Container(
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
              )
            : Scaffold(
                appBar: AppBar(
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(gradient: gradient),
                  ),
                  elevation: 0.5,
                  title: Text(
                    user.userProfile.value.data!.user?.name ?? " ",
                    style: const TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                      onPressed: () {
                        Get.back(closeOverlays: true);
                      },
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back)),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        // try {
                        //   progressDialogue(context);
                        //   var response =
                        //       await RestApi.checkBlock(userModel!.id);
                        //   var json = jsonDecode(response.body);
                        //   closeDialogue(context);
                        //   showReportAndBlock(json['status']);
                        // } catch (e) {
                        //   closeDialogue(context);
                        //   showErrorToast(context, e.toString());
                        // }
                      },
                      color: Colors.grey,
                      icon: const Icon(Icons.report_gmailerrorred_outlined),
                    ),
                  ],
                ),
                body: videosController.videosLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF171D22),
                              Color(0xff143035),
                              Color(0xff171D23)
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 40, left: 10, right: 10),
                              child: Image.asset(
                                "assets/background_stars.png",
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            SingleChildScrollView(
                              child: SizedBox(
                                height: getHeight(context),
                                width: getWidth(context),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      height: 115,
                                      width: 115,
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
                                    SizedBox(
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
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SvgPicture.asset(
                                          'assets/verified.svg',
                                        )
                                      ],
                                    ),
                                    Visibility(
                                      visible: showFollowers.value,
                                      child: SizedBox(
                                        height: 100,
                                        child: user
                                                .followersModel.value!.isEmpty
                                            ? Center(
                                                child: Text(
                                                "No Followers to Display!",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                              ))
                                            : ListView.builder(
                                                itemCount: user.followersModel
                                                    .value!.length,
                                                scrollDirection:
                                                    Axis.horizontal,
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
                                                            margin:
                                                                const EdgeInsets
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
                                                                fit: BoxFit
                                                                    .cover,
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
                                                              textAlign:
                                                                  TextAlign
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
                                            Get.to(FollowingAndFollowers());
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
                                            Get.to(FollowingAndFollowers());

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
                                    ).w(MediaQuery.of(context).size.width *
                                        .80),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 10, top: 10),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            ClipOval(
                                              child: InkWell(
                                                onTap: () {
                                                  InboxModel inboxModel = InboxModel(
                                                      id: user.isProfileLoading
                                                              .value
                                                          ? 0
                                                          : user
                                                              .userProfile
                                                              .value
                                                              .data!
                                                              .user!
                                                              .id!,
                                                      userImage: user
                                                              .isProfileLoading
                                                              .value
                                                          ? ""
                                                          : user
                                                              .userProfile
                                                              .value
                                                              .data!
                                                              .user!
                                                              .avatar,
                                                      message: "",
                                                      msgDate: "",
                                                      name: user
                                                              .isProfileLoading
                                                              .value
                                                          ? ""
                                                          : user
                                                              .userProfile
                                                              .value
                                                              .data!
                                                              .user!
                                                              .name!);
                                                  Get.to(ChatScreen(
                                                      inboxModel: inboxModel));
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
                                                    padding: const EdgeInsets
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
                                                        context, '/referral');
                                                  },
                                                  child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                      colors: [
                                                            Color(0xff9B67FB),
                                                            Color(0xff6E1DE9)
                                                          ])),
                                                      height: 60,
                                                      width: 60,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
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

                                        // GestureDetector(
                                        //   onTap: () async {
                                        //     // String action = '';
                                        //     // if (followList.contains(user
                                        //     //     .userProfile.value.data!.user!.id
                                        //     //     .toString())) {
                                        //     //   followList.remove(user
                                        //     //       .userProfile.value.data!.user!.id
                                        //     //       .toString());
                                        //     //   userModel?.followers =
                                        //     //       "${int.parse(user.userProfile.value.data!.user!.followers!) - 1}";
                                        //     //   if (int.parse(user.userProfile.value.data!
                                        //     //           .user!.followers!) <
                                        //     //       0) {
                                        //     //     user.userProfile.value.data!.user!
                                        //     //         .followers = '0';
                                        //     //   }
                                        //     //   action = "unfollow";
                                        //     // } else {
                                        //     //   followList.add(user
                                        //     //       .userProfile.value.data!.user!.id
                                        //     //       .toString());
                                        //     //   user.userProfile.value.data!.user!.followers =
                                        //     //       "${int.parse(user.userProfile.value.data!.user!.followers!) + 1}";
                                        //     //   action = "follow";
                                        //     // }
                                        //     // SharedPreferences pref =
                                        //     //     await SharedPreferences.getInstance();
                                        //     // pref.setStringList('followList', followList);

                                        //     // try {
                                        //     //   //var result =
                                        //     //   await RestApi.followUserAndUnfollow(
                                        //     //       user.userProfile.value.data!.user!.id!,
                                        //     //       action);
                                        //     //   //var json = jsonDecode(result.body);
                                        //     //   BlocProvider.of<ProfileBloc>(context)
                                        //     //       .add(const ProfileLoading());
                                        //     // } catch (_) {}
                                        //   },
                                        //   child: Material(
                                        //     borderRadius: BorderRadius.circular(50),
                                        //     elevation: 10,
                                        //     child: Container(
                                        //         height: 32,
                                        //         padding: const EdgeInsets.only(
                                        //             left: 10, right: 5),
                                        //         decoration: BoxDecoration(
                                        //             borderRadius: BorderRadius.circular(50),
                                        //             border: Border.all(
                                        //                 color: Colors.grey.shade300,
                                        //                 width: 1)),
                                        //         child: SizedBox(
                                        //           height: 10,
                                        //           child: followList.contains(user
                                        //                   .userProfile.value.data!.user?.id
                                        //                   .toString())
                                        //               ? const Icon(
                                        //                   Icons.person_remove_alt_1_sharp,
                                        //                   size: 20,
                                        //                 )
                                        //               : //SvgPicture.asset('assets/person-check.svg',):
                                        //               const Icon(
                                        //                   Icons.person_add_alt_sharp,
                                        //                   size: 20,
                                        //                 ),
                                        //         )),
                                        //   ),
                                        // ),

                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                        //   GestureDetector(
                                        //     onTap: () {
                                        //       //share();
                                        //       Share.share(
                                        //           'I found this awesome person in the great platform called Thrill!!!');
                                        //     },
                                        //     child: Material(
                                        //       borderRadius: BorderRadius.circular(50),
                                        //       elevation: 10,
                                        //       child: Container(
                                        //           padding: const EdgeInsets.symmetric(
                                        //               horizontal: 10, vertical: 5),
                                        //           decoration: BoxDecoration(
                                        //               borderRadius:
                                        //                   BorderRadius.circular(50),
                                        //               border: Border.all(
                                        //                   color: Colors.grey.shade300,
                                        //                   width: 1)),
                                        //           child: const Icon(
                                        //             Icons.share,
                                        //             size: 20,
                                        //           )),
                                        //     ),
                                        //   ),
                                        //   const SizedBox(
                                        //     width: 10,
                                        //   ),
                                        //   GestureDetector(
                                        //     onTap: () {
                                        //       showFollowers.value = false;
                                        //     },
                                        //     child: Material(
                                        //       borderRadius: BorderRadius.circular(50),
                                        //       elevation: 10,
                                        //       child: Container(
                                        //           padding: const EdgeInsets.symmetric(
                                        //               horizontal: 10, vertical: 5),
                                        //           decoration: BoxDecoration(
                                        //               borderRadius:
                                        //                   BorderRadius.circular(50),
                                        //               border: Border.all(
                                        //                   color: Colors.grey.shade300,
                                        //                   width: 1)),
                                        //           child: Icon(
                                        //             showFollowers.value
                                        //                 ? Icons
                                        //                     .keyboard_arrow_up_outlined
                                        //                 : Icons
                                        //                     .keyboard_arrow_down_outlined,
                                        //             size: 22,
                                        //           )),
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    DefaultTabController(
                                      length: 2,
                                      initialIndex: selectedTab.value,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(),
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
                                                    color: selectedTab.value ==
                                                            1
                                                        ? Colors.white
                                                        : Color(0XffB2E3E3)),
                                              )
                                            ]),
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
                          ],
                        ),
                      )));
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
        builder: (videosController) => Flexible(
              child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: videosController.otherUserVideos.value.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
//                Get.to(Home(vModel: controller.videoModel));
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => true, arguments: {
                          'videoModel':
                              videosController.otherUserVideos.value[index]
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // CachedNetworkImage(
                          //     placeholder: (a, b) => const Center(
                          //       child: CircularProgressIndicator(),
                          //     ),
                          //     fit: BoxFit.cover,
                          //     imageUrl:publicVideos[index].gif_image.isEmpty
                          //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                          //         : '${RestUrl.gifUrl}${publicVideos[index].gif_image}'),
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
                                        : videosController
                                            .otherUserVideos.value[index].views
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
                                        : videosController
                                            .otherUserVideos.value[index].likes
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
            : videosController.likedVideos.value.isEmpty
                ? GetX<UserController>(
                    builder: (userController) => RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          const TextSpan(
                              text: '\n\n\n'
                                  "This user's liked videos or private",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
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
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/', (route) => true, arguments: {
                                'videoModel':
                                    videosController.likedVideos.value[index]
                              });
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
