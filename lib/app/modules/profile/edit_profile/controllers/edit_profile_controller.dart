import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';

import '../../../../utils/color_manager.dart';

class EditProfileController extends GetxController {
  var dio = client.Dio(client.BaseOptions(baseUrl: RestUrl.baseUrl));
  var imagePath = "".obs;
  XFile image = XFile("");
  final _imagePicker = ImagePicker();
  var selectedGender = 'Male'.obs;
  var genderList = ["Male", "Female", "Other"];
  var genderSelectIndex = 0.obs;
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
  FocusNode fieldNode = FocusNode();
  FocusNode userNode = FocusNode();
  FocusNode nameNode = FocusNode();
  FocusNode lastNameNode = FocusNode();
  FocusNode bioNode = FocusNode();
  FocusNode urlNode = FocusNode();
  FocusNode locationNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode mobileNode = FocusNode();

  @override
  void onInit() {

    super.onInit();
  }

  @override
  void onReady() {
    userNameController.text = Get.arguments["username"]??"";
    nameController.text = Get.arguments["name"]??"";
    lastNameController.text = Get.arguments["name"]??"";
    emailController.text = Get.arguments["email"]??"";
    mobileController.text = Get.arguments["mobile"]??"";
    webSiteController.text = Get.arguments["website"]??"";
    bioController.text = Get.arguments["bio"]??"";
    locationController.text = Get.arguments["location"]??"";
    dob.value = Get.arguments["dob"]??"";
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> updateProfile() async {

    dio.options.headers={"Authorization":"Bearer ${await GetStorage().read("token")}"};
    if (imagePath.value.isNotEmpty) {
      client.FormData formData = client.FormData.fromMap({
        "avatar": File(imagePath.value),
        "username": userNameController.text,
        "first_name": nameController.text,
        'last_name': lastNameController.text,
        "gender": genderList[genderSelectIndex.value],
        "website_url": webSiteController.text,
        "bio": bioController.text,
        "location": location.value,
        "phone": mobileController.text,
        "email": emailController.text,
        "dob":dob.value
      });
    await dio.post("user/edit", data:formData).then((value) {
        if (value.data["status"]) {
          successToast(value.data["message"]);
        } else {
          errorToast(value.data["message"]);
        }
      }).onError((error, stackTrace) {});
    } else {
      dio.post("user/edit", queryParameters: {
        "username": userNameController.text,
        "first_name": nameController.text,
        'last_name': lastNameController.text,
        "gender": genderList[genderSelectIndex.value],
        "website_url": webSiteController.text,
        "bio": bioController.text,
        "location": location.value,
        "phone": mobileController.text,
        "email": emailController.text,
        "dob":dob.value

      }).then((value) {
        if (value.data["status"]) {
          successToast(value.data["message"]);
        } else {
          errorToast(value.data["message"]);
        }

      }).onError((error, stackTrace) {});
    }
  }

  showSetImageDialog() {
    Get.defaultDialog(
        title: "Update Profile Image",
        content: Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  image = (await _imagePicker.pickImage(
                      source: ImageSource.camera))!;
                  openCropper(image.path);
                  Get.back();
                },
                child: Column(
                  children: const [
                    Icon(
                      IconlyLight.camera,
                      color: ColorManager.colorAccent,
                    ),
                    Text('Take Picture',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  image = (await _imagePicker.pickImage(
                      source: ImageSource.gallery))!;
                  openCropper(image.path);
                  Get.back();
                },
                child: Column(
                  children: const [
                    Icon(Icons.image, color: ColorManager.colorAccent),
                    Text(
                      'Pick Image',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  openCropper(String imageUri) async {
    await ImageCropper().cropImage(
      cropStyle: CropStyle.circle,
      sourcePath: imageUri,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            activeControlsWidgetColor: ColorManager.colorAccent,
            toolbarTitle: '',
            toolbarColor: ColorManager.colorAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: '',
        ),
      ],
    ).then((croppedImage) {
      imagePath.value = croppedImage!.path;
    });
  }
}
