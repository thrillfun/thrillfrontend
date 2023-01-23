import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
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
        body: controller.obx((state) => Stack(
              fit: StackFit.expand,
              children: [
                ListView.builder(
                    itemCount: state!.length,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          // Get.to(ChatScreen(
                          //     inboxModel:
                          //     state[index]));

                          Get.to(ChatPage());
                          // await Navigator.pushNamed(
                          //     context, '/chatScreen',
                          //     arguments:
                          //     state[index])
                          //     .then((value) {
                          //   if (value != null) {
                          //     Inbox _inboxModel = value as Inbox;
                          //     for (Inbox im in state.value) {
                          //       if (im.id == _inboxModel.id) {
                          //         setState(() => inboxList.replaceRange(
                          //             inboxList.indexOf(im),
                          //             inboxList.indexOf(im) + 1,
                          //             [_inboxModel]));
                          //         break;
                          //       }
                          //     }
                          //   }
                          // });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                padding: const EdgeInsets.all(2),
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: ColorManager.spinColorDivider)),
                                child: ClipOval(
                                    child: imgProfile(
                                        '${RestUrl.profileUrl}${state[index].userImage}')),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          state[index].name.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          state[index].message!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w200,
                                              fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  getComparedTime(state[index].time.toString()),
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
            )));
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

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);
  void _handlePressed(types.User otherUser, BuildContext context) async {
    print(await FirebaseChatCore.instance.createRoom(otherUser));

    // Navigate to the Chat screen
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream:FirebaseFirestore.instance
            .collection("users")
            .doc("84").snapshots(),
         builder: (context,  AsyncSnapshot<DocumentSnapshot> snapshot)  {
          Object? map = snapshot.data!.data();
          return snapshot.data!=null
              ? Wrap(
                  children: List.generate(
                      3,
                      (index) => InkWell(onTap: ()=>_handlePressed(types.User(id: map.toString()), context),child: Text(snapshot.data!.data().toString()),)),
                )
              : Container(child: Center(child: InkWell(onTap:()=> _handlePressed(const types.User(id: "86"),context),child: Text("No chats yet!",style: TextStyle(fontSize: 18),),),),);
          // ...
        },
      ),
    );
  }
}
