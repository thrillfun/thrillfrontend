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
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: Get.height,
        width: Get.width,
        child:controller.obx((state) =>  ListView(
          shrinkWrap: true,
          children: [
            Row(
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
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () => Get.toNamed(Routes.EDIT_PROFILE,arguments: {  "avatar": state!.value.avatar,
                "email": state!.value.email??"",
                "phone": state!.value.phone??"",
                "dob":state!.value.dob??"",
                "userName": state.value.username??"",
                "name": state!.value.firstName??"",
                "last_name": state!.value.lastName??"",
                "mobile": state!.value.phone??"",
                "website":state!.value.websiteUrl??"",
                "bio":state!.value.bio??"",
                "location":state!.value.location??""}),
              child: profilePicLayout(),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
            ),
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
        )),
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
  aboutYouLayout() => controller.obx((state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "About You",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
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
              fontSize: 20,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
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
              fontSize: 20,
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
                        "@" +
                            state!.value.username
                                .toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
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
              fontSize: 20,
            ),
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
                            state!.value.bio.toString().isEmpty
                                ? "N/A"
                                : state!.value.bio.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ),
          Flexible(
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
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ),
          Flexible(
              child: Container(
                  width: Get.width,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        state!.value.gender
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.gender
                            .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ),
          Flexible(
              child: Container(
                  width: Get.width,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        state!.value.email
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.email.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ),
          Flexible(
              child: Container(
                  width: Get.width,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        state!.value.phone
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.phone.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
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
                        state!.value.instagram
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.instagram
                            .toString(),
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
                        state!.value.facebook
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.facebook
                            .toString(),
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
                        state!.value.twitter
                            .toString()
                            .isEmpty
                            ? "N/A"
                            : state!.value.twitter
                            .toString(),
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

