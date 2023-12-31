import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/modules/spin_wheel/user_levels/views/user_levels_view.dart';

import '../../../rest/models/spin_wheel_data_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/spin_wheel_controller.dart';

class SpinWheelView extends GetView<SpinWheelController> {
  SpinWheelView({Key? key}) : super(key: key);
  ScrollController _controller = ScrollController();

  var selectedInt = 0.obs;
  late AnimationController spinController = AnimationController(
      vsync: Scaffold.of(Get.context!),
      duration: const Duration(milliseconds: 789));

  var isLoading = true.obs;
  var isSpin = false.obs;

  //List<EarnSpin> earnList = List<EarnSpin>.empty(growable: true);
  var listForReward = [];
  int rewardId = 0;
  AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(_scrollListener);
    return Scaffold(
        body: Stack(
      children: [
        controller.obx(
          (state) => SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                prizeLayout(),
                wheelLayout(),
                submitButtonLayout(),
                UserLevelsView()
                //    lastRewardLayout()
              ],
            ),
          ),
          onLoading: spinWheelShimmer(),
        )
      ],
    ));
  }

  prizeLayout() => GlassmorphicContainer(
        width: Get.width,
        height: 100,
        borderRadius: 10,
        blur: 20,
        margin: const EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0A8381).withOpacity(0.7),
              Colors.black.withOpacity(0.7),
              Color(0xff1D5855).withOpacity(0.7),
            ]),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFffffff).withOpacity(0.0),
            Color((0xFFFFFFFF)).withOpacity(0.0),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(imageUrl: RestUrl.assetsUrl + "gift.png"),
              const SizedBox(
                width: 20,
              ),
              Row(
                children: [
                  Obx(() => Text(
                        "${controller.remainingChance.value} ",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 44,
                            color: Colors.white),
                      )),
                  const Text(
                    "Available \nChances ",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        "${controller.lastReward.value}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white),
                      )),
                  const Text(
                    "Last Reward  ",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
              )
            ],
          ),
        ),
      );

  wheelLayout() => Container(
        decoration: const BoxDecoration(
            color: ColorManager.colorAccent, shape: BoxShape.circle),
        margin: const EdgeInsets.only(top: 40, bottom: 10),
        padding: const EdgeInsets.all(10),
        height: Get.height / 2,
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
                gradient: ColorManager.walletGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
            child: FortuneWheel(
              duration: const Duration(seconds: 10),
              animateFirst: false,
              selected: controller.streamController!.stream,
              indicators: <FortuneIndicator>[
                FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: Container(
                      alignment: Alignment.center,
                      height: Get.height,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: SvgPicture.asset(
                        'assets/spinDirection.svg',
                        height: 120,
                        width: 120,
                        fit: BoxFit.fill,
                      ),
                    )),
              ],
              physics: CircularPanPhysics(
                duration: const Duration(seconds: 10),
                curve: Curves.decelerate,
              ),
              items: [
                for (int i = 0;
                    i < controller.wheelData.data!.wheelRewards!.length;
                    i++)
                  FortuneItem(
                    style: FortuneItemStyle(
                        borderColor: Colors.white,
                        borderWidth: 4,
                        color: i.isOdd
                            ? Color(0xff01CCC9).withOpacity(1)
                            : i == 0
                                ? Color(0xffF2C94C)
                                : Color(0xff2F80ED).withOpacity(1)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        i.isOdd
                            ? Container(
                                decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                        focalRadius: 0.28,
                                        focal: Alignment.centerLeft,
                                        radius: 0.9,
                                        colors: [
                                      Color(0xff0177CC).withOpacity(0.3),
                                      Color(0xff01CCC9).withOpacity(0),
                                      Color(0xff0060A5).withOpacity(0.47),
                                      Color(0xff0177CC),
                                      Color(0xff01CCC9).withOpacity(0),
                                      Color(0xff01CCC9).withOpacity(0),
                                    ])),
                              )
                            : i == 0
                                ? Container(
                                    width: Get.width,
                                    height: Get.height,
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                            focalRadius: 0.28,
                                            focal: Alignment.centerLeft,
                                            radius: 0.9,
                                            colors: [
                                          Color(0xffFF0000).withOpacity(0.3),
                                          Color(0xffF2C94C).withOpacity(0),
                                          Color(0xffFF0000).withOpacity(0.47),
                                          Color(0xffFF0000),
                                          Color(0xffF2C94C).withOpacity(0),
                                          Color(0xffF2C94C).withOpacity(0),
                                        ])),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                            focalRadius: 0.28,
                                            focal: Alignment.centerLeft,
                                            radius: 0.9,
                                            colors: [
                                          Color(0xff0177CC).withOpacity(0.3),
                                          Color(0xff2F80ED).withOpacity(0),
                                          Color(0xff110056).withOpacity(0.47),
                                          Color(0xff2F11A5),
                                          Color(0xff2F80ED).withOpacity(0),
                                          Color(0xff2F80ED).withOpacity(0),
                                        ])),
                                  ),
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              controller.wheelData.data!.wheelRewards![i]
                                          .imagePath ==
                                      null
                                  ? RotatedBox(
                                      quarterTurns: 2,
                                      child: Text(
                                        controller.wheelData.data!
                                            .wheelRewards![i].currencySymbol
                                            .toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(left: 40),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white)),
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            height: 30,
                                            width: 30,
                                            imageUrl: controller.wheelData.data!
                                                .wheelRewards![i].imagePath
                                                .toString()),
                                      ),
                                    ),
                              RotatedBox(
                                quarterTurns: 1,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${controller.wheelData.data!.wheelRewards![i].amount} ',
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '${controller.wheelData.data!.wheelRewards![i].currency} ',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    //     : Padding(
                    //   padding: const EdgeInsets.only(left: 25),
                    //   child: Image.network(
                    //     "${RestUrl.profileUrl}${wheelController.wheelData.value.data!.wheelRewards![i].imagePath}",
                    //     width: 30,
                    //     height: 30,
                    //   ),
                    // ),
                  ),
              ],
              onAnimationEnd: () {
                updateSpin();
              },
            ),
          ),
          Center(
            child: Obx(() => Visibility(
                maintainAnimation: true,
                maintainState: true,
                visible: controller.isRewardWon.isTrue,
                child: Obx(() => AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      curve: controller.isRewardWon.isTrue
                          ? Curves.easeInOutCirc
                          : Curves.easeInCirc,
                      opacity: controller.isRewardWon.isTrue ? 1 : 0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    IgnorePointer(
                                      child: Lottie.asset(
                                        "assets/congrats.json",
                                        fit: BoxFit.contain,
                                        width: Get.width,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Lottie.asset("assets/winning.json",
                                            fit: BoxFit.contain, height: 250),
                                        Text(
                                          "Congratulations!",
                                          style: TextStyle(
                                              color: ColorManager
                                                  .colorPrimaryLight,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Obx(() => Text(
                                              controller.rewardMsg.value
                                                  .replaceAll("Congratus", "")
                                                  .capitalizeFirst
                                                  .toString(),
                                              style: TextStyle(
                                                  color: ColorManager
                                                      .colorPrimaryLight,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    )
                                  ],
                                ),

                                // InkWell(
                                //   onTap: () {
                                //     // ScreenshotController()
                                //     //     .captureFromWidget(Container(
                                //     //         padding: const EdgeInsets.all(30.0),
                                //     //         decoration: BoxDecoration(
                                //     //           border: Border.all(
                                //     //               color: Colors.blueAccent, width: 5.0),
                                //     //           color: Colors.redAccent,
                                //     //         ),
                                //     //         child: Text("This is an invisible widget")))
                                //     //     .then((capturedImage) async {
                                //     //   var file = await File("${saveCacheDirectory}temp.png")
                                //     //       .writeAsBytes(capturedImage);
                                //     //   Logger().wtf(file.path);
                                //     //   // Handle captured image
                                //     // });
                                //   },
                                //   child: Container(
                                //     width: Get.width,
                                //     margin: const EdgeInsets.symmetric(
                                //         horizontal: 20, vertical: 20),
                                //     padding: const EdgeInsets.all(10),
                                //     alignment: Alignment.center,
                                //     decoration: const BoxDecoration(
                                //         borderRadius: BorderRadius.all(
                                //           Radius.circular(10),
                                //         ),
                                //         gradient: LinearGradient(
                                //             begin: Alignment.topCenter,
                                //             end: Alignment.bottomCenter,
                                //             colors: [
                                //               ColorManager.colorPrimaryLight,
                                //               ColorManager.colorAccent
                                //             ])),
                                //     child: const Text(
                                //       "Excellent!",
                                //       style:
                                //           TextStyle(color: Colors.white, fontSize: 18),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )))),
          )
        ]),
      );

  submitButtonLayout() => Obx(() => InkWell(
        onTap: () => spinTheWheelTap(),
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    controller.isSpinning.isTrue ||
                            controller.isRewardWon.isTrue
                        ? Colors.grey
                        : ColorManager.colorPrimaryLight,
                    controller.isSpinning.isTrue ||
                            controller.isRewardWon.isTrue
                        ? Colors.grey
                        : ColorManager.colorAccent
                  ])),
          child: const Text(
            "Spin the wheel!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ));

  spinTheWheelTap() async {
    if (controller.remainingChance.value > 0 &&
        controller.isRewardWon.isFalse) {
      controller.isSpinning.value = true;
      listForReward.clear();
      controller.streamController!.add(controller.random?.id - 2);
    }
  }

  void updateSpin() async {
    try {
      //progressDialogue(Get.context!);
      controller.getRewardUpdate(controller.random?.id);
      // closeDialogue(Get.context!);
      // player!.stop();
      // await player.stop();
      // await player.play();
      // await player.pause();
      isSpin.value = false;
    } catch (e) {
      closeDialogue(Get.context!);
      showErrorToast(Get.context!, e.toString());
    }
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {}
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {}
  }
}
