import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/profile/users_following/followers/views/followers_view.dart';
import 'package:thrill/app/modules/profile/users_following/followings/views/followings_view.dart';

import '../controllers/users_following_controller.dart';

class UsersFollowingView extends GetView<UsersFollowingController> {
  const UsersFollowingView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: Get.arguments["index"] as int,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your followers and followings"),
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
        body: TabBarView(children: [FollowingsView(), FollowersView()]),
      ),
    );
  }
}
