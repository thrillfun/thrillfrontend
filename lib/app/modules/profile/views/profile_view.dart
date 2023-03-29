import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/profile/user_private_videos/views/user_private_videos_view.dart';
import 'package:thrill/app/modules/profile/user_videos/views/user_videos_view.dart';
import 'package:thrill/app/rest/models/user_details_model.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';
import '../controllers/profile_controller.dart';
import '../user_liked_videos/views/user_liked_videos_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedTab = 0.obs;

    return Scaffold(
        body: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Get.width, maxHeight: Get.height),
      child: Column(children: [
        UserProfileDetails(),
        Expanded(
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    toolbarHeight: 10,
                    bottom: TabBar(
                        onTap: (int index) {
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
                  body: TabBarView(children: [
                    UserVideosView(),
                    UserPrivateVideosView(),
                    UserLikedVideosView()
                  ]),
                )))
      ]),
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

class UserProfileDetails extends GetView<ProfileController> {
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
                        onPressed: () =>
                            Get.toNamed(Routes.SETTINGS, arguments: {
                          "username":
                              "${controller.userProfile.value.username}",
                          "avatar": "${controller.userProfile.value.avatar}",
                          "name": controller.userProfile.value.name
                        }),
                        icon: Icon(
                          Icons.more_vert_outlined,
                        ),
                      )
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // followersController
                        //     .getUserFollowers(state.value.id!)
                        //     .then((value) => followersController
                        //     .getUserFollowing(state.value.id!)
                        //     .then((value) => Get.to(FollowingAndFollowers(
                        //     true.obs, state.value.id!.obs))));
                        Get.toNamed(Routes.USERS_FOLLOWING,
                            arguments: {"index": 0});
                        // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                      },
                      child:Column(children: [  Text(
                          '${state.value.following}'
                             ,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                            following,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))],),
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
                        // followersController
                        //     .getUserFollowers(state.value.id!)
                        //     .then((value) => followersController
                        //     .getUserFollowing(state.value.id!)
                        //     .then((value) => Get.to(FollowingAndFollowers(
                        //     true.obs, state.value.id!.obs))));
                        Get.toNamed(Routes.USERS_FOLLOWING,
                            arguments: {"index": 1});

                        // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                      },
                      child: Column(children: [  Text(
                          '${state.value.followers}'
                          ,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                            followers,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))],),
                    ),
                    const SizedBox(
                      height: 45,
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ),
                    ),
                    Column(children: [  Text(
                        '${state.value.likes == null || state.value.likes!.isEmpty ? 0 : state.value.likes}'
                        ,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                          likes,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))],)
                    ,
                  ],
                ),
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
                            ),
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
                        Get.toNamed(Routes.EDIT_PROFILE, arguments: {
                          "avatar": controller.state!.value.avatar,
                          "email": controller.state!.value.email,
                          "phone": controller.state!.value.phone,
                          "dob": controller.state!.value.dob,
                          "username": controller.state!.value.username,
                          "name": controller.state!.value.name,
                          "last_name": controller.state!.value.lastName,
                          "mobile": controller.state!.value.phone,
                          "website": controller.state!.value.websiteUrl,
                          "bio": controller.state!.value.bio,
                          "location": controller.state!.value.location
                        });
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
                  ),
                ),
              ),
            ));
  }
}
