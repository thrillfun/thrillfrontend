import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/app/modules/spin_wheel/user_levels/views/user_levels_view.dart';

import '../../../rest/models/spin_wheel_data_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/spin_wheel_controller.dart';

class SpinWheelView extends GetView<SpinWheelController> {
  SpinWheelView({Key? key}) : super(key: key);
  ScrollController _controller = ScrollController();
  var isSpinning = false.obs;

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
                prizeLayout(),
                wheelLayout(),
                submitButtonLayout(),
                UserLevelsView()
                //    lastRewardLayout()
              ],
            ),
          ),
          onLoading: Container(
            child: loader(),
            height: Get.height,
            width: Get.width,
          ),
        )
      ],
    ));
  }
  prizeLayout() => Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(left: 20, right: 20),
    decoration: const BoxDecoration(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  fontSize: 50),
            )),
            const Text(
              "Available \nChances ",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            )
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
              "${controller.lastReward.value}",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            )),
            const Text(
              "Last Reward  ",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            )
          ],
        )
      ],
    ),
  );

  wheelLayout() => Container(
        decoration: const BoxDecoration(
            color: ColorManager.colorAccent, shape: BoxShape.circle),
        margin: const EdgeInsets.only(top: 40, bottom: 10),
        padding: const EdgeInsets.all(10),
        height: Get.height / 2,
        child: Container(
          decoration: BoxDecoration(
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      i.isOdd
                          ? Image.asset(
                              "assets/ellipse6.png",
                              fit: BoxFit.cover,
                            )
                          : i == 0
                              ? Image.asset(
                                  "assets/ellipse7.png",
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "assets/ellipse8.png",
                                  fit: BoxFit.cover,
                                ),
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            controller.wheelData.data!.wheelRewards![i]
                                        .imagePath ==
                                    null
                                ? Text(
                                    controller.wheelData.data!.wheelRewards![i]
                                        .currencySymbol
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  )
                                : CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    height: 20,
                                    width: 20,
                                    imageUrl: RestUrl.profileUrl +
                                        controller.wheelData.data!
                                            .wheelRewards![i].imagePath
                                            .toString()),
                            Text(
                              '${controller.wheelData.data!.wheelRewards![i].currencySymbol} ${controller.wheelData.data!.wheelRewards![i].amount} ',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )
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
      );

  submitButtonLayout() => InkWell(
        onTap: () async {
          spinTheWheelTap();
        },
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.colorPrimaryLight,
                    ColorManager.colorAccent
                  ])),
          child: const Text(
            "Spin the wheel!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );

  spinTheWheelTap() async {
    if (controller.remainingChance.value > 0) {
      isSpin.value = true;

      listForReward.clear();

      Random p = Random();
      double cumulativeProbability = 0.0;
      List<WheelRewards> dataList = [];
      for (WheelRewards data in controller.wheelRewardsList) {
        cumulativeProbability = data.probability!.toDouble();
        if (p.nextInt(100) + 1 <= cumulativeProbability) {
          dataList.add(data);
          // return data;
        }
      }

      var random = getRandomElement(dataList);
      int id = random.id!.toInt();
      rewardId = id;
      selectedInt.value = random.id!.toInt();

      // for(WheelRewards data in wheelController.wheelRewardsList){
      //   if(data.probability != null && data.probability!.toInt() < 10 && data.probability!.toInt()>0){
      //
      //   }
      // }
      //

      //await player.resume();
      controller.streamController!.add(selectedInt.value);
    } else {
      isSpin.value = true;
    }
  }

  void updateSpin() async {
    try {
      //progressDialogue(Get.context!);
      controller.getRewardUpdate(rewardId);
      // closeDialogue(Get.context!);
      controller.getWheelData();
      // player!.stop();
      // await player.stop();
      // await player.play();
      // await player.pause();
      isSpin.value = false;
      showWinDialog(controller.wheelData.message.toString());
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
