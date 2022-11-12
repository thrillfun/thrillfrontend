import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  SoundDetails({Key? key, required this.map}) : super(key: key);
  final Map map;

  @override
  State<SoundDetails> createState() => _SoundDetailsState();
}

class _SoundDetailsState extends State<SoundDetails>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  AudioPlayer audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  List<VideoModel> videoList = List.empty(growable: true);
  String title = "";

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.map['soundName'] != null) title = widget.map['soundName'];
    super.initState();
    getVideos();
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            child: loadLocalSvg("background_2.svg"),
          ),
          videoList.isEmpty
              ?  Center(
                  child: loader(),
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 100,
                      width: 100,
                      child: Stack(
                        children: [
                      RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_controller!),
                      child:Container( height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF2F8897),
                                Color(0xff1F2A52),
                                Color(0xff1F244E)
                              ]),
                              borderRadius: BorderRadius.circular(50),
                              color: ColorManager.cyan)),
                    ),
                          Center(
                              child: InkWell(
                            onTap: () async {
                              if (!isPlaying.value) {
                                audioPlayer
                                    .play(
                                        "https://thrillvideo.s3.amazonaws.com/sound/" +
                                            widget.map["sound"])
                                    .then((value) {
                                  isPlaying.value = true;

                                });

                                _controller!.forward();
                                _controller!.repeat();
                              } else {
                                isPlaying.value = false;
                                audioPlayer.pause();
                                _controller!.stop();
                              }
                            },
                            child: Obx(() => !isPlaying.value
                                ? const Icon(
                                    Icons.play_circle,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.pause_circle,
                                    size: 50,
                                    color: Colors.white,
                                  )),
                          )),

                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
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
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Flexible(
                        child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10),
                      children: List.generate(
                          videoList.length,
                          (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (route) => true,
                                        arguments: {
                                          'videoModel': videoList[index]
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
                                        imageUrl: videoList[index]
                                                .gif_image
                                                .isEmpty
                                            ? '${RestUrl.thambUrl}thumb-not-available.png'
                                            : '${RestUrl.gifUrl}${videoList[index].gif_image}',
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.fill)),
                                        ),
                                      ),
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
                                                videoList[index]
                                                    .views
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                              const Icon(
                                                Icons.favorite,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              Text(
                                                videoList[index]
                                                    .likes
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              )),
                    )),
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
                            await FileSupport()
                                .downloadCustomLocation(
                                  url: "${RestUrl.awsSoundUrl}$sound",
                                  path: saveCacheDirectory,
                                  filename: sound.split('.').first,
                                  extension: ".${sound.split('.').last}",
                                  progress: (progress) async {
                                    print(progress);
                                  },
                                );
                            Get.to(CameraScreen(

                              selectedSound: file.path,
                              owner: widget.map["user"],
                              id: widget.map['id'],
                            ));
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
                )
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
