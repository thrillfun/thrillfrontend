import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../../../utils/color_manager.dart';
import '../../../../../utils/utils.dart';
import '../controllers/favourite_hashtags_controller.dart';

class FavouriteHashtagsView extends GetView<FavouriteHashtagsController> {
  const FavouriteHashtagsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty
            ? Column(
                children: [emptyListWidget()],
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: state!.length,
                itemBuilder: (context, index) => InkWell(
                      onTap: () async {
                        await GetStorage().write("hashtagId", state[index].id);
                        Get.toNamed(Routes.HASH_TAGS_DETAILS, arguments: {
                          "hashtag_name": "${state[index].name}"
                        }); // discoverController
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            73, 204, 201, 0.08),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Icon(
                                      Icons.numbers,
                                      color: ColorManager.colorAccent,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  state[index].name == null
                                      ? ""
                                      : state[index].name!,
                                  style: TextStyle(
                                      color: ColorManager.dayNightText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                )
                              ],
                            ),
                            Text(
                              state.length == null
                                  ? ""
                                  : state.length.toString()!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )),
        onLoading: loader(),
        onEmpty: emptyListWidget(data: "No favourite hashtags"));
  }
}
