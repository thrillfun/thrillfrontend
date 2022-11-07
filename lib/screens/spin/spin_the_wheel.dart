import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrill/models/recent_rewards.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/earnSpin_model.dart';
import '../../models/probility_counter.dart';
import '../../models/wheelDetails_model.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

class SpinTheWheel extends StatefulWidget {
  const SpinTheWheel({Key? key}) : super(key: key);

  @override
  State<SpinTheWheel> createState() => _SpinTheWheelState();

  static const String routeName = '/spin';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const SpinTheWheel(),
    );
  }
}

class _SpinTheWheelState extends State<SpinTheWheel>
    with TickerProviderStateMixin {
  bool isSpinning = false;
  int remainingChance = 0;
  int usedChanceValue = 0;
  int selectedInt = 0;
  late AnimationController spinController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 789));

  StreamController<int> controller = StreamController<int>();
  bool isLoading = true;
  bool isSpin = false;
  List<EarnSpin> earnList = List<EarnSpin>.empty(growable: true);
  WheelDetails? wheelDetails;
  var listForReward = [];
  int rewardId = 0;
  AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    controller.close();
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setSpinSound();
    loadWheelDetails();
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/splash.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          //shape: const Border(bottom: BorderSide(color: Colors.white, width: 1)),
          centerTitle: true,
          title: const Text(''),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear)),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    wheelDetails!.recentRewards.isEmpty
                        ? const SizedBox(width: 10)
                        : ListView.builder(
                            itemCount: wheelDetails!.recentRewards.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return winnerLayout(
                                  wheelDetails!.recentRewards[index]);
                            }),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      grabExtensiveRewards,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      eventClosingIn,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Month: 01 to 31',
                      style: TextStyle(fontSize: 17, color: ColorManager.cyan),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              remainingChance.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              availableChange,
                              style: TextStyle(color: ColorManager.orange),
                            )
                          ],
                        ),
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              //usedChanceValue.toString(),
                              wheelDetails?.last_reward ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              lastReward,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                      ],
                    ),
                    // const Spacer(),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height * .52,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                height: 300,
                                width: 300,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorManager.spinColorBorder,
                                      ColorManager.spinColorBorderTwo
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomLeft,
                                  ),
                                ),
                                child: FortuneWheel(
                                  duration: const Duration(seconds: 20),
                                  animateFirst: false,
                                  selected: controller.stream,
                                  indicators: <FortuneIndicator>[

                                  ],
                                  physics: CircularPanPhysics(
                                    duration: const Duration(seconds: 10),
                                    curve: Curves.decelerate,
                                  ),
                                  items: [
                                    for (int i = 0;
                                        i < wheelDetails!.wheelRewards.length;
                                        i++)
                                      FortuneItem(
                                        child: wheelDetails!
                                                    .wheelRewards[i].is_image ==
                                                0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 25),
                                                child: Text(
                                                  '${wheelDetails!.wheelRewards[i].currency_symbol} ${wheelDetails!.wheelRewards[i].amount} ',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 25),
                                                child: Image.network(
                                                  "${RestUrl.profileUrl}${wheelDetails!.wheelRewards[i].image_path}",
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                        style: FortuneItemStyle(
                                          color: i % 2 == 1
                                              ? ColorManager.spinColorTwo
                                              : ColorManager.spinColorThree,
                                          borderColor:
                                              ColorManager.spinColorDivider,
                                          borderWidth: 1,
                                        ),
                                      ),
                                  ],
                                  onAnimationEnd: () {
                                    updateSpin();
                                  },
                                ),
                              ),
                              const Positioned(
                                  top: 10,
                                  child: SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Text(""),
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                              //isSpin ? null :
                              onPressed: spinTheWheelTap,
                              style: ElevatedButton.styleFrom(
                                  primary: isSpin
                                      ? Colors.grey[400]
                                      : ColorManager.deepPurple,
                                  fixedSize: Size(getWidth(context) * .75, 54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: Text(
                                spinTheWheel,
                                style: TextStyle(
                                    fontSize: 19,
                                    color:
                                        isSpin ? Colors.black : Colors.white),
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: getWidth(context),
                              height: getHeight(context),
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: earnList.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Level for ${earnList[index].name}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        card(earnList[index]),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  spinTheWheelTap() async {
    try {
      if (remainingChance > 0) {
        setState(() {
          isSpin = true;
        });
        listForReward.clear();
        var result = await RestApi.getAvailableProbilityCounter();
        var jsonResult = jsonDecode(result.body);
        listForReward = List<ProbilityCounter>.from(
                jsonResult['data'].map((i) => ProbilityCounter.fromJson(i)))
            .toList(growable: true);
        ProbilityCounter element =
            getRandomElement(listForReward) as ProbilityCounter;
        int id = element.id - 1;
        rewardId = element.id;
        await player.resume();
        setState(() {
          selectedInt = id;
          controller.add(selectedInt);
        });
      } else {
        setState(() {
          isSpin = true;
        });
      }
    } catch (e) {
      showErrorToast(context, e.toString());
    }
  }

  Widget winnerLayout(RecentRewards recentReward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
      decoration: BoxDecoration(
          color: ColorManager.deepPurple,
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_circle_rounded,
            color: Colors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 0,
            child: Text(
              'Congrates! User @${recentReward.username} Just won ',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Text(
            '${recentReward.amount} ${recentReward.currency_symbol}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void loadWheelDetails() async {
    try {
      var result = await RestApi.getWheelDetails();
      var json = jsonDecode(result.body);
      if (json['status']) {
        wheelDetails = WheelDetails.fromJson(json['data']);
        remainingChance = int.parse(wheelDetails!.available_chance);
        usedChanceValue = int.parse(wheelDetails!.used_chance);
      }
      if (remainingChance == 0) {
        isSpin = true;
      }
      var resultEarn = await RestApi.getWheelEarnedDetails();
      var jsonEarn = jsonDecode(resultEarn.body);
      if (jsonEarn['status']) {
        earnList.clear();
        earnList = List<EarnSpin>.from(
                jsonEarn['data']['activities'].map((i) => EarnSpin.fromJson(i)))
            .toList(growable: true);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }

  void updateSpin() async {
    try {
      progressDialogue(context);
      var result = await RestApi.updateWheel(rewardId);
      var json = jsonDecode(result.body);
      closeDialogue(context);
      if (json['status']) {
        loadWheelDetails();
        player.stop();
        await player.stop();
        await player.play('${saveCacheDirectory}spin.mp3', isLocal: true);
        await player.pause();
        isSpin = false;
        remainingChance = int.parse(json['data']['available_chance']);
        usedChanceValue = int.parse(json['data']['used_chance']);
        showSuccessToast(context, json['message']);
        setState(() {});
      } else {
        showErrorToast(context, json['message']);
      }
    } catch (e) {
      closeDialogue(context);
      showErrorToast(context, e.toString());
    }
  }

  Widget card(EarnSpin earnModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          boxShadow: kElevationToShadow[2],
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: earnModel.conditions + '\n\n',
                      style: const TextStyle(color: Colors.black)),
                  const TextSpan(
                      text: earnedSpins, style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: '${earnModel.earned_spins}/${earnModel.total_spin}',
                      style: const TextStyle(color: Colors.black))
                ]),
              )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .80,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: Row(
              children: [
                Container(
                  height: 25,
                  width: 25,
                  margin: const EdgeInsets.only(left: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade900, shape: BoxShape.circle),
                  child: Text(
                    earnModel.current_level,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: SliderComponentShape.noThumb,
                        trackHeight: 3),
                    child: Slider(
                        max: int.parse(earnModel.max_level) * 10,
                        min: 0,
                        value: double.parse(earnModel.progress.toString()) * 10,
                        activeColor: ColorManager.cyan,
                        onChanged: (val) {}),
                  ),
                ),
                Container(
                  height: 25,
                  width: 25,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Text(
                    earnModel.next_level,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
