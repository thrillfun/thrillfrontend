import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart' as client;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../../../../utils/color_manager.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../../../rest/models/user_details_model.dart';

class EditProfileController extends GetxController with StateMixin<Rx<User>> {
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

  var userProfile = User().obs;

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
  var settingsController = Get.find<SettingsController>();
  var profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getUserProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    dio.post('/user/get-profile', queryParameters: {
      "id": "${GetStorage().read("userId")}"
    }).then((result) {
      userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
      change(userProfile, status: RxStatus.success());
      userNameController.text = userProfile.value.username!;
      nameController.text = userProfile.value.name!;
      lastNameController.text = userProfile.value.name!;
      emailController.text = userProfile.value.email!;
      mobileController.text = userProfile.value.phone!;
      webSiteController.text = userProfile.value.websiteUrl!;
      bioController.text = userProfile.value.bio!;
      locationController.text = userProfile.value.location!;
      dob.value = userProfile.value.dob!;
    }).onError((error, stackTrace) {
      change(userProfile, status: RxStatus.error(error.toString()));
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> updateProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (imagePath.value.isNotEmpty) {
      var imageFile = File(imagePath.value);
      client.FormData formData = client.FormData.fromMap({
        "avatar": await client.MultipartFile.fromFile(imageFile.path,
            filename: basenameWithoutExtension(imageFile.path)),
        "username": userNameController.text,
        "first_name": nameController.text,
        'last_name': lastNameController.text,
        "gender": genderList[genderSelectIndex.value],
        "website_url": webSiteController.text,
        "bio": bioController.text,
        "location": location.value,
        "phone": mobileController.text,
        "email": emailController.text,
        "dob": dob.value
      });
      await dio.post("user/edit", data: formData).then((value)async {
        successToast(value.data["message"]);
        getUserProfile();
        await settingsController.getUserProfile();
        await  profileController.getUserProfile();
        // Get.close(1);
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
        "dob": dob.value
      }).then((value) async {
        if (value.data["status"]) {
          successToast(value.data["message"]);
          getUserProfile();
          await settingsController.getUserProfile();
          await  profileController.getUserProfile();
          // Get.close(1);
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
      if(croppedImage!=null){
        imagePath.value = croppedImage!.path;
        updateProfile();
      }
    });
  }
}
