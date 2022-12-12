import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
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

import '../../controller/model/wheel_data_model.dart';

var wheelController = Get.find<WheelController>();

class SpinTheWheelGetx extends GetView<WheelController> {
  ScrollController _controller = ScrollController();

  SpinTheWheelGetx({Key? key}) : super(key: key);
  StreamController<int> _streamController = StreamController<int>();
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
                      wheelLayout(),
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
            ))
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
        margin: const EdgeInsets.only(top: 40, bottom: 10),
        height: Get.height / 2,
        child: ClipOval(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorManager.colorAccent,
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.colorAccent,
              ),
              padding: const EdgeInsets.all(2),
              child: FortuneWheel(
                duration: const Duration(seconds: 20),
                animateFirst: false,
                selected: _streamController.stream,
                indicators: <FortuneIndicator>[
                  FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: Get.height,
                        margin: EdgeInsets.only(bottom: 20),
                        child: RotatedBox(quarterTurns: 2,child: SvgPicture.asset(
                        'assets/spinDirection.svg',
                        height: 50,width: 50,
                          fit: BoxFit.fill,
                      ),),)),
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
                      child: Container(
                          height: Get.height,
                          width: Get.width,
                          decoration: BoxDecoration(
                              image: i % 2 == 0
                                  ? DecorationImage(
                                  image: AssetImage(
                                      "assets/pizza_two.png"),
                                  fit: BoxFit.fitHeight)
                                  :i % 2 == 1 ? DecorationImage(
                                  image: AssetImage(
                                      "assets/pizza_one.png"),
                                  fit: BoxFit.fitHeight):DecorationImage(
                                  image: AssetImage(
                                      "assets/pizza_three.png"),
                                  fit: BoxFit.fill)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    height: 30,
                                    width: 30,
                                    imageUrl: RestUrl.profileUrl +
                                        wheelController
                                            .wheelData
                                            .value
                                            .data!
                                            .wheelRewards![i]
                                            .imagePath
                                            .toString()),
                                Text(
                                  '${wheelController.wheelData.value.data!.wheelRewards![i].currencySymbol} ${wheelController.wheelData.value.data!.wheelRewards![i].amount} ',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )),
                      //     : Padding(
                      //   padding: const EdgeInsets.only(left: 25),
                      //   child: Image.network(
                      //     "${RestUrl.profileUrl}${wheelController.wheelData.value.data!.wheelRewards![i].imagePath}",
                      //     width: 30,
                      //     height: 30,
                      //   ),
                      // ),
                      style: const FortuneItemStyle(
                        borderColor: Colors.white,
                        borderWidth: 5,
                      ),
                    ),
                ],
                onAnimationEnd: () {
                  updateSpin();
                },
              ),
            ),
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

  levelsLayout() => GetX<WheelController>(
      builder: (wheelController) => wheelController.isWheelDataLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wheelController.activityList.length,
              itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Levels for " +
                              wheelController.activityList[index].name
                                  .toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          wheelController.activityList[index].conditions
                              .toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                            text: "Earned Spins: ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                              text: wheelController
                                  .activityList[index].earnedSpins
                                  .toString(),
                              style: const TextStyle(
                                  color: ColorManager.colorPrimaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          TextSpan(
                              text: "/" +
                                  wheelController.activityList[index].totalSpin
                                      .toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))
                        ])),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ClipOval(
                              child: Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 30,
                                color: ColorManager.colorPrimaryLight,
                                child: ClipOval(
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    width: 24,
                                    height: 24,
                                    child: Text(wheelController
                                        .activityList[index].progress
                                        .toString()),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: LinearProgressIndicator(
                              color: ColorManager.colorPrimaryLight,
                              value: wheelController
                                          .activityList[index].progress !=
                                      null
                                  ? wheelController
                                      .activityList[index].progress!
                                      .toDouble()
                                  : 0.0,
                              backgroundColor: Colors.grey,
                            )),
                            ClipOval(
                              child: Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 30,
                                color: ColorManager.colorPrimaryLight,
                                child: ClipOval(
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    width: 24,
                                    height: 24,
                                    child: Text(wheelController
                                        .activityList[index].maxLevel
                                        .toString()),
                                  ),
                                ),
                              ),
                            )
                          ],
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
        player.setUrl('${saveCacheDirectory}spin.mp3', isLocal: true);
      } else {
        player.play('${saveCacheDirectory}spin.mp3', isLocal: true);
        player.pause();
      }
    } catch (_) {}
  }

  spinTheWheelTap() async {
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
    _streamController.add(selectedInt.value - 1);

    if (wheelController.remainingChance.value > 0) {
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
      await player.play('${saveCacheDirectory}spin.mp3', isLocal: true);
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
