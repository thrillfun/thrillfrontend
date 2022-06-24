import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/hashtags_model.dart';

import '../common/color.dart';
import '../common/strings.dart';
import '../models/video_model.dart';
import '../rest/rest_api.dart';
import '../rest/rest_url.dart';
import '../utils/util.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  State<Favourites> createState() => _FavouritesState();

  static const String routeName = '/favourites';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const Favourites(),
    );
  }
}

class _FavouritesState extends State<Favourites> {
  int selectedTab = 0;
  bool isLoading = true;
  List<String> favId = List<String>.empty(growable: true);
  List<HashtagModel> favHastag = List<HashtagModel>.empty(growable: true);
  List<VideoModel> favVideo = List<VideoModel>.empty(growable: true);
  List<AddSoundModel> favSound = List<AddSoundModel>.empty(growable: true);

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        centerTitle: true,
        title: const Text(
          favourites,
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Column(
        children: [
          DefaultTabController(
            length: 3,
            initialIndex: selectedTab,
            child: TabBar(
                onTap: (int index) {
                  setState(() {
                    selectedTab = index;
                  });
                },
                indicatorColor: ColorManager.cyan,
                tabs: [
                  Tab(
                    child: Text(
                      videos,
                      style: TextStyle(
                          fontSize: 17,
                          color: selectedTab == 0
                              ? ColorManager.cyan
                              : Colors.grey),
                    ),
                  ),
                  Tab(
                    child: Text(
                      sounds,
                      style: TextStyle(
                          fontSize: 17,
                          color: selectedTab == 1
                              ? ColorManager.cyan
                              : Colors.grey),
                    ),
                  ),
                  Tab(
                    child: Text(
                      hashTag,
                      style: TextStyle(
                          fontSize: 17,
                          color: selectedTab == 2
                              ? ColorManager.cyan
                              : Colors.grey),
                    ),
                  )
                ]),
          ),
          const SizedBox(
            height: 5,
          ),
          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Colors.lightBlueAccent),
                )
              : tabview()
        ],
      ),
    );
  }

  tabview() {
    if (selectedTab == 0) {
      return video();
    } else if (selectedTab == 1) {
      return sound();
    } else {
      return hashtag();
    }
  }

  Widget video() {
    return Column(
      children: [
        favVideo.isEmpty
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: whoops + '\n',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 20)),
                  TextSpan(
                      text: '\nThere is no favourite video so far.',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ]))
            : GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.8,
                    mainAxisSpacing: 1.8),
                itemCount: favVideo.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                          placeholder: (a, b) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          fit: BoxFit.cover,
                          imageUrl: favVideo[index].gif_image.isEmpty
                              ? '${RestUrl.thambUrl}thumb-not-available.png'
                              : '${RestUrl.gifUrl}${favVideo[index].gif_image}'),
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
                                favVideo[index].views.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                favVideo[index].likes.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ))
                    ],
                  );
                }),
      ],
    );
  }

  Widget sound() {
    return Column(
      children: [
        favSound.isEmpty
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: whoops + '\n',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 20)),
                  TextSpan(
                      text: '\nThere is no favourite sounds so far.',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ]))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: favSound.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          color: ColorManager.cyan,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/play.svg',
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                favSound[index].name,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap:()async{
                                        var result =
                                            await RestApi.addAndRemoveFavariteSoundHastag(
                                            favSound[index].id, "sound", 0);
                                        var json = jsonDecode(result.body);
                                        if (json['status']) {
                                          favSound.removeAt(index);
                                          showErrorToast(context, json['message']);
                                        } else {
                                          showErrorToast(context, json['message']);
                                        }
                                        setState(() {});
                                    },
                                    child: Material(
                                      borderRadius: BorderRadius.circular(50),
                                      elevation: 10,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1)),
                                          child: const Icon(
                                              Icons.bookmark,color: Colors.lightBlueAccent)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }),
      ],
    );
  }

  Widget hashtag() {
    return Column(
      children: [
        favHastag.isEmpty
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: whoops + '\n',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 20)),
                  TextSpan(
                      text: '\nThere is no favourite hashtag so far.',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ]))
            : GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  childAspectRatio: 1.5,
                ),
                itemCount: favHastag.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 150.0,
                    height: 65.0,
                    child: Card(
                      color: Colors.grey,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          '#${favHastag[index].name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  void loadData() async {
    var result = await RestApi.getFavriteItems();
    var json = jsonDecode(result.body);
    if (json['status']) {
      List jsonList = json['data']['hash_tags'] as List;
      favHastag = jsonList.map((e) => HashtagModel.fromJson(e)).toList();

      favId =
          jsonList.map((e) => HashtagModel.fromJson(e).id.toString()).toList();

      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setStringList('favTag', favId);

      List jsonVideoList = json['data']['videos'] as List;
      favVideo = jsonVideoList.map((e) => VideoModel.fromJson(e)).toList();

      List jsonSoundList = json['data']['sounds'] as List;
      favSound = jsonSoundList.map((e) => AddSoundModel.fromJson(e)).toList();
    }
    isLoading = false;
    setState(() {});
  }
}
