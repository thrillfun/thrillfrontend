import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../../../routes/app_pages.dart';
import '../../../../../utils/color_manager.dart';
import '../../../../../utils/utils.dart';
import '../controllers/followers_controller.dart';

class FollowersView extends GetView<FollowersController> {
  const FollowersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getUserFollowers();
    return controller.obx(
        (state) => state!.isEmpty
            ? NoSearchResult(
                text: "You have no followers yet!",
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.pixels ==
                      scrollNotification.metrics.maxScrollExtent) {
                    controller.getPaginationFollowers(1);
                    return true;
                  }
                  return false;
                },
                child: ListView.builder(
                    itemCount: state.length,
                    itemBuilder: (context, index) => InkWell(
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
                                                          .toString() ==
                                                      "null"
                                                  ? state[index]
                                                      .username
                                                      .toString()
                                                  : state[index]
                                                      .name
                                                      .toString(),
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
                                InkWell(
                                  onTap: () {
                                    controller.followUnfollowUser(
                                        state[index].id!,
                                        state[index].isFolling == 0
                                            ? "follow"
                                            : "unfollow",
                                        fcmToken: state[index].firebaseToken!,
                                        image: RestUrl.profileUrl +
                                            state[index].avtars!,
                                        name: state[index].username!);
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
                                                  color: Colors.red.shade600),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(
                                            "Unfollow",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade600),
                                          ),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ))),
        onLoading: Column(
          children: [Expanded(child: loader())],
        ),
        onEmpty: NoSearchResult(
          text: "You have no followers yet!",
        ),
        onError: (error) => NoSearchResult(
              text: "You have no followers yet!",
            ));
  }
}
