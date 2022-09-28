import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import '../common/strings.dart';
import '../models/hashtags_model.dart';
import '../models/vidio_discover_model.dart';

class TagDetails extends StatefulWidget {
  const TagDetails({Key? key, required this.tag}) : super(key: key);
  final DiscoverVideo tag;

  @override
  State<TagDetails> createState() => _TagDetailsState();
  static const String routeName = '/tagDetails';

  static Route route({required DiscoverVideo video}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => TagDetails(
        tag: video,
      ),
    );
  }
}

class _TagDetailsState extends State<TagDetails> {
  List<String> favTagList = List<String>.empty(growable: true);
  bool isLoading = true;

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
        title: Text(
          widget.tag.hashtag_name,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.lightBlue))
          : Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/hash.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          widget.tag.hashtag_name,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Text(
                          videos,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (favTagList
                                .contains(widget.tag.hashtag_id.toString())) {
                              var result =
                                  await RestApi.addAndRemoveFavariteSoundHastag(
                                      widget.tag.hashtag_id, "hashtag", 0);
                              var json = jsonDecode(result.body);
                              if (json['status']) {
                                favTagList
                                    .remove(widget.tag.hashtag_id.toString());
                                showSuccessToast(context, json['message']);
                              } else {
                                showErrorToast(context, json['message']);
                              }
                            } else {
                              var result =
                                  await RestApi.addAndRemoveFavariteSoundHastag(
                                      widget.tag.hashtag_id, "hashtag", 1);
                              var json = jsonDecode(result.body);
                              if (json['status']) {
                                favTagList
                                    .add(widget.tag.hashtag_id.toString());
                                showSuccessToast(context, json['message']);
                              } else {
                                showErrorToast(context, json['message']);
                              }
                            }
                            setState(() {});
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            pref.setStringList('favTag', favTagList);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400.withOpacity(0.50),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: favTagList.contains(
                                            widget.tag.hashtag_id.toString())
                                        ? Colors.deepOrange
                                        : Colors.grey.shade700,
                                    size: 15,
                                  ),
                                  Text(
                                    favTagList.contains(
                                            widget.tag.hashtag_id.toString())
                                        ? addedToFavourite
                                        : "Add to Favourite",
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13),
                                  )
                                ],
                              )),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 1.8,
                              mainAxisSpacing: 1.8),
                      itemCount: widget.tag.hashVideo.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => true, arguments: {
                              'videoModel': widget.tag.videoModel[index]
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                  placeholder: (a, b) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  fit: BoxFit.cover,
                                  errorWidget: (a, b, c) => Image.network(
                                        '${RestUrl.thambUrl}thumb-not-available.png',
                                        fit: BoxFit.fill,
                                      ),
                                  imageUrl: widget.tag.hashVideo[index]
                                          .gif_image.isEmpty
                                      ? '${RestUrl.thambUrl}thumb-not-available.png'
                                      : '${RestUrl.gifUrl}${widget.tag.hashVideo[index].gif_image}'),
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
                                        widget.tag.hashVideo[index].views
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
                                        widget.tag.hashVideo[index].likes
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
                )
              ],
            ),
    );
  }

  void loadData() async {
    var result = await RestApi.getFavriteItems();
    var json = jsonDecode(result.body);
    if (json['status']) {
      List jsonList = json['data']['hash_tags'] as List;
      favTagList =
          jsonList.map((e) => HashtagModel.fromJson(e).id.toString()).toList();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setStringList('favTag', favTagList);
    }
    isLoading = false;
    setState(() {});
  }
}
