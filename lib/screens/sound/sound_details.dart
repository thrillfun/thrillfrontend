import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';

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
  String title = '';

  @override
  void initState(){
    super.initState();
    getVideos();
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
          title,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: videoList.isEmpty?
          const Center(child: CircularProgressIndicator(),):
      Column(
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
                height: 120,
                width: 100,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: ColorManager.cyan),
                child: SvgPicture.asset(
                  'assets/play.svg',
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      widget.map["user"],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.8,
                    mainAxisSpacing: 1.8),
                itemCount: videoList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => true, arguments: {'videoModel': videoList[index]});
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                            placeholder: (a, b) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            fit: BoxFit.cover,
                            imageUrl:videoList[index].gif_image.isEmpty
                                ? '${RestUrl.thambUrl}thumb-not-available.png'
                                : '${RestUrl.gifUrl}${videoList[index].gif_image}'),
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
          ElevatedButton(
              onPressed: () async {
                String sound = widget.map["sound"];
                File file = File('$saveCacheDirectory$sound');
                    try{
                      if(await file.exists()){
                        Navigator.pushNamed(context, "/record", arguments: {"soundName":title,"soundPath":file.path});
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
                        Navigator.pushNamed(context, "/record", arguments: {"soundName":title,"soundPath":file.path});
                      }
                    } catch(e){
                      closeDialogue(context);
                      showErrorToast(context, e.toString());
                    }
              },
              style: ElevatedButton.styleFrom(
                  primary: ColorManager.cyan,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.camera_alt_outlined),
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

  getVideos()async{
    try{
      var response = await RestApi.getVideosBySound(widget.map["sound"]);
      var json = jsonDecode(response.body);
      List jsonList = json["data"];
      videoList = jsonList.map((e) => VideoModel.fromJson(e)).toList();
      try{
        title = json["data"]["name"]??'';
      } catch(e){
        title = '';
      }
      setState((){});
    } catch(e){
      showErrorToast(context, e.toString());
      Navigator.pop(context);
    }
  }
}
