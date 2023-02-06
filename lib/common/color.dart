import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorManager {
  static const Color deepPurple = Color(0xff1e234d);
  static const Color cyan = Color(0xff2DCBC8);
  static const Color orange = Color(0xffFF9933);
  static const Color red = Color(0xfff64a4a);
  static const Color colorPrimaryLight = Color(0xff0A8381);

  static const Color spinColorOne = Color(0xffB9E2E2);
  static const Color spinColorTwo = Color(0xffC8ECEC);
  static const Color spinColorThree = Color(0xffE5F3F2);
  static const Color spinColorBorder = Color(0xffA3683E);
  static const Color spinColorBorderTwo = Color(0xff20244C);
  static const Color spinColorDivider = Color(0xffC8CACA);

  static const Color colorAccent = Color(0xff0A8381);
  static Color dayNight = Get.isPlatformDarkMode ? Colors.black : Colors.white;
  static Color dayNightText =
      Get.isPlatformDarkMode ? Colors.white : Colors.black;
  static Color dayNightIcon =
      Get.isPlatformDarkMode ? colorPrimaryLight : colorAccent;

  static const Color colorAccentTransparent = Color(0x2f2dcbc8);

  static const LinearGradient walletGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff0A8381),
        Color(0xff1D5855),
        Colors.black,
      ]);
}
