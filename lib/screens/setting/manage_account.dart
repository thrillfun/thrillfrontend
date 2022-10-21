import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/profile/edit_profile.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';

import '../../common/strings.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class ManageAccount extends StatelessWidget {
  User user = User.fromJson(GetStorage().read("user"));
  var selectedGender = 'Male'.obs;
  var genderList = ["Male", "Female", "Other"];
  ImagePicker _imagePicker = ImagePicker();
  var imagePath = "".obs;
  XFile image = XFile("");

  var fbLink = "https://www.facebook.com/".obs;
  var instaLink = "https://www.instagram.com/".obs;
  var youtubeLink = "https://www.youtube.com/".obs;
  var twitterLink = "https://twitter.com/".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: processGradient),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    profilePicLayout(),
                    updateFieldsLayout(),
                    submitButtonLayout()
                    // InkWell(onTap: ()=>Get.to(EditProfile(user: user,)),child:  mainTile(Carbon.person, 'Edit Profile'),)
                  ],
                ),
              ))
        ],
      ),
    );
  }

  profilePicLayout() => Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(200))),
      width: 120,
      height: 120,
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
                child: Obx(() => imagePath.value.isEmpty
                    ? user.avatar!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: '${RestUrl.profileUrl}${user.avatar}',
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
                          File(image.path),
                          fit: BoxFit.fill,
                        ),
                      ))),
            Container(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => Get.defaultDialog(
                    title: "Update Profile Image",
                    content: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async => {
                              image = (await _imagePicker.pickImage(
                                  source: ImageSource.camera))!,
                              imagePath.value = image.path,
                            },
                            child: Column(
                              children: const [
                                Iconify(
                                  Carbon.camera,
                                  color: ColorManager.colorAccent,
                                ),
                                Text('Take Picture',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async => {
                              image = (await _imagePicker.pickImage(
                                  source: ImageSource.gallery))!,
                              imagePath.value = image.path
                            },
                            child: Column(
                              children: const [
                                Iconify(Carbon.image,
                                    color: ColorManager.colorAccent),
                                Text(
                                  'Pick Image',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                child: Iconify(
                  Carbon.camera,
                  color: Colors.white,
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
          Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: const Color(0xff353841)),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              initialValue: user.username,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Username",
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: const Color(0xff353841)),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              initialValue: user.name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          dropDownGender(),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: const Color(0xff353841)),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              initialValue: user.websiteUrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Website Url",
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: const Color(0xff353841)),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              initialValue: user.bio,
              style: TextStyle(color: Colors.white),
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Bio",
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              layoutYoutube(),
              layoutFacebook(),
              layoutInstagram(),
              layoutTwitter(),
            ],
          )
        ],
      );

  submitButtonLayout() => InkWell(
        onTap: () {},
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

  dropDownGender() => Obx(() => selectedGender.value == ""
      ? Container()
      : Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          padding: const EdgeInsets.only(left: 10, right: 10),
          width: Get.width,
          decoration: BoxDecoration(
              color: const Color(0xff353841),
              border: Border.all(color: const Color(0xff353841)),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Theme(
              data: Theme.of(Get.context!)
                  .copyWith(canvasColor: const Color(0xff353841)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  icon: const Icon(
                    Icons.keyboard_double_arrow_down,
                    color: Colors.white,
                  ),
                  value: selectedGender.value,
                  items: genderList
                      .map((element) => DropdownMenuItem(
                            child: Text(
                              element,
                              style: TextStyle(color: Colors.white),
                            ),
                            value: element,
                          ))
                      .toList(growable: true),
                  onChanged: (value) {
                    selectedGender.value = value!.toString();
                  },
                ),
              ))));

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
        child: const Iconify(Logos.youtube_icon),
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
        child: const Iconify(Logos.facebook),
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
        child: const Iconify(
          Logos.instagram_icon,
          color: Colors.white,
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
        child: const Iconify(Logos.twitter),
      );

  Widget mainTile(String icon, String text) {
    return SizedBox(
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: Card(
          margin: EdgeInsets.only(right: 20),
          child: Container(
            padding: EdgeInsets.all(5),
            child: Iconify(icon, color: ColorManager.colorAccent, size: 20),
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
