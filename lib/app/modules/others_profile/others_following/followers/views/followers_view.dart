import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/modules/others_profile/others_following/followers/controllers/others_followers_controller.dart';

import '../../../../../routes/app_pages.dart';
import '../../../../../utils/color_manager.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/no_search_result.dart';

class FollowersView extends GetView<OtherFollowersController> {
  const FollowersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getUserFollowers();
    return controller.obx(
        (state) => state!.isEmpty
            ? NoSearchResult(
                text: "User have no followers yet!",
              )
            : Wrap(
                children: List.generate(
                    state!.length,
                    (index) => InkWell(
                          onTap: () async {
                            Get.toNamed(Routes.OTHERS_PROFILE,
                                arguments: {"profileId": state[index].id});
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
                                      imgProfile(
                                          state[index].avtars.toString()),
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
                                              state[index]
                                                          .name
                                                          ??
                                                state[index]
                                                      .username
                                                      .toString()
                                                  ,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              state[index].username.toString(),
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
                                Visibility(
                                  visible: state[index].id !=
                                      GetStorage().read("userId"),
                                  child: InkWell(
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
                                    child: state[index].isFolling == 0
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
                                                    color: ColorManager
                                                        .colorAccent),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: const Text(
                                              "Following",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      ColorManager.colorAccent),
                                            ),
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
        onEmpty: NoSearchResult(
          text: "User have no followers yet!",
        ),
        onError: (error) => NoSearchResult(
              text: "User have no followers yet!",
            ));
  }
}
