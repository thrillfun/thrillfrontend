import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/screens/setting/manage_account.dart';
import 'package:thrill/utils/util.dart';

import '../../rest/rest_url.dart';

class ProfileDetails extends GetView<UserDetailsController> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: Get.height,
        width: Get.width,
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: ColorManager.dayNightText,
                    )),
                Flexible(
                    child: Container(
                  alignment: Alignment.center,
                  width: Get.width,
                  child: Text(
                    "Your Account",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.dayNightText),
                  ),
                ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () => Get.to(ManageAccount()),
              child: profilePicLayout(),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              color: ColorManager.dayNightText,
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () => Get.to(ManageAccount()),
              child: aboutYouLayout(),
            ),
            const SizedBox(
              height: 10,
            ),

            // InkWell(
            //   onTap: () => Get.to(ManageAccount()),
            //   child: socialLayout(),
            // ),
          ],
        ),
      ),
    );
  }

  profilePicLayout() => SizedBox(
        height: 160,
        width: 160,
        child: CachedNetworkImage(
            placeholder: (a, b) => Center(
                  child: loader(),
                ),
            height: 160,
            width: 160,
            imageBuilder: (context, imageProvider) => Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.contain),
                  ),
                ),
            errorWidget: (context, string, dynamic) => CachedNetworkImage(
                placeholder: (a, b) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),
                imageUrl: RestUrl.placeholderImage),
            imageUrl: RestUrl.profileUrl +
                controller.userProfile.value.avatar.toString()),
      );
  aboutYouLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About You",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: ColorManager.dayNightText),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.profile,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Name",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorManager.dayNightText),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.name.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: ColorManager.dayNightText),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.tick_square,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Username",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorManager.dayNightText),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "@" +
                                controller.userProfile.value.username
                                    .toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: ColorManager.dayNightText),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.info_square,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Bio",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorManager.dayNightText),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                              child: Text(
                            controller.userProfile.value.bio.toString().isEmpty
                                ? "N/A"
                                : controller.userProfile.value.bio.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: ColorManager.dayNightText,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.calendar,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "DOB",
                style: TextStyle(
                    color: ColorManager.dayNightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.dob.toString().isEmpty
                                ? "N/A"
                                : controller.userProfile.value.dob.toString(),
                            style: TextStyle(
                                color: ColorManager.dayNightText,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.male,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Gender",
                style: TextStyle(
                    color: ColorManager.dayNightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.gender
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.gender
                                    .toString(),
                            style: TextStyle(
                                color: ColorManager.dayNightText,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.message,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Email",
                style: TextStyle(
                    color: ColorManager.dayNightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.email
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.email.toString(),
                            style: TextStyle(
                                color: ColorManager.dayNightText,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.call,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Mobile",
                style: TextStyle(
                    color: ColorManager.dayNightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.phone
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.phone.toString(),
                            style: TextStyle(
                                color: ColorManager.dayNightText,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
        ],
      );
  socialLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Social",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.info_square,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Instagram",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.instagram
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.instagram
                                    .toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.paper,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Facebook",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.facebook
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.facebook
                                    .toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.bag,
                color: ColorManager.dayNightText,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Twitter",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            controller.userProfile.value.twitter
                                    .toString()
                                    .isEmpty
                                ? "N/A"
                                : controller.userProfile.value.twitter
                                    .toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(child: Icon(IconlyLight.arrow_right_square))
                        ],
                      )))
            ],
          ),
        ],
      );
}
