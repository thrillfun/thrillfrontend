import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/strings.dart';

class SettingAndPrivacy extends StatefulWidget {
  const SettingAndPrivacy({Key? key}) : super(key: key);

  @override
  State<SettingAndPrivacy> createState() => _SettingAndPrivacyState();

  static const String routeName = '/setting';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const SettingAndPrivacy(),
    );
  }

}

class _SettingAndPrivacyState extends State<SettingAndPrivacy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          settingAndPrivacy,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
             Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              title(account),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                Navigator.pushNamed(context, '/manageAccount');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/profile.svg',
                      height: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      manageAccount,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20,),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      privacy,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              /* const SizedBox(
                height: 10,
              ),
             InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/requestVerification');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      requestVerification,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),*/
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/wallet');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      wallet,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/qrcode');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/qr_small.svg',
                      height: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      qrCode,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  //share();
                  Share.share('text');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      shareProfile,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              title(contentAndActivity),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/pushNotification');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_none_outlined, color: Colors.grey, size: 20,),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      pushNotification,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        appLanguage,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ),
                    Text(
                      english,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ],
                ),
              ),
             /* const SizedBox(
                height: 20,
              ),
              title(cacheAndCellularData),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                Navigator.pushNamed(context, '/freeSpace');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restore_from_trash_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      freeUpSpace,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),*/
              const SizedBox(
                height: 20,
              ),
              title(about.toUpperCase()),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_books_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      termsOfService,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_books_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      privacyPolicy,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                Navigator.pushNamed(context, '/customerSupport');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      technicalSupport,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              title(login.toUpperCase()),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  switchAccountLayout();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      switchAccount,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async{
                  SharedPreferences preferences =
                  await SharedPreferences.getInstance();
                  await preferences.clear();
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.signOut();
                  await FacebookAuth.instance.logOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => true);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.login_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      logout,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  title(String txt) {
    return Text(
      txt,
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  share() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (BuildContext context) {
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                sendTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              height: 60,
                              width: 60,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3053232163929.567197ac6e6f5.png',
                                placeholder: (a, b) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'User$index',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                shareTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/message.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          message,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/whatsapp.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          whatsApp,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/facebook (2).png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          facebook,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/messenger.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          messenger,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/sms.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          sms,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                            radius: 60,
                            backgroundColor: Colors.blue,
                            child: SvgPicture.asset(
                              'assets/link.svg',
                              color: Colors.white,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          copyLink,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ).scrollHorizontal(),
              const Divider(
                height: 30,
                color: Colors.grey,
              ),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    cancel,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }

  switchAccountLayout() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (BuildContext context) {
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  const Expanded(
                    child: Text(
                      switchAccount,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                      Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3F3e5C2_4KVWpSSvmBDVb8iPGyRnDB5DVPA&usqp=CAU',
                      placeholder: (a, b) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '@kanikasharma',
                              style: TextStyle(fontSize: 18),
                            ),
                            Icon(
                              Icons.check,
                              size: 30,
                              color: ColorManager.cyan,
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                        const Text('Kanika Sharma')
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    VxCircle(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const Text(
                      addAccount,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          );
        });
  }
}
