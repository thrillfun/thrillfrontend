import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';

class NoLikedVideos extends StatelessWidget {
  const NoLikedVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset("assets/background.json", height: 200, width: 200),
              Lottie.asset("assets/no_videos.json", height: 150, width: 150)
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "No videos found!",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}
