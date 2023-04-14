import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/strings.dart';

import '../../../../../utils/utils.dart';
import '../controllers/favourite_sounds_controller.dart';

class FavouriteSoundsView extends GetView<FavouriteSoundsController> {
  const FavouriteSoundsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => state!.isEmpty?Column(children: [emptyListWidget()],):ListView.builder(
            shrinkWrap: true,
            itemCount: state!.value.length,
            itemBuilder: (context, index) => InkWell(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  "assets/Image.png",
                                  height: 80,
                                  width: 80,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: imgProfile(
                                      state[index].thumbnail.toString()),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state[index].name.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                                Text(
                                  state[index].sound.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                                Text(
                                  state[index].sound.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Text(
                          state[index].id.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  onTap: () => {
                    Get.toNamed(Routes.SOUNDS,arguments: {"sound_name":state[index].sound,"sound_url":state[index].sound})
                  },
                )),
        onLoading: loader(),
        onEmpty: Column(children: [emptyListWidget(data: "No favourite sounds")],));
  }
}
