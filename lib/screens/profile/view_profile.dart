import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import '../../models/video_model.dart';
import '../../rest/rest_url.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key, required this.mapData}) : super(key: key);
  final Map mapData;

  @override
  State<ViewProfile> createState() => _ViewProfileState();

  static const String routeName = '/viewProfile';

  static Route route({required Map map}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  ViewProfile(mapData: map),
     );
  }
}

class _ViewProfileState extends State<ViewProfile> {

  int selectedTab = 0;
  UserModel? userModel;
  List<String> followList = List.empty(growable: true);
  List<VideoModel> publicVideos = List.empty(growable: true);
  List<VideoModel> favVideos = List.empty(growable: true);
  bool isPublicVideosLoaded = false, isFavVideosLoaded = false;

  @override
  void initState() {
    getFollowList();
      if(widget.mapData["getProfile"]){
        getProfile();
      } else {
        setState(()=>userModel = widget.mapData["userModel"]);
      }
    getUserPublicVideos(widget.mapData["getProfile"]?widget.mapData["id"]:userModel?.id);
    getUserLikedVideos(widget.mapData["getProfile"]?widget.mapData["id"]:userModel?.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          userModel?.name??" ",
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () {
               Navigator.pushNamed(context, '/notifications');
              },
              color: Colors.grey,
              icon: const Icon(Icons.notifications)),
        ],
      ),
      body: userModel==null?
      const Center(child: CircularProgressIndicator(),):
      Column(
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
              imageUrl:
              userModel!.avatar.isEmpty
                  ? 'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'
                  : '${RestUrl.profileUrl}${userModel!.avatar}',
              placeholder: (a, b) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '@${userModel!.username}',
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
              RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(children: [
                    TextSpan(
                        text: '${userModel?.following}' '\n',
                        style: const TextStyle(color: Colors.black, fontSize: 17)),
                    const TextSpan(
                        text: following, style: TextStyle(color: Colors.grey)),
                  ])),
              Container(
                height: 20,
                width: 1,
                color: Colors.grey.shade300,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(children: [
                    TextSpan(
                        text: '${userModel?.following}' '\n',
                        style: const TextStyle(color: Colors.black, fontSize: 17)),
                    const TextSpan(
                        text: followers, style: TextStyle(color: Colors.grey)),
                  ])),
              Container(
                height: 20,
                width: 1,
                color: Colors.grey.shade300,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(children: [
                    TextSpan(
                        text: '${userModel?.likes}' '\n',
                        style: const TextStyle(color: Colors.black, fontSize: 17)),
                    const TextSpan(text: likes, style: TextStyle(color: Colors.grey)),
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
                      id: userModel!.id,
                      userImage: userModel!.avatar,
                      message: "",
                      msgDate: "",
                      name: userModel!.name
                  );
                 Navigator.pushNamed(context, '/chatScreen', arguments: inboxModel);
                },
                child: Material(
                  borderRadius: BorderRadius.circular(50),
                  elevation: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1)),
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
              GestureDetector(
                onTap: () async {
                  String action = '';
                  if (followList.contains(userModel?.id.toString())) {
                    followList.remove(userModel?.id.toString());
                    //int followers = int.parse(userModel!.followers)-1;
                    action = "unfollow";
                  } else {
                    followList.add(userModel!.id.toString());
                    //int followers = int.parse(userModel!.followers)+1;
                    action = "follow";
                  }
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setStringList('followList', followList);

                  try {
                    //var result =
                    await RestApi.followUserAndUnfollow(userModel!.id,action);
                    //var json = jsonDecode(result.body);
                  } catch (_) {}
                  setState(() {});
                },
                child: Material(
                  borderRadius: BorderRadius.circular(50),
                  elevation: 10,
                  child: Container(
                      height: 32,
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1)),
                    child: SizedBox(height: 10,
                    child: followList.contains(userModel?.id.toString())?
                    SvgPicture.asset('assets/person-check.svg',):
                    const Icon(Icons.person_add_alt_sharp, size: 20,),)
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  //share();
                  Share.share('I found this awesome person in the great platform called Thrill!!!');
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
                              color: Colors.grey.shade300, width: 1)),
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
                onTap: () {},
                child: Material(
                  borderRadius: BorderRadius.circular(50),
                  elevation: 10,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),
                      child: const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 22,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
           Text(
            "${userModel?.bio}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                  "${userModel?.website_url}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
               )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          DefaultTabController(
            length: 2,
            initialIndex: selectedTab,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade400, width: 1),
                      bottom:
                          BorderSide(color: Colors.grey.shade400, width: 1))),
              child: TabBar(
                  onTap: (int index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  indicatorColor: Colors.black,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 30),
                  tabs: [
                    Tab(
                      icon: SvgPicture.asset(
                        'assets/feedTab.svg',
                        color: selectedTab == 0 ? Colors.black : Colors.grey,
                      ),
                    ),
                    Tab(
                      icon: SvgPicture.asset('assets/favTab.svg',
                          color: selectedTab == 2 ? Colors.black : Colors.grey),
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
    );
  }

  getFollowList()async{
    var pref = await SharedPreferences.getInstance();
    followList = pref.getStringList('followList') ?? [];
    setState(() {});
  }

  getProfile()async{
    try{
      var response = await RestApi.getUserProfile(widget.mapData["id"]);
      var json = jsonDecode(response.body);
      userModel = UserModel.fromJson(json["data"]["user"]);
      setState((){});
    } catch(e){
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }

  tabview() {
    if (selectedTab == 0) {
      return feed();
    } else {
      return fav();
    }
  }

  feed() {
    return isPublicVideosLoaded?
    publicVideos.isEmpty?
        const Text("No Videos Found!"):
    Flexible(
      child: GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 1.8, mainAxisSpacing: 1.8),
          itemCount: publicVideos.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (){
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => true, arguments: {'videoModel': publicVideos[index]});
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
                  imgNet('${RestUrl.gifUrl}${publicVideos[index].gif_image}'),
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
                            publicVideos[index].views.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            publicVideos[index].likes.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ))
                ],
              ),
            );
          }),
    ):
    const CircularProgressIndicator();
  }

  fav() {
    return  isFavVideosLoaded?
    favVideos.isEmpty?
    RichText(
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
                  "Videos liked by @${userModel!.username.isNotEmpty ? userModel?.username : 'anonymous'} are currently hidden",
              style: const TextStyle(fontSize: 17, color: Colors.grey))
        ])):
    Flexible(
      child: GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 1.8, mainAxisSpacing: 1.8),
          itemCount: favVideos.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (){
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => true, arguments: {'videoModel': favVideos[index]});
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
                  imgNet('${RestUrl.gifUrl}${favVideos[index].gif_image}'),
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
                            favVideos[index].views.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            favVideos[index].likes.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ))
                ],
              ),
            );
          }),
    ):
    const CircularProgressIndicator();
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
              const Spacer(),
              const Text(
                sendTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
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
              const Spacer(),
              const Text(
                shareTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
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
                    width: 10,
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
                    width: 10,
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
                    width: 10,
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
                    width: 10,
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
                    width: 10,
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
              const Spacer(),
              const Divider(
                height: 10,
                color: Colors.grey,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.flag_outlined,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          report,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.block,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          block,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.email_outlined,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          sendMessage,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 10,
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

  getUserPublicVideos(int userID)async{
    try{
      var response = await RestApi.getUserPublicVideos(userID);
      var json = jsonDecode(response.body);
      List jsonList = json['data'];
      setState(() {
        publicVideos = jsonList.map((e) => VideoModel.fromJson(e)).toList();
        isPublicVideosLoaded = true;
      });
    } catch(e){
      showErrorToast(context, e.toString());
      setState(()=>isPublicVideosLoaded=true);
    }
  }

  getUserLikedVideos(int userID)async{
    try{
      var response = await RestApi.getUserLikedVideo(userID: userID);
      var json = jsonDecode(response.body);
      List jsonList = json['data'];
      setState(() {
        favVideos = jsonList.map((e) => VideoModel.fromJson(e)).toList();
        isFavVideosLoaded = true;
      });
    } catch(e){
      showErrorToast(context, e.toString());
      setState(()=>isFavVideosLoaded=true);
    }
  }
}
