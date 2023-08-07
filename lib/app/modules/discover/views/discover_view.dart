import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/discover_controller.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getTopHashTagVideos();
    return Scaffold(
        body: controller.obx(
            (state) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).viewPadding.top,
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                            height: 5,
                          ),
                          GlassContainer(
                            color: ColorManager.colorAccent.withOpacity(0.5),
                            blur: 5,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: InkWell(
                                  onTap: () async {
                                    Get.toNamed(Routes.SEARCH);
                                  },
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),

                          Wrap(
                            runSpacing: 10,
                            children: List.generate(
                                controller.allHashtagsList.length,
                                (index) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 20, bottom: 20),
                                    child: GlassContainer(
                                      blur: 10,
                                      shadowColor: Colors.transparent,
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.4)),
                                      color: ColorManager.colorAccent
                                          .withOpacity(0.5),
                                      child: InkWell(
                                          onTap: () async {
                                            await GetStorage().write(
                                                "hashtagId",
                                                controller
                                                    .allHashtagsList[index].id);
                                            Get.toNamed(
                                                Routes.HASH_TAGS_DETAILS,
                                                arguments: {
                                                  "hashtag_name":
                                                      "${controller.allHashtagsList[index].name}",
                                                  "hashtagId": controller
                                                      .allHashtagsList[index].id
                                                });
                                          },
                                          child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 10,
                                                  bottom: 10),
                                              margin: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                              ),
                                              child: Text(
                                                controller
                                                    .allHashtagsList[index].name
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ))),
                                    ))),
                          )
                        ],
                      ),
                    ),
                    controller.obx((state) =>  Expanded(
                      child: NotificationListener<ScrollEndNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent) {
                            controller.getPaginationTopHashTagVideos();
                          }

                          return true;
                        },
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: state!.length,
                            itemBuilder: (context, index) {
                              state[index].videos!.removeWhere((element) => element.id==null);
                              return Visibility(
                                  visible: state[index].videos!.isNotEmpty,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          await GetStorage().write(
                                              "hashtagId",
                                              controller
                                                  .allHashtagsList[index].id);
                                          Get.toNamed(Routes.HASH_TAGS_DETAILS,
                                              arguments: {
                                                "hashtag_name":
                                                "${state[index].hashtagName}",
                                                "hashtagId":
                                                state[index].hashtagId
                                              });

                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                          color: ColorManager
                                                              .colorAccentTransparent,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(50)),
                                                      child: const Icon(
                                                        Icons.numbers,
                                                        color: ColorManager
                                                            .colorAccent,
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        state[index].hashtagName ==
                                                            null
                                                            ? ""
                                                            : state[index]
                                                            .hashtagName!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w700,
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        "Trending Hashtag",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            fontSize: 14),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    state[index].videoCount ==
                                                        null
                                                        ? ""
                                                        : state[index]
                                                        .videoCount
                                                        .toString()!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        fontSize: 14),
                                                  ),
                                                  const Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color:
                                                    ColorManager.colorAccent,
                                                    size: 25,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(
                                                state[index].videos!.length,
                                                    (videoIndex) => Container(
                                                  margin:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  height: 150,
                                                  width: 120,
                                                  child: InkWell(
                                                    onTap: () {},
                                                    child: InkWell(
                                                      onTap: () {
                                                        Get.toNamed(
                                                            Routes
                                                                .DISCOVER_VIDEO_PLAYER,
                                                            arguments: {
                                                              "init_page":
                                                              videoIndex,
                                                              "hashtagId":
                                                              state[index]
                                                                  .hashtagId
                                                            });
                                                      },
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          imgNet(RestUrl
                                                              .gifUrl +
                                                              state[index]
                                                                  .videos![
                                                              videoIndex]
                                                                  .gifImage
                                                                  .toString()),
                                                          Positioned(
                                                              bottom: 10,
                                                              left: 10,
                                                              right: 10,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  RichText(
                                                                    text:
                                                                    TextSpan(
                                                                      children: [
                                                                        const WidgetSpan(
                                                                          child:
                                                                          Icon(
                                                                            Icons.play_circle,
                                                                            size: 18,
                                                                            color: ColorManager.colorAccent,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                            text: " " + NumberFormat.compact().format(state[index].videos![videoIndex].views??0).toString(),
                                                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ),
                                      )
                                    ],
                                  ));

                            }),
                      ),
                    ))

                  ],
                ),
            onLoading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: loader(),
                )
              ],
            ),
            onError: (error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: emptyListWidget(),
                    )
                  ],
                ),
            onEmpty: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: emptyListWidget(),
                )
              ],
            )));
  }
}
