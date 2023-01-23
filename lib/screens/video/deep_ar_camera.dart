import 'dart:convert';
import 'dart:io';

import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/video/post_screen.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import '../../models/add_sound_model.dart';
import '../../models/post_data.dart';

class DeepArCamera extends StatefulWidget {
  DeepArCamera({Key? key}) : super(key: key);

  @override
  State<DeepArCamera> createState() => _DeepArCameraState();
}

class _DeepArCameraState extends State<DeepArCamera> {
  DeepArController deepArController = DeepArController();
  String version = '';
  bool _isFaceMask = false;
  bool _isFilter = false;

  var videosController = Get.find<VideosController>();

  final List<String> _effectsList = [];
  final List<String> _maskList = [];
  final List<String> _filterList = [];
  int _effectIndex = 0;
  int _maskIndex = 0;
  int _filterIndex = 0;
  final String _assetEffectsPath = 'assets/effects/';

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _initEffects();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    deepArController
        .initialize(
      androidLicenseKey:
          "776ad3d8bd64b9451697e4640fc4552fb8956c6253d5dab714851ddebb4e387749a8b70ce2feffdb",
      iosLicenseKey: "",
    )
        .then((value) async {
      setState(() {
        deepArController.switchEffect("assets/effects/horns.deepar");
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    deepArController.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          DeepArPreview(deepArController),
          Container(
            margin: EdgeInsets.only(bottom: 80),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                _effectsList.length,
                    (index) => InkWell(
                  onTap: () {
                    deepArController.switchEffect(_effectsList[index]);
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(RestUrl.placeholderImage))),
                    height: 80,
                    width: 80,
                    child: Text(''),
                  ),
                )),
          ),),
          _topMediaOptions(),
          _bottomMediaOptions()
        ],
      ),
    );
  }

  Positioned _topMediaOptions() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              await deepArController.toggleFlash();
              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(
                deepArController.flashState ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: () async {
              _isFaceMask = !_isFaceMask;
              if (_isFaceMask) {
                deepArController.switchFaceMask(_maskList[_maskIndex]);
              } else {
                deepArController.switchFaceMask("null");
              }

              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(
              _isFaceMask
                  ? Icons.face_retouching_natural_rounded
                  : Icons.face_retouching_off,
            ),
          ),
          IconButton(
            onPressed: () async {
              _isFilter = !_isFilter;
              if (_isFilter) {
                deepArController.switchFilter(_filterList[_filterIndex]);
              } else {
                deepArController.switchFilter("null");
              }
              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(
              _isFilter ? Icons.filter_hdr : Icons.filter_hdr_outlined,
            ),
          ),
          IconButton(
              onPressed: () {
                deepArController.flipCamera();
              },
              iconSize: 50,
              color: Colors.white70,
              icon: const Icon(Icons.cameraswitch))
        ],
      ),
    );
  }

  Positioned _bottomMediaOptions() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                iconSize: 60,
                onPressed: () {
                  if (_isFaceMask) {
                    String prevMask = _getPrevMask();
                    deepArController.switchFaceMask(prevMask);
                  } else if (_isFilter) {
                    String prevFilter = _getPrevFilter();
                    deepArController.switchFilter(prevFilter);
                  } else {
                    String prevEffect = _getPrevEffect();
                    deepArController.switchEffect(prevEffect);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white70,
                )),
            IconButton(
                onPressed: () async {
                  if (deepArController.isRecording) {
                    File? file = await deepArController.stopVideoRecording();

                   await VESDK.openEditor(Video(file.path)).then((value) {
                     if (value != null) {
                       var addSoundModel = AddSoundModel(
                           0,
                           0,
                           0,
                          "",
                           "",
                           '',
                           '',
                           true);
                       PostData postData = PostData(
                         speed: '1',
                         newPath: value.video,
                         filePath: value.video.substring(7, value.video.length),
                         filterName: "",
                         isDuet: false,
                         isDefaultSound: true,
                         isUploadedFromGallery: true,
                         trimStart: 0,
                         trimEnd: 0,
                       );

                       // Get.snackbar("path", value.video);
                       Get.to(() => PostScreenGetx(postData, "", true));
                     }
                   });
                    successToast(file.path);
                   // OpenFile.open(file.path);
                  } else {
                    await deepArController.startVideoRecording();
                  }

                  setState(() {});
                },
                iconSize: 50,
                color: Colors.white70,
                icon: Icon(deepArController.isRecording
                    ? Icons.videocam_sharp
                    : Icons.videocam_outlined)),
            const SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  deepArController.takeScreenshot().then((file) {
                    //  OpenFile.open(file.path);
                  });
                },
                color: Colors.white70,
                iconSize: 40,
                icon: const Icon(Icons.photo_camera)),
            IconButton(
                iconSize: 60,
                onPressed: () {
                  if (_isFaceMask) {
                    String nextMask = _getNextMask();
                    deepArController.switchFaceMask(nextMask);
                  } else if (_isFilter) {
                    String nextFilter = _getNextFilter();
                    deepArController.switchFilter(nextFilter);
                  } else {
                    String nextEffect = _getNextEffect();
                    deepArController.switchEffect(nextEffect);
                  }
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                )),
          ],
        ),
      ),
    );
  }

  /// Add effects which are rendered via DeepAR sdk
  void _initEffects() {
    // Either get all effects

    // OR

    // Only add specific effects
    _effectsList.add(_assetEffectsPath + 'burning_effect.deepar');
    _effectsList.add(_assetEffectsPath + 'flower_face.deepar');
    _effectsList.add(_assetEffectsPath + 'Hope.deepar');
    _effectsList.add(_assetEffectsPath + 'viking_helmet.deepar');
  }

  /// Get all deepar effects from assets
  ///
  Future<List<String>> _getEffectsFromAssets(BuildContext context) async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final filePaths = manifestMap.keys
        .where((path) => path.startsWith(_assetEffectsPath))
        .toList();
    return filePaths;
  }

  /// Get next effect
  String _getNextEffect() {
    _effectIndex < _effectsList.length ? _effectIndex++ : _effectIndex = 0;
    return _effectsList[_effectIndex];
  }

  /// Get previous effect
  String _getPrevEffect() {
    _effectIndex > 0 ? _effectIndex-- : _effectIndex = _effectsList.length;
    return _effectsList[_effectIndex];
  }

  /// Get next mask
  String _getNextMask() {
    _maskIndex < _maskList.length ? _maskIndex++ : _maskIndex = 0;
    return _maskList[_maskIndex];
  }

  /// Get previous mask
  String _getPrevMask() {
    _maskIndex > 0 ? _maskIndex-- : _maskIndex = _maskList.length;
    return _maskList[_maskIndex];
  }

  /// Get next filter
  String _getNextFilter() {
    _filterIndex < _filterList.length ? _filterIndex++ : _filterIndex = 0;
    return _filterList[_filterIndex];
  }

  /// Get previous filter
  String _getPrevFilter() {
    _filterIndex > 0 ? _filterIndex-- : _filterIndex = _filterList.length;
    return _filterList[_filterIndex];
  }
}
