import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/fluent.dart';
import 'package:iconify_flutter/icons/icon_park_outline.dart';
import 'package:iconly/iconly.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/model/hashtag_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/user_details_model.dart' as userModel;
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/sound/sound_details.dart';
import 'package:thrill/screens/video/duet.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_player/video_player.dart';

var videosController = Get.find<VideosController>();
var commentsController = Get.find<CommentsController>();

class BetterReelsPlayer extends StatefulWidget {
  BetterReelsPlayer(
      this.gifImage,
      this.videoUrl,
      this.pageIndex,
      this.currentPageIndex,
      this.isPaused,
      this.callback,
      this.publicUser,
      this.videoId,
      this.soundName,
      this.isDuetable,
      this.publicVideos,
      this.UserId,
      this.userName,
      this.description,
      this.isHome,
      this.hashtagsList,
      this.sound,
      this.soundOwner,
      this.videoLikeStatus,
      this.isCommentAllowed);

  String gifImage, sound, soundOwner;
  int? videoLikeStatus;
  String videoUrl;
  int pageIndex;
  int currentPageIndex;
  bool isPaused;
  bool isCommentAllowed = true;
  VoidCallback callback;
  PublicUser? publicUser;
  int videoId;
  String soundName;
  bool isDuetable = false;
  PublicVideos publicVideos;
  int UserId;
  String userName;
  String description;
  bool isHome = false;
  List hashtagsList;

  @override
  State<BetterReelsPlayer> createState() => _VideoAppState();
}

class _VideoAppState extends State<BetterReelsPlayer>  with WidgetsBindingObserver{
  AppLifecycleState? _lastLifecycleState;

  var userController = Get.find<UserController>();
  TextEditingController? _textEditingController;
  var initialized = false.obs;
  var volume = 1.0.obs;
  var comment = "".obs;

  late VideoPlayerController _betterPlayerController;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _textEditingController = TextEditingController();

    _betterPlayerController = VideoPlayerController.network(
        RestUrl.videoUrl + widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false))
      ..setLooping(true)
      ..initialize().then((value) => setState(() {
            initialized.value = true;
          }));

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (initialized.value &&
          widget.pageIndex == widget.currentPageIndex &&
          !widget.isPaused) {
        _betterPlayerController.play();
      } else {
        _betterPlayerController.pause();
      }
    });

    return Stack(
      children: [
        GestureDetector(
            onDoubleTap: widget.callback,
            onLongPressEnd: (_) {
              setState(() {
                widget.isPaused = false;
              });
            },
            onTap: () {
              if (volume.value == 1) {
                volume.value = 0;
              } else {
                volume.value = 1;
              }
              _betterPlayerController.setVolume(volume.value);
            },
            onLongPressStart: (_) {
              setState(() {
                widget.isPaused = true;
              });
            },
            child: Stack(
              children: [
                Container(
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: Obx(() => initialized.value
                        ? AspectRatio(
                            aspectRatio:
                                _betterPlayerController.value.aspectRatio,
                            child: VideoPlayer(_betterPlayerController),
                          )
                        : CachedNetworkImage(
                            height: Get.height,
                            width: Get.width,
                            fit: BoxFit.fill,
                            imageUrl: RestUrl.gifUrl + widget.gifImage))),
                Container(
                  margin: widget.isHome
                      ? const EdgeInsets.only(right: 10, bottom: 100)
                      : const EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 10, right: 10),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: widget.videoLikeStatus==0?const Icon(
                                  IconlyLight.heart,
                                  color: Colors.white,
                                ): const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                )),
                            const Text(
                              "Like",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: widget.isHome
                            ? const EdgeInsets.only(right: 0)
                            : const EdgeInsets.only(right: 5),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  commentsController
                                      .getComments(widget.videoId);
                                  GetStorage().read("videoPrivacy") == "Private"
                                      ? showErrorToast(
                                          context, "this video is private!")
                                      : showComments();
                                },
                                icon: const Iconify(
                                  Fluent.comment_multiple_28_regular,
                                  color: Colors.white,
                                )),
                            const Text(
                              "Comments",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Share.share(
                                      'You need to watch this awesome video only on Thrill!!!');
                                },
                                icon: const Iconify(
                                  Fluent.share_16_regular,
                                  color: Colors.white,
                                )),
                            const Text(
                              "Share",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.bottomSheet(
                                      Container(
                                        height: 220,
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        VideoModel videModel = VideoModel(
                                                            widget.publicVideos
                                                                .id!,
                                                            widget.publicVideos
                                                                .comments!,
                                                            widget.publicVideos
                                                                .video!,
                                                            widget.publicVideos
                                                                .description!,
                                                            widget.publicVideos
                                                                .likes!,
                                                            null,
                                                            widget.publicVideos
                                                                .filter!,
                                                            widget.publicVideos
                                                                .gifImage!,
                                                            widget.publicVideos
                                                                .sound!,
                                                            widget.publicVideos
                                                                .soundName!,
                                                            widget.publicVideos
                                                                .soundCategoryName!,
                                                            widget.publicVideos
                                                                .views!,
                                                            widget.publicVideos
                                                                .speed!,
                                                            [],
                                                            widget.publicVideos
                                                                .isDuet!,
                                                            widget.publicVideos
                                                                .duetFrom!,
                                                            widget.publicVideos
                                                                .isDuetable!,
                                                            widget.publicVideos
                                                                .isCommentable!,
                                                            widget.publicVideos
                                                                .soundOwner!);
                                                        Get.to(RecordDuet(
                                                            videoModel:
                                                                videModel));
                                                      },
                                                      icon: const Icon(
                                                        IconlyLight.plus,
                                                        color: ColorManager
                                                            .colorAccent,
                                                        size: 30,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Duet",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          if (widget.UserId ==
                                                              GetStorage().read(
                                                                      "user")[
                                                                  'id']) {
                                                            showDeleteDialog();
                                                          }
                                                        },
                                                        icon: widget.UserId ==
                                                                GetStorage().read(
                                                                        "user")[
                                                                    'id']
                                                            ? const Iconify(
                                                                Fluent
                                                                    .delete_16_regular,
                                                                color:
                                                                    ColorManager
                                                                        .red,
                                                              )
                                                            : const Iconify(
                                                                Fluent
                                                                    .save_16_regular,
                                                                color: ColorManager
                                                                    .colorAccent,
                                                              )),
                                                    widget.UserId ==
                                                            GetStorage().read(
                                                                "user")['id']
                                                        ? const Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                                color:
                                                                    ColorManager
                                                                        .red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : const Text(
                                                            "Save",
                                                            style: TextStyle(
                                                                color: ColorManager
                                                                    .colorAccent,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () async {
                                                          var deepLink =
                                                              await createDynamicLink(
                                                                  widget
                                                                      .videoUrl);
                                                          GetStorage().write(
                                                              "deeplink",
                                                              deepLink
                                                                  .toString());
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: deepLink
                                                                      .toString()));
                                                          successToast(
                                                              "Link copied!");
                                                          //     widget.videoUrl));
                                                        },
                                                        icon: const Iconify(
                                                          Fluent
                                                              .link_16_regular,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )),
                                                    const Text(
                                                      "Link",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          Get.back(
                                                              closeOverlays:
                                                                  true);
                                                          GallerySaver.saveVideo(
                                                                  RestUrl.videoUrl +
                                                                      widget
                                                                          .videoUrl)
                                                              .then((value) =>
                                                                  showSuccessToast(
                                                                      context,
                                                                      "Video Saved Successfully"));
                                                        },
                                                        icon: const Iconify(
                                                          Fluent
                                                              .arrow_download_16_regular,
                                                          color: ColorManager
                                                              .colorAccent,
                                                        )),
                                                    const Text(
                                                      "Download",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .colorAccent,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                GetStorage().read("token") !=
                                                        null
                                                    ? showReportDialog(
                                                        widget.videoId,
                                                        widget.userName,
                                                        widget.UserId)
                                                    : showLoginAlert(),
                                            child: Row(
                                              children: const [
                                                Iconify(
                                                  Fluent
                                                      .chat_warning_24_regular,
                                                  color: Color(0xffFF2400),
                                                  size: 30,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Report...",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xffFF2400)),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (GetStorage()
                                                      .read("token")
                                                      .toString()
                                                      .isNotEmpty &&
                                                  GetStorage().read("token") !=
                                                      null) {
                                                usersController.isUserBlocked(
                                                    widget.UserId);
                                                Future.delayed(const Duration(
                                                        seconds: 1))
                                                    .then((value) => usersController
                                                            .userBlocked.value
                                                        ? usersController
                                                            .blockUnblockUser(
                                                                widget.UserId,
                                                                "Unblock")
                                                        : usersController
                                                            .blockUnblockUser(
                                                                widget.UserId,
                                                                "Block"));
                                              } else {
                                                showLoginAlert();
                                              }
                                            },
                                            child: Row(
                                              children: const [
                                                Iconify(
                                                  Fluent.block_24_regular,
                                                  color:
                                                      ColorManager.colorAccent,
                                                  size: 30,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Block User...",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: ColorManager
                                                          .colorAccent),
                                                )
                                              ],
                                            ),
                                          )
                                        ]),
                                      ),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)));
                                },
                                icon: const Iconify(
                                  Fluent.more_vertical_28_regular,
                                  color: Colors.white,
                                )),
                            const Text(
                              "More",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: widget.isHome
                      ? const EdgeInsets.only(bottom: 100, left: 10)
                      : const EdgeInsets.only(left: 10, bottom: 10),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (GetStorage()
                                  .read("token")
                                  .toString()
                                  .isNotEmpty &&
                              GetStorage().read("token") != null) {
                            Get.to(ViewProfile(
                              widget.UserId.toString(),
                            ));
                          } else {
                            showLoginAlert();
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              width: 30,
                              height: 30,
                              child: CachedNetworkImage(
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                imageUrl: widget.publicUser!.avatar == null ||
                                        widget.publicUser!.avatar!.isEmpty
                                    ? "https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png"
                                    : RestUrl.profileUrl +
                                        widget.publicUser!.avatar.toString(),
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "@" +
                                          widget.publicUser!.username
                                              .toString() ??
                                      "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => Get.to(SoundDetails(
                          map: {
                            "sound": widget.sound,
                            "user": widget.soundOwner.isEmpty
                                ? widget.userName
                                : widget.soundOwner,
                            "soundName": widget.soundName,
                            "title": widget.soundOwner,
                            "id":widget.UserId
                          },
                        )),
                        child: Row(
                          children: [
                            const Iconify(
                              Carbon.music,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.soundName.isEmpty
                                  ? "Original Sound"
                                  : widget.soundName,
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.hashtagsList.isNotEmpty,
                        child: Container(
                          height: 35,
                          child: ListView.builder(
                              itemCount: widget.hashtagsList.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => InkWell(
                                onTap: ()=>Get.to(()=>HashTagsScreen(widget.hashtagsList[index].toString())),
                                child: Container(
                                decoration: BoxDecoration(
                                    color: ColorManager.colorAccent
                                        .withOpacity(0.5),
                                    border: Border.all(
                                        color: Colors.transparent),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                margin: const EdgeInsets.only(
                                    right: 5, top: 5, bottom: 5),
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.hashtagsList[index].toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
        IgnorePointer(
          child: Obx((() => Visibility(
                visible: volume.value == 0,
                child: Center(
                    child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: ColorManager.colorAccent.withOpacity(0.5),
                    child: const Icon(
                      IconlyLight.volume_off,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                )),
              ))),
        )
      ],
    );
  }

  showReportDialog(int videoId, String name, int id) async {
    String dropDownValue = "Reason";
    List<String> dropDownValues = [
      "Reason",
    ];
    try {
      var response = await RestApi.getSiteSettings();
      var json = jsonDecode(response.body);
      if (json['status']) {
        List jsonList = json['data'] as List;
        for (var element in jsonList) {
          if (element['name'] == 'report_reason') {
            List reasonList = element['value'].toString().split(',');
            for (String reason in reasonList) {
              dropDownValues.add(reason);
            }
            break;
          }
        }
      } else {
        showErrorToast(context, json['message'].toString());
        return;
      }
    } catch (e) {
      closeDialogue(context);
      showErrorToast(context, e.toString());
      return;
    }
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                        width: getWidth(context) * .80,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "Report $name's Video ?",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5)),
                              child: DropdownButton(
                                value: dropDownValue,
                                underline: Container(),
                                isExpanded: true,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                                onChanged: (String? value) {
                                  setState(() {
                                    dropDownValue =
                                        value ?? dropDownValues.first;
                                  });
                                },
                                items: dropDownValues.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                                onPressed: dropDownValue == "Reason"
                                    ? null
                                    : () async {
                                        try {
                                          var response =
                                              await RestApi.reportVideo(
                                                  videoId, id, dropDownValue);
                                          var json = jsonDecode(response.body);
                                          closeDialogue(context);
                                          if (json['status']) {
                                            //Navigator.pop(context);
                                            showSuccessToast(context,
                                                json['message'].toString());
                                          } else {
                                            //Navigator.pop(context);
                                            showErrorToast(context,
                                                json['message'].toString());
                                          }
                                        } catch (e) {
                                          closeDialogue(context);
                                          showErrorToast(context, e.toString());
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 5)),
                                child: const Text("Report"))
                          ],
                        )),
                  ),
                );
              },
            ));
  }

  showDeleteDialog() {
    Get.defaultDialog(
      backgroundColor: Colors.transparent.withOpacity(0),
      content: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: ColorManager.colorAccent,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            margin: const EdgeInsets.only(top: 60),
            height: 160,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "This will permanently delete your video, continue?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorManager.colorAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            primary: Colors.red),
                        onPressed: () =>
                            videosController.deleteVideo(widget.videoId),
                        child: const Text('Yes')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            primary: ColorManager.colorAccent),
                        onPressed: () => Get.back(),
                        child: const Text('No')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50))),
            child: const Icon(
              Icons.error,
              color: Colors.red,
              size: 100,
            ),
          ),
        ],
      ),
      middleText: "",
      title: "",
    );
  }

  showComments() {
    Get.bottomSheet(
        GetX<CommentsController>(
            builder: (commentsController) => commentsController
                    .isCommentsLoading.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Comments",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Iconify(IconParkOutline.close_small))
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      Flexible(
                        child: commentsController.commentsModel.isEmpty
                            ? const Center(
                                child: Text("No Comments Yet",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 179, 178, 178))),
                              )
                            : commentsController.isCommentsLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        commentsController.commentsModel.length,
                                    itemBuilder: (context, index) => Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    usersController.userId
                                                        .value = widget.UserId;
                                                    Get.to(ViewProfile(
                                                      commentsController
                                                          .commentsModel[index]
                                                          .userId
                                                          .toString(),
                                                    ));
                                                  },
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: commentsController
                                                                  .commentsModel[
                                                                      index]
                                                                  .avatar!
                                                                  .isEmpty ||
                                                              commentsController
                                                                      .commentsModel[
                                                                          index]
                                                                      .avatar ==
                                                                  null
                                                          ? "https://www.kindpng.com/picc/m/252-2524695_dummy-profile-image-jpg-hd-png-download.png"
                                                          : RestUrl.profileUrl +
                                                              commentsController
                                                                  .commentsModel[
                                                                      index]
                                                                  .avatar
                                                                  .toString(),
                                                      fit: BoxFit.cover,
                                                      height: 30,
                                                      width: 30,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        commentsController
                                                            .commentsModel[
                                                                index]
                                                            .name
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      SizedBox(
                                                        width: 300,
                                                        child: Text(
                                                          commentsController
                                                              .commentsModel[
                                                                  index]
                                                              .comment
                                                              .toString(),
                                                          maxLines: 4,
                                                          overflow:
                                                              TextOverflow.clip,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        commentsController
                                                                .commentsModel[
                                                                    index]
                                                                .commentLikeCounter
                                                                .toString() +
                                                            " Likes",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      commentsController
                                                          .likeComment(
                                                              commentsController
                                                                  .commentsModel[
                                                                      index]
                                                                  .id
                                                                  .toString(),
                                                              "1");
                                                      Future.delayed(
                                                              const Duration(
                                                                  seconds: 1))
                                                          .then((value) =>
                                                              commentsController
                                                                  .getComments(
                                                                      widget
                                                                          .videoId));
                                                    },
                                                    child: const Icon(
                                                      IconlyLight.heart,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ))
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      Expanded(
                        flex: 0,
                        child: Container(
                            height: 40,
                            margin: const EdgeInsets.all(15),
                            child: GetStorage()
                                        .read("token")
                                        .toString()
                                        .isEmpty ||
                                    GetStorage().read("token") == null
                                ? Container(
                              alignment: Alignment.center,
                                    width: Get.width,
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: 'Login',
                                          recognizer: TapGestureRecognizer()..onTap=(){
                                            Get.back(closeOverlays: true);
                                            Get.to(LoginGetxScreen());

                                          },
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: ColorManager
                                                  .colorPrimaryLight)),
                                      const TextSpan(
                                          text: " to post comments",
                                          style: TextStyle(color: Colors.grey))
                                    ])),
                                  )
                                : widget.isCommentAllowed
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            child: Flexible(
                                              child: TextFormField(
                                                enabled:
                                                    widget.isCommentAllowed,
                                                controller:
                                                    _textEditingController,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      255, 65, 64, 64),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                onChanged: (value) {
                                                  comment.value = value;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        0.0,
                                                                    horizontal:
                                                                        20.0),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          100)),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          50)),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                        fillColor: Color
                                                            .fromARGB(255, 242,
                                                                240, 240),
                                                        filled: true,
                                                        focusColor:
                                                            Colors.white,
                                                        hintStyle: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    113,
                                                                    112,
                                                                    112)),
                                                        hintText:
                                                            "Post your comment"
                                                        //add prefix icon

                                                        ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ClipOval(
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              color: Colors.black,
                                              child: InkWell(
                                                  onTap: () async {

                                                    var currentUser =
                                                        userModel.User.fromJson(
                                                            GetStorage()
                                                                .read("user"));

                                                    await commentsController
                                                        .postComment(
                                                            widget.videoId,
                                                            currentUser.id
                                                                .toString(),
                                                            comment.value).then((value)async {
                                                    await commentsController
                                                        .getComments(
                                                    widget.videoId);

                                                        _textEditingController!
                                                        .clear();
                                                    });


                                                  },
                                                  child: const Icon(
                                                    IconlyLight.send,
                                                    color: Colors.white,
                                                    size: 15,
                                                  )),
                                            ),
                                          )
                                        ],
                                      )
                                    : SizedBox(
                                        width: Get.width,
                                        child: const Text(
                                          'Comments are disabled for this video',
                                          textAlign: TextAlign.center,
                                        ),
                                      )),
                      )
                    ],
                  )),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
  }

  Future<Uri> createDynamicLink(String videoName) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse('https://thrillvideo.s3.amazonaws.com/test/$videoName'),
      androidParameters: AndroidParameters(
        packageName: 'com.thrill',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await parameters.buildShortLink();
    final Uri shortUrl = dynamicUrl.shortUrl;
    return shortUrl;
  }
}
