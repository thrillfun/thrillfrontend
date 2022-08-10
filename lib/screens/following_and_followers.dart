import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import '../models/follower_model.dart';
import '../widgets/video_item.dart';

class FollowingAndFollowers extends StatefulWidget {
  const FollowingAndFollowers({Key? key, required this.map}) : super(key: key);
  static const String routeName = '/followingAndFollowers';
  final Map map;

  static Route route(Map mapp) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => FollowingAndFollowers(map: mapp,),
    );
  }

  @override
  State<FollowingAndFollowers> createState() => _FollowingAndFollowersState();
}

class _FollowingAndFollowersState extends State<FollowingAndFollowers> {

  bool isLoading = true;
  List<FollowerModel> followerList = List<FollowerModel>.empty(growable: true);
  List<FollowerModel> followingList = List<FollowerModel>.empty(growable: true);
  late int selectedTabIndex = widget.map['index'];

  @override
  void initState() {
    getData();
    try{
      reelsPlayerController?.pause();
    }catch(_){}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: isLoading?
      const Center(child: CircularProgressIndicator(),):
      Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap:()=>setState(()=>selectedTabIndex=0),
                        child: Text(followers,
                          style: TextStyle(
                              color: selectedTabIndex==0?ColorManager.cyan:Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:()=>setState(()=>selectedTabIndex=1),
                        child: Text(following,
                          style: TextStyle(
                              color: selectedTabIndex==1?ColorManager.cyan:Colors.grey,
                              fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedAlign(
                    alignment: selectedTabIndex==0?Alignment.topLeft:Alignment.topRight,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: ColorManager.cyan,
                      height: 3,
                      width: 100,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                    ))
              ],
            ),
          ),
          myTabView()
        ],
      )
    );
  }

  Widget myTabView(){
    if(selectedTabIndex==0){
      if(followerList.isEmpty){
        return Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: getHeight(context)/2.5),
          child: Text("Followers Not Found!", style: Theme.of(context).textTheme.headline3,),
        ),);
      } else {
        return followersTabLayout();
      }
    } else {
      if(followingList.isEmpty){
        return Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: getHeight(context)/2.5),
          child: Text("Nothings Here!", style: Theme.of(context).textTheme.headline3,),
        ),);
      } else {
        return followingTabLayout();
      }
    }
  }

  followersTabLayout(){
    return Expanded(
      child: ListView.builder(
        itemCount: followerList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(2),
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white60)),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (a,b,c)=>Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/profile.svg',
                            width: 10,
                            height: 10,
                            fit: BoxFit.contain,
                            color: Colors.white60,
                          ),
                        ),
                        imageUrl: '${RestUrl.profileUrl}${followerList[index].image}',
                        placeholder: (a, b) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: followerList[index].name+'\n',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const WidgetSpan(child: SizedBox(height: 5,)),
                          TextSpan(
                              text: '\n'+getStarredEmail(followerList[index].email),
                              style: const TextStyle(
                                  color: Colors.black,
                              ),
                          ),
                          TextSpan(
                            text: '\n'+getFormattedDate(followerList[index].date),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ]
                      )
                  ),
                )

              ],
            ),
          );
        },

      ),
    );
  }

  followingTabLayout(){
    return Expanded(
      child: ListView.builder(
        itemCount: followingList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(2),
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white60)),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (a,b,c)=>Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/profile.svg',
                            width: 10,
                            height: 10,
                            fit: BoxFit.contain,
                            color: Colors.white60,
                          ),
                        ),
                        imageUrl: '${RestUrl.profileUrl}${followingList[index].image}',
                        placeholder: (a, b) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: followingList[index].name+'\n',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            const WidgetSpan(child: SizedBox(height: 5,)),
                            TextSpan(
                                text: '\n'+getStarredEmail(followingList[index].email),
                                style: const TextStyle(
                                  color: Colors.black,
                                )
                            ),
                            TextSpan(
                              text: '\n'+getFormattedDate(followingList[index].date),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ]
                      )
                  ),
                )

              ],
            ),
          );
        },

      ),
    );
  }

  String getStarredEmail(String email){
    List _email =  email.split('');
    String string = '';
    if(email.isEmpty){
      string = "unknown";
    } else {
      if(_email.length >= 3){
        string += _email[0];
        string += _email[1];
        string += _email[2];
        string += "****@";
        string += email.split('@').last;
      } else {
        string += _email[0];
        string += "****@";
        string += email.split('@').last;
      }
    }
    return string;
  }

  getData()async{
    try{
      var followersResponse = await RestApi.getFollowerList(widget.map['id']);
      var followingResponse = await RestApi.getFollowingList(widget.map['id']);
      var followersJson = jsonDecode(followersResponse.body);
      var followingJson = jsonDecode(followingResponse.body);
      if(followersJson['status']){
        List _followersList = followersJson['data'] as List;
        followerList = _followersList.map((e) => FollowerModel.fromJson(e)).toList();
      } else {
        showErrorToast(context, followersJson['message']);
      }
      if(followingJson['status']){
        List _followingList = followingJson['data'] as List;
        followingList = _followingList.map((e) => FollowerModel.fromJson(e)).toList();
      } else {
        showErrorToast(context, followingJson['message']);
      }
      setState(()=>isLoading=false);
    }catch(e){
      isLoading=false;
      showErrorToast(context, e.toString());
      setState((){});
    }
  }

  String getFormattedDate(String date){
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MM/yy').format(dateTime);
  }
}
