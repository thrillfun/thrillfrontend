import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
import 'package:velocity_x/velocity_x.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/follower_model.dart';
import '../../models/user.dart';
import '../../models/video_model.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

// class ViewProfile extends StatefulWidget {
//   @override
//   State<ViewProfile> createState() => _ViewProfileState();
// }

// class _ViewProfileState extends State<ViewProfile> {
//   var userController = Get.find<UserController>();

//   var selectedTab = 0.obs;
//   UserModel? userModel;
//   List<String> followList = List.empty(growable: true);
//   List<VideoModel> publicVideos = List.empty(growable: true);
//   List<VideoModel> favVideos = List.empty(growable: true);
//   bool isPublicVideosLoaded = false, isFavVideosLoaded = false;
//   bool showFollowers = false;
//   List<FollowerModel> followerModelList =
//       List<FollowerModel>.empty(growable: true);

//   @override
//   void initState() {

//     try {
//       reelsPlayerController?.pause();
//     } catch (_) {}
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetX<UserController>(
//         builder: (user) => videosController.videosLoading.value
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : Scaffold(
//                 appBar: AppBar(
//                   flexibleSpace: Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: <Color>[
//                             Color(0xFF2F8897),
//                             Color(0xff1F2A52),
//                             Color(0xff1F244E)
//                           ]),
//                     ),
//                   ),
//                   elevation: 0.5,
//                   title: Text(
//                     user.userProfile.value.data!.user?.name ?? " ",
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   centerTitle: true,
//                   backgroundColor: Colors.white,
//                   leading: IconButton(
//                       onPressed: () {
//                         Get.back(closeOverlays: true);
//                       },
//                       color: Colors.white,
//                       icon: const Icon(Icons.arrow_back)),
//                   actions: [
//                     IconButton(
//                       onPressed: () async {
//                         try {
//                           progressDialogue(context);
//                           var response =
//                               await RestApi.checkBlock(userModel!.id);
//                           var json = jsonDecode(response.body);
//                           closeDialogue(context);
//                           showReportAndBlock(json['status']);
//                         } catch (e) {
//                           closeDialogue(context);
//                           showErrorToast(context, e.toString());
//                         }
//                       },
//                       color: Colors.grey,
//                       icon: const Icon(Icons.report_gmailerrorred_outlined),
//                     ),
//                   ],
//                 ),
//                 body: SingleChildScrollView(
//                   child: SizedBox(
//                     height: getHeight(context),
//                     width: getWidth(context),
//                     child: Column(
//                       children: [
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           height: 115,
//                           width: 115,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                           ),
//                           child: CachedNetworkImage(
//                             fit: BoxFit.cover,
//                             imageUrl: user.userProfile.value.data!.user!.avatar
//                                     .isEmpty
//                                 ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
//                                 : '${RestUrl.profileUrl}${user.userProfile.value.data!.user!.avatar}',
//                             placeholder: (a, b) => const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               user.isProfileLoading.value
//                                   ? "loading"
//                                   : '@${user.userProfile.value.data!.user!.username}',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             SvgPicture.asset(
//                               'assets/verified.svg',
//                             )
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 25,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(FollowingAndFollowers(
//                                   map: {
//                                     'id':
//                                         user.userProfile.value.data!.user!.id!,
//                                     'index': 1
//                                   },
//                                   isMyProfile: false,
//                                 ));
//                                 // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
//                               },
//                               child: RichText(
//                                   textAlign: TextAlign.center,
//                                   text: TextSpan(children: [
//                                     TextSpan(
//                                         text: user.isProfileLoading.value
//                                             ? "0"
//                                             : '${user.userProfile.value.data!.user!.following}'
//                                                 '\n',
//                                         style: const TextStyle(
//                                             color: Colors.black, fontSize: 17)),
//                                     const TextSpan(
//                                         text: following,
//                                         style: TextStyle(color: Colors.grey)),
//                                   ])),
//                             ),
//                             Container(
//                               height: 20,
//                               width: 1,
//                               color: Colors.grey.shade300,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(FollowingAndFollowers(
//                                   map: {
//                                     'id': user.isProfileLoading.value
//                                         ? 0
//                                         : user
//                                             .userProfile.value.data!.user!.id!,
//                                     'index': 0
//                                   },
//                                   isMyProfile: false,
//                                 ));

//                                 // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
//                               },
//                               child: RichText(
//                                   textAlign: TextAlign.center,
//                                   text: TextSpan(children: [
//                                     TextSpan(
//                                         text: user.isProfileLoading.value
//                                             ? ""
//                                             : '${user.userProfile.value.data!.user!.followers}'
//                                                 '\n',
//                                         style: const TextStyle(
//                                             color: Colors.black, fontSize: 17)),
//                                     const TextSpan(
//                                         text: followers,
//                                         style: TextStyle(color: Colors.grey)),
//                                   ])),
//                             ),
//                             Container(
//                               height: 20,
//                               width: 1,
//                               color: Colors.grey.shade300,
//                             ),
//                             RichText(
//                                 textAlign: TextAlign.center,
//                                 text: TextSpan(children: [
//                                   TextSpan(
//                                       text:
//                                           '${user.userProfile.value.data!.user!.likes!.isEmpty ? 0 : user.userProfile.value.data!.user!.likes}'
//                                           '\n',
//                                       style: const TextStyle(
//                                           color: Colors.black, fontSize: 17)),
//                                   const TextSpan(
//                                       text: likes,
//                                       style: TextStyle(color: Colors.grey)),
//                                 ])),
//                           ],
//                         ).w(MediaQuery.of(context).size.width * .80),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 InboxModel inboxModel = InboxModel(
//                                     id: user.isProfileLoading.value
//                                         ? 0
//                                         : user
//                                             .userProfile.value.data!.user!.id!,
//                                     userImage: user.isProfileLoading.value
//                                         ? ""
//                                         : user.userProfile.value.data!.user!
//                                             .avatar,
//                                     message: "",
//                                     msgDate: "",
//                                     name: user.isProfileLoading.value
//                                         ? ""
//                                         : user.userProfile.value.data!.user!
//                                             .name!);
//                                 Navigator.pushNamed(context, '/chatScreen',
//                                     arguments: inboxModel);
//                               },
//                               child: Material(
//                                 borderRadius: BorderRadius.circular(50),
//                                 elevation: 10,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(50),
//                                       border: Border.all(
//                                           color: Colors.grey.shade300,
//                                           width: 1)),
//                                   child: const Text(
//                                     message,
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             GestureDetector(
//                               onTap: () async {
//                                 String action = '';
//                                 if (followList.contains(user
//                                     .userProfile.value.data!.user!.id
//                                     .toString())) {
//                                   followList.remove(user
//                                       .userProfile.value.data!.user!.id
//                                       .toString());
//                                   userModel?.followers =
//                                       "${int.parse(user.userProfile.value.data!.user!.followers!) - 1}";
//                                   if (int.parse(user.userProfile.value.data!
//                                           .user!.followers!) <
//                                       0) {
//                                     user.userProfile.value.data!.user!
//                                         .followers = '0';
//                                   }
//                                   action = "unfollow";
//                                 } else {
//                                   followList.add(user
//                                       .userProfile.value.data!.user!.id
//                                       .toString());
//                                   user.userProfile.value.data!.user!.followers =
//                                       "${int.parse(user.userProfile.value.data!.user!.followers!) + 1}";
//                                   action = "follow";
//                                 }
//                                 SharedPreferences pref =
//                                     await SharedPreferences.getInstance();
//                                 pref.setStringList('followList', followList);

//                                 try {
//                                   //var result =
//                                   await RestApi.followUserAndUnfollow(
//                                       user.userProfile.value.data!.user!.id!,
//                                       action);
//                                   //var json = jsonDecode(result.body);
//                                   BlocProvider.of<ProfileBloc>(context)
//                                       .add(const ProfileLoading());
//                                 } catch (_) {}
//                                 setState(() {});
//                               },
//                               child: Material(
//                                 borderRadius: BorderRadius.circular(50),
//                                 elevation: 10,
//                                 child: Container(
//                                     height: 32,
//                                     padding: const EdgeInsets.only(
//                                         left: 10, right: 5),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(50),
//                                         border: Border.all(
//                                             color: Colors.grey.shade300,
//                                             width: 1)),
//                                     child: SizedBox(
//                                       height: 10,
//                                       child: followList.contains(user
//                                               .userProfile.value.data!.user?.id
//                                               .toString())
//                                           ? const Icon(
//                                               Icons.person_remove_alt_1_sharp,
//                                               size: 20,
//                                             )
//                                           : //SvgPicture.asset('assets/person-check.svg',):
//                                           const Icon(
//                                               Icons.person_add_alt_sharp,
//                                               size: 20,
//                                             ),
//                                     )),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 //share();
//                                 Share.share(
//                                     'I found this awesome person in the great platform called Thrill!!!');
//                               },
//                               child: Material(
//                                 borderRadius: BorderRadius.circular(50),
//                                 elevation: 10,
//                                 child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 5),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(50),
//                                         border: Border.all(
//                                             color: Colors.grey.shade300,
//                                             width: 1)),
//                                     child: const Icon(
//                                       Icons.share,
//                                       size: 20,
//                                     )),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() => showFollowers = !showFollowers);
//                               },
//                               child: Material(
//                                 borderRadius: BorderRadius.circular(50),
//                                 elevation: 10,
//                                 child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 5),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(50),
//                                         border: Border.all(
//                                             color: Colors.grey.shade300,
//                                             width: 1)),
//                                     child: Icon(
//                                       showFollowers
//                                           ? Icons.keyboard_arrow_up_outlined
//                                           : Icons.keyboard_arrow_down_outlined,
//                                       size: 22,
//                                     )),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         Visibility(
//                           visible: showFollowers,
//                           child: SizedBox(
//                             height: 100,
//                             child: user.followersModel.value.data!.isEmpty
//                                 ? Center(
//                                     child: Text(
//                                     "No Followers to Display!",
//                                     style:
//                                         Theme.of(context).textTheme.headline3,
//                                   ))
//                                 : ListView.builder(
//                                     itemCount:
//                                         user.followersModel.value.data!.length,
//                                     scrollDirection: Axis.horizontal,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 15),
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return GestureDetector(
//                                         onTap: () {
//                                           //Navigator.pushNamed(context, "/viewProfile", arguments: {"id":followerModelList[index].id, "getProfile":true});
//                                         },
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Container(
//                                                 padding:
//                                                     const EdgeInsets.all(2),
//                                                 margin: const EdgeInsets.only(
//                                                     right: 5, left: 5),
//                                                 height: 70,
//                                                 width: 70,
//                                                 decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                         color: ColorManager
//                                                             .spinColorDivider)),
//                                                 child: ClipOval(
//                                                   child: CachedNetworkImage(
//                                                     fit: BoxFit.cover,
//                                                     errorWidget: (a, b, c) =>
//                                                         Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               10.0),
//                                                       child: SvgPicture.asset(
//                                                         'assets/profile.svg',
//                                                         width: 10,
//                                                         height: 10,
//                                                         fit: BoxFit.contain,
//                                                       ),
//                                                     ),
//                                                     imageUrl:
//                                                         '${RestUrl.profileUrl}${user.followersModel.value.data![index].avtars}',
//                                                     placeholder: (a, b) =>
//                                                         const Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                                   ),
//                                                 )),
//                                             const SizedBox(
//                                               height: 5,
//                                             ),
//                                             SizedBox(
//                                                 width: 70,
//                                                 child: Text(
//                                                   user.followersModel.value
//                                                       .data![index].name!,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                   textAlign: TextAlign.center,
//                                                 ))
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                         Text(
//                           "${user.userProfile.value.data!.user?.bio}",
//                           textAlign: TextAlign.center,
//                           style:
//                               const TextStyle(color: Colors.grey, fontSize: 13),
//                         ).w(MediaQuery.of(context).size.width * .85),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset(
//                               'assets/link.svg',
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Flexible(
//                               child: Text(
//                                 "${user.userProfile.value.data!.user!.websiteUrl}",
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                     color: Colors.grey, fontSize: 14),
//                               ),
//                             )
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         DefaultTabController(
//                           length: 2,
//                           initialIndex: selectedTab.value,
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(
//                                 border: Border(
//                                     top: BorderSide(
//                                         color: Colors.grey.shade400, width: 1),
//                                     bottom: BorderSide(
//                                         color: Colors.grey.shade400,
//                                         width: 1))),
//                             child: TabBar(
//                                 onTap: (int index) {
//                                   selectedTab.value = index;
//                                 },
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 50),
//                                 indicatorColor: Colors.black,
//                                 indicatorPadding:
//                                     const EdgeInsets.symmetric(horizontal: 30),
//                                 tabs: [
//                                   Tab(
//                                     icon: SvgPicture.asset(
//                                       'assets/feedTab.svg',
//                                       color: selectedTab.value == 0
//                                           ? Colors.black
//                                           : Colors.grey,
//                                     ),
//                                   ),
//                                   Tab(
//                                     icon: SvgPicture.asset('assets/favTab.svg',
//                                         color: selectedTab.value == 2
//                                             ? Colors.black
//                                             : Colors.grey),
//                                   )
//                                 ]),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         tabview()
//                       ],
//                     ),
//                   ),
//                 ),
//               ));
//   }

//   share() {
//     return showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30), topRight: Radius.circular(30))),
//         builder: (BuildContext context) {
//           return Column(
//             children: [
//               const Spacer(),
//               const Text(
//                 sendTo,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               const Spacer(),
//               SizedBox(
//                 height: 90,
//                 child: ListView.builder(
//                     itemCount: 10,
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.only(left: 20, right: 20),
//                     itemBuilder: (BuildContext context, int index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               clipBehavior: Clip.antiAliasWithSaveLayer,
//                               height: 60,
//                               width: 60,
//                               margin: const EdgeInsets.only(right: 10),
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                               ),
//                               child: CachedNetworkImage(
//                                 fit: BoxFit.cover,
//                                 imageUrl:
//                                     'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3053232163929.567197ac6e6f5.png',
//                                 placeholder: (a, b) => const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Text(
//                               'User$index',
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       );
//                     }),
//               ),
//               const Spacer(),
//               const Text(
//                 shareTo,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               const Spacer(),
//               Row(
//                 children: [
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundImage: const DecorationImage(
//                               image: AssetImage('assets/message.png')),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           message,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundImage: const DecorationImage(
//                               image: AssetImage('assets/whatsapp.png')),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           whatsApp,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundImage: const DecorationImage(
//                               image: AssetImage('assets/facebook (2).png')),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           facebook,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundImage: const DecorationImage(
//                               image: AssetImage('assets/messenger.png')),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           messenger,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundImage: const DecorationImage(
//                               image: AssetImage('assets/sms.png')),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           sms,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                             radius: 60,
//                             backgroundColor: Colors.blue,
//                             child: SvgPicture.asset(
//                               'assets/link.svg',
//                               color: Colors.white,
//                             )),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           copyLink,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ).scrollHorizontal(),
//               const Spacer(),
//               const Divider(
//                 height: 10,
//                 color: Colors.grey,
//               ),
//               Row(
//                 children: [
//                   const SizedBox(
//                     width: 30,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundColor: Colors.grey.shade200,
//                           child: const Icon(
//                             Icons.flag_outlined,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           report,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundColor: Colors.grey.shade200,
//                           child: const Icon(
//                             Icons.block,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           block,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         VxCircle(
//                           radius: 60,
//                           backgroundColor: Colors.grey.shade200,
//                           child: const Icon(
//                             Icons.email_outlined,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           sendMessage,
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const Divider(
//                 height: 10,
//                 color: Colors.grey,
//               ),
//               const Spacer(),
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text(
//                     cancel,
//                     style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ))
//             ],
//           );
//         });
//   }

//   showReportAndBlock(bool block) {
//     bool isSelected = false;
//     String reason = '';
//     showDialog(
//         context: context,
//         builder: (_) => StatefulBuilder(
//               builder: (BuildContext context,
//                   void Function(void Function()) setState) {
//                 return Center(
//                   child: Material(
//                     type: MaterialType.transparency,
//                     child: Container(
//                       width: getWidth(context) * .80,
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: isSelected
//                           ? Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 30),
//                                   child: Text(
//                                     "Report ${userModel?.name}",
//                                     style:
//                                         Theme.of(context).textTheme.headline3,
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10),
//                                   child: TextFormField(
//                                     onChanged: (txt) =>
//                                         setState(() => reason = txt),
//                                     minLines: 2,
//                                     maxLines: 4,
//                                     maxLength: 150,
//                                     decoration: const InputDecoration(
//                                         counterStyle:
//                                             TextStyle(color: Colors.grey),
//                                         hintText: "Reason",
//                                         counterText: "",
//                                         hintStyle:
//                                             TextStyle(color: Colors.grey),
//                                         border: OutlineInputBorder()),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 ElevatedButton(
//                                     onPressed: reason.isEmpty
//                                         ? null
//                                         : () async {
//                                             try {
//                                               FocusScope.of(context).unfocus();
//                                               var response =
//                                                   await RestApi.reportUser(
//                                                       userModel!.id, reason);
//                                               var json =
//                                                   jsonDecode(response.body);
//                                               closeDialogue(context);
//                                               if (json['status']) {
//                                                 //Navigator.pop(context);
//                                                 showSuccessToast(context,
//                                                     json['message'].toString());
//                                               } else {
//                                                 //Navigator.pop(context);
//                                                 showErrorToast(context,
//                                                     json['message'].toString());
//                                               }
//                                             } catch (e) {
//                                               closeDialogue(context);
//                                               showErrorToast(
//                                                   context, e.toString());
//                                             }
//                                           },
//                                     style: ElevatedButton.styleFrom(
//                                         primary: Colors.red,
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 30, vertical: 5)),
//                                     child: const Text("Report"))
//                               ],
//                             )
//                           : Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 30),
//                                   child: Text(
//                                     "Report or Block",
//                                     style:
//                                         Theme.of(context).textTheme.headline3,
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 35),
//                                   child: Text(
//                                     "Report or block '${userModel?.name}' for offensive behaviour.",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headline4!
//                                         .copyWith(
//                                             fontWeight: FontWeight.normal),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     ElevatedButton(
//                                         onPressed: () {
//                                           performBlock(block);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                             primary: Colors.red,
//                                             fixedSize: Size(
//                                                 getWidth(context) * .26, 40),
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10))),
//                                         child:
//                                             Text(block ? "Unblock" : "Block")),
//                                     const SizedBox(
//                                       width: 15,
//                                     ),
//                                     ElevatedButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             isSelected = true;
//                                           });
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                             primary: Colors.red,
//                                             fixedSize: Size(
//                                                 getWidth(context) * .26, 40),
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10))),
//                                         child: const Text("Report")),
//                                   ],
//                                 )
//                               ],
//                             ),
//                     ),
//                   ),
//                 );
//               },
//             ));
//   }

//   performBlock(bool block) async {
//     try {
//       progressDialogue(context);
//       var response = await RestApi.blockUnblockUser(userModel!.id, block);
//       var json = jsonDecode(response.body);
//       closeDialogue(context);
//       if (json['status']) {
//         Navigator.pop(context);
//         showSuccessToast(context, json['message'].toString());
//       } else {
//         showErrorToast(context, json['message'].toString());
//       }
//     } catch (e) {
//       closeDialogue(context);
//       showErrorToast(context, e.toString());
//     }
//   }
// }

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
        builder: (user) => videosController.videosLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                appBar: AppBar(
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFF2F8897),
                            Color(0xff1F2A52),
                            Color(0xff1F244E)
                          ]),
                    ),
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
                body: SingleChildScrollView(
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
                            imageUrl: user.userProfile.value.data!.user!.avatar
                                    .isEmpty
                                ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                                : '${RestUrl.profileUrl}${user.userProfile.value.data!.user!.avatar}',
                            placeholder: (a, b) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.isProfileLoading.value
                                  ? "loading"
                                  : '@${user.userProfile.value.data!.user!.username}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              'assets/verified.svg',
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                usersController.isMyProfile.value = true;
                                Get.to(FollowingAndFollowers());
                                // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':1});
                              },
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: user.isProfileLoading.value
                                            ? "0"
                                            : '${user.userProfile.value.data!.user!.following}'
                                                '\n',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 17)),
                                    const TextSpan(
                                        text: following,
                                        style: TextStyle(color: Colors.grey)),
                                  ])),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            GestureDetector(
                              onTap: () {
                                userController.userId.value =
                                    user.userProfile.value.data!.user!.id!;
                                userController.isMyProfile.value = false;
                                Get.to(FollowingAndFollowers());

                                // Navigator.pushNamed(context, "/followingAndFollowers", arguments: {'id':userModel!.id, 'index':0});
                              },
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: user.isProfileLoading.value
                                            ? ""
                                            : '${user.userProfile.value.data!.user!.followers}'
                                                '\n',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 17)),
                                    const TextSpan(
                                        text: followers,
                                        style: TextStyle(color: Colors.grey)),
                                  ])),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                          '${user.userProfile.value.data!.user!.likes!.isEmpty ? 0 : user.userProfile.value.data!.user!.likes}'
                                          '\n',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 17)),
                                  const TextSpan(
                                      text: likes,
                                      style: TextStyle(color: Colors.grey)),
                                ])),
                          ],
                        ).w(MediaQuery.of(context).size.width * .80),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                InboxModel inboxModel = InboxModel(
                                    id: user.isProfileLoading.value
                                        ? 0
                                        : user
                                            .userProfile.value.data!.user!.id!,
                                    userImage: user.isProfileLoading.value
                                        ? ""
                                        : user.userProfile.value.data!.user!
                                            .avatar,
                                    message: "",
                                    msgDate: "",
                                    name: user.isProfileLoading.value
                                        ? ""
                                        : user.userProfile.value.data!.user!
                                            .name!);
                                Navigator.pushNamed(context, '/chatScreen',
                                    arguments: inboxModel);
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(50),
                                elevation: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1)),
                                  child: const Text(
                                    message,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
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
                            GestureDetector(
                              onTap: () {
                                //share();
                                Share.share(
                                    'I found this awesome person in the great platform called Thrill!!!');
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(50),
                                elevation: 10,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1)),
                                    child: const Icon(
                                      Icons.share,
                                      size: 20,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                showFollowers.value = false;
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(50),
                                elevation: 10,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1)),
                                    child: Icon(
                                      showFollowers.value
                                          ? Icons.keyboard_arrow_up_outlined
                                          : Icons.keyboard_arrow_down_outlined,
                                      size: 22,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Visibility(
                          visible: showFollowers.value,
                          child: SizedBox(
                            height: 100,
                            child: user.followersModel.value!.isEmpty
                                ? Center(
                                    child: Text(
                                    "No Followers to Display!",
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ))
                                : ListView.builder(
                                    itemCount:
                                        user.followersModel.value!.length,
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
                                                margin: const EdgeInsets.only(
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
                                                    errorWidget: (a, b, c) =>
                                                        Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: SvgPicture.asset(
                                                        'assets/profile.svg',
                                                        width: 10,
                                                        height: 10,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    imageUrl:
                                                        '${RestUrl.profileUrl}${user.followersModel.value![index].avtars}',
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
                                                  user.followersModel
                                                      .value![index].name!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                ))
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Text(
                          "${user.userProfile.value.data!.user?.bio}",
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ).w(MediaQuery.of(context).size.width * .85),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/link.svg',
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "${user.userProfile.value.data!.user!.websiteUrl}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DefaultTabController(
                          length: 2,
                          initialIndex: selectedTab.value,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.grey.shade400, width: 1),
                                    bottom: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1))),
                            child: TabBar(
                                onTap: (int index) {
                                  selectedTab.value = index;
                                },
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                indicatorColor: Colors.black,
                                indicatorPadding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                tabs: [
                                  Tab(
                                    icon: SvgPicture.asset(
                                      'assets/feedTab.svg',
                                      color: selectedTab.value == 0
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Tab(
                                    icon: SvgPicture.asset('assets/favTab.svg',
                                        color: selectedTab.value == 2
                                            ? Colors.black
                                            : Colors.grey),
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
        builder: (videosController) => Flexible(
              child: GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1.8,
                      mainAxisSpacing: 1.8),
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
                        padding: const EdgeInsets.all(2),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 1.8,
                                mainAxisSpacing: 1.8),
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
