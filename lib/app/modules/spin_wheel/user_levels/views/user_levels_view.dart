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
    return controller.obx((state) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.activityList.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Html(
                data: "Levels for " +
                    controller.activityList[index].name.toString(),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w400))
                  ])),
              const SizedBox(
                height: 20,
              ),
              Divider(
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
                              width: 24,
                              height: 24,
                              child: Text(
                                controller.activityList[index].currentLevel
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
                                  controller.activityList[index].nextLevel
                                      .toString(),
                                  style: TextStyle(
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
  }
}
