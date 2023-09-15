import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/user_levels_controller.dart';

class UserLevelsView extends GetView<UserLevelsController> {
  const UserLevelsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) => Wrap(
          children: List.generate(
              state!.length,
              (index) => Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/spin_background.png"),
                            fit: BoxFit.fill)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          index == 0
                              ? Iconsax.video_octagon
                              : index == 1
                                  ? Iconsax.people
                                  : index == 2
                                      ? Iconsax.share
                                      : Iconsax.activity,
                          size: 65,
                          color: Colors.white,
                        ),
                        Html(
                          data: "Levels for " + state[index].name.toString(),
                          style: {
                            "body": Style(
                                fontSize: FontSize(22),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center),
                          },
                        ),
                        Container(
                          width: 20,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Visibility(
                          visible: state![index].earnedSpins.toString() !=
                              state![index].totalSpin.toString(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              state[index].conditions.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: state![index].earnedSpins.toString() !=
                              state![index].totalSpin.toString(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Earned Spins: ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                    controller.activityList[index].earnedSpins
                                            .toString()
                                            .isEmpty
                                        ? "0"
                                        : controller
                                            .activityList[index].earnedSpins
                                            .toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    " / " +
                                        controller.activityList[index].totalSpin
                                            .toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700))
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: state![index].earnedSpins.toString() ==
                                state![index].totalSpin.toString(),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Level Completed!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                            )),
                        Visibility(
                          visible: state![index].earnedSpins.toString() !=
                              state![index].totalSpin.toString(),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        Visibility(
                          visible: state![index].earnedSpins.toString() !=
                              state![index].totalSpin.toString(),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: FAProgressBar(
                                    currentValue: state[index].progress != null
                                        ? state[index].progress!.toDouble()
                                        : 0.0,
                                    size: 7,
                                    maxValue: 100,
                                    changeColorValue: 100,
                                    changeProgressColor: Colors.white,
                                    backgroundColor:
                                        ColorManager.colorAccentTransparent,
                                    progressColor: Colors.white,
                                    animatedDuration:
                                        const Duration(milliseconds: 300),
                                    direction: Axis.horizontal,
                                    verticalDirection: VerticalDirection.up,
                                    formatValueFixed: 2,
                                  ),
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
                                          width: 24,
                                          height: 24,
                                          child: Text(
                                            state[index]
                                                .currentLevel
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
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
                                          width: 24,
                                          height: 24,
                                          child: Text(
                                              (int.parse(state![index]
                                                          .currentLevel
                                                          .toString()) +
                                                      1)
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
        ));
  }
}
