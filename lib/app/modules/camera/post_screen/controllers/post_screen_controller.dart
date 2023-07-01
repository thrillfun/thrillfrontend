import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dioForm;
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../rest/models/followers_model.dart';
import '../../../../rest/models/top_hashtags_videos_model.dart' as topHashtags;
import '../../../../rest/models/video_field_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';

class PostScreenController extends GetxController {
  String? selectedSound;
  bool? isFromGallery;

  VideoPlayerController? videoPlayerController;
  var isHashtag = false.obs;
  var descriptionText = "".obs;
  var isPlaying = false.obs;
  var selectedItem = 'English'.obs;
  var selectedPrivacy = "Public".obs;
  var types = ["Funny", "boring "].obs;
  var allowComments = true.obs;
  var allowDuets = true.obs;
  var selectedChip = 0.obs;
  var selectedItems = [].obs;
  var privacy = ["Public", "Private"].obs;
  var selectedCategory = 'Funny'.obs;
  var searchItems = [].obs;
  var currentText = "".obs;
  var userHashtagsList = [];
  var lastChangedWord = "".obs;
  var isOriginal = Get.arguments["is_original"] ?? "";
  var soundUrl = Get.arguments["sound_url"] ?? "";
  var soundName = Get.arguments["sound_name"] ?? "Original";
  var soundOwner = Get.arguments["sound_owner"] ?? "";
  RxList<topHashtags.Tophashtagvideos> tophashtagvideosList = RxList();
  var entities = RxList<FileSystemEntity>();
  var videosList = RxList<String>();

  TextEditingController searchController = TextEditingController();

  TextEditingController textEditingController = TextEditingController();
  RxList<Languages> languagesList = RxList();
  RxList<Categories> categoriesList = RxList();
  RxList<Hashtags> hashtagsList = RxList();
  var dio = dioForm.Dio(dioForm.BaseOptions(baseUrl: RestUrl.baseUrl));
  var simpleS3 = SimpleS3();
  var videoFile = File(Get.arguments["file_path"]).obs;
  var relatedVideosController = Get.find<RelatedVideosController>();
  int currentUnix = DateTime.now().millisecondsSinceEpoch;
  var snackBarMessageText = ''.obs;
  var followersModel = RxList<Followers>();

  @override
  void onInit() {
    super.onInit();
    videoPlayerController = VideoPlayerController.file(videoFile.value)
      ..initialize()
      ..setLooping(true);
    // createGIF(currentUnix);
  }

  @override
  void onReady() {
    getTopHashTagVideos();
    getVideoClips();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getTopHashTagVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.get("hashtag/top-hashtags-videos").then((value) {
      tophashtagvideosList =
          topHashtags.TopHashtagVideosModel.fromJson(value.data).data!.obs;
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> getVideoClips() async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    entities.value = await dir.list().toList();
    entities.forEach((element) async {
      videosList.add(element.path);
    });
  }

  Future<void> getVideoField() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.get("video/field-data").then((value) {
      languagesList =
          VideoFieldsModel.fromJson(value.data).data!.languages!.obs;
      categoriesList =
          VideoFieldsModel.fromJson(value.data).data!.categories!.obs;
      hashtagsList = VideoFieldsModel.fromJson(value.data).data!.hashtags!.obs;
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> awsUploadVideo(
      int currentUnix, String desc, String soundName, String soundOwner) async {
    var _videoS3 = SimpleS3();
    snackBarMessageText.value = "Uploading video";

    // Get.defaultDialog(
    //     content: StreamBuilder<dynamic>(
    //         stream: _videoS3.getUploadPercentage,
    //         builder: (context, snapshot) {
    //           return LinearProgressIndicator(
    //             value: double.parse(
    //                 snapshot.hasData ? snapshot.data.toString() : "0"),
    //           );
    //         }),
    //     barrierDismissible: false);
    // dioForm.FormData formData = dioForm.FormData.fromMap({
    //   'file': await dioForm.MultipartFile.fromFile(
    //       File(videoFile.value.path).path,
    //       filename: "$currentUnix.mp4"),
    // });

    // await dio
    //     .post(
    //   "https://s3.console.aws.amazon.com/s3/object/thrillvideonew?region=ap-south-1&prefix=test/",
    //   data: formData,
    //   options: dioForm.Options(contentType: 'multipart/form-data'),
    // )
    //     .then((value) async {
    //   if (isOriginal == "original") {
    //     postUpload("$currentUnix.mp4", basename(soundUrl.toString()),
    //         "$currentUnix.gif", desc, soundName,
    //         soundOwner: soundOwner);
    //   } else if (isOriginal == "extracted") {
    //     File file = await toFile(soundUrl);
    //     awsUploadSound(file.path, "$currentUnix").then((value) async =>
    //         postUpload("$currentUnix.mp4", "$currentUnix.mp3",
    //             "$currentUnix.gif", desc, "original",
    //             soundOwner: soundOwner));
    //   } else {
    //     File file = await toFile(soundUrl);
    //     awsUploadSound(file.path, "$currentUnix").then((value) async =>
    //         postUpload("$currentUnix.mp4", "$currentUnix.mp3",
    //             "$currentUnix.gif", desc, soundName,
    //             soundOwner: soundOwner));
    //   }
    // }).onError((error, stackTrace) {
    //   Logger().wtf(error);
    // });

    await _videoS3
        .uploadFile(
      File(videoFile.value.path),
      "thrillvideonew",
      "ap-south-1:79285cd8-42a4-4d69-8330-0d02e2d7fc0b",
      AWSRegions.apSouth1,
      debugLog: true,
      fileName: "$currentUnix.mp4",
      s3FolderPath: "test",
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) async {
      print("============================> Video Upload Success!!!!");
      if (isOriginal == "original") {
        postUpload("$currentUnix.mp4", basename(soundUrl.toString()),
            "$currentUnix.gif", desc, soundName,
            soundOwner: soundOwner);
      } else if (isOriginal == "extracted") {
        File file = await toFile(soundUrl);
        awsUploadSound(file.path, "$currentUnix").then((value) async =>
            postUpload("$currentUnix.mp4", "$currentUnix.mp3",
                "$currentUnix.gif", desc, "original",
                soundOwner: soundOwner));
      } else {
        File file = await toFile(soundUrl);
        awsUploadSound(file.path, "$currentUnix").then((value) async =>
            postUpload("$currentUnix.mp4", "$currentUnix.mp3",
                "$currentUnix.gif", desc, soundName,
                soundOwner: soundOwner));
      }
    });
  }

  Future<void> awsUploadSound(String file, String currentUnix) async {
    var _soundS3 = SimpleS3();
    snackBarMessageText.value = "Uploading gif";

    // Get.defaultDialog(
    //     content: StreamBuilder<dynamic>(
    //         stream: _soundS3.getUploadPercentage,
    //         builder: (context, snapshot) {
    //           return Text(
    //             snapshot.data != null
    //                 ? "Uploaded: ${snapshot.data}"
    //                 : "Uploading Audio please wait",
    //           );
    //         }),
    //     barrierDismissible: false);

    _soundS3
        .uploadFile(
      File(file),
      "thrillvideonew",
      "ap-south-1:79285cd8-42a4-4d69-8330-0d02e2d7fc0b",
      AWSRegions.apSouth1,
      debugLog: true,
      fileName: '$currentUnix.mp3',
      s3FolderPath: "sound",
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) {
      Logger().wtf(value);
    });
  }

  Future<String> createGIF() async {
    String outputPath = '$saveCacheDirectory$currentUnix.gif';
    FFmpegKit.execute(
            "-y -i ${videoFile.value.path} -r 18 -s 200x320 -t 3 $outputPath")
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Logger().wtf("success");
        await uploadGif(textEditingController.text, soundName, soundOwner);
      } else {
        errorToast("thumbnail uploaded failed");
        Logger().wtf("failed");
      }
    });

    // Get.defaultDialog(
    //     content: StreamBuilder<dynamic>(
    //         stream: simpleS3.getUploadPercentage,
    //         builder: (context, snapshot) {
    //           return Text(
    //             snapshot.data != null
    //                 ? "Uploaded: ${snapshot.data}"
    //                 : "Uploading gif please wait",
    //           );
    //         }),
    //     barrierDismissible: false);

    return outputPath;
  }

  uploadGif(String desc, String soundName, String owner) async {
    snackBarMessageText.value = "Uploading gif";

    var uint8list = (await VideoThumbnail.thumbnailData(
      video: videoFile.value.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    ))!;

    GetSnackBar(
      backgroundGradient: ColorManager.postGradient,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.GROUNDED,
      icon: Image.memory(
        uint8list,
        height: 50,
        width: 50,
      ),
      messageText: const Text(
        "Uploading Video please wait.......",
        style: TextStyle(color: Colors.white),
      ),
      titleText: const Text(
        "Uploading......",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      message: "",
      title: "",
      isDismissible: false,
      showProgressIndicator: true,
    ).show();

    Get.offAllNamed(Routes.HOME);

    await simpleS3
        .uploadFile(
      File('$saveCacheDirectory$currentUnix.gif'),
      "thrillvideonew",
      "ap-south-1:79285cd8-42a4-4d69-8330-0d02e2d7fc0b",
      AWSRegions.apSouth1,
      debugLog: true,
      s3FolderPath: "gif",
      fileName: '$currentUnix.gif',
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) async {
      awsUploadVideo(currentUnix, desc, soundName, owner);
    }).onError((error, stackTrace) {
      Get.back(closeOverlays: true);
      Logger().wtf(error);
    });
  }

  postUpload(String videoId, String soundId, String gifId, String desc,
      String soundName,
      {String soundOwner = ""}) async {
    String tagList = jsonEncode(extractHashTags(textEditingController.text));
    snackBarMessageText.value = "posting video";

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("video/post", queryParameters: {
      "user_id": await GetStorage().read("userId"),
      "sound_owner": soundOwner.isEmpty
          ? GetStorage().read("userId").toString()
          : soundOwner,
      "video": videoId,
      "sound": soundId,
      "sound_name": soundName == null || soundName.toString().isEmpty
          ? "Original by ${GetStorage().read("name") ?? GetStorage().read("userName").toString()}"
          : soundName,
      "language": 1,
      "category": 1,
      "hashtags": tagList,
      "visibility": selectedPrivacy.value,
      "is_comment_allowed": allowComments.isFalse ? 0 : 1,
      "is_commentable": allowComments.isFalse ? "No" : "Yes",
      "description": desc,
      "gif_image": gifId,
      "speed": 1
    }).then((value) async {
      if (value.data["status"]) {
        successToast("your video uploaded");

        var tempDirectory = await getTemporaryDirectory();
        final dir = Directory(tempDirectory.path + "/videos");
        List<FileSystemEntity> entities = [];
        if (await Directory(dir.path).exists()) {
          entities = await dir.list().toList();
        }
        if (entities.isNotEmpty) {
          dir.delete(recursive: true);
        }
        if (Get.isSnackbarOpen) {
          Get.back();
        }
        relatedVideosController.refereshVideos();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      // errorToast(error.toString());
      if (Get.isSnackbarOpen) {
        Get.back();
      }
    });
  }

  Future<void> sendNotification(String fcmToken,
      {String? body = "", String? title = "", String? image = ""}) async {
    var dio = dioForm.Dio(
        dioForm.BaseOptions(baseUrl: "https://fcm.googleapis.com/fcm"));
    dio.options.headers = {
      "Authorization":
          "key= AAAAzWymZ2o:APA91bGABMolgt7oiBiFeTU7aCEj_hL-HSLlwiCxNGaxkRl385anrsMMNLjuuqmYnV7atq8vZ5LCNBPt3lPNA1-0ZDKuCJHezvoRBpL9VGvixJ-HHqPScZlwhjeQJPhbsiLDSTtZK-MN"
    };

    final data = {
      "to": fcmToken,
      "notification": {"body": body, "title": title, "image": image},
      "priority": "high",
      "image": image,
      "data": {
        "url": image,
        "body": body,
        "title": title,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image": image
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
