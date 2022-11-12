import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/rest/rest_url.dart';

class SoundListBottomSheet extends StatelessWidget {
  SoundListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GetX<SoundsController>(
          builder: (soundsController) => soundsController.localSoundsList.isEmpty?Center(child: ,),
        ),
      ),
    );
  }
}
