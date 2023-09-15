import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailController extends GetxController with StateMixin<dynamic> {
  VideoPlayerController? videoPlayerController;
  Rx<Uint8List>? u8intList;
  var currentDuration = Duration().obs;
  var totalduration = Duration().obs;

  var selectedThumbnail = ''.obs;
  RxList<FileSystemEntity> entities = RxList();
  var currentSelectedFrame = 999.obs;
  var isThumbnailReady = false.obs;
  @override
  void onInit() {
    super.onInit();
    extractFrames(File(Get.arguments['video_file']).path);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  playPauseVideo() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      videoPlayerController!.value.isPlaying
          ? videoPlayerController!.pause()
          : videoPlayerController!.play();
    }
  }

  extractFrames(String videoFilePath) async {
    change(selectedThumbnail, status: RxStatus.loading());
    var directory = await checkforDirectory();
    entities.clear();
    if (directory.existsSync()) {
      FFmpegKit.execute(
              '-i $videoFilePath -r 1 -f image2 -compression_level 0 ${directory.path}image-%3d.png')
          .then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          var frameFiles = await directory.list().toList();
          entities.value = await getFilesFromFolder(directory);
          selectedThumbnail.value = entities[0].path;
        } else {
          change(selectedThumbnail,
              status: RxStatus.error('Something went wrong'));
        }
      }).then((value) {
        isThumbnailReady.value = true;
        change(selectedThumbnail, status: RxStatus.success());
      });
    }
  }

  Future<Directory> checkforDirectory() async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/frames/");
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create();

    return dir;
  }
}
