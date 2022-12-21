import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_url.dart';

import '../../rest/rest_api.dart';
import '../../utils/util.dart';

FocusNode fieldNode = FocusNode();
FocusNode userNode = FocusNode();
FocusNode nameNode = FocusNode();
FocusNode lastNameNode = FocusNode();
FocusNode bioNode = FocusNode();
FocusNode urlNode = FocusNode();

class ManageAccount extends StatelessWidget {
  ManageAccount({Key? key}) : super(key: key);

  var selectedGender = 'Male'.obs;
  var genderList = ["Male", "Female", "Other"];
  ImagePicker _imagePicker = ImagePicker();
  var imagePath = "".obs;
  XFile image = XFile("");

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

  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController webSiteController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  var usersController = Get.find<UserDetailsController>();

  @override
  Widget build(BuildContext context) {
    nameController.text =
        usersController.userProfile.value.firstName.toString() == "null"
            ? ""
            : usersController.userProfile.value.firstName.toString();
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
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: ColorManager.dayNightText,
                        )),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.dayNightText),
                    )
                  ],
                ),
                profilePicLayout(),
                Divider(
                  color: ColorManager.dayNightText,
                ),
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
                      margin: const EdgeInsets.all(20),
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
                                Icon(
                                  Icons.camera,
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
                                Icon(Icons.image,
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
                child: Icon(
                  Icons.camera,
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
            controller: nameController,
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
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_outline,
                color: userNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
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
            controller: userNameController,
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
                Icons.person_outline,
                color: userNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
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
          TextFormField(
            controller: lastNameController,
            focusNode: lastNameNode,
            style: TextStyle(color: ColorManager.dayNightText),
            onChanged: (value) {
              lastName.value = value;
            },
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: lastNameNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: lastNameNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : const BorderSide(
                        color: Color(0xffFAFAFA),
                      ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: lastNameNode.hasFocus
                    ? const BorderSide(
                        color: Color(0xff2DCBC8),
                      )
                    : BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                      ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_outline,
                color: lastNameNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
              ),
              hintText: "Last name....",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          dropDownGender(),
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
                Icons.person_outline,
                color: urlNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
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
            style: TextStyle(color: ColorManager.dayNightText),
            maxLines: 10,
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
            ),
            onChanged: (value) {
              bio.value = value;
            },
          ),
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
        onTap: () {
          if (image.path.isNotEmpty) {
            usersController.updateuserProfile(
                profileImage: File(image.path),
                fullName: nameController.text,
                lastName: lastNameController.text,
                userName: userNameController.text,
                bio: bioController.text,
                gender: selectedGender.value,
                webSiteUrl: webSiteController.text);
          } else {
            usersController.updateuserProfile(
                fullName: nameController.text,
                lastName: lastNameController.text,
                userName: userNameController.text,
                bio: bioController.text,
                gender: selectedGender.value,
                webSiteUrl: webSiteController.text);
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

  dropDownGender() => Obx(() => selectedGender.value == ""
      ? Container()
      : Container(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          width: Get.width,
          decoration: BoxDecoration(
              color: ColorManager.colorAccentTransparent,
              border: Border.all(color: ColorManager.colorAccent),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Theme(
              data: Theme.of(Get.context!)
                  .copyWith(canvasColor: const Color(0xff353841)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  icon: const Icon(
                    Icons.keyboard_double_arrow_down,
                  ),
                  value: selectedGender.value,
                  items: genderList
                      .map((element) => DropdownMenuItem(
                            child: Text(
                              element,
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
