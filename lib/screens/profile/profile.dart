import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import '../../rest/rest_url.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();

  static const String routeName = '/profile';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => Profile(),
    );
  }
}

class _ProfileState extends State<Profile> {
  int selectedTab = 2;
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
            if (state is ProfileInProcess) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ProfileLoaded) {
              return Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Text(
                        state.userModel.name.isNotEmpty
                            ? state.userModel.name
                            : 'anonymous',
                        style: const TextStyle(fontSize: 20),
                      )),
                      IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/setting");
                          },
                          icon: const Icon(Icons.more_horiz))
                    ],
                  ),
                  Divider(
                    height: 5,
                    color: Colors.grey.shade400,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                          height: 111,
                          width: 111,
                          decoration:  BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ColorManager.spinColorDivider)
                          ),
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
                                child: SvgPicture.asset('assets/profile.svg',width: 10,height: 10,fit: BoxFit.contain,),
                              )),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '@${state.userModel.username.isNotEmpty ? state.userModel.username : 'anonymous'}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                state.userModel.is_verified.contains('1')
                                    ? SvgPicture.asset(
                                        'assets/verified.svg',
                                      )
                                    : const SizedBox(width: 2),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              userReferralCount +
                                  state.userModel.referral_count,
                              style: const TextStyle(
                                  color: ColorManager.cyan, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: '${state.userModel.following} \n',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 17)),
                                  const TextSpan(
                                      text: following,
                                      style: TextStyle(color: Colors.grey)),
                                ])),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: '${state.userModel.followers}' '\n',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 17)),
                                  const TextSpan(
                                      text: followers,
                                      style: TextStyle(color: Colors.grey)),
                                ])),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: '${state.userModel.likes} \n',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 17)),
                                  const TextSpan(
                                      text: likes,
                                      style: TextStyle(color: Colors.grey)),
                                ])),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ).w(getWidth(context) * .90),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    state.userModel.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ).w(getWidth(context) * .85),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.userModel.youtube.isEmpty
                      ? const SizedBox(width: 1,) : IconButton(
                        onPressed: () {},
                        iconSize: 25,
                        padding: const EdgeInsets.only(),
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.asset('assets/youtube.svg'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      state.userModel.facebook.isEmpty
                          ? const SizedBox(width: 1,) : IconButton(
                        onPressed: () {},
                        iconSize: 25,
                        padding: const EdgeInsets.only(),
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.asset('assets/facebook.svg'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      state.userModel.instagram.isEmpty
                          ? const SizedBox(width: 1,) : IconButton(
                        onPressed: () {},
                        iconSize: 25,
                        padding: const EdgeInsets.only(),
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.asset('assets/insta.svg'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      state.userModel.twitter.isEmpty
                          ? const SizedBox(width: 1,) : IconButton(
                        onPressed: () {},
                        iconSize: 25,
                        padding: const EdgeInsets.only(),
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.asset('assets/twitter.svg'),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    level,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Container(
                    width: getWidth(context) * .85,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1)),
                    child: Row(
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          margin: const EdgeInsets.only(left: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              shape: BoxShape.circle),
                          child: Text(
                            state.userModel.levels.current,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                                overlayShape: SliderComponentShape.noOverlay,
                                thumbShape: SliderComponentShape.noThumb,
                                trackHeight: 3),
                            child: Slider(
                                max: 100,
                                min: 0,
                                value: double.parse(
                                    state.userModel.levels.progress),
                                activeColor: ColorManager.cyan,
                                onChanged: (val) {}),
                          ),
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Text(
                            state.userModel.levels.next,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/editProfile',
                                  arguments: state.userModel)
                              .then((value) async {
                            var pref = await SharedPreferences.getInstance();
                            var currentUser = pref.getString('currentUser');
                            UserModel current =
                                UserModel.fromJson(jsonDecode(currentUser!));
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
                            setState(() {});
                          });
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(50),
                          elevation: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: const Text(
                              editProfile,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/referral');
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(50),
                          elevation: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: const Text(
                              inviteUser,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/favourites');
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(50),
                          elevation: 10,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border:
                                      Border.all(color: Colors.grey, width: 1)),
                              child: const Icon(Icons.bookmark_outline_sharp)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultTabController(
                    length: 3,
                    initialIndex: selectedTab,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: Colors.grey.shade400, width: 1),
                              bottom: BorderSide(
                                  color: Colors.grey.shade400, width: 1))),
                      child: TabBar(
                          onTap: (int index) {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          indicatorColor: Colors.black,
                          indicatorPadding:
                              const EdgeInsets.symmetric(horizontal: 30),
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
                              icon: SvgPicture.asset('assets/favTab.svg',
                                  color: selectedTab == 2
                                      ? Colors.black
                                      : Colors.grey),
                            )
                          ]),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  tabview(state.userModel)
                ],
              ).h(getHeight(context) + 3 * 80).scrollVertical();
            } else {
              return const Center(
                child: Text("Something went wrong"),
              );
            }
          }),
        ),
      ),
    );
  }

  tabview(UserModel userModel) {
    if (selectedTab == 0) {
      return feed();
    } else if (selectedTab == 1) {
      return lock();
    } else {
      return fav(userModel);
    }
  }

  feed() {
    return Flexible(
      child: GridView.builder(
          padding: const EdgeInsets.all(2),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 1.8, mainAxisSpacing: 1.8),
          itemCount: 9,
          itemBuilder: (BuildContext context, int index) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                    placeholder: (a, b) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                    fit: BoxFit.cover,
                    imageUrl:
                        'https://media-cldnry.s-nbcnews.com/image/upload/newscms/2019_02/2709956/190109-tiktok-app-ew-124p.jpg'),
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
                          '${Random().nextInt(500)}M',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                        Text(
                          '${Random().nextInt(10) + 1}M',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ))
              ],
            );
          }),
    );
  }

  lock() {
    return const SizedBox();
  }

  fav(UserModel userModel) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          const TextSpan(
              text: '\n\n\n' "This user's liked videos or private",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          TextSpan(
              text: '\n\n'
                  "Videos liked by @ ${userModel.username.isNotEmpty ? userModel.username : 'anonymous'} are currently hidden",
              style: const TextStyle(fontSize: 17, color: Colors.grey))
        ]));
  }
}
