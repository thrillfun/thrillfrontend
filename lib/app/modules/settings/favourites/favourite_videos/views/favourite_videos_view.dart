import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../rest/rest_urls.dart';
import '../../../../../routes/app_pages.dart';
import '../../../../../utils/color_manager.dart';
import '../../../../../utils/utils.dart';
import '../controllers/favourite_videos_controller.dart';

class FavouriteVideosView extends GetView<FavouriteVideosController> {
  const FavouriteVideosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? Column(
                children: [emptyListWidget()],
              )
            : Padding(
                padding: EdgeInsets.all(10),
                child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels ==
                          scrollNotification.metrics.maxScrollExtent) {
                        controller.getPaginationAllVideos(1);
                      }
                      return true;
                    },
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.8,
                      mainAxisSpacing: 10,
                      children: List.generate(state!.length, (index) {
                        return InkWell(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  fit: StackFit.loose,
                                  children: [
                                    imgNet(RestUrl.gifUrl +
                                        state[index].gifImage!),
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              child: Icon(
                                                Icons.play_circle,
                                                size: 14,
                                                color: ColorManager.colorAccent,
                                              ),
                                            ),
                                            TextSpan(
                                                text: "  " +
                                                    state[index]
                                                        .views!
                                                        .formatViews(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: imgProfile(
                                        state[index].user!.avatar.toString()),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(
                                    state[index].user!.name ??
                                        state[index].user!.username.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ))
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            Get.toNamed(Routes.FAVOURITE_VIDEO_PLAYER,
                                arguments: {
                                  "favourite_videos": state,
                                  "init_page": index
                                });
                          },
                        );
                      }),
                    )),
              ),
        onLoading: searchVideosShimmer(),
        onEmpty: emptyListWidget(data: "No favourite videos"));
  }
}
