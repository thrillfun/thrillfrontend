import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/color.dart';
import '../common/strings.dart';

class SoundDetails extends StatefulWidget {
  const SoundDetails({Key? key, required this.title}) : super(key: key);
  final String title;
  static const String routeName = '/soundDetails';
  static Route route({required String title_}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => SoundDetails(title: title_),
    );
  }

  @override
  State<SoundDetails> createState() => _SoundDetailsState();
}

class _SoundDetailsState extends State<SoundDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
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
                      '$originalSound${widget.title}',
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    const Text(
                      '#status #song #punjabi #lovesong',
                      style: TextStyle(color: Colors.grey),
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
                itemCount: 14,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                          placeholder: (a, b) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          fit: BoxFit.cover,
                          imageUrl:
                              'https://i.ytimg.com/vi/DYMmHIOD7wA/maxresdefault.jpg'),
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
                                '${Random().nextInt(500)}M',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                '${Random().nextInt(10) + 1}M',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ))
                    ],
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
              onPressed: () {
                // Get.to(() => const Record());
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
}
