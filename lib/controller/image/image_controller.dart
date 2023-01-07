import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/color.dart';

class ImageController extends GetxController with StateMixin<XFile> {
  var imagePath = "".obs;
  XFile image = XFile("");
  final _imagePicker = ImagePicker();

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
                  change(image, status: RxStatus.loading());
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
                  change(image, status: RxStatus.loading());
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
      change(image, status: RxStatus.success());
    });
  }
}
