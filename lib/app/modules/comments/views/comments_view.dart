import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';

import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/comments_controller.dart';

class CommentsView extends GetView<CommentsController> {
  CommentsView(
      {Key? key,
      this.videoId,
      this.userId,
      this.isCommentAllowed,
      this.isfollow,
      this.userName,
      this.avatar})
      : super(key: key);
  int? videoId, userId;
  RxBool? isCommentAllowed;
  int? isfollow;
  String? userName, avatar;
  FocusNode fieldNode = FocusNode();

  final _textEditingController = TextEditingController();
  RxString videoComment = "".obs;
  var relatedVideosController = Get.find<RelatedVideosController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        body: controller.obx(
      (state) => Column(
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
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          const Divider(
            thickness: 2,
          ),
          Flexible(
            child: state!.isEmpty
                ? const Center(
                    child: Text("No Comments Yet", style: TextStyle()),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: state.length,
                    itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if(await GetStorage().read("token") == null ){
                                      if (await Permission.phone.isGranted) {
                                        await SimDataPlugin.getSimData().then((value) =>
                                        value.cards.isEmpty
                                            ? Get.bottomSheet(LoginView(false.obs))
                                            : Get.bottomSheet(LoginView(true.obs)));
                                      } else {
                                        await Permission.phone.request().then((value) async =>
                                        await SimDataPlugin.getSimData().then((value) =>
                                        value.cards.isEmpty
                                            ? Get.bottomSheet(LoginView(false.obs))
                                            : Get.bottomSheet(LoginView(true.obs))));
                                      }
                                    }
                                    else{
                                      await GetStorage()
                                          .write("profileId", userId)
                                          .then((value) {
                                        Get.toNamed(Routes.OTHERS_PROFILE);
                                      });
                                    }

                                  },
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: state[index].avatar!.isEmpty ||
                                              state[index].avatar == null
                                          ? RestUrl.placeholderImage
                                          : RestUrl.profileUrl +
                                              state[index].avatar.toString(),
                                      fit: BoxFit.cover,
                                      height: 48,
                                      width: 48,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state[index].name.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                controller
                                                    .likeComment(
                                                        state[index]
                                                            .id
                                                            .toString(),
                                                        controller
                                                                    .commentsList[
                                                                        index]
                                                                    .commentLikeCounter ==
                                                                0
                                                            ? "1"
                                                            : "0")
                                                    .then((value) => controller
                                                        .getComments(videoId!));
                                              },
                                              child: Icon(
                                                controller.commentsList[index]
                                                            .commentLikeCounter ==
                                                        0
                                                    ? IconlyLight.heart
                                                    : IconlyBold.heart,
                                                size: 20,
                                                color: controller
                                                            .commentsList[index]
                                                            .commentLikeCounter ==
                                                        0
                                                    ? Colors.grey
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        )),
                                    Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          state[index]
                                                  .commentLikeCounter
                                                  .toString() +
                                              " Likes",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              state[index].comment.toString(),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                margin: const EdgeInsets.all(15),
                child: GetStorage().read("token").toString().isEmpty ||
                        GetStorage().read("token") == null
                    ? Container(
                        alignment: Alignment.center,
                        width: Get.width,
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Login',
                              recognizer: TapGestureRecognizer()
                                ..onTap = ()async  {
                                  Get.back(closeOverlays: true);
                                  if (await Permission.phone.isGranted) {
                                    await SimDataPlugin.getSimData().then((value) =>
                                    value.cards.isEmpty
                                        ? Get.bottomSheet(LoginView(false.obs))
                                        : Get.bottomSheet(LoginView(true.obs)));
                                  } else {
                                    await Permission.phone.request().then((value) async =>
                                    await SimDataPlugin.getSimData().then((value) =>
                                    value.cards.isEmpty
                                        ? Get.bottomSheet(LoginView(false.obs))
                                        : Get.bottomSheet(LoginView(true.obs))));
                                  }

                                },
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: ColorManager.colorPrimaryLight)),
                          const TextSpan(
                              text: " to post comments",
                              style: TextStyle(color: Colors.grey))
                        ])),
                      )
                    : isCommentAllowed!.value
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: Flexible(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    focusNode: fieldNode,
                                    enabled: isCommentAllowed?.value,
                                    controller: _textEditingController,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: fieldNode.hasFocus
                                            ? ColorManager.colorAccent
                                            : Colors.grey),
                                    onChanged: (value) {
                                      videoComment.value = value;
                                    },
                                    decoration: InputDecoration(
                                      focusColor: ColorManager.colorAccent,
                                      fillColor: fieldNode.hasFocus
                                          ? ColorManager.colorAccentTransparent
                                          : Colors.grey.withOpacity(0.1),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: fieldNode.hasFocus
                                            ? const BorderSide(
                                                color: Color(0xff2DCBC8),
                                              )
                                            : const BorderSide(
                                                color: Color(0xffFAFAFA),
                                              ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: fieldNode.hasFocus
                                            ? const BorderSide(
                                                color: Color(0xff2DCBC8),
                                              )
                                            : BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                              ),
                                      ),
                                      filled: true,
                                      prefixIcon: Icon(
                                        Icons.message,
                                        color: fieldNode.hasFocus
                                            ? ColorManager.colorAccent
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                      prefixStyle: TextStyle(
                                          color: fieldNode.hasFocus
                                              ? const Color(0xff2DCBC8)
                                              : Colors.grey,
                                          fontSize: 14),
                                      hintText: "Type your message...",
                                      hintStyle: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                    Color.fromRGBO(255, 77, 103, 0.12),
                                    Color.fromRGBO(45, 203, 200, 1),
                                  ])),
                                  child: InkWell(
                                      onTap: () async {
                                        controller
                                            .postComment(
                                          videoId: videoId!,
                                          userId: GetStorage()
                                              .read("userId")
                                              .toString(),
                                          comment: videoComment.value,
                                        )
                                            .then((value) async {
                                              relatedVideosController.getAllVideos();
                                          _textEditingController.clear();
                                        });
                                      },
                                      child: const Icon(
                                        IconlyLight.send,
                                        size: 20,
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
      ),
      onLoading: Container(
        width: Get.width,
        height: Get.height,
        child: loader(),),
    ));
  }
}
