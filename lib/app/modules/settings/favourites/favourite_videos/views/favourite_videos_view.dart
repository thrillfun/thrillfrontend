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
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
                mainAxisSpacing: 10,
                children: List.generate(
                    state!.length,
                    (index) => InkWell(
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
                                                  state[index].views.toString(),
                                            ),
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
                                  ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: state[index]
                                                  .user!
                                                  .avatar
                                                  .toString()
                                                  .isEmpty ||
                                              state[index]
                                                      .user!
                                                      .avatar
                                                      .toString() ==
                                                  "null"
                                          ? RestUrl.placeholderImage
                                          : RestUrl.profileUrl +
                                              state[index]
                                                  .user!
                                                  .avatar
                                                  .toString(),
                                      height: 20,
                                      width: 20,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    state[index].user!.name.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            Get.toNamed(Routes.FAVOURITE_VIDEO_PLAYER,
                                arguments: {"favourite_videos": state});
                            // List<PublicVideos> videosList1 = [];
                            // controller.favouriteVideos.forEach((element) {
                            //   var user = PublicUser(
                            //     id: element.user?.id,
                            //     name: element.user?.name,
                            //     facebook: element.user?.facebook,
                            //     firstName: element.user?.firstName,
                            //     lastName: element.user?.lastName,
                            //     username: element.user?.username,
                            //     isFollow: 0,
                            //   );
                            //   videosList1.add(PublicVideos(
                            //     id: element.id,
                            //     video: element.video,
                            //     description: element.description,
                            //     sound: element.sound,
                            //     soundName: element.soundName,
                            //     soundCategoryName: element.soundCategoryName,
                            //     // soundOwner: element.soundOwner,
                            //     filter: element.filter,
                            //     likes: element.likes,
                            //     views: element.views,
                            //     gifImage: element.gifImage,
                            //     speed: element.speed,
                            //     comments: element.comments,
                            //     isDuet: "no",
                            //     duetFrom: "",
                            //     isCommentable: "yes",
                            //     // videoLikeStatus: element.videoLikeStatus,
                            //     user: user,
                            //   ));
                            // });
                            // Get.to(VideoPlayerItem(
                            //   videosList: videosList1,
                            //   position: index,
                            // ));
                          },
                        )),
              ),
        onLoading: loader(),
        onEmpty: emptyListWidget(data: "No favourite videos"));
  }
}
