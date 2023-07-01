import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:readmore/readmore.dart';
import 'package:thrill/app/modules/profile/user_private_videos/views/user_private_videos_view.dart';
import 'package:thrill/app/modules/profile/user_videos/views/user_videos_view.dart';
import 'package:thrill/app/rest/models/user_details_model.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_liked_videos.dart';
import 'package:thrill/app/widgets/no_search_result.dart';
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
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: controller.obx(
            (state) =>
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        decoration: const BoxDecoration(
                            gradient: ColorManager.postGradient,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).viewPadding.top,
                          ),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20, top: 60),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 80,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${state!.value.name.toString().isEmpty ? state.value.username : state.value.name}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Visibility(
                                            visible: state.value.isVerified ==
                                                'true',
                                            child: SvgPicture.asset(
                                              'assets/verified.svg',
                                            ))
                                      ],
                                    ),
                                    Text(
                                      '@${state.value.username}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Visibility(
                                      visible: state.value.bio
                                              .toString()
                                              .isNotEmpty ||
                                          state.value.bio.toString() != "null",
                                      child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: ReadMoreText(
                                            state.value.bio.toString() + " ",
                                            trimLines: 2,
                                            textAlign: TextAlign.justify,
                                            colorClickableText:
                                                ColorManager.colorAccent,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'More',
                                            trimExpandedText: 'Less',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                            moreStyle: TextStyle(
                                                fontSize: 14,
                                                color: ColorManager.colorAccent,
                                                fontWeight: FontWeight.w700),
                                            lessStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorManager.colorAccent),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.USERS_FOLLOWING,
                                                arguments: {"index": 0});
                                          },
                                          child: Column(
                                            children: [
                                              Text('${state.value.following}',
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const Text(following,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300))
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.USERS_FOLLOWING,
                                                arguments: {"index": 1});
                                          },
                                          child: Column(
                                            children: [
                                              Text('${state.value.followers}',
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const Text(followers,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300))
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                                '${state.value.likes == null || state.value.likes!.isEmpty ? 0 : state.value.likes}',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const Text(likes,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            child: InkWell(
                                          onTap: () async {
                                            Get.toNamed(Routes.EDIT_PROFILE,
                                                arguments: {
                                                  "avatar": controller
                                                      .state!.value.avatar,
                                                  "email": controller
                                                      .state!.value.email,
                                                  "phone": controller
                                                      .state!.value.phone,
                                                  "dob": controller
                                                      .state!.value.dob,
                                                  "username": controller
                                                      .state!.value.username,
                                                  "name": controller
                                                      .state!.value.name,
                                                  "last_name": controller
                                                      .state!.value.lastName,
                                                  "mobile": controller
                                                      .state!.value.phone,
                                                  "website": controller
                                                      .state!.value.websiteUrl,
                                                  "bio": controller
                                                      .state!.value.bio,
                                                  "location": controller
                                                      .state!.value.location
                                                });
                                          },
                                          child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: ColorManager.colorAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Text("  Edit Profile",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                      fontSize: 18))),
                                        )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => Get.defaultDialog(
                                    title: "",
                                    middleText: "",
                                    backgroundColor:
                                        Colors.transparent.withOpacity(0.0),
                                    contentPadding: EdgeInsets.zero,
                                    content: SizedBox(
                                      height: Get.height / 2,
                                      child: imgProfileDialog(
                                          state.value.avatar.toString()),
                                    )),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/profile_progress.svg",
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                      ),
                                      Container(
                                        height: 80,
                                        width: 80,
                                        child: imgProfileDetails(
                                            state!.value.avatar.toString()),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                      child: DefaultTabController(
                          length: 3,
                          child: Scaffold(
                            body: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TabBar(
                                    onTap: (int index) {
                                      selectedTab.value = index;
                                    },
                                    indicatorPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10),
                                    tabs: [
                                      Tab(
                                        text: "Posts",
                                      ),
                                      Tab(
                                        text: "Private",
                                      ),
                                      Tab(
                                        text: "Liked",
                                      )
                                    ]),
                                Expanded(
                                  child: TabBarView(children: [
                                    UserVideosView(),
                                    UserPrivateVideosView(),
                                    UserLikedVideosView()
                                  ]),
                                )
                              ],
                            ),
                          )))
                ]),
            onError: (error) => NoSearchResult(
                  text: "No Profile Found!",
                ),
            onLoading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: loader(),
                )
              ],
            ),
            onEmpty: NoSearchResult(
              text: "No Profile Found!",
            )));
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
