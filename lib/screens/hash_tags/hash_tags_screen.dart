import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/widgets/video_player_screen.dart';

class HashTagsScreen extends StatelessWidget {
  const HashTagsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171D22), Color(0xff143035), Color(0xff171D23)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: GetX<DiscoverController>(
          builder: (controller) => controller.isHashTagsLoading.value && controller.hashTagsVideos.isNotEmpty
              ? Container()
              : StaggeredGridView.countBuilder(
                staggeredTileBuilder: (index) => index % 7 == 0
                    ? StaggeredTile.count(1, 2)
                    : StaggeredTile.count(1, 1),
                physics: const NeverScrollableScrollPhysics(),
                //cross axis cell count
                mainAxisSpacing: 8,
                // vertical spacing between items
                crossAxisSpacing: 8,
                // horizontal spacing between items
                crossAxisCount: 3,
                shrinkWrap: true,
                itemCount: controller.hashTagsDetailsList.length,
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Get.to(VideoPlayerScreen(
                          controller.hashTagsDetailsList, index));
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: RestUrl.gifUrl +
                                  controller
                                      .hashTagsDetailsList[index].gifImage
                                      .toString())),
                    )),
              ),
        )),
      ),
    );
  }
}
