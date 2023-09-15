import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/app/modules/settings/profile_details/controllers/profile_details_controller.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/utils.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Flexible(
                child: Container(
              alignment: Alignment.center,
              width: Get.width,
              child: Text(
                "Your Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ))
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: Get.height,
        width: Get.width,
        child: controller.obx(
            (state) => ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () =>
                          Get.toNamed(Routes.EDIT_PROFILE, arguments: {}),
                      child: profilePicLayout(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
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
            onLoading: manageAccountShimmer()),
      ),
    );
  }

  profilePicLayout() => SizedBox(
        height: 160,
        width: 160,
        child:
            imgProfileDetails(controller.userProfile.value.avatar.toString()),
      );
  aboutYouLayout() => controller.obx((state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About You",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                IconlyLight.profile,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
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
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Username",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Expanded(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "@" + state!.value.username.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Bio",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Text(
                            state!.value.bio.toString().isEmpty
                                ? "N/A"
                                : state!.value.bio.toString(),
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "DOB",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Expanded(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.dob.toString().isEmpty
                                ? "N/A"
                                : state!.value.dob.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.gender.toString().isEmpty
                                ? "N/A"
                                : state!.value.gender.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Expanded(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.email.toString().isEmpty
                                ? "N/A"
                                : state!.value.email.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
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
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Mobile",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Expanded(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.phone.toString().isEmpty
                                ? "N/A"
                                : state!.value.phone.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
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
      ));
  socialLayout() => controller.obx((state) => Column(
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
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Instagram",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.instagram.toString().isEmpty
                                ? "N/A"
                                : state!.value.instagram.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
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
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Facebook",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.facebook.toString().isEmpty
                                ? "N/A"
                                : state!.value.facebook.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
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
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Twitter",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              Flexible(
                  child: Container(
                      width: Get.width,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state!.value.twitter.toString().isEmpty
                                ? "N/A"
                                : state!.value.twitter.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
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
      ));
}
