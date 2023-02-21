import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/wheel_controller.dart';
import 'package:thrill/models/earnSpin_model.dart';
import 'package:thrill/models/wheelDetails_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import 'dart:math' as math;

import '../../controller/model/wheel_data_model.dart';

var wheelController = Get.find<WheelController>();

class SpinTheWheelGetx extends GetView<WheelController> {
  ScrollController _controller = ScrollController();

  SpinTheWheelGetx({Key? key}) : super(key: key);
  WheelDetails? wheelDetails;

  var isSpinning = false.obs;

  var selectedInt = 0.obs;
  late AnimationController spinController = AnimationController(
      vsync: Scaffold.of(Get.context!),
      duration: const Duration(milliseconds: 789));

  var isLoading = true.obs;
  var isSpin = false.obs;
  List<EarnSpin> earnList = List<EarnSpin>.empty(growable: true);
  var listForReward = [];
  int rewardId = 0;
  AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(_scrollListener);
    wheelController.getEarnedSpinData();
    wheelController.getWheelData();
    setSpinSound();
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: Stack(
          children: [
            controller.obx(
              (state) => SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      child: titleLayout(),
                    ),
                    rewardLayout(),
                    prizeLayout(),
                    controller.isWheelDataLoading.isTrue
                        ? loader()
                        : wheelLayout(),
                    submitButtonLayout(),
                    levelsLayout()
                    //    lastRewardLayout()
                  ],
                ),
              ),
              onLoading: Container(
                color: ColorManager.dayNight,
                child: loader(),
                height: Get.height,
                width: Get.width,
              ),
            )
          ],
        ));
  }

  titleLayout() => Text(
        "Grab Extensive Rewards",
        style: TextStyle(
            color: ColorManager.dayNightText,
            fontWeight: FontWeight.w700,
            fontSize: 25),
        textAlign: TextAlign.center,
      );

  rewardLayout() => Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 50),
        padding: const EdgeInsets.all(20),
        width: Get.width,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
        child: Column(
          children: [
            Text(
              "Event Closing in ",
              style: TextStyle(
                  color: ColorManager.dayNightText,
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Month: 01 to 31 ",
              style: TextStyle(
                  color: ColorManager.colorPrimaryLight,
                  fontWeight: FontWeight.w400,
                  fontSize: 20),
            )
          ],
        ),
      );

  prizeLayout() => Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: const BoxDecoration(color: Color(0xff1F2128)),
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
                      "${wheelController.remainingChance.value} ",
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w400,
                          fontSize: 50),
                    )),
                const Text(
                  "Available \nChances ",
                  style: TextStyle(
                      color: Color(0xffB2B2B2),
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
                      "${wheelController.lastReward.value}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                const Text(
                  "Last Reward  ",
                  style: TextStyle(
                      color: Color(0xffB2B2B2),
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
            selected: controller.streamController.stream,
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
                  i <
                      wheelController
                          .wheelData.value.data!.wheelRewards!.length;
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
                            wheelController.wheelData.value.data!
                                        .wheelRewards![i].imagePath ==
                                    null
                                ? Text(
                                    wheelController.wheelData.value.data!
                                        .wheelRewards![i].currencySymbol
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
                                        wheelController.wheelData.value.data!
                                            .wheelRewards![i].imagePath
                                            .toString()),
                            Text(
                              '${wheelController.wheelData.value.data!.wheelRewards![i].currencySymbol} ${wheelController.wheelData.value.data!.wheelRewards![i].amount} ',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
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
                  style: const FortuneItemStyle(
                    borderColor: Colors.red,
                    borderWidth: 20,
                  ),
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );

  levelsLayout() => controller.obx((state) => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.activityList.length,
      itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: ColorManager.dayNightText),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Levels for " +
                      controller.activityList[index].name.toString(),
                  style: TextStyle(
                      color: ColorManager.dayNight,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    controller.activityList[index].conditions.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: ColorManager.dayNight,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                    text: "Earned Spins: ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                      text:
                          controller.activityList[index].currentView.toString(),
                      style: const TextStyle(
                          color: ColorManager.colorPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: "/" +
                          controller.activityList[index].totalView.toString(),
                      style: TextStyle(
                          color: ColorManager.dayNight,
                          fontSize: 16,
                          fontWeight: FontWeight.w400))
                ])),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  color: ColorManager.dayNight,
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Expanded(
                            child: FAProgressBar(
                          currentValue:
                              controller.activityList[index].progress != null
                                  ? controller.activityList[index].progress!
                                      .toDouble()
                                  : 0.0,
                          size: 7,
                          maxValue: 100,
                          changeColorValue: 100,
                          changeProgressColor: ColorManager.colorPrimaryLight,
                          backgroundColor: Colors.grey,
                          progressColor: ColorManager.colorPrimaryLight,
                          animatedDuration: const Duration(milliseconds: 300),
                          direction: Axis.horizontal,
                          verticalDirection: VerticalDirection.up,
                          formatValueFixed: 2,
                        )),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipOval(
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            width: 30,
                            color: ColorManager.colorPrimaryLight,
                            child: ClipOval(
                              child: Container(
                                alignment: Alignment.center,
                                color: ColorManager.dayNight,
                                width: 24,
                                height: 24,
                                child: Text(
                                  controller.activityList[index].currentLevel
                                      .toString(),
                                  style: TextStyle(
                                      color: ColorManager.dayNightText,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipOval(
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            width: 30,
                            color: ColorManager.colorPrimaryLight,
                            child: ClipOval(
                              child: Container(
                                alignment: Alignment.center,
                                color: ColorManager.dayNight,
                                width: 24,
                                height: 24,
                                child: Text(
                                    controller.activityList[index].nextLevel
                                        .toString(),
                                    style: TextStyle(
                                        color: ColorManager.dayNightText,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          )));

  lastRewardLayout() => Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          )),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Congratulations! you won!",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
          ),
          const Divider(
            thickness: 2,
            color: Color(0xff1F2128),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                GetX<WheelController>(
                    builder: (wheelController) => wheelController
                            .isWheelDataLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Expanded(
                            child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: wheelController
                                .wheelData.value.data!.recentRewards!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => Row(
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: RestUrl.placeholderImage,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      wheelController.wheelData.value.data!
                                          .recentRewards![index].amount
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "@" +
                                          wheelController.wheelData.value.data!
                                              .recentRewards![index].username
                                              .toString(),
                                      style: const TextStyle(
                                          color: Color(0xffB2B2B2),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ))),
              ],
            ),
          )
        ],
      ));

  setSpinSound() async {
    try {
      if (Platform.isIOS) {
        player.setUrl('${saveCacheDirectory}spin.mp3');
      } else {
        player.play();
        player.pause();
      }
    } catch (_) {}
  }

  spinTheWheelTap() async {
    if (wheelController.remainingChance.value > 0) {
      isSpin.value = true;

      listForReward.clear();

      Random p = Random();
      double cumulativeProbability = 0.0;
      List<WheelRewards> dataList = [];
      for (WheelRewards data in wheelController.wheelRewardsList) {
        cumulativeProbability = data.probability!.toDouble();
        if (p.nextInt(100) + 1 <= cumulativeProbability) {
          dataList.add(data);
          // return data;
        }
      }

      var random = getRandomElement(dataList);
      int id = random.id!.toInt();
      rewardId = id;
      selectedInt = random.id!.toInt().obs;

      // for(WheelRewards data in wheelController.wheelRewardsList){
      //   if(data.probability != null && data.probability!.toInt() < 10 && data.probability!.toInt()>0){
      //
      //   }
      // }
      //

      //await player.resume();
      controller.streamController.add(selectedInt.value - 1);
    } else {
      isSpin.value = true;
    }
  }

  void updateSpin() async {
    try {
      //progressDialogue(Get.context!);
      wheelController.getRewardUpdate(rewardId);
      // closeDialogue(Get.context!);
      wheelController.getWheelData();
      player.stop();
      await player.stop();
      await player.play();
      await player.pause();
      isSpin.value = false;
      showWinDialog(wheelController.wheelData.value.message.toString());
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
