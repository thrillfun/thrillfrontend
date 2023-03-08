import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../rest/models/user_details_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/other_user_videos_controller.dart';

class OtherUserVideosView extends GetView<OtherUserVideosController> {
  const OtherUserVideosView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
          (state) =>  Column(
        children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: GridView.count(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  children: List.generate(
                      state!.length,
                          (index) => GestureDetector(
                        onTap: () {
                          User publicUser = User(
                            id:state[index].user!.id,
                            name: state[index].user?.name
                                .toString(),
                            username: state[index].user?.username,
                            email: state[index].user?.email,
                            dob:
                            state[index].user?.dob,
                            phone: state[index].user?.phone,
                            avatar: state[index].user!.avatar,
                            socialLoginType: state[index]
                                .user
                                ?.socialLoginType,
                            socialLoginId: state[index].user?.socialLoginId,
                            firstName: state[index].user?.firstName,
                            lastName: state[index].user?.lastName,
                            gender: state[index].user?.gender,
                          );

                          // Get.to(VideoPlayerScreen(
                          //   isFeed: false,
                          //   isFav: true,
                          //   isLock: false,
                          //   likedVideos: controller.likedVideos,
                          //   position: index,
                          //   hashTagVideos: [],
                          //   videosList: [],
                          //   privateVideos: [],
                          // ));
                          // Get.to(UserLikedVideoPlayer({
                          //   strings.gifImage:
                          //   controller.likedVideos[index].gifImage,
                          //   strings.videoLikeStatus:
                          //   controller.likedVideos[index].videoLikeStatus,
                          //   strings.sound:
                          //   controller.likedVideos[index].sound,
                          //   strings.soundOwner:
                          //   controller.likedVideos[index].soundOwner,
                          //   strings.videoUrl:
                          //   controller.likedVideos[index].video,
                          //   strings.isCommentAllowed:
                          //   controller.likedVideos[index].isCommentable ==
                          //       "yes"
                          //       ? true.obs
                          //       : false.obs,
                          //   strings.publicUser: publicUser,
                          //   strings.videoId: controller.likedVideos[index].id,
                          //   strings.soundName:
                          //   controller.likedVideos[index].soundName,
                          //   strings.isDuetable:
                          //   controller.likedVideos[index].isDuetable ==
                          //       "yes"
                          //       ? true.obs
                          //       : false.obs,
                          //   //   strings.publicVideos:controller.likedVideos
                          //   //   PublicVideos publicVideos;
                          //   strings.description:
                          //   controller.likedVideos[index].description,
                          //   strings.hashtagsList: (controller
                          //       .likedVideos[index]
                          //       .hashtags as List<dynamic>),
                          //   strings.likes:
                          //   controller.likedVideos[index].likes,
                          //   strings.isFollow:
                          //   controller.likedVideos[index].isfollow,
                          //   strings.commentsCount:
                          //   controller.likedVideos[index].comments
                          // }));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imgNet(
                                '${RestUrl.gifUrl}${controller.userVideos[index].gifImage}'),
                            Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.play_circle,
                                              size: 18,
                                              color: ColorManager
                                                  .colorAccent,
                                            ),
                                          ),
                                          TextSpan(
                                              text: " " +
                                                  controller
                                                      .userVideos[index]
                                                      .views
                                                      .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      )),
                ),
              ))
        ],
      ),
      onLoading: Column(
        children: [
          Expanded(child: loader()),
        ],
      ),
      onEmpty: emptyListWidget(),
    );
  }
}
