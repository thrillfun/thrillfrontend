import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/screens/home/discover.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/widgets/video_item.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../repository/login/login_repository.dart';
import 'home.dart';
import 'notifications.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();

  static const String routeName = '/';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => ProfileBloc(loginRepository: LoginRepository())
          ..add(ProfileLoading()),
        child: const BottomNavigation(),
      ),
    );
  }
}

class _BottomNavigationState extends State<BottomNavigation> {
  int selectedIndex = 0;
  List screens = [
    const Home(),
    const Discover(),
    const Notifications(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(selectedIndex!=0){
          setState(() {
            selectedIndex=0;
          });
          return false;
        }else {
          return true;
        }
      },
      child: Scaffold(
          bottomNavigationBar: myDrawer(), body: screens[selectedIndex]),
    );
  }

  myDrawer() {
    return Container(
      height: 65,
      padding: const EdgeInsets.only(top: 7),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = 0;
                //reelsPlayerController?.play();
              });
            },
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/home.png',
                    scale: 1.4,
                    width: 20,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                        color:
                            selectedIndex == 0 ? Colors.white : Colors.white60,
                        fontSize: 9),
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
                  });
                } else {
                  showAlertDialog(context);
                }
              });
            },
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/search.png',
                    scale: 1.4,
                    width: 20,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Discover',
                    style: TextStyle(
                        color:
                            selectedIndex == 1 ? Colors.white : Colors.white60,
                        fontSize: 9),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: ()async {
              await isLogined().then((value) {
                if (value) {
                  Navigator.pushNamed(context, '/spin');
                  reelsPlayerController?.pause();
                } else {
                  showAlertDialog(context);
                }
              });

            },
            child: SizedBox(
                width: MediaQuery.of(context).size.width * .24,
                child: Image.asset(
                  'assets/spin.png',
                  scale: 1.4,
                  width: 20,
                )),
          ),
          GestureDetector(
            onTap: ()async {
              await isLogined().then((value) {
                if (value) {
                  setState(() {
                    selectedIndex = 2;
                    reelsPlayerController?.pause();
                  });
                } else {
                  showAlertDialog(context);
                }
              });
            },
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/bell.png',
                    scale: 1.4,
                    width: 20,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Notification',
                    style: TextStyle(
                        color:
                            selectedIndex == 2 ? Colors.white : Colors.white60,
                        fontSize: 9),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: ()async {
              await isLogined().then((value) {
                if (value) {
                  setState(() {
                    selectedIndex = 3;
                    reelsPlayerController?.pause();
                  });
                } else {
                  showAlertDialog(context);
                }
              });
            },
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width * .19,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: selectedIndex == 3 ? 0.99 : 0.60,
                    child: SvgPicture.asset(
                      'assets/profile.svg',
                      width: 20,
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
                        fontSize: 9),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("CANCEL"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Login"),
      content: const Text("Please login your account."),
      actions: [continueButton, cancelButton],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> isLogined() async {
    var instance = await SharedPreferences.getInstance();
    var loginData = instance.getString('currentUser');
    if (loginData != null) {
      return true;
    } else {
      return false;
    }
  }
}
