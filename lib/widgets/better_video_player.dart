import 'dart:convert';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/fluent.dart';
import 'package:iconify_flutter/icons/icon_park_outline.dart';
import 'package:iconly/iconly.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/model/comments_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/video/duet.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_player/video_player.dart';

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
      this.description);

  String gifImage;
  String videoUrl;
  int pageIndex;
  int currentPageIndex;
  bool isPaused;
  VoidCallback callback;
  PublicUser? publicUser;
  int videoId;
  String soundName;
  bool isDuetable = false;
  PublicVideos publicVideos;
  int UserId;
  String userName;
  String description;
  @override
  State<BetterReelsPlayer> createState() => _VideoAppState();
}

class _VideoAppState extends State<BetterReelsPlayer> {
  var userController = Get.find<UserController>();
  TextEditingController? _textEditingController;
  var initialized = false.obs;
  var volume = 1.0.obs;
  var comment = "".obs;

  late VideoPlayerController _betterPlayerController;

  @override
  void initState() {
    // TODO: implement initState
    _textEditingController = TextEditingController();

    _betterPlayerController =
        VideoPlayerController.network(RestUrl.videoUrl + widget.videoUrl)
          ..setLooping(false)
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
                  child: AspectRatio(
                    aspectRatio: _betterPlayerController.value.aspectRatio,
                    child: VideoPlayer(_betterPlayerController),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, bottom: 60),
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
                                icon: const Icon(
                                  IconlyLight.heart,
                                  color: Colors.white,
                                )),
                            const Text(
                              "Like",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 7),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  commentsController
                                      .getComments(widget.videoId);
                                  Get.bottomSheet(
                                      GetX<CommentsController>(
                                          builder:
                                              (commentsController) => Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              "Comments",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          IconButton(
                                                              onPressed: () {
                                                                Get.back(
                                                                    closeOverlays:
                                                                        true);
                                                              },
                                                              icon: const Iconify(
                                                                  IconParkOutline
                                                                      .close_small))
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                      ),
                                                      Divider(
                                                        thickness: 2,
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                      ),
                                                      Flexible(
                                                        child: commentsController
                                                                .commentsModel
                                                                .isEmpty
                                                            ? const Center(
                                                                child: Text(
                                                                    "No Comments Yet",
                                                                    style: TextStyle(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            179,
                                                                            178,
                                                                            178))),
                                                              )
                                                            : commentsController
                                                                    .isLoading
                                                                    .value
                                                                ? const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  )
                                                                : ListView
                                                                    .builder(
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount: commentsController
                                                                        .commentsModel
                                                                        .length,
                                                                    itemBuilder: (context,
                                                                            index) =>
                                                                        Container(
                                                                            margin:
                                                                                const EdgeInsets.all(10),
                                                                            child: Column(
                                                                              children: [
                                                                                Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        userController.userId.value = widget.UserId;
                                                                                        Get.to(ViewProfile(
                                                                                          mapData: {},
                                                                                          userId: widget.UserId.toString(),
                                                                                        ));
                                                                                      },
                                                                                      child: ClipOval(
                                                                                        child: CachedNetworkImage(
                                                                                          imageUrl: commentsController.commentsModel[index].avatar!.isEmpty || commentsController.commentsModel[index].avatar == null ? "https://www.kindpng.com/picc/m/252-2524695_dummy-profile-image-jpg-hd-png-download.png" : RestUrl.profileUrl + commentsController.commentsModel[index].avatar.toString(),
                                                                                          fit: BoxFit.cover,
                                                                                          height: 30,
                                                                                          width: 30,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(left: 10),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            commentsController.commentsModel[index].name.toString(),
                                                                                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 300,
                                                                                            child: Text(
                                                                                              commentsController.commentsModel[index].comment.toString(),
                                                                                              maxLines: 4,
                                                                                              overflow: TextOverflow.clip,
                                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Text(
                                                                                            commentsController.commentsModel[index].commentLikeCounter.toString() + " Likes",
                                                                                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                        child: Container(
                                                                                      alignment: Alignment.bottomRight,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          commentsController.likeComment(commentsController.commentsModel[index].id.toString(), "1");
                                                                                          Future.delayed(Duration(seconds: 1)).then((value) => commentsController.getComments(widget.videoId));
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
                                                            margin:
                                                                EdgeInsets.all(
                                                                    15),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  child:
                                                                      Flexible(
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _textEditingController,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            65,
                                                                            64,
                                                                            64),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      onChanged:
                                                                          (value) {
                                                                        comment.value =
                                                                            value;
                                                                      },
                                                                      decoration: const InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(100)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(50)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          fillColor: Color.fromARGB(255, 242, 240, 240),
                                                                          filled: true,
                                                                          focusColor: Colors.white,
                                                                          hintStyle: TextStyle(fontSize: 12, color: Color.fromARGB(255, 113, 112, 112)),
                                                                          hintText: "Post your comment"
                                                                          //add prefix icon

                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                ClipOval(
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    width: 35,
                                                                    color: Colors
                                                                        .black,
                                                                    child: InkWell(
                                                                        onTap: () async {
                                                                          var pref =
                                                                              await SharedPreferences.getInstance();
                                                                          var currentUser =
                                                                              pref.getString('currentUser');
                                                                          UserModel
                                                                              current =
                                                                              UserModel.fromJson(jsonDecode(currentUser!));

                                                                          commentsController.postComment(
                                                                              widget.videoId,
                                                                              current.id.toString(),
                                                                              comment.value);

                                                                          commentsController
                                                                              .getComments(widget.videoId);

                                                                          _textEditingController!
                                                                              .clear();
                                                                        },
                                                                        child: Icon(
                                                                          IconlyLight
                                                                              .send,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              15,
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            )),
                                                      )
                                                    ],
                                                  )),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)));
                                },
                                icon: const Iconify(
                                  Fluent.comment_multiple_28_regular,
                                  color: Colors.white,
                                )),
                            const Text(
                              "Comments",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10, top: 10, bottom: 10),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.bottomSheet(
                                      Container(
                                        height: 220,
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
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
                                                        color: Colors.black,
                                                        size: 30,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Duet",
                                                      style: TextStyle(
                                                          color: Colors.black,
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
                                                        onPressed: () {},
                                                        icon: const Iconify(Fluent
                                                            .save_16_regular)),
                                                    const Text(
                                                      "Save",
                                                      style: TextStyle(
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
                                                        onPressed: () {},
                                                        icon: const Iconify(Fluent
                                                            .link_16_regular)),
                                                    const Text(
                                                      "Link",
                                                      style: TextStyle(
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
                                                        onPressed: () {},
                                                        icon: const Iconify(Fluent
                                                            .arrow_download_16_regular)),
                                                    const Text(
                                                      "Download",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () => showReportDialog(
                                                widget.videoId,
                                                widget.userName,
                                                widget.UserId),
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
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              usersController
                                                  .isUserBlocked(widget.UserId);
                                              Future.delayed(
                                                      Duration(seconds: 1))
                                                  .then((value) =>
                                                      usersController
                                                              .userBlocked.value
                                                          ? usersController
                                                              .blockUnblockUser(
                                                                  widget.UserId,
                                                                  "Unblock")
                                                          : usersController
                                                              .blockUnblockUser(
                                                                  widget.UserId,
                                                                  "Block"));
                                            },
                                            child: Row(
                                              children: const [
                                                Iconify(
                                                  Fluent.block_24_regular,
                                                  color: Colors.black,
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
                                                      color: Colors.black),
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
                  margin: EdgeInsets.only(bottom: 60, left: 10),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              userController.userId.value = widget.UserId;
                              Get.to(ViewProfile(
                                mapData: {},
                                userId: widget.UserId.toString(),
                              ));
                            },
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              width: 25,
                              height: 25,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: widget.publicUser!.avatar == null ||
                                          widget.publicUser!.avatar!.isEmpty
                                      ? "https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png"
                                      : RestUrl.profileUrl +
                                          widget.publicUser!.avatar.toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "@" + widget.publicUser!.username!.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Iconify(
                            Carbon.music,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.soundName,
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
        Obx((() => Visibility(
              visible: volume.value == 0,
              child: Center(
                  child: ClipOval(
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white.withOpacity(0.5),
                  child: Icon(
                    IconlyLight.volume_off,
                    size: 25,
                  ),
                ),
              )),
            )))
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
}
