import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/settings/favourites/favourite_hashtags/views/favourite_hashtags_view.dart';
import 'package:thrill/app/modules/settings/favourites/favourite_sounds/views/favourite_sounds_view.dart';
import 'package:thrill/app/modules/settings/favourites/favourite_videos/views/favourite_videos_view.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/favourites_controller.dart';

class FavouritesView extends GetView<FavouritesController> {
  const FavouritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedTab = 0.obs;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favourites",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
      body: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 10,
              bottom: TabBar(
                  onTap: (int index) {
                    selectedTab.value = index;
                  },
                  indicatorColor: ColorManager.colorAccent,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(
                      text: "Sounds",
                    ),
                    Tab(
                      text: "Videos",
                    ),
                    Tab(
                      text: "Hashtags",
                    )
                  ]),
            ),
            body: TabBarView(children: [
              FavouriteSoundsView(),
              const FavouriteVideosView(),
              const FavouriteHashtagsView(),
            ]),
          )),
    );
  }
}
