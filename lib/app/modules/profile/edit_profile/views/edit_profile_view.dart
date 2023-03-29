
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back,
                        )),
                    Flexible(
                        child: Container(
                      alignment: Alignment.center,
                      width: Get.width,
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                profilePicLayout(),

                updateFieldsLayout(),
                submitButtonLayout()
                // InkWell(onTap: ()=>Get.to(EditProfile(user: user,)),child:  mainTile(Carbon.person, 'Edit Profile'),)
              ],
            ),
          )),
    );
  }
  profilePicLayout() => Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(200))),
      width: 100,
      height: 100,
      child: InkWell(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.network(
              RestUrl.assetsUrl + "profile_circle.svg",
              fit: BoxFit.fill,
              height: Get.height,
              width: Get.width,
            ),
            Container(
                height: 100,
                width: 100,
                child: Obx(() => controller.imagePath.value.isEmpty
                    ? Get.arguments["avatar"].toString().isNotEmpty
                    ? ClipOval(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl:
                    '${RestUrl.profileUrl}${Get.arguments["avatar"]}',
                    placeholder: (a, b) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CachedNetworkImage(
                    imageUrl: RestUrl.placeholderImage,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill)),
                        ),
                  ),
                )
                    : ClipOval(
                  child: Image.file(
                    File(controller.imagePath.value),
                    fit: BoxFit.fill,
                  ),
                ))),
            Container(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => controller.showSetImageDialog(),
                child: Icon(
                  IconlyBold.editSquare,
                  color: ColorManager.dayNightIcon,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ));


  updateFieldsLayout() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextFormField(
        controller: controller.userNameController,
        focusNode: controller.userNode,
        onChanged: (value) {
          controller.userName.value = value;
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Icon(
            IconlyLight.profile,

          ),
          hintText: "User name....",

        ),
      ),

      const SizedBox(
        height: 10,
      ),

      TextFormField(
        focusNode:controller. nameNode,
        controller: controller.nameController,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Icon(
            IconlyLight.tick_square,
          ),
          hintText: "full name....",

        ),
        onChanged: (value) {
          controller.name.value = value;
        },
      ),
      const SizedBox(
        height: 10,
      ),
      Visibility(
        visible: Get.arguments["email"].toString().isEmpty,
        child: TextFormField(
          controller: controller.emailController,
          focusNode: controller.emailNode,
          onChanged: (value) {
            controller.email.value = value;
          },
          decoration: InputDecoration(

            filled: true,
            prefixIcon: Icon(
              IconlyLight.message,

            ),
            hintText: "Email....",

          ),
        ),
      ),

      Visibility(
        visible: Get.arguments["phone"].toString().isEmpty,
        child: TextFormField(
          controller: controller.mobileController,
          focusNode: controller.mobileNode,
          onChanged: (value) {
            controller.mobile.value = value;
          },
          decoration: InputDecoration(


            filled: true,
            prefixIcon: Icon(
              Icons.mobile_friendly,

            ),
            hintText: "Mobile....",

          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),

      TextFormField(
        focusNode: controller.urlNode,
        controller: controller.webSiteController,
        decoration: InputDecoration(


          filled: true,
          prefixIcon: Icon(
            CupertinoIcons.link,

          ),
          hintText: "Website URL....",

        ),
        onChanged: (value) {
          controller.webSiteUrl.value = value;
        },
      ),
      const SizedBox(
        height: 10,
      ),

      TextFormField(
        focusNode: controller.bioNode,
        controller: controller.bioController,
        maxLength: 150,
        decoration: const InputDecoration(
          filled: true,
          hintText: "Bio....",
          prefixIcon: Icon(
            IconlyLight.info_square,
          ),
        ),
        onChanged: (value) {
          controller.bio.value = value;
        },
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        focusNode: controller.locationNode,
        controller: controller.locationController,
        decoration: InputDecoration(

          filled: true,
          hintText: "Location....",
          prefixIcon: Icon(
            IconlyLight.location,),
        ),
        onChanged: (value) {
          controller.location.value = value;
        },
      ),
      const SizedBox(
        height: 10,
      ),
      InkWell(
        onTap: () {
          DatePicker.showDatePicker(Get.context!,
              showTitleActions: true,
              minTime: DateTime(1920, 12, 12),
              maxTime: DateTime.now(), onChanged: (date) {
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                controller.dob.value = formattedDate;
              }, onConfirm: (date) {
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                controller.dob.value = formattedDate;
              }, currentTime: DateTime.now());

          // Get.bottomSheet(
          //     Container(
          //       height: Get.height / 4,
          //       child: CupertinoDatePicker(
          //         minimumDate: DateTime(1920),
          //         backgroundColor: ColorManager.dayNight,
          //         mode: CupertinoDatePickerMode.date,
          //         onDateTimeChanged: (value) {
          //           dob.value = value.toString();
          //         },
          //         initialDateTime: DateTime.now(),
          //         maximumDate: DateTime.now(),
          //       ),
          //     ),
          //     backgroundColor: ColorManager.dayNight);
        },
        child: Container(
          width: Get.width,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
            ),
          ),
          child: Row(
            children: [
              Icon(
                IconlyLight.calendar,
                color: ColorManager.colorAccent,
              ),
             Obx(() =>  Text(
               "  " + controller.dob.value.toString(),
             ))
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      dropDownGender(),
      const SizedBox(
        height: 10,
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     layoutYoutube(),
      //     layoutFacebook(),
      //     layoutInstagram(),
      //     layoutTwitter(),
      //   ],
      // )
    ],
  );
  dropDownGender() => Obx(() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
        3,
            (index) => InkWell(
          onTap: () {
            controller.genderSelectIndex.value = index;
          },
          child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                      controller.genderSelectIndex.value == index && index == 1
                          ? Colors.pink.shade100
                          : controller.genderSelectIndex.value == index &&
                          index == 0
                          ? Colors.blue.shade100
                          : controller.genderSelectIndex.value == index &&
                          index == 2
                          ? ColorManager.colorAccent
                          : Theme.of(Get.context!).primaryColor)),
              child: Row(
                children: [
                  Text(
                    controller.genderList[index],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: controller.genderSelectIndex.value == index &&
                            index == 1
                            ? Colors.pink.shade300
                            : controller.genderSelectIndex.value == index &&
                            index == 0
                            ? Colors.blue.shade300
                            : controller.genderSelectIndex.value == index &&
                            index == 2
                            ? ColorManager.colorAccent
                            : Theme.of(Get.context!).primaryColor),
                  ),
                  index == 0
                      ? Icon(
                    Icons.male,
                    color: Colors.blue.shade300,
                  )
                      : index == 1
                      ? Icon(
                    Icons.female,
                    color: Colors.pink.shade300,
                  )
                      : Icon(
                    Icons.transgender,
                    color: ColorManager.colorAccent,
                  )
                ],
              )),
        )),
  ));

  submitButtonLayout() => InkWell(
    onTap: () async {
      await controller.updateProfile();

    },
    child: Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorManager.colorPrimaryLight,
                ColorManager.colorAccent
              ])),
      child: const Text(
        "Save Profile",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  );
}
