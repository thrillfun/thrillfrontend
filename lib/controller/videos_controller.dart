import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

// import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/delete_video_response.dart';
import 'package:thrill/controller/model/following_video_model.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/user_details_model.dart' as user;
import 'package:thrill/controller/model/video_fields_model.dart' as videoFields;
import 'package:thrill/controller/notifications/notifications_controller.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users/followers_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/videos_post_response.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/video/post_screen.dart';
import 'package:thrill/utils/notification.dart';
import 'package:thrill/utils/util.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

var soundsController = Get.find<SoundsController>();
var relatedVideosController = Get.find<RelatedVideosController>();
var followingVideosController = Get.find<FollowingVideosController>();

class VideosController extends GetxController with StateMixin<dynamic> {
  RxBool on = false.obs; // our observable
  var currentUploadStatus = "".obs;
  var token = GetStorage().read('token');
  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
      headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
      responseType: ResponseType.json));

  var simpleS3 = SimpleS3();
  GetSnackBar? snackBar;

  // swap true/false & save it to observable

  var usersController = Get.lazyPut(() => UserController());
  var notificationController = Get.find<NotificationsController>();

  var isLoading = false.obs;
  var isLikedVideosLoading = true.obs;
  var isUserVideosLoading = false.obs;
  var videosLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isError = false.obs;

  RxList<Videos> userVideosList = RxList();
  RxList<PrivateVideos> privateVideosList = RxList();
  RxList<PublicVideos> publicVideosList = RxList();
  RxList<FollowingVideos> followingVideosList = RxList();
  var languageList = RxList<videoFields.Languages>();
  var categoriesList = RxList<videoFields.Categories>();
  var hashTagList = RxList<videoFields.Hashtags>();

  var otherUserVideos = RxList<Videos>();
  var likedVideos = RxList<LikedVideos>();
  RxList<LikedVideos> othersLikedVideos = RxList<LikedVideos>();

  var followersController = Get.find<FollowersController>();

  user.User? userData = user.User();

  var customNotification = CustomNotification();

  VideosController() {
    // snackBar = GetSnackBar(
    //   duration: null,
    //   barBlur: 10,
    //   borderColor: ColorManager.colorPrimaryLight,
    //   borderWidth: 1.5,
    //   margin: const EdgeInsets.only(
    //     left: 10,
    //     right: 10,
    //     bottom: 10,
    //   ),
    //   borderRadius: 10,
    //   backgroundColor: Colors.green.shade50,
    //   messageText: StreamBuilder<dynamic>(
    //       stream: simpleS3.getUploadPercentage,
    //       builder: (context, snapshot) {
    //         return snapshot.data != null
    //             ? Text(snapshot.data)
    //             : const LinearProgressIndicator(
    //                 value: 0,
    //               );
    //       }),
    //   isDismissible: false,
    //   mainButton: IconButton(
    //     onPressed: () {
    //       Get.back();
    //     },
    //     icon: const Icon(Icons.close),
    //   ),f
    //   icon: const Icon(
    //     Icons.error,
    //     color: Colors.green,
    //   ),
    // );
  }

  showUploadSnackbar() => Get.showSnackbar(GetSnackBar(
      title: currentUploadStatus.value,
      message: "uploading ${currentUploadStatus.value}",
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: false,
      duration: const Duration(days: 365),
      backgroundColor: ColorManager.colorAccent,
      showProgressIndicator: true));

  void toggle() => on.value = on.value ? false : true;

  Future<void> postVideoView(int videoId) async {
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    await dio.post("/video/view", queryParameters: {"video_id": videoId});
  }

  RxList<int> adIndexes = [
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110,
    120,
    130,
    140,
    150,
    160,
    170,
    180,
    190,
    200,
    210,
    220,
    230,
    240,
    250,
    260,
    270,
    280,
    290,
    300
  ].obs;

  Future<void> getAllVideos() async {
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.get("/video/list").then((value) {
      if (publicVideosList.isEmpty) {
        publicVideosList = PublicVideosModel.fromJson(value.data).data!.obs;
      } else {
        publicVideosList.value =
            PublicVideosModel.fromJson(value.data).data!.obs;
      }
      videosLoading.value = false;
      change(RxStatus.success());
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      videosLoading.value = false;
      change(RxStatus.error());
      change(RxStatus.empty());
    });
    if (publicVideosList.isEmpty) change(RxStatus.empty());
  }

  Future<void> getFollowingVideos() async {
    isFollowingLoading.value = true;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    await dio.get("/video/following").then((response) {
      followingVideosList =
          FollowingVideoModel.fromJson(response.data).data!.obs;
      change(followingVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      change(followingVideosList, status: RxStatus.error(error.toString()));
      change(followingVideosList, status: RxStatus.empty());
    });
    if (followingVideosList.isEmpty)
      change(publicVideosList, status: RxStatus.empty());

    isFollowingLoading.value = false;
  }

  Future<void> getUserVideos() async {
    isUserVideosLoading.value = true;
    try {
      var id = userData!.id;
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/user-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$id"});

      try {
        userVideosList =
            OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } catch (e) {}
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    isUserVideosLoading.value = false;
    update();
  }

  Future<void> getUserPrivateVideos() async {
    isUserVideosLoading.value = true;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.get('/video/private').then((value) {
      privateVideosList.value =
          PrivateVideosModel.fromJson(value.data).data!.obs;
      isUserVideosLoading.value = false;
    }).onError((error, stackTrace) {
      isUserVideosLoading.value = false;
    });
    isUserVideosLoading.value = false;
  }

  Future<void> getOtherUserVideos(int userId) async {
    isUserVideosLoading.value = true;
    dio.post('/video/user-videos',
        queryParameters: {"user_id": "$userId"}).then((response) {
      otherUserVideos.clear();
      otherUserVideos = OwnVideosModel.fromJson(response.data).data!.obs;
      change(otherUserVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(otherUserVideos, status: RxStatus.error());
    });
    if (otherUserVideos.isEmpty)
      change(otherUserVideos, status: RxStatus.empty());

    isUserVideosLoading.value = false;
  }

  Future<void> getOthersLikedVideos(int userId) async {
    isLikedVideosLoading.value = true;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.post('/user/user-liked-videos',
        queryParameters: {"user_id": "$userId"}).then((result) {
      othersLikedVideos.clear();
      othersLikedVideos.value = LikedVideosModel.fromJson(result.data).data!;
      change(otherUserVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      print(error);
      change(otherUserVideos, status: RxStatus.error());
    });
    isLikedVideosLoading.value = false;
  }

  Future<bool> likeVideo(int isLike, int videoId) async {
    var isLiked = false;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.post('${RestUrl.baseUrl}/video/like', queryParameters: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).then((value) async {
      await relatedVideosController.getAllVideos();
      relatedVideosController.getFollowingVideos();
    }).onError((error, stackTrace) {});

    if (isLike == 0) {
      isLiked = false;
    } else {
      isLiked = true;
    }

    return isLiked;
  }

  Future<void> postVideo(
      String userId,
      String videoUrl,
      String sound,
      String soundName,
      String category,
      String hashtags,
      String visibility,
      int isCommentAllowed,
      String description,
      String filterImg,
      String language,
      String gifName,
      String speed,
      bool isDuetable,
      bool isCommentable,
      String? duetFrom,
      bool isDuet,
      int soundOwnerId,
      {String coverImage = ""}) async {
    isLoading.value = true;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    await dio.post(
      '/video/post',
      queryParameters: {
        'user_id': userId,
        'video': videoUrl,
        'sound': sound,
        'sound_name': soundName,
        'filter': filterImg,
        'language': language,
        'category': category,
        'hashtags': hashtags,
        'visibility': visibility,
        'is_comment_allowed': isCommentAllowed.toString(),
        'description': description,
        'gif_image': gifName,
        'speed': speed,
        'is_duetable': isDuetable ? "Yes" : "No",
        'is_commentable': isCommentable ? "Yes" : "No",
        'is_duet': isDuet ? "Yes" : "No",
        'duet_from': duetFrom ?? '',
        'sound_owner': soundOwnerId.toString(),
        "cover_image": coverImage
      },
    ).then((value) async {
      try {
        if (value.data["status"]) {
          successToast(
              VideoPostResponse.fromJson(value.data).message.toString());

          final directory =
              await ExternalPath.getExternalStoragePublicDirectory(
                  ExternalPath.DIRECTORY_PICTURES);
          // await followersController
          //     .getUserFollowers(await GetStorage().read("userId"))
          //     .then((value) {
          //   List<String> tokenList = [""];
          //   followersController.followersModel.forEach((element) {
          //     tokenList.add(element.firebaseToken.toString().isEmpty
          //         ? ""
          //         : element.firebaseToken.toString());
          //   });
          //   notificationController.sendMultipleFcmNotifications(
          //       tokenList.isEmpty
          //           ? [
          //               "c8eSDzg1Sj6F9LmH6VNgEx:APA91bFYCWc1e75c-8IXPWLHZVi2A-geaAqaFNSf_9KTJGyNxmPod4AHYaQXyoVQx5szUGD0Ow3U25uoaXwVX3dvZUGclPNDzgvpmbCP18Kgf_YN4A5FeernekpsMMGkdwArNKeQQLsC",
          //               "ewMOBsDFQXuJGzVURNxE1X:APA91bGuHCrtS6sPqLZQUfpaQ4ajLeY5ZHtkZ_hIx9LSolVNwgqa3lgB6s9s4ZFjaKShwAkAOEBTAQOECSV1JWk0pT9qHWeCH36TCiZPSl-rQ3kO6jlIDZlmhQ7L3LLQlrtPqvPIsvVF",
          //               "du-07SiLQO-XOWJYOSjeUb:APA91bE3azTzl1pU0JDOxT8EY7OHRnfQTfnKnkprk7f7xMNmUnP3HnoecCT-IMSy_orKKl-hlyi2toJ5Lj-hvRk0_KC1GAGNfSDAtfuC81VZS6PcJm_085dpHFwLThWrbJ7cdkOLrBeq"
          //             ]
          //           : tokenList,
          //       title: 'New Video',
          //       body:
          //           "${GetStorage().read("user")['username']} uploaded a new video!");
          // });
          notificationController.sendMultipleFcmNotifications([
            "c8eSDzg1Sj6F9LmH6VNgEx:APA91bFYCWc1e75c-8IXPWLHZVi2A-geaAqaFNSf_9KTJGyNxmPod4AHYaQXyoVQx5szUGD0Ow3U25uoaXwVX3dvZUGclPNDzgvpmbCP18Kgf_YN4A5FeernekpsMMGkdwArNKeQQLsC",
            "ewMOBsDFQXuJGzVURNxE1X:APA91bGuHCrtS6sPqLZQUfpaQ4ajLeY5ZHtkZ_hIx9LSolVNwgqa3lgB6s9s4ZFjaKShwAkAOEBTAQOECSV1JWk0pT9qHWeCH36TCiZPSl-rQ3kO6jlIDZlmhQ7L3LLQlrtPqvPIsvVF",
            "du-07SiLQO-XOWJYOSjeUb:APA91bE3azTzl1pU0JDOxT8EY7OHRnfQTfnKnkprk7f7xMNmUnP3HnoecCT-IMSy_orKKl-hlyi2toJ5Lj-hvRk0_KC1GAGNfSDAtfuC81VZS6PcJm_085dpHFwLThWrbJ7cdkOLrBeq"
          ],
              title: 'New Video',
              body:
                  "${GetStorage().read("user")['username']} uploaded a new video!");
          if (Directory("$directory/thrill/videos").existsSync()) {
            await Directory("$directory/thrill/videos").delete(recursive: true);
          }
        } else {}
      } catch (e) {
        errorToast(VideoPostResponse.fromJson(value.data).message.toString());
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
    isLoading.value = false;

    update();
    Get.back(closeOverlays: true);
  }

  Future<void> deleteVideo(int videoId) async {
    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/delete'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"video_id": "$videoId"});

      try {
        successToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());
      } catch (e) {
        errorToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getVideoFields() async {
    isLoading.value = true;

    try {
      var response = await http.get(
        Uri.parse('${RestUrl.baseUrl}/video/field-data'),
        headers: {"Authorization": "Bearer $token"},
      );
      try {
        languageList =
            videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
                .data!
                .languages!
                .obs;

        categoriesList =
            videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
                .data!
                .categories!
                .obs;
        hashTagList =
            videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
                .data!
                .hashtags!
                .obs;
      } catch (e) {
        errorToast(e.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    languageList.refresh();
    categoriesList.refresh();
    hashTagList.refresh();
    isLoading.value = false;
    update();
  }

  Future<void> awsUploadVideo(File file, int currentUnix) async {
    currentUploadStatus.value = "Video";

    try {
      await simpleS3
          .uploadFile(
        file,
        "thrillvideonew",
        "ap-south-1:79285cd8-42a4-4d69-8330-0d02e2d7fc0b",
        AWSRegions.apSouth1,
        debugLog: true,
        fileName: "Thrill-$currentUnix.mp4",
        s3FolderPath: "test",
        accessControl: S3AccessControl.publicRead,
      )
          .then((value) {
        print(value);
        print("============================> Video Upload Success!!!!");
      });
    } on Exception catch (e) {
      Logger().wtf(e);
    }
  }

  Future<String> createGIF(int currentUnix, String filePath) async {
    var thumbnailDirectory = await getTemporaryDirectory();

    String outputPath = saveCacheDirectory + 'thumbnail.gif';
    if (!Directory(outputPath).existsSync()) {
      await Directory(outputPath).create();
    }
    var path = File(filePath).path;

    await FFmpegKit.execute(

        // "-y -i $path -r 3 -filter:v scale=${Get.width}:${Get.height} -t 5 $outputPath"
        "-i $path -frames:v 1 $outputPath").then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Get.back();
        print("============================> GIF Success!!!!" + outputPath);
      } else {
        Logger().wtf("Gif error ${session.getReturnCode()}");
      }
    });

    return outputPath;
  }

  Future<void> awsUploadThumbnail(File path, String name) async {
    currentUploadStatus.value = "Thumbnail";
    try {
      await simpleS3
          .uploadFile(
        path,
        "thrillvideonew",
        "ap-south-1:79285cd8-42a4-4d69-8330-0d02e2d7fc0b",
        AWSRegions.apSouth1,
        debugLog: true,
        s3FolderPath: "gif",
        fileName: 'Thrill-$name.gif',
        accessControl: S3AccessControl.publicRead,
      )
          .onError((error, stackTrace) {
        errorToast(error.toString());
        return "$error";
      });
      Logger().w("============================> Thumbnail upload Success!!!!");
    } on Exception catch (e) {
      Get.back();
      Logger().wtf(e);
    }
    Get.back();
  }

  Future<void> awsUploadSound(String file, String currentUnix) async {
    currentUploadStatus.value = "Sound";

    try {
      await simpleS3
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
        Get.back();
        Logger().w(value);
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } catch (e) {
      Logger().wtf(e);
    }
    Get.back();
  }

  Future<void> openEditor(bool isGallery, String path, String selectedSound,
      int id, String owner) async {
    VESDK.unlockWithLicense("assets/vesdk_android_license");
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    final List<FileSystemEntity> entities = await dir.list().toList();

    List<String> videosList = <String>[];

    entities.forEach((element) {
      videosList.add("${element.path}");
    });

    List<SongModel> albums = [];
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request().then((value) async {
        albums = await OnAudioQuery().querySongs();
      });
    }
    albums = await OnAudioQuery().querySongs();
    try {} catch (e) {
      errorToast(e.toString());
    } finally {
      if (!isGallery) {
        await VESDK
            .openEditor(Video.composition(videos: videosList),
                configuration: setConfig(albums, selectedSound, owner))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;

          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          for (int i = 0;
              i < serializationData["operations"].toList().length;
              i++) {
            if (serializationData["operations"][i]["type"] == "audio") {
              isOriginal.value = false;
            }
            for (var element in albums) {
              print(element);
              if (serializationData["operations"][i]["options"]["clips"] !=
                  null) {
                for (int j = 0;
                    j <
                        serializationData["operations"][i]["options"]["clips"]
                            .toList()
                            .length;
                    j++) {
                  List<dynamic> clipsList = serializationData["operations"][i]
                          ["options"]["clips"]
                      .toList();
                  if (clipsList.isNotEmpty) {
                    if (element.title.contains(serializationData["operations"]
                            [i]["options"]["clips"][j]["options"]["identifier"]
                        .toString())) {
                      songPath = element.uri.toString();
                      songName = element.displayName;
                    }
                  }
                }
              }
            }
            print(serializationData["operations"][i]["type"]);
          }
          List<dynamic> operationData =
              serializationData['operations'].toList();

          if (value == null) {
            dir.exists().then((value) => dir.delete(recursive: true));
          }

          // await dir.delete(recursive: true);

          if (isOriginal.isFalse) {
            selectedSound = "";
            if (value != null) {
              var addSoundModel = AddSoundModel(
                  0,
                  id,
                  0,
                  songPath.isNotEmpty ? songPath : path,
                  songName.isNotEmpty ? songName : "original",
                  '',
                  '',
                  true);
              PostData postData = PostData(
                speed: '1',
                newPath: value.video,
                filePath: value.video.substring(7, value.video.length),
                filterName: "",
                addSoundModel: addSoundModel,
                isDuet: false,
                isDefaultSound: true,
                isUploadedFromGallery: false,
                trimStart: 0,
                trimEnd: 0,
              );
              // Get.snackbar("path", value.video);
              Get.to(() => PostScreenGetx(postData, selectedSound, false));
            }
          } else {
            if (selectedSound.isNotEmpty) {
              await FFmpegKit.execute(
                      '-y -i ${value!.video.substring(7, value.video.length)} -i $selectedSound -map 0:v -map 1:a  -shortest $saveCacheDirectory/selectedVideo.mp4')
                  .then((ffmpegValue) async {
                final returnCode = await ffmpegValue.getReturnCode();
                var data = await ffmpegValue.getOutput();
                if (ReturnCode.isSuccess(returnCode)) {
                  var addSoundModel = AddSoundModel(
                      0,
                      id,
                      0,
                      songPath.isNotEmpty ? songPath : path,
                      songName.isNotEmpty ? songName : "original",
                      '',
                      '',
                      true);
                  PostData postData = PostData(
                    speed: '1',
                    newPath: "$saveCacheDirectory/selectedVideo.mp4",
                    filePath: "$saveCacheDirectory/selectedVideo.mp4",
                    filterName: "",
                    addSoundModel: addSoundModel,
                    isDuet: false,
                    isDefaultSound: true,
                    isUploadedFromGallery: true,
                    trimStart: 0,
                    trimEnd: 0,
                  );
                  Get.to(() => PostScreenGetx(postData, selectedSound, false));
                } else {
                  errorToast(data.toString());
                }
              });
            } else {
              await FFmpegKit.execute(
                      "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                  .then((audio) async {
                var addSoundModel = AddSoundModel(
                    0,
                    id,
                    0,
                    songPath.isNotEmpty
                        ? songPath
                        : "$saveCacheDirectory/originalAudio.mp3",
                    songName.isNotEmpty ? songName : "original",
                    '',
                    '',
                    true);
                PostData postData = PostData(
                  speed: '1',
                  newPath: value.video,
                  filePath: value.video.substring(7, value.video.length),
                  filterName: "",
                  addSoundModel: addSoundModel,
                  isDuet: false,
                  isDefaultSound: true,
                  isUploadedFromGallery: true,
                  trimStart: 0,
                  trimEnd: 0,
                );

                // Get.snackbar("path", value.video);
                await Get.to(
                    () => PostScreenGetx(postData, selectedSound, false));
              });
            }
          }
        });
      } else {
        await VESDK
            .openEditor(Video(path),
                configuration: setConfig(albums, selectedSound, owner))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;

          print("data=>" + serializationData.toString());

          List<dynamic> operationData =
              serializationData['operations'].toList();

          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          var file = await toFile(selectedSound);

          operationData.forEach((operation) async {
            Map<dynamic, dynamic> data = operation['options'];
            if (data.containsKey("clips")) {
              isOriginal.value = false;
              songPath = file.path;
              songName = basename(file.path);
              // albums.forEach((element) {
              //   if(element.displayNameWOExt!.contains(operation["options"]["clips"][0]["options"]["identifier"])) {
              //     songPath = element.uri.toString();
              //     songName = element.displayNameWOExt;
              //
              //   }
              // });
            }
          });
          if (!isOriginal.value) {
            if (value != null) {
              var addSoundModel =
                  AddSoundModel(0, id, 0, songPath, songName, '', '', true);
              PostData postData = PostData(
                speed: '1',
                newPath: value.video,
                filePath: value.video.substring(7, value.video.length),
                filterName: "",
                addSoundModel: addSoundModel,
                isDuet: false,
                isDefaultSound: true,
                isUploadedFromGallery: false,
                trimStart: 0,
                trimEnd: 0,
              );

              // Get.snackbar("path", value.video);
              Get.to(() => PostScreenGetx(postData, selectedSound, true));
            }
          } else {
            var dir = await getTempDirectory();
            await FFmpegKit.execute(
                    "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                .then((audio) async {
              var addSoundModel = AddSoundModel(
                  0,
                  id,
                  0,
                  songPath.isNotEmpty
                      ? songPath
                      : "${saveCacheDirectory}originalAudio.mp3",
                  songName.isNotEmpty ? songName : "original",
                  '',
                  '',
                  true);
              PostData postData = PostData(
                speed: '1',
                newPath: value.video,
                filePath: value.video.substring(7, value.video.length),
                filterName: "",
                addSoundModel: addSoundModel,
                isDuet: false,
                isDefaultSound: true,
                isUploadedFromGallery: true,
                trimStart: 0,
                trimEnd: 0,
              );

              // Get.snackbar("path", value.video);
              await Get.to(() => PostScreenGetx(postData, selectedSound, true));
            });
          }
        });
      }
    }
    await dir.delete(recursive: true);
  }

  imgly.Configuration setConfig(
      List<SongModel> albums, String selectedSound, String? userName) {
    List<imgly.AudioClip> audioClips = [];
    List<imgly.AudioClip> selectedAudioClips = [];

    if (selectedSound.isNotEmpty) {
      selectedAudioClips.add(
          imgly.AudioClip("", selectedSound, title: "Original by $userName"));
    }

    if (albums.isNotEmpty) {
      albums.forEach((element) {
        audioClips.add(imgly.AudioClip(
          element.title,
          element.uri.toString(),
          title: element.title,
          artist: element.artist,
        ));
      });
    }

    if (soundsController.soundsList.isNotEmpty) {
      List<imgly.AudioClip> onlineAudioClips = [];
      soundsController.soundsList.forEach((element) {
        onlineAudioClips.add(imgly.AudioClip(element.name.toString(),
            RestUrl.soundUrl + element.sound.toString(),
            title: element.name));
      });
    }

    List<imgly.AudioClipCategory> audioClipCategories = [];
    if (selectedSound.isNotEmpty) {
      audioClipCategories.add(imgly.AudioClipCategory("", "selected sound",
          items: selectedAudioClips));
    }
    audioClipCategories.add(
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png",
          items: audioClips),
    );

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);

    var codec = imgly.VideoCodec.values;

    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 0.9, codec: codec[0]),
    );

    // imgly.WatermarkOptions waterMarkOptions = imgly.WatermarkOptions(
    //     RestUrl.assetsUrl + "transparent_logo.png",
    //     alignment: imgly.AlignmentMode.topLeft);

    var stickerList = [
      imgly.StickerCategory.giphy(
          imgly.GiphyStickerProvider("Q1ltQCCxdfmLcaL6SpUhEo5OW6cBP6p0"))
    ];

    var trimOptions = imgly.TrimOptions(
        minimumDuration: 5,
        maximumDuration: 60,
        forceMode: imgly.ForceTrimMode.always);
    List<imgly.Tool> tools = [imgly.Tool.audio];
    final configuration = imgly.Configuration(
      // tools:tools ,
      theme: imgly.ThemeOptions(imgly.Theme("")),
      trim: trimOptions,
      sticker:
          imgly.StickerOptions(personalStickers: true, categories: stickerList),
      audio: audioOptions,
      export: exportOptions,
      // watermark: waterMarkOptions,
    );

    return configuration;
  }
}
