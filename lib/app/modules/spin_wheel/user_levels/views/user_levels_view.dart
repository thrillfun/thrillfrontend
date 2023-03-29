import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:get/get.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/user_levels_controller.dart';

class UserLevelsView extends GetView<UserLevelsController> {
  const UserLevelsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) => Wrap(
          children: List.generate(
              state!.length,
              (index) => Card(
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 10,
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Html(
                            data: "Levels for " + state[index].name.toString(),
                            style: {
                              "body": Style(
                                  fontSize: FontSize(24),
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center),
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: state![index].nextLevel != 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                state[index].conditions.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: state![index].nextLevel != 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Earned Spins: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                    controller.activityList[index].currentView
                                        .toString(),
                                    style: const TextStyle(
                                        color: ColorManager.colorPrimaryLight,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                                Text(
                                    "/" +
                                        controller.activityList[index].totalView
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Visibility(
                            visible: state![index].nextLevel != 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: FAProgressBar(
                                      currentValue: state[index].progress !=
                                              null
                                          ? state[index].progress!.toDouble()
                                          : 0.0,
                                      size: 7,
                                      maxValue: 100,
                                      changeColorValue: 100,
                                      changeProgressColor:
                                          ColorManager.colorPrimaryLight,
                                      backgroundColor: Colors.grey,
                                      progressColor:
                                          ColorManager.colorPrimaryLight,
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
                                                state[index]
                                                    .nextLevel
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                              visible: state![index].nextLevel == 0,
                              child: Text(
                                'Level Completed!',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  )),
        ));
  }
}
