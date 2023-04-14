import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/app/utils/aws_client.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../../../../rest/models/top_hashtags_videos_model.dart' as topHashtags;
import '../../../../rest/models/video_field_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';

class PostScreenController extends GetxController {
  String? selectedSound;
  bool? isFromGallery;
  var dialog = Get.snackbar("Uploading files", "please wait",
      showProgressIndicator: true, shouldIconPulse: true);
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
  RxList<topHashtags.Tophashtagvideos> tophashtagvideosList = RxList();

  TextEditingController searchController = TextEditingController();

  TextEditingController textEditingController = TextEditingController();
  RxList<Languages> languagesList = RxList();
  RxList<Categories> categoriesList = RxList();
  RxList<Hashtags> hashtagsList = RxList();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var simpleS3 = SimpleS3();

  @override
  void onInit() {
    super.onInit();
    videoPlayerController = videoPlayerController =
        VideoPlayerController.file(File(Get.arguments["file_path"]))
          ..initialize()
          ..setLooping(true)
          ..play().then((value) => isPlaying.value = true);
    getTopHashTagVideos();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getTopHashTagVideos() async {
    await dio.get("hashtag/top-hashtags-videos").then((value) {
      tophashtagvideosList =
          topHashtags.TopHashtagVideosModel.fromJson(value.data).data!.obs;
    }).onError((error, stackTrace) {});
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
      errorToast(error.toString());
    });
  }

  Future<void> awsUploadVideo(int currentUnix, String desc) async {
    await SimpleS3()
        .uploadFile(
      File(Get.arguments["file_path"]),
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
      if (Get.arguments["is_original"] == false) {
        await postUpload(
            "$currentUnix.mp4",basename(Get.arguments["sound_url"]).toString(), "$currentUnix.gif", desc);
      } else {
        awsUploadSound(
                File(Get.arguments["sound_url"]).path, "$currentUnix")
            .then((value) async => await postUpload("$currentUnix.mp4",
                "$currentUnix.mp3", "$currentUnix.gif", desc));
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  Future<void> awsUploadSound(String file, String currentUnix) async {
    if (file.isNotEmpty) {
      await SimpleS3()
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
          .then((value) async {
        Logger().wtf(value);
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    }
  }

  Future<String> createGIF(int currentUnix, String desc) async {
    String outputPath = '$saveCacheDirectory$currentUnix.gif';
    FFmpegKit.execute(
            "-y -i ${Get.arguments["file_path"]} -r 18 -s 250x160 -t 2.8 $outputPath")
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
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
          awsUploadVideo(currentUnix, desc);
        }).onError((error, stackTrace) {
          errorToast(error.toString());
        });
      } else {
        errorToast("thumbnail uploaded failed");
        awsUploadVideo(currentUnix, desc);
        Logger().wtf("failed");
      }
    });
    return outputPath;
  }

  postUpload(String videoId, String soundId, String gifId, String desc) async {
    String tagList = jsonEncode(extractHashTags(textEditingController.text));

    videoPlayerController!.pause();
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/post", queryParameters: {
      "user_id": await GetStorage().read("userId"),
      "video": videoId,
      "sound": soundId,
      "sound_name": Get.arguments["sound_name"]==null || Get.arguments["sound_name"].toString().isEmpty
          ? "original"
          : Get.arguments["sound_name"].toString(),
      "language": 1,
      "category": 1,
      "hashtags": tagList,
      "visibility": selectedPrivacy.value,
      "is_comment_allowed": allowComments.value,
      "description": desc,
      "gif_image": gifId,
      "speed": 1
    }).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
        Get.offAllNamed(Routes.HOME);
        Get.forceAppUpdate();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }
}
