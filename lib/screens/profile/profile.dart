import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/octicon.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/video/video_bloc.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

var videosController = Get.find<VideosController>();

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int selectedTab = 2;

  @override
  void initState() {
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoading) {
            } else if (state is ProfileLoaded) {}
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.network(RestUrl.assetsUrl+"background_2.svg",
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.3),
              fit: BoxFit.fill,
              width: Get.width,
              height: Get.height,)

             ,
              BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
                if (state is ProfileLoaded) {
                  return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: 50, left: 10, right: 10),
                            child: SvgPicture.asset(
                              "assets/background_profile_1.svg",
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                         Container(
                           margin: EdgeInsets.only(bottom: 60),
                             child:  Column(
                           children: [
                             Container(
                               alignment: Alignment.centerRight,
                               child: Row(

                                 mainAxisAlignment:
                                 MainAxisAlignment.end,
                                 children: [

                                   IconButton(
                                       onPressed: () {
                                         Get.to(SettingAndPrivacy());
                                         //       Navigator.pushNamed(context, "/setting");
                                       },
                                       icon: const Iconify(
                                         Carbon.settings,
                                         color: Colors.white,
                                       ))
                                 ],
                               ),
                             ),
                             const SizedBox(
                               height: 10,
                             ),
                             Column(
                               children: [
                                 Container(
                                   alignment: Alignment.center,
                                   decoration: BoxDecoration(

                                       border: Border.all(
                                         color: Colors.transparent,
                                       ),
                                       borderRadius: const BorderRadius.all(
                                           Radius.circular(200))),
                                   width: 170,
                                   height: 170,
                                   child: Stack(
                                     alignment: Alignment.center,
                                     children: [
                                       SvgPicture.network(RestUrl.assetsUrl+"profile_circle.svg",fit: BoxFit.fill,height: Get.height,width: Get.width,),
                                       SvgPicture.network(RestUrl.assetsUrl+"profile_circle_2.svg",width: 130,height: 130,fit: BoxFit.fill,),

                                       Container(
                                           height: 100,
                                           width: 100,
                                           child: state
                                               .userModel.avatar.isNotEmpty
                                               ? ClipOval(
                                             child: CachedNetworkImage(
                                               fit: BoxFit.cover,
                                               imageUrl:
                                               '${RestUrl.profileUrl}${state.userModel.avatar}',
                                               placeholder: (a, b) =>
                                               const Center(
                                                 child:
                                                 CircularProgressIndicator(),
                                               ),
                                             ),
                                           )
                                               : Padding(
                                             padding:
                                             const EdgeInsets.all(
                                                 10.0),
                                             child: SvgPicture.asset(
                                               'assets/profile.svg',
                                               width: 10,
                                               height: 10,
                                               fit: BoxFit.contain,
                                             ),
                                           )),
                                       Container(
                                         height: 120,
                                         width: 120,
                                         child: CircularProgressIndicator(
                                           value: double.parse(state
                                               .userModel.levels.current
                                               .toString()),
                                           backgroundColor: Colors.transparent,
                                           valueColor:
                                           AlwaysStoppedAnimation<Color>(
                                               Colors.purple),
                                           color: Colors.green,
                                         ),
                                       ),
                                     ],
                                   ),
                                 )
                                 // Expanded(
                                 //   child:
                                 // )
                               ],
                             ),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Container(
                                   margin: const EdgeInsets.only(
                                       bottom: 5, top: 5),
                                   child: Text(
                                     "@" + state.userModel.username,
                                     style: const TextStyle(
                                         fontSize: 20,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white),
                                   ),
                                 ),
                                 state.userModel.is_verified.contains('1')
                                     ? SvgPicture.asset(
                                   'assets/verified.svg',
                                 )
                                     : const SizedBox(width: 2),
                               ],
                             ),
                             Container(
                               alignment: Alignment.center,
                               margin: EdgeInsets.only(left: 10, bottom: 20),
                               width: MediaQuery.of(context).size.width,
                               child: Text(
                                 '${state.userModel.name.isNotEmpty ? state.userModel.name : 'anonymous'}',
                                 style: const TextStyle(
                                     fontSize: 15,
                                     fontWeight: FontWeight.bold,
                                     color: Color(0xffB2B2B2)),
                                 textAlign: TextAlign.start,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 GestureDetector(
                                     onTap: () {
                                       usersController.userId.value =
                                           state.userModel.id;

                                       usersController.isMyProfile.value =
                                       true;
                                       selectedTabIndex.value = 1;

                                       Get.to(FollowingAndFollowers());
                                     },
                                     child: Column(
                                       children: [
                                         Text(
                                             '${state.userModel.following.isEmpty ? 0 : state.userModel.following}',
                                             style: const TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 16,
                                                 fontWeight: FontWeight.bold)),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         const Text(following,
                                             style: TextStyle(
                                                 color: Colors.grey,
                                                 fontSize: 12,
                                                 fontWeight: FontWeight.bold))
                                       ],
                                     )),
                                 Container(
                                   margin:
                                   EdgeInsets.only(left: 15, right: 15),
                                   height: 40,
                                   width: 1,
                                   color: Colors.white.withOpacity(0.2),
                                 ),
                                 GestureDetector(
                                     onTap: () {
                                       usersController.userId.value =
                                           state.userModel.id;

                                       usersController.isMyProfile.value =
                                       true;
                                       selectedTabIndex.value = 0;

                                       Get.to(FollowingAndFollowers());
                                     },
                                     child: Column(
                                       children: [
                                         Text(
                                             '${state.userModel.followers.isEmpty ? 0 : state.userModel.followers}',
                                             style: const TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 16,
                                                 fontWeight: FontWeight.bold)),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         const Text(followers,
                                             style: TextStyle(
                                                 fontSize: 12,
                                                 color: Colors.grey,
                                                 fontWeight: FontWeight.bold))
                                       ],
                                     )),
                                 Container(
                                   margin:
                                   EdgeInsets.only(left: 15, right: 15),
                                   height: 40,
                                   width: 1,
                                   color: Colors.white.withOpacity(0.2),
                                 ),
                                 Column(
                                   children: [
                                     Text(
                                         '${state.userModel.likes.isEmpty ? 0 : state.userModel.likes}',
                                         style: const TextStyle(
                                             color: Colors.white,
                                             fontSize: 16,
                                             fontWeight: FontWeight.bold)),
                                     const SizedBox(
                                       height: 10,
                                     ),
                                     const Text(likes,
                                         style: TextStyle(
                                             fontSize: 12,
                                             color: Colors.grey,
                                             fontWeight: FontWeight.bold))
                                   ],
                                 )
                               ],
                             ),
                             const SizedBox(
                               height: 10,
                             ),
                             Container(
                               padding: EdgeInsets.all(10),
                               child: GlassContainer(
                                   border: const Border.fromBorderSide(
                                       BorderSide.none),
                                   shape: BoxShape.rectangle,
                                   borderRadius: BorderRadius.circular(20),
                                   color: Color.fromARGB(50, 31, 33, 40),
                                   shadowStrength: 0,
                                   blur: 20,
                                   child: Container(
                                     margin: EdgeInsets.all(10),
                                     child: Column(
                                       children: [
                                         const SizedBox(
                                           height: 5,
                                         ),
                                         Container(
                                           margin: const EdgeInsets.only(
                                               bottom: 10),
                                           alignment: Alignment.center,
                                           child: const Text(
                                             'About',
                                             maxLines: 3,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 15,
                                                 color: Colors.white),
                                           ),
                                         ),
                                         Container(
                                           margin: const EdgeInsets.only(
                                               left: 10, right: 20),
                                           alignment: Alignment.centerLeft,
                                           child: Text(
                                             state.userModel.bio,
                                             maxLines: 3,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(
                                                 fontSize: 15,
                                                 color: Colors.white
                                                     .withOpacity(0.5)),
                                           ),
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         Container(
                                           margin:
                                           const EdgeInsets.only(left: 10),
                                           alignment: Alignment.centerLeft,
                                           width: MediaQuery.of(context)
                                               .size
                                               .width,
                                           child: Row(
                                             children: [
                                               const Icon(
                                                 Icons.link,
                                                 color: Colors.white,
                                               ),
                                               SizedBox(
                                                 width: 5,
                                               ),
                                               InkWell(
                                                 onTap: () {
                                                   Uri openInBrowser = Uri(
                                                     scheme: 'https',
                                                     path:
                                                     "${state.userModel.website_url}",
                                                   );
                                                   launchUrl(openInBrowser,
                                                       mode: LaunchMode
                                                           .externalApplication);
                                                 },
                                                 child: Text(
                                                   state.userModel.website_url,
                                                   maxLines: 3,
                                                   textAlign: TextAlign.start,
                                                   overflow:
                                                   TextOverflow.ellipsis,
                                                   style: TextStyle(
                                                       fontSize: 15,
                                                       color: Colors
                                                           .blue.shade300),
                                                 ),
                                               )
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                   )),
                             ),
                             SizedBox(
                               height: 20,
                             ),
                             Container(
                               child: Row(
                                 mainAxisSize: MainAxisSize.max,
                                 mainAxisAlignment:
                                 MainAxisAlignment.spaceEvenly,
                                 children: [
                                   Container(
                                     padding: const EdgeInsets.symmetric(
                                         vertical: 25, horizontal: 20),
                                     alignment: Alignment.center,
                                     decoration: const BoxDecoration(
                                         color: Color.fromARGB(50, 31, 33, 40),
                                         borderRadius: BorderRadius.all(
                                             Radius.circular(200))),
                                     child: Column(
                                       children: [
                                         ClipOval(
                                           child: InkWell(
                                             onTap: () {
                                               Navigator.pushNamed(
                                                   context, '/editProfile',
                                                   arguments:
                                                   state.userModel)
                                                   .then((value) async {
                                                 var pref =
                                                 await SharedPreferences
                                                     .getInstance();
                                                 var currentUser = pref
                                                     .getString('currentUser');
                                                 UserModel current =
                                                 UserModel.fromJson(
                                                     jsonDecode(
                                                         currentUser!));
                                                 state.userModel.copyWith(
                                                     username: state.userModel
                                                         .username =
                                                         current.username);
                                                 state.userModel.copyWith(
                                                     first_name: state
                                                         .userModel
                                                         .first_name =
                                                         current.first_name);
                                                 state.userModel.copyWith(
                                                     last_name: state.userModel
                                                         .last_name =
                                                         current.last_name);
                                                 state.userModel.copyWith(
                                                     gender: state.userModel
                                                         .gender =
                                                         current.gender);
                                                 state.userModel.copyWith(
                                                     website_url: state
                                                         .userModel
                                                         .website_url =
                                                         current.website_url);
                                                 state.userModel.copyWith(
                                                     bio: state.userModel.bio =
                                                         current.bio);
                                                 state.userModel.copyWith(
                                                     youtube: state.userModel
                                                         .youtube =
                                                         current.youtube);
                                                 state.userModel.copyWith(
                                                     facebook: state.userModel
                                                         .facebook =
                                                         current.facebook);
                                                 state.userModel.copyWith(
                                                     instagram: state.userModel
                                                         .instagram =
                                                         current.instagram);
                                                 state.userModel.copyWith(
                                                     twitter: state.userModel
                                                         .twitter =
                                                         current.twitter);
                                                 state.userModel.copyWith(
                                                     avatar: state.userModel
                                                         .avatar =
                                                         current.avatar);
                                                 state.userModel.copyWith(
                                                     name: state.userModel
                                                         .name = current.name);
                                                 setState(() {});
                                               });
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
                                         color: Color.fromARGB(50, 31, 33, 40),
                                         border: Border.all(
                                           color: Colors.transparent,
                                         ),
                                         borderRadius: const BorderRadius.all(
                                             Radius.circular(200))),
                                     child: Column(
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
                                         color: Color.fromARGB(50, 31, 33, 40),
                                         border: Border.all(
                                           color: Colors.transparent,
                                         ),
                                         borderRadius: const BorderRadius.all(
                                             Radius.circular(200))),
                                     child: Column(
                                       children: [
                                         ClipOval(
                                           child: Container(
                                             decoration: const BoxDecoration(
                                                 gradient: LinearGradient(
                                                     colors: [
                                                       Color(0xffFF87CF),
                                                       Color(0xffE968D9)
                                                     ])),
                                             width: 60,
                                             height: 60,
                                             child: InkWell(
                                               onTap: () {
                                                 Navigator.pushNamed(
                                                     context, '/favourites');
                                               },
                                               child: Container(
                                                   padding:
                                                   const EdgeInsets.all(
                                                       15),
                                                   child: const Iconify(
                                                     Carbon.star,
                                                     color: Colors.white,
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
                               ),
                             ),
                             const SizedBox(
                               height: 20,
                             ),
                             DefaultTabController(

                                 length: 3,
                                 initialIndex: selectedTab,
                                 child: TabBar(
                                   unselectedLabelColor: Color(0xff333742),
                                     onTap: (int index) {
                                       setState(() {
                                         selectedTab = index;
                                       });
                                     },
                                     padding: const EdgeInsets.symmetric(
                                         horizontal: 0, vertical: 0),
                                     indicatorColor: Colors.white,
                                     indicatorPadding:
                                     const EdgeInsets.symmetric(
                                         horizontal: 10),
                                     tabs: [
                                       Tab(

                                         icon: SvgPicture.asset(
                                           'assets/feedTab.svg',
                                           color: selectedTab == 0
                                               ? Colors.white
                                               : const Color(0XffB2E3E3),
                                         ),
                                       ),
                                       Tab(
                                         icon: Icon(Icons.lock,
                                             color: selectedTab == 1
                                                 ? Colors.white
                                                 : const Color(0XffB2E3E3)),
                                       ),
                                       Tab(
                                         icon: Icon(Icons.favorite,
                                             color: selectedTab == 2
                                                 ? Colors.white
                                                 : const Color(0XffB2E3E3)),
                                       )
                                     ])),
                             const SizedBox(
                               height: 5,
                             ),
                             tabview(
                                 state.userModel,
                                 state.publicList.isEmpty
                                     ? []
                                     : state.publicList,
                                 state.privateList.isEmpty
                                     ? []
                                     : state.privateList,
                                 state.likesList.isEmpty
                                     ? []
                                     : state.likesList)
                           ],
                         ),)
                        ],
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ],
          )),
    );
  }

  tabview(UserModel userModel, List<VideoModel> publicList,
      List<VideoModel> privateList, List<VideoModel> likesList) {
    if (selectedTab == 0) {
      return feed();
    } else if (selectedTab == 1) {
      return lock(privateList);
    } else {
      return fav(userModel, likesList);
    }
  }

  feed() {
    return GetX<VideosController>(
        builder: ((videoModelsController) => videoModelsController
                    .isLoading.value ||
                videoModelsController.videoModelsController.isEmpty
            ? RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(children: [
                  TextSpan(
                      text: '\n\n\n' "User's Public Video",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '\n\n'
                          "Public Videos are currently not available",
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
                itemCount: videoModelsController.videoModelsController.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/', arguments: {
                        'videoModel':
                            videoModelsController.videoModelsController[index]
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
                        //     imageUrl:publicList[index].gif_image.isEmpty
                        //         ? '${RestUrl.thambUrl}thumb-not-available.png'
                        //         : '${RestUrl.gifUrl}${publicList[index].gif_image}'),
                        imgNet(
                            '${RestUrl.gifUrl}${videoModelsController.videoModelsController[index].gifImage}'),
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
                                  videoModelsController
                                      .videoModelsController[index].views
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
                                      .videoModelsController[index].likes
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
                                        .videoModelsController[index].id!,
                                    videoModelsController.videoModelsController,
                                    index);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.red,
                              icon: const Icon(Icons.delete_forever_outlined)),
                        )
                      ],
                    ),
                  );
                })));
  }

  lock(List<VideoModel> privateList) {
    return privateList.isEmpty
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
            itemCount: privateList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/',
                      arguments: {'videoModel': privateList[index]});
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
                    imgNet('${RestUrl.gifUrl}${privateList[index].gif_image}'),
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
                              privateList[index].views.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            const Icon(
                              IconlyBold.heart,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              privateList[index].likes.toString(),
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
                                privateList[index].id, privateList, index);
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
                            showPrivate2PublicDialog(privateList[index].id);
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
            });
  }

  fav(UserModel userModel, List<VideoModel> likesList) {
    return likesList.isEmpty
        ? RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(children: [
              TextSpan(
                  text: '\n\n\n' "User's liked Video",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
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
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: likesList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // Get.to(VideoPlaybackScreen());
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imgNet('${RestUrl.gifUrl}${likesList[index].gif_image}'),
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
                              likesList[index].views.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            const Icon(
                              IconlyBold.heart,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              likesList[index].likes.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ))
                  ],
                ),
              );
            });
  }

  showDeleteVideoDialog(int videoID, List list, int index) {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: getWidth(context) * .80,
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
                          style: Theme.of(context).textTheme.headline3,
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
                          style: Theme.of(context)
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
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  fixedSize: Size(getWidth(context) * .26, 40),
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
                                    showSuccessToast(
                                        context, json['message'].toString());
                                    setState(() {});
                                    BlocProvider.of<VideoBloc>(context).add(
                                        const VideoLoading(
                                            selectedTabIndex: 1));
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (route) => true);
                                  } else {
                                    showErrorToast(
                                        context, json['message'].toString());
                                  }
                                } catch (e) {
                                  closeDialogue(context);
                                  showErrorToast(context, e.toString());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  fixedSize: Size(getWidth(context) * .26, 40),
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
        context: context,
        builder: (_) => Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: getWidth(context) * .80,
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
                          style: Theme.of(context).textTheme.headline3,
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
                          style: Theme.of(context)
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
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  fixedSize: Size(getWidth(context) * .26, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text("No")),
                          const SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                try {
                                  Navigator.pop(context);
                                  progressDialogue(context);
                                  var response =
                                      await RestApi.publishPrivateVideo(
                                          videoID);
                                  var json = jsonDecode(response.body);
                                  if (json['status']) {
                                    BlocProvider.of<VideoBloc>(context).add(
                                        const VideoLoading(
                                            selectedTabIndex: 1));
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                    closeDialogue(context);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (route) => true);
                                    showSuccessToast(
                                        context, json['message'].toString());
                                  } else {
                                    closeDialogue(context);
                                    showErrorToast(
                                        context, json['message'].toString());
                                  }
                                } catch (e) {
                                  closeDialogue(context);
                                  showErrorToast(context, e.toString());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  fixedSize: Size(getWidth(context) * .26, 40),
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
