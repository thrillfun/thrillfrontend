import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/image/image_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';

import '../../controller/image/image_controller.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

FocusNode fieldNode = FocusNode();
FocusNode userNode = FocusNode();
FocusNode nameNode = FocusNode();
FocusNode lastNameNode = FocusNode();
FocusNode bioNode = FocusNode();
FocusNode urlNode = FocusNode();
FocusNode locationNode = FocusNode();
FocusNode emailNode = FocusNode();
FocusNode mobileNode = FocusNode();

class ManageAccount extends StatelessWidget {
  var imageController = Get.find<ImageController>();
  ManageAccount({Key? key}) : super(key: key);

  var selectedGender = 'Male'.obs;
  var genderList = ["Male", "Female", "Other"];

  var genderSelectIndex = 0.obs;

  var fbLink = "https://www.facebook.com/".obs;
  var instaLink = "https://www.instagram.com/".obs;
  var youtubeLink = "https://www.youtube.com/".obs;
  var twitterLink = "https://twitter.com/".obs;

  var name = "".obs;
  var userName = "".obs;
  var lastName = "".obs;

  var webSiteUrl = "".obs;
  var gender = "".obs;
  var bio = "".obs;
  var dob = "".obs;
  var email = "".obs;
  var mobile = "".obs;

  var location = "".obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController webSiteController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  var usersController = Get.find<UserDetailsController>();

  @override
  Widget build(BuildContext context) {
    usersController.userProfile.value.gender == "Male"
        ? genderSelectIndex.value = 0
        : usersController.userProfile.value.gender == "Female"
            ? genderSelectIndex.value = 1
            : genderSelectIndex.value = 2;
    nameController.text =
        usersController.userProfile.value.name.toString() == "null"
            ? ""
            : usersController.userProfile.value.name.toString();
    lastNameController.text =
        usersController.userProfile.value.lastName.toString() == "null"
            ? ""
            : usersController.userProfile.value.lastName.toString();
    userNameController.text =
        usersController.userProfile.value.username.toString() == "null"
            ? ""
            : usersController.userProfile.value.username.toString();
    webSiteController.text =
        usersController.userProfile.value.websiteUrl.toString() == "null"
            ? ""
            : usersController.userProfile.value.websiteUrl.toString();
    bioController.text =
        usersController.userProfile.value.bio.toString() == "null"
            ? ""
            : usersController.userProfile.value.bio.toString();
    emailController.text =
        usersController.userProfile.value.email.toString() == "null"
            ? ""
            : usersController.userProfile.value.email.toString();

    mobileController.text =
        usersController.userProfile.value.phone.toString() == "null"
            ? ""
            : usersController.userProfile.value.phone.toString();
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
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
                          color: ColorManager.dayNightText,
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
                            color: ColorManager.dayNightText),
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
                child: Obx(() => imageController.imagePath.value.isEmpty
                    ? usersController.userProfile.value.avatar!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  '${RestUrl.profileUrl}${usersController.userProfile.value.avatar}',
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
                          File(imageController.imagePath.value),
                          fit: BoxFit.fill,
                        ),
                      ))),
            Container(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => imageController.showSetImageDialog(),
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
            controller: userNameController,
            focusNode: userNode,
            style: TextStyle(color: ColorManager.dayNightText),
            onChanged: (value) {
              userName.value = value;
            },
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: userNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: userNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: userNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.transparent.withOpacity(0.0),
                      ),
              ),
              filled: true,
              prefixIcon: Icon(
                IconlyLight.profile,
                color: userNode.hasFocus
                    ? ColorManager.colorAccent
                    : ColorManager.dayNightText,
              ),
              hintText: "User name....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TextFormField(
            focusNode: nameNode,
            controller: nameController,
            style: TextStyle(color: ColorManager.dayNightText),
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: nameNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: nameNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: nameNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              prefixIcon: Icon(
                IconlyLight.tick_square,
                color: userNode.hasFocus
                    ? ColorManager.colorAccent
                    : ColorManager.dayNightText,
              ),
              hintText: "full name....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
            ),
            onChanged: (value) {
              name.value = value;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: usersController.userProfile.value.email!.isEmpty,
            child: TextFormField(
              controller: emailController,
              focusNode: emailNode,
              style: TextStyle(color: ColorManager.dayNightText),
              onChanged: (value) {
                email.value = value;
              },
              decoration: InputDecoration(
                focusColor: ColorManager.colorAccent,
                fillColor: emailNode.hasFocus
                    ? ColorManager.colorAccentTransparent
                    : Colors.grey.withOpacity(0.1),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: emailNode.hasFocus
                      ? const BorderSide(
                          color: Color(0xff2DCBC8),
                        )
                      : const BorderSide(
                          color: Color(0xffFAFAFA),
                        ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: emailNode.hasFocus
                      ? const BorderSide(
                          color: Color(0xff2DCBC8),
                        )
                      : BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                ),
                filled: true,
                prefixIcon: Icon(
                  IconlyLight.message,
                  color: emailNode.hasFocus
                      ? ColorManager.colorAccent
                      : ColorManager.dayNightText,
                ),
                hintText: "Email....",
                hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 14),
              ),
            ),
          ),

          Visibility(
            visible: usersController.userProfile.value.phone!.isEmpty,
            child: TextFormField(
              controller: mobileController,
              focusNode: mobileNode,
              style: TextStyle(color: ColorManager.dayNightText),
              onChanged: (value) {
                mobile.value = value;
              },
              decoration: InputDecoration(
                focusColor: ColorManager.colorAccent,
                fillColor: mobileNode.hasFocus
                    ? ColorManager.colorAccentTransparent
                    : Colors.grey.withOpacity(0.1),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: mobileNode.hasFocus
                      ? const BorderSide(
                          color: Color(0xff2DCBC8),
                        )
                      : const BorderSide(
                          color: Color(0xffFAFAFA),
                        ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: mobileNode.hasFocus
                      ? const BorderSide(
                          color: Color(0xff2DCBC8),
                        )
                      : BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                ),
                filled: true,
                prefixIcon: Icon(
                  Icons.mobile_friendly,
                  color: mobileNode.hasFocus
                      ? ColorManager.colorAccent
                      : ColorManager.dayNightText,
                ),
                hintText: "Mobile....",
                hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),

          TextFormField(
            focusNode: urlNode,
            controller: webSiteController,
            style: TextStyle(color: ColorManager.dayNightText),
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: urlNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: urlNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: urlNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              prefixIcon: Icon(
                CupertinoIcons.link,
                color: urlNode.hasFocus
                    ? ColorManager.colorAccent
                    : ColorManager.dayNightText,
              ),
              hintText: "Website URL....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
            ),
            onChanged: (value) {
              webSiteUrl.value = value;
            },
          ),
          const SizedBox(
            height: 10,
          ),

          TextFormField(
            focusNode: bioNode,
            controller: bioController,
            maxLength: 150,
            style: TextStyle(color: ColorManager.dayNightText),
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: bioNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: bioNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: bioNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              hintText: "Bio....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
              prefixIcon: Icon(
                IconlyLight.info_square,
                color: bioNode.hasFocus
                    ? ColorManager.colorAccent
                    : ColorManager.dayNightText,
              ),
            ),
            onChanged: (value) {
              bio.value = value;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            focusNode: locationNode,
            controller: locationController,
            style: TextStyle(color: ColorManager.dayNightText),
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: locationNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: bioNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: bioNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              hintText: "Location....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
              prefixIcon: Icon(
                IconlyLight.location,
                color: locationNode.hasFocus
                    ? ColorManager.colorAccent
                    : ColorManager.dayNightText,
              ),
            ),
            onChanged: (value) {
              location.value = value;
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
                dob.value = formattedDate;
              }, onConfirm: (date) {
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                dob.value = formattedDate;
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
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(IconlyLight.calendar),
                  Obx(() =>
                      Text(usersController.userProfile.value.dob.toString()))
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

  submitButtonLayout() => InkWell(
        onTap: () async {
          if (imageController.imagePath.value.isNotEmpty) {
            await usersController.updateuserProfile(
                profileImage: File(imageController.imagePath.value),
                fullName: nameController.text,
                lastName: lastNameController.text,
                userName: userNameController.text,
                bio: bioController.text,
                gender: genderList[genderSelectIndex.value],
                webSiteUrl: webSiteController.text,
                dob: dob.value,
                location: location.value,
                phone: mobile.value,
                email: email.value);
          } else {
            await usersController.updateuserProfile(
                fullName: nameController.text,
                lastName: lastNameController.text,
                userName: userNameController.text,
                bio: bioController.text,
                gender: genderList[genderSelectIndex.value],
                webSiteUrl: webSiteController.text,
                dob: dob.value,
                location: location.value,
                phone: mobile.value,
                email: email.value);
          }
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

  dropDownGender() => Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            3,
            (index) => InkWell(
                  onTap: () {
                    genderSelectIndex.value = index;
                  },
                  child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  genderSelectIndex.value == index && index == 1
                                      ? Colors.pink.shade100
                                      : genderSelectIndex.value == index &&
                                              index == 0
                                          ? Colors.blue.shade100
                                          : genderSelectIndex.value == index &&
                                                  index == 2
                                              ? ColorManager.colorAccent
                                              : ColorManager.dayNightText)),
                      child: Row(
                        children: [
                          Text(
                            genderList[index],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: genderSelectIndex.value == index &&
                                        index == 1
                                    ? Colors.pink.shade300
                                    : genderSelectIndex.value == index &&
                                            index == 0
                                        ? Colors.blue.shade300
                                        : genderSelectIndex.value == index &&
                                                index == 2
                                            ? ColorManager.colorAccent
                                            : ColorManager.dayNightText),
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

  layoutYoutube() => InkWell(
        onTap: () => Get.defaultDialog(
            title: 'input Youtube URL',
            content: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: TextFormField(
                initialValue: youtubeLink.value,
                onChanged: (text) => youtubeLink.value = text,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Youtube link",
                  hintStyle: const TextStyle(color: Colors.grey),
                  isDense: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ColorManager.colorPrimaryLight),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )),
        child: const Icon(Icons.youtube_searched_for_sharp),
      );

  layoutFacebook() => InkWell(
        onTap: () => Get.defaultDialog(
            title: 'input Facebook URL',
            content: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: TextFormField(
                initialValue: fbLink.value,
                onChanged: (text) => fbLink.value = text,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Facebook link",
                  hintStyle: const TextStyle(color: Colors.grey),
                  isDense: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ColorManager.colorPrimaryLight),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )),
        child: const Icon(Icons.facebook),
      );

  layoutInstagram() => InkWell(
        onTap: () => Get.defaultDialog(
            title: 'input Instagram URL',
            content: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: TextFormField(
                initialValue: instaLink.value,
                onChanged: (text) => instaLink.value = text,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Instagram link",
                  hintStyle: const TextStyle(color: Colors.grey),
                  isDense: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ColorManager.colorPrimaryLight),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )),
        child: Icon(
          Icons.camera,
          color: ColorManager.dayNightIcon,
        ),
      );

  layoutTwitter() => InkWell(
        onTap: () => Get.defaultDialog(
            title: 'input Twitter URL',
            content: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: const Color(0xff353841),
                      border: Border.all(color: Colors.transparent),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    initialValue: twitterLink.value,
                    onChanged: (text) => twitterLink.value = text,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Twitter link",
                      hintStyle: const TextStyle(color: Colors.grey),
                      isDense: true,
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: ColorManager.colorPrimaryLight),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )),
        child: const Icon(Icons.brightness_medium),
      );

  Widget mainTile(IconData icon, String text) {
    return SizedBox(
      child: ListTile(
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: Card(
          margin: const EdgeInsets.only(right: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, color: ColorManager.colorAccent, size: 20),
          ),
        ),
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 0,
        minLeadingWidth: 30,
        minVerticalPadding: 0,
      ),
    );
  }

  saveLinkButton() => Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
          "Save",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Request"),
      onPressed: () {
        Navigator.pop(context);
        deactiveAccount();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Manage Account"),
      content: const Text(
          "Would you like to send Deactivate Account request to admin?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deactiveAccount() async {
    progressDialogue(Get.context!);
    var result = await RestApi.deactiveAccount();
    var json = jsonDecode(result.body);
    if (json['status']) {
      closeDialogue(Get.context!);
      showSuccessToast(Get.context!, json['message']);
    } else {
      closeDialogue(Get.context!);
      showErrorToast(Get.context!, json['message']);
    }
  }

  getProfile() async {
    try {
      var instance = await SharedPreferences.getInstance();
    } catch (e) {
      Navigator.pop(Get.context!);
      showErrorToast(Get.context!, e.toString());
    }
  }
}
