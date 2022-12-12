import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/InboxController.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';

var usersController = Get.find<InboxController>();

class Inbox extends GetView<InboxController> {
  Inbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: GetX<InboxController>(
          builder: (inboxController) => inboxController.isInboxLoading.value
              ? Center(
                  child: loader(),
                )
              : inboxController.inboxList.isEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        const Center(
                            child: Text(
                          "No Chats yet!",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 24),
                        )),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 10, top: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(70)),
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ListView.builder(
                            itemCount: controller.inboxList.length,
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () async {
                                  Get.to(ChatScreen(
                                      inboxModel:
                                          inboxController.inboxList[index]));
                                  await Navigator.pushNamed(
                                          context, '/chatScreen',
                                          arguments:
                                              inboxController.inboxList[index])
                                      .then((value) {
                                    // if (value != null) {
                                    //   InboxModel _inboxModel = value as InboxModel;
                                    //   for (Inbox im in usersController.inboxList) {
                                    //     if (im.id == _inboxModel.id) {
                                    //       setState(() => inboxList.replaceRange(
                                    //           inboxList.indexOf(im),
                                    //           inboxList.indexOf(im) + 1,
                                    //           [_inboxModel]));
                                    //       break;
                                    //     }
                                    //   }
                                    // }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 5, top: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        padding: const EdgeInsets.all(2),
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: ColorManager
                                                    .spinColorDivider)),
                                        child: ClipOval(
                                          child: inboxController
                                                  .inboxList[index]
                                                  .userImage!
                                                  .isEmpty
                                              ? SvgPicture.asset(
                                                  'assets/profile.svg',
                                                  width: 10,
                                                  height: 10,
                                                )
                                              : CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  errorWidget: (a, b, c) =>
                                                      Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: SvgPicture.asset(
                                                      'assets/profile.svg',
                                                      width: 10,
                                                      height: 10,
                                                    ),
                                                  ),
                                                  imageUrl:
                                                      '${RestUrl.profileUrl}${inboxController.inboxList[index].userImage}',
                                                  placeholder: (a, b) =>
                                                      const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  inboxController
                                                      .inboxList![index].name
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  inboxController
                                                      .inboxList![index]
                                                      .message!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              ],
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          getComparedTime(inboxController
                                              .inboxList![index].time
                                              .toString()),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 10, top: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(70)),
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
        ));
  }

  String getComparedTime(String dateTime) {
    Duration difference = DateTime.now().difference(DateTime.parse(dateTime));
    final List prefix = [
      "just now",
      "second(s) ago",
      "minute(s) ago",
      "hour(s) ago",
      "day(s) ago",
      "month(s) ago",
      "year(s) ago"
    ];
    if (difference.inDays == 0) {
      if (difference.inMinutes == 0) {
        if (difference.inSeconds < 20) {
          return (prefix[0]);
        } else {
          return ("${difference.inSeconds} ${prefix[1]}");
        }
      } else {
        if (difference.inMinutes > 59) {
          return ("${(difference.inMinutes / 60).floor()} ${prefix[3]}");
        } else {
          return ("${difference.inMinutes} ${prefix[2]}");
        }
      }
    } else {
      if (difference.inDays > 30) {
        if (((difference.inDays) / 30).floor() > 12) {
          return ("${((difference.inDays / 30) / 12).floor()} ${prefix[6]}");
        } else {
          return ("${(difference.inDays / 30).floor()} ${prefix[5]}");
        }
      } else {
        return ("${difference.inDays} ${prefix[4]}");
      }
    }
  }
}
