import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/video/video_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';
import 'package:get/get.dart';



class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();

  static const String routeName = '/profile';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const Profile(),
    );
  }
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
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
          } else if (state is ProfileLoaded) {}
        },
        child: SafeArea(
          child:
              BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                      [IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back)),IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/setting");
                          },
                          icon: const Icon(Icons.settings))],),),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(2),
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorManager.spinColorDivider)),
                            child: state.userModel.avatar.isNotEmpty
                                ? ClipOval(
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                '${RestUrl.profileUrl}${state.userModel.avatar}',
                                placeholder: (a, b) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                'assets/profile.svg',
                                width: 10,
                                height: 10,
                                fit: BoxFit.contain,
                              ),
                            )),
                        // Expanded(
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           state.userModel.is_verified.contains('1')
                        //               ? SvgPicture.asset(
                        //             'assets/verified.svg',
                        //           )
                        //               : const SizedBox(width: 2),
                        //         ],
                        //       ),
                        //       // Text("$userReferralCount ${state.userModel.referral_count.isEmpty ? "0" : state.userModel.referral_count}",
                        //       //   style: const TextStyle(
                        //       //       color: ColorManager.cyan, fontSize: 15),
                        //       // ),
                        //
                        //
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20,top: 5),
                      child:   Text(state.userModel.username,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "/followingAndFollowers",
                                  arguments: {
                                    'id': state.userModel.id,
                                    'index': 1
                                  });
                            },
                            child: Column(
                              children: [
                                Text(
                                    '${state.userModel.following.isEmpty ? 0 : state.userModel.following}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold)),
                                const Text(following,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.bold))
                              ],
                            )),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "/followingAndFollowers",
                                  arguments: {
                                    'id': state.userModel.id,
                                    'index': 0
                                  });
                            },
                            child: Column(
                              children: [
                                Text(
                                    '${state.userModel.followers.isEmpty ? 0 : state.userModel.followers}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold)),
                                const Text(followers,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight:
                                        FontWeight.bold))
                              ],
                            )),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        Column(
                          children: [
                            Text(
                                '${state.userModel.likes.isEmpty ? 0 : state.userModel.likes}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
                      margin: EdgeInsets.only(left: 10, top: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        '${state.userModel.name.isNotEmpty ? state.userModel.name : 'anonymous'}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.userModel.bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                   Container(
                     margin: EdgeInsets.only(left: 10),
                     alignment: Alignment.centerLeft,
                     width: MediaQuery.of(context).size.width,
                       child:  Row(children: [
                         Icon(Icons.link),
                         SizedBox(width: 5,),
                         InkWell(
                         onTap: (){
                           Uri openInBrowser = Uri(
                             scheme: 'https',
                             path:
                             "${state.userModel.website_url}",
                           );
                           launchUrl(openInBrowser,
                               mode: LaunchMode.externalApplication);
                         },
                         child: Text(
                           state.userModel.website_url,
                           maxLines: 3,
                           textAlign: TextAlign.start,
                           overflow: TextOverflow.ellipsis,
                           style: TextStyle(fontSize: 15,color: Colors.blue.shade300),
                         ),
                       )],),),

                    // Container(
                    //   width: MediaQuery.of(context).size.width,
                    //   alignment: Alignment.centerLeft,
                    //   margin: EdgeInsets.only(left: 10, bottom: 10),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       Visibility(
                    //         visible: state.userModel.youtube.isNotEmpty,
                    //         child: IconButton(
                    //           onPressed: () {
                    //             Uri openInBrowser = Uri(
                    //               scheme: 'https',
                    //               path:
                    //                   "www.youtube.com/${state.userModel.youtube}",
                    //             );
                    //             launchUrl(openInBrowser,
                    //                 mode: LaunchMode.externalApplication);
                    //           },
                    //           iconSize: 25,
                    //           padding: const EdgeInsets.only(),
                    //           constraints: const BoxConstraints(),
                    //           icon: SvgPicture.asset('assets/youtube.svg'),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 5,
                    //       ),
                    //       Visibility(
                    //         visible: state.userModel.facebook.isNotEmpty,
                    //         child: IconButton(
                    //           onPressed: () {
                    //             Uri openInBrowser = Uri(
                    //               scheme: 'https',
                    //               path:
                    //                   "www.facebook.com/${state.userModel.facebook}",
                    //             );
                    //             launchUrl(openInBrowser,
                    //                 mode: LaunchMode.externalApplication);
                    //           },
                    //           iconSize: 25,
                    //           padding: const EdgeInsets.only(),
                    //           constraints: const BoxConstraints(),
                    //           icon: SvgPicture.asset('assets/facebook.svg'),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 5,
                    //       ),
                    //       Visibility(
                    //         visible: state.userModel.instagram.isNotEmpty,
                    //         child: IconButton(
                    //           onPressed: () {
                    //             Uri openInBrowser = Uri(
                    //               scheme: 'https',
                    //               path:
                    //                   "www.instagram.com/${state.userModel.instagram}",
                    //             );
                    //             launchUrl(openInBrowser,
                    //                 mode: LaunchMode.externalApplication);
                    //           },
                    //           iconSize: 25,
                    //           padding: const EdgeInsets.only(),
                    //           constraints: const BoxConstraints(),
                    //           icon: SvgPicture.asset('assets/insta.svg'),
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       Visibility(
                    //         visible: state.userModel.twitter.isNotEmpty,
                    //         child: IconButton(
                    //           onPressed: () {
                    //             Uri openInBrowser = Uri(
                    //               scheme: 'https',
                    //               path:
                    //                   "www.twitter.com/${state.userModel.twitter}",
                    //             );
                    //             launchUrl(openInBrowser,
                    //                 mode: LaunchMode.externalApplication);
                    //           },
                    //           iconSize: 25,
                    //           padding: const EdgeInsets.only(),
                    //           constraints: const BoxConstraints(),
                    //           icon: SvgPicture.asset('assets/twitter.svg'),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    // const Text(
                    //   level,
                    //   style: TextStyle(
                    //       fontSize: 22,
                    //       color: Colors.grey,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(
                    //   height: 2,
                    // ),
                    // Container(
                    //   width: getWidth(context) * .85,
                    //   height: 40,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(25),
                    //       border:
                    //           Border.all(color: Colors.grey.shade300, width: 1)),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         height: 25,
                    //         width: 25,
                    //         margin: const EdgeInsets.only(left: 10),
                    //         alignment: Alignment.center,
                    //         decoration: BoxDecoration(
                    //             color: Colors.blue.shade900,
                    //             shape: BoxShape.circle),
                    //         child: Text(
                    //           state.userModel.levels.current,
                    //           style: const TextStyle(
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 12),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: SliderTheme(
                    //           data: SliderThemeData(
                    //               overlayShape: SliderComponentShape.noOverlay,
                    //               thumbShape: SliderComponentShape.noThumb,
                    //               trackHeight: 3),
                    //           child: Slider(
                    //               max: int.parse(state.userModel.levels.max_level)*10,
                    //               min: 0,
                    //               value: double.parse(
                    //                   state.userModel.levels.current)*10,
                    //               activeColor: ColorManager.cyan,
                    //               onChanged: (val) {}),
                    //         ),
                    //       ),
                    //       Container(
                    //         height: 25,
                    //         width: 25,
                    //         alignment: Alignment.center,
                    //         margin: const EdgeInsets.only(right: 10),
                    //         decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             border: Border.all(color: Colors.grey, width: 1)),
                    //         child: Text(
                    //           state.userModel.levels.next,
                    //           style: const TextStyle(
                    //               color: Colors.grey,
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 12),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/editProfile',
                                        arguments: state.userModel)
                                    .then((value) async {
                                  var pref =
                                      await SharedPreferences.getInstance();
                                  var currentUser =
                                      pref.getString('currentUser');
                                  UserModel current = UserModel.fromJson(
                                      jsonDecode(currentUser!));
                                  state.userModel.copyWith(
                                      username: state.userModel.username =
                                          current.username);
                                  state.userModel.copyWith(
                                      first_name: state.userModel.first_name =
                                          current.first_name);
                                  state.userModel.copyWith(
                                      last_name: state.userModel.last_name =
                                          current.last_name);
                                  state.userModel.copyWith(
                                      gender: state.userModel.gender =
                                          current.gender);
                                  state.userModel.copyWith(
                                      website_url: state.userModel.website_url =
                                          current.website_url);
                                  state.userModel.copyWith(
                                      bio: state.userModel.bio = current.bio);
                                  state.userModel.copyWith(
                                      youtube: state.userModel.youtube =
                                          current.youtube);
                                  state.userModel.copyWith(
                                      facebook: state.userModel.facebook =
                                          current.facebook);
                                  state.userModel.copyWith(
                                      instagram: state.userModel.instagram =
                                          current.instagram);
                                  state.userModel.copyWith(
                                      twitter: state.userModel.twitter =
                                          current.twitter);
                                  state.userModel.copyWith(
                                      avatar: state.userModel.avatar =
                                          current.avatar);
                                  state.userModel.copyWith(
                                      name: state.userModel.name =
                                          current.name);
                                  setState(() {});
                                });
                              },
                              child: Material(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                                elevation: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.transparent, width: 1)),
                                  child: const Text(
                                    editProfile,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/referral');
                              },
                              child: Material(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                                elevation: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.transparent, width: 1)),
                                  child: const Text(
                                    inviteUser,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/favourites');
                              },
                              child: Material(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                                elevation: 10,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.transparent,
                                            width: 1)),
                                    child: const Icon(
                                        Icons.bookmark_outline_sharp)),
                              ),
                            ),
                            flex: 0,
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
                            onTap: (int index) {
                              setState(() {
                                selectedTab = index;
                              });
                            },
                            padding: const EdgeInsets.symmetric(
                                horizontal: 110, vertical: 10),
                            indicatorColor: Colors.black26,
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            tabs: [
                              Tab(
                                icon: SvgPicture.asset(
                                  'assets/feedTab.svg',
                                  color: selectedTab == 0
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              Tab(
                                icon: Icon(Icons.lock,
                                    color: selectedTab == 1
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              Tab(
                                icon: Icon(Icons.favorite,
                                    color: selectedTab == 2
                                        ? Colors.black
                                        : Colors.grey),
                              )
                            ])),
                    const SizedBox(
                      height: 5,
                    ),
                    tabview(
                        state.userModel,
                        state.publicList.isEmpty ? [] : state.publicList,
                        state.privateList.isEmpty ? [] : state.privateList,
                        state.likesList.isEmpty ? [] : state.likesList)
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ),
      ),
    );
  }

  tabview(UserModel userModel, List<VideoModel> publicList,
      List<VideoModel> privateList, List<VideoModel> likesList) {
    if (selectedTab == 0) {
      return feed(publicList);
    } else if (selectedTab == 1) {
      return lock(privateList);
    } else {
      return fav(userModel, likesList);
    }
  }

  feed(List<VideoModel> publicList) {
    return publicList.isEmpty
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
            padding: const EdgeInsets.all(2),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
            itemCount: publicList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/',
                      arguments: {'videoModel': publicList[index]});
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
                    imgNet('${RestUrl.gifUrl}${publicList[index].gif_image}'),
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
                              publicList[index].views.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              publicList[index].likes.toString(),
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
                                publicList[index].id, publicList, index);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.red,
                          icon: const Icon(Icons.delete_forever_outlined)),
                    )
                  ],
                ),
              );
            });
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
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: '\n\n'
                      "Private Videos are currently not available",
                  style: TextStyle(fontSize: 17, color: Colors.grey))
            ]))
        : GridView.builder(
            padding: const EdgeInsets.all(2),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
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
                              Icons.favorite,
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
            padding: const EdgeInsets.all(2),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 2.5, mainAxisSpacing: 2.5),
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
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              likesList[index].views.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            const Icon(
                              Icons.favorite,
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
                                  Navigator.pop(context);
                                  progressDialogue(context);
                                  var response =
                                      await RestApi.deleteVideo(videoID);
                                  var json = jsonDecode(response.body);
                                  closeDialogue(context);
                                  if (json['status']) {
                                    list.removeAt(index);
                                    showSuccessToast(
                                        context, json['message'].toString());
                                    setState(() {});
                                    BlocProvider.of<VideoBloc>(context).add(
                                        const VideoLoading(
                                            selectedTabIndex: 1));
                                    //Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>true);
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
