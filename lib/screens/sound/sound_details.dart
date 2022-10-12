import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/gradient_elevated_button.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

class SoundDetails extends StatefulWidget {
  const SoundDetails({Key? key, required this.map}) : super(key: key);
  final Map map;
  static const String routeName = '/soundDetails';

  static Route route({required Map map_}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => SoundDetails(map: map_),
    );
  }

  @override
  State<SoundDetails> createState() => _SoundDetailsState();
}

class _SoundDetailsState extends State<SoundDetails> {
  List<VideoModel> videoList = List.empty(growable: true);
  String title = "";

  @override
  void initState() {
    if (widget.map['soundName'] != null) title = widget.map['soundName'];
    super.initState();
    getVideos();
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back(closeOverlays: true);
              // Navigator.pop(context);
            },
            color: Colors.white,
            icon: const Icon(Icons.arrow_back)),
      ),
      body: videoList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFF2F8897),
                            Color(0xff1F2A52),
                            Color(0xff1F244E)
                          ]),
                          borderRadius: BorderRadius.circular(50),
                          color: ColorManager.cyan),
                      child: const Icon(
                        Icons.play_circle,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            '@' + widget.map["user"],
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Divider(
                  thickness: 2,
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
                      itemCount: videoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => true,
                                arguments: {'videoModel': videoList[index]});
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
                                  imageUrl: videoList[index].gif_image.isEmpty
                                      ? '${RestUrl.thambUrl}thumb-not-available.png'
                                      : '${RestUrl.gifUrl}${videoList[index].gif_image}'),
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
                                        videoList[index].views.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      Text(
                                        videoList[index].likes.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        );
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     ElevatedButton(
                //         onPressed: () {
                //          // Get.to(() => const Favourites());
                //         },
                //         style: ElevatedButton.styleFrom(
                //             primary: ColorManager.deepPurple,
                //             fixedSize:
                //                 Size(MediaQuery.of(context).size.width * .30, 30),
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(50))),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: const [
                //             Icon(
                //               Icons.bookmark_outline_outlined,
                //               color: Colors.white,
                //               size: 20,
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Text(
                //               save,
                //               style: TextStyle(fontSize: 16),
                //             )
                //           ],
                //         )),
                //     const SizedBox(
                //       width: 15,
                //     ),
                //     ElevatedButton(
                //         onPressed: () {
                //          // Get.to(() => const Record());
                //         },
                //         style: ElevatedButton.styleFrom(
                //             primary: ColorManager.cyan,
                //             fixedSize:
                //                 Size(MediaQuery.of(context).size.width * .30, 30),
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(50))),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Image.asset(
                //               'assets/cam.png',
                //               scale: 1.5,
                //             ),
                //             const SizedBox(
                //               width: 10,
                //             ),
                //             const Text(
                //               create,
                //               style: TextStyle(fontSize: 16),
                //             )
                //           ],
                //         ))
                //   ],
                // ),
                GradientElevatedButton(
                    onPressed: () async {
                      String sound = widget.map["sound"];
                      File file = File('$saveCacheDirectory$sound');
                      try {
                        if (await file.exists()) {
                          // Get.to(Record(soundMap: {"soundName":title,"soundPath":file.path}));
                          Get.to(CameraScreen(selectedSound: "${RestUrl.awsSoundUrl}$sound",));
                          // Navigator.pushNamed(context, "/record", arguments: {
                          //   "soundName": title,
                          //   "soundPath": file.path
                          // });
                        } else {
                          progressDialogue(context);
                          await FileSupport().downloadCustomLocation(
                            url: "${RestUrl.awsSoundUrl}$sound",
                            path: saveCacheDirectory,
                            filename: sound.split('.').first,
                            extension: ".${sound.split('.').last}",
                            progress: (progress) async {},
                          );
                          closeDialogue(context);
                          Get.to(CameraScreen(selectedSound: "${RestUrl.awsSoundUrl}$sound",));
                          // Navigator.pushNamed(context, "/record", arguments: {
                          //   "soundName": title,
                          //   "soundPath": file.path
                          // });
                        }
                      } catch (e) {
                        closeDialogue(context);
                        showErrorToast(context, e.toString());
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.music_note),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Use Audio",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
    );
  }

  getVideos() async {
    try {
      var response = await RestApi.getVideosBySound(widget.map["sound"]);
      var json = jsonDecode(response.body);
      List jsonList = json["data"];
      videoList = jsonList.map((e) => VideoModel.fromJson(e)).toList();
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }
}
