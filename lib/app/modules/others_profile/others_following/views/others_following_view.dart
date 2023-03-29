import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/others_profile/others_following/followers/views/followers_view.dart';
import 'package:thrill/app/modules/others_profile/others_following/following/views/following_view.dart';

import '../controllers/others_following_controller.dart';

class OthersFollowingView extends GetView<OtherssFollowingController> {
  const OthersFollowingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: Get.arguments["index"] as int,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: (index) => {},
            tabs: const [
              Tab(
                text: "Following",
              ),
              Tab(
                text: "Followers",
              )
            ],
          ),
        ),
        body: TabBarView(children: [FollowingView(), FollowersView()]),
      ),
    );
  }
}
