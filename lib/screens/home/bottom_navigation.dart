import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/discover_getx.dart';
import 'package:thrill/screens/home/home.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/spin/spin_the_wheel.dart';
import 'package:thrill/widgets/better_video_player.dart';
import 'package:thrill/widgets/fab_items.dart';
import 'package:thrill/widgets/video_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../blocs/profile/profile_bloc.dart';
import '../../main.dart';
import '../../repository/login/login_repository.dart';
import '../../utils/util.dart';
import 'notifications.dart';

bool popupDisplayed = false;
var index = 0;

class BottomNavigation extends StatefulWidget {
  BottomNavigation({Key? key, this.mapData}) : super(key: key);
  final Map? mapData;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  var discoverController = Get.find<DiscoverController>();
  late AnimationController _animationController;
  late Animation _animation;

  int selectedIndex = 0;
  late List<Widget> screens = [
    const HomeGetx(),
    DiscoverGetx(),
    const Notifications(),
    Profile(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => ShowCaseWidget.of(context).startShowCase([key]));

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 5.0, end: 15.0).animate(_animationController)
      ..addStatusListener((status) {
        setState(() {});
      });
    if (widget.mapData?['index'] != null)
      selectedIndex = widget.mapData?['index'] ?? 0;
    if (!popupDisplayed) {
      showPromotionalPopup();
      popupDisplayed = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (selectedIndex != 0) {
            setState(() {
              selectedIndex = 0;
              shouldAutoPlayReel = true;
            });
            return false;
          } else {
            showExitDialog();
            return false;
          }
        },
        child: Scaffold(
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(80)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff00CCC9).withOpacity(0.7),
                    blurRadius: 15,
                    spreadRadius: 15,
                  )
                ]),
            child: Container(
              height: 60,
              width: 60,
              child: Showcase(
                  showcaseBackgroundColor: Color.fromARGB(255, 1, 180, 177),
                  shapeBorder: const CircleBorder(),
                  radius: const BorderRadius.all(Radius.circular(40)),
                  tipBorderRadius: const BorderRadius.all(Radius.circular(8)),
                  overlayPadding: const EdgeInsets.all(5),
                  key: key,
                  child: FloatingActionButton(
                    child: SvgPicture.network(
                      RestUrl.assetsUrl + 'spin_wheel.svg',
                      //scale: 1.4,
                      fit: BoxFit.fill,
                    ),
                    onPressed: () => Get.to(() => const SpinTheWheel()),
                  ),
                  textColor: Colors.white,
                  descTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  description: "check out the spin wheel to earn rewards!!"),
            ),
          ),
          bottomNavigationBar: myDrawer2(),
          body: IndexedStack(index: selectedIndex, children: screens),
        ));
  }

  myDrawer2() {
    return Container(
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(color: Color(0xff262B41), blurRadius: 100, spreadRadius: 15),
        BoxShadow(color: Color(0xff000000), blurRadius: 100, spreadRadius: 15),
      ]),
      child: FABBottomAppBar(
        backgroundColor: Colors.green,
        color: Color(0xffB2E3E3),
        selectedColor: Colors.white,
        iconSize: 35,
        notchedShape: const CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: IconlyLight.home, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.discovery, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.notification, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.profile, text: ''),
        ],
      ),
    );
  }

  void _selectedTab(index) async {
    if (index == 0) {
      VideosController().getAllVideos();
    }
    if (index == 1) {
      DiscoverController().getHashTagsList();
      DiscoverController().getBanners();
      DiscoverController().getTopHashTags();
    }
    if (index == 3) {
      VideosController().getUserVideos();
      VideosController().getFollowingVideos();
      VideosController().getUserPrivateVideos();
      VideosController().getUserLikedVideos();
    }

    if (index >= 0) {
      await isLogined().then((value) {
        if (value) {
          setState(() {
            selectedIndex = index;
          });
        } else {
          showLoginAlert();
        }
      });
    }
  }

  myDrawer() {
    return Container(
      color: Colors.black,
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = 0;
                //reelsPlayerController?.play();
                shouldAutoPlayReel = true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.house_outlined,
                    color: selectedIndex == 0 ? Colors.white : Colors.white60,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                        color:
                            selectedIndex == 0 ? Colors.white : Colors.white60,
                        fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await isLogined().then((value) {
                if (value) {
                  setState(() {
                    selectedIndex = 1;
                    reelsPlayerController?.pause();
                    shouldAutoPlayReel = false;
                  });
                } else {
                  showLoginAlert();
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: selectedIndex == 1 ? Colors.white : Colors.white60,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Discover',
                    style: TextStyle(
                        color:
                            selectedIndex == 1 ? Colors.white : Colors.white60,
                        fontSize: 11),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await isLogined().then((value) async {
                if (value) {
                  reelsPlayerController?.pause();
                  shouldAutoPlayReel = false;
                  await Navigator.pushNamed(context, '/spin');
                  reelsPlayerController?.play();
                  shouldAutoPlayReel = true;
                  setState(() => selectedIndex = 0);
                } else {
                  showLoginAlert();
                }
              });
            },
            child: SizedBox(
                width: MediaQuery.of(context).size.width * .24,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    'assets/spin.png',
                    //scale: 1.4,
                    width: 20,
                  ),
                )),
          ),
          GestureDetector(
            onTap: () async {
              await isLogined().then((value) {
                if (value) {
                  setState(() {
                    selectedIndex = 2;
                    reelsPlayerController?.pause();
                    shouldAutoPlayReel = false;
                  });
                } else {
                  showLoginAlert();
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications,
                    color: selectedIndex == 2 ? Colors.white : Colors.white60,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Notification',
                    style: TextStyle(
                        color:
                            selectedIndex == 2 ? Colors.white : Colors.white60,
                        fontSize: 11),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await isLogined().then((value) {
                if (value) {
                  setState(() {
                    selectedIndex = 3;
                    reelsPlayerController?.pause();
                    shouldAutoPlayReel = false;
                    //BlocProvider.of<ProfileBloc>(context).add( const ProfileLoading());
                  });
                } else {
                  showLoginAlert();
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: selectedIndex == 3 ? 0.99 : 0.60,
                    child: Icon(
                      Icons.person_outline,
                      color: selectedIndex == 3 ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                        color:
                            selectedIndex == 3 ? Colors.white : Colors.white60,
                        fontSize: 11),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> isLogined() async {
    var token = GetStorage().read("token");
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  showPromotionalPopup() async {
    var instance = await SharedPreferences.getInstance();
    var loginData = instance.getString('currentUser');
    if (loginData != null) {
      String imgPath = '';
      String redirectPath = '';
      var response = await RestApi.getSiteSettings();
      var json = jsonDecode(response.body);
      if (json['status']) {
        List jsonList = json['data'];
        for (var el in jsonList) {
          if (el['name'] == 'advertisement_image') {
            imgPath = el['value'] ?? '';
          } else if (el['name'] == 'advertisement_link') {
            redirectPath = el['value'] ?? '';
          }
        }
      }
      await Future.delayed(const Duration(seconds: 4));
      if (imgPath.isNotEmpty) {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (_) => Material(
                  type: MaterialType.transparency,
                  child: Center(
                    child: Container(
                      height: getHeight(navigatorKey.currentContext!) * .90,
                      width: getWidth(navigatorKey.currentContext!) * .90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                if (redirectPath.isNotEmpty) {
                                  Uri openInBrowser = Uri(
                                    scheme: 'https',
                                    path: redirectPath,
                                  );
                                  launchUrl(openInBrowser,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl: "${RestUrl.profileUrl}$imgPath",
                                placeholder: (a, b) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: GestureDetector(
                              onTap: () {
                                Get.back(closeOverlays: true);
                              },
                              child: VxCircle(
                                radius: 30,
                                backgroundColor: Colors.red,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
      }
    }
  }

  showExitDialog() {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: getWidth(context) * .80,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          exitDialog,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Get.back(closeOverlays: true);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  fixedSize: Size(getWidth(context) * .26, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text(no)),
                          const SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  fixedSize: Size(getWidth(context) * .26, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text(yes)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
