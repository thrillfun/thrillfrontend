import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../utils/color_manager.dart';
import '../../../../../utils/utils.dart';
import '../controllers/followings_controller.dart';

class FollowingsView extends GetView<FollowingsController> {
  const FollowingsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
            (state) => Wrap(
          children: List.generate(
              state!.length,
                  (index) => InkWell(
                onTap: () async {
                  // state![index].id == GetStorage().read("userId")
                  //     ? await likedVideosController.getUserLikedVideos()
                  //     : await likedVideosController
                  //     .getOthersLikedVideos(state![index].id!);
                  //
                  // state![index].id == GetStorage().read("userId")
                  //     ? await userVideosController.getUserVideos()
                  //     : await userVideosController
                  //     .getOtherUserVideos(state[index].id!);
                  // state![index].id == GetStorage().read("userId")
                  //     ? await userDetailsController
                  //     .getUserProfile()
                  //     .then((value) => Get.to(Profile()))
                  //     : await otherUsersController
                  //     .getOtherUserProfile(state[index].id!)
                  //     .then((value) => Get.to(ViewProfile(
                  //     controller.followersModel[index].id
                  //         .toString(),
                  //     controller
                  //         .followersModel[index].isFolling!.obs,
                  //     controller.followersModel[index].name
                  //         .toString(),
                  //     controller.followersModel[index].avtars
                  //         .toString())));
                },
                child: Container(
                  width: Get.width,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            imgProfile(state[index].avtars
                                .toString()),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state[index].name
                                        .toString()=="null" ?state[index].username
                                        .toString():state[index].name
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(

                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    state[index].username
                                        .toString(),
                                    style: TextStyle(

                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.followUnfollowUser(
                              state[index].id!,
                              state[index].isFolling == 0
                                  ? "follow"
                                  : "unfollow");
                          // usersController.followUnfollowUser(
                          //     controller.followersModel[index].id!,
                          //     controller.followersModel[index]
                          //         .isFolling ==
                          //         0
                          //         ? "follow"
                          //         : "unfollow");
                          //
                          // controller.getUserFollowers(userId);
                        },
                        child:state[index].isFolling ==
                            0
                            ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: ColorManager.colorAccent,
                              borderRadius:
                              BorderRadius.circular(20)),
                          child: const Text(
                            "Follow",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        )
                            : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                  ColorManager.colorAccent),
                              borderRadius:
                              BorderRadius.circular(20)),
                          child: const Text(
                            "Following",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.colorAccent),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ),
        onLoading: Column(
          children: [Expanded(child: loader())],
        ),
        onEmpty: emptyListWidget()
    );
  }
}
