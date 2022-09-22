import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/utils/util.dart';

class LoginGetxScreen extends StatelessWidget {
  LoginGetxScreen({Key? key}) : super(key: key);
  final TextEditingController emailCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: Get.width,
          height: Get.height,
          decoration: const BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: Column(
              children: [
                Image.asset(
                  "assets/logo.png",
                  width: Get.width / 3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 40,
                ),
                loginLayout()
              ],
            ),
          )),
    );
  }

  loginLayout() {
    return Expanded(
        child: GlassContainer(
      width: Get.width,
      color: Colors.white.withOpacity(0.1),
      blur: 10,
      height: Get.height,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Login',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            maxLength: 10,
            controller: emailCtr,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                hintText: mobileNumber,
                isDense: true,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(
                  Icons.phone_android_outlined,
                  color: Colors.white,
                ),
                errorText: ""),
          ),
        ],
      ),
    ));
  }
}
