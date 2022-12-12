import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';

import '../../common/strings.dart';
import 'chat_contrroller.dart';

var usersController = Get.find<UserController>();

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key, required this.inboxModel}) : super(key: key);
  Inbox? inboxModel;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController txtController = TextEditingController();
  String txtValue = '';
  List<ChatMsg> chats = List<ChatMsg>.empty(growable: true);
  User? userModel;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
    backgroundColor: ColorManager.dayNight,

        body:Column(
          children: [
            Row(children: [
              IconButton(onPressed: ()=>Get.back(), icon: Icon(Icons.keyboard_backspace)),
              Text(widget.inboxModel!.name!,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),)
            ],),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                child: CachedNetworkImage(
                    placeholder: (a, b) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    fit: BoxFit.fill,
                    height: 120,
                    width: 120,
                    imageBuilder: (context, imageProvider) => Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover),
                      ),
                    ),
                    errorWidget: (context, string, dynamic) =>
                        CachedNetworkImage(
                            placeholder: (a, b) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            fit: BoxFit.fill,
                            height: 60,
                            width: 60,
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(60),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.fill),
                                  ),
                                ),
                            imageUrl: RestUrl.placeholderImage),
                    imageUrl: RestUrl.profileUrl +
                        widget.inboxModel!.userImage!),
              ),
            ),
            Text(
              "@"+widget.inboxModel!.name!,
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMsg>>(
                stream: ChatController.getChatMsg(
                  usersController.userProfile.value.id! >
                      widget.inboxModel!.id!
                      ? '${usersController.userProfile.value!.id}_${widget.inboxModel!.id}'
                      : '${widget.inboxModel!.id}_${usersController.userProfile.value!.id}',
                ),
                builder: (context, snapshot) {
                  chats = snapshot.data ?? [];
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    reverse: true,
                    itemCount: chats.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      var chat = chats[index];

                      /* if (!(chat.senderId == 1) && !chat.seen) {
                        ChatController.markMsgSeen(widget.chatId, chat);
                      }*/

                      if (chat.senderId ==
                          usersController.userProfile.value?.id
                              .toString()) {
                        return myBubble(chat);
                      } else {
                        return friendBubble(chat);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GlassContainer(
              blur: 10,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF171D22),
                  Color(0xff143035),
                  Color(0xff171D23)
                ],
              ),
              //--code to remove border
              border: Border.fromBorderSide(BorderSide.none),
              shadowStrength: 3,
              color: Colors.red.withOpacity(0.5),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(0),
              shadowColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 20, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: txtController,
                        onChanged: (txt) =>
                            setState(() => txtValue = txt),
                        decoration: InputDecoration(
                          hintText: type,
                          hintStyle: const TextStyle(
                              color: Colors.black26, fontSize: 13),
                          fillColor: Colors.white,
                          filled: true,
                          constraints:
                          const BoxConstraints(maxHeight: 40),
                          border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(
                              left: 15, right: 15),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    InkWell(
                        onTap: () async {
                          if (txtController.text.isNotEmpty) {
                            ChatMsg message = ChatMsg(
                              msgId: '',
                              message: txtValue,
                              senderId: usersController
                                  .userProfile.value!.id
                                  .toString(),
                              time: DateTime.now().toString(),
                              seen: false,
                            );
                            ChatController.sendMsg(
                                usersController.userProfile.value!
                                    .id! >
                                    widget.inboxModel!.id!
                                    ? '${usersController.userProfile.value!.id}_${widget.inboxModel!.id}'
                                    : '${widget.inboxModel!.id}_${usersController.userProfile.value!.id}',
                                message);
                            txtValue = '';
                            txtController.clear();
                            widget.inboxModel?.message =
                                message.message;
                            widget.inboxModel!.time =
                                message.time;
                            await RestApi.sendChatNotification(
                                widget.inboxModel!.id.toString(),
                                message.message);
                          }

                          /// sendMessage();
                        },
                        child: ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                gradient:
                                LinearGradient(colors: [
                                  Color.fromRGBO(
                                      255, 77, 103, 0.12),
                                  Color.fromRGBO(45, 203, 200, 1),
                                ])),
                            child:  Icon(
                              IconlyLight.send,
                              size: 20,
                              color: ColorManager.dayNightIcon,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget myBubble(ChatMsg msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .80),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(255, 77, 103, 0.12),
                    Color(0xff2dcbc8)
                  ]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(20)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle( fontSize: 16,fontWeight: FontWeight.w400)),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                        DateFormat('h:mm a')
                            .format(DateTime.parse(msg.time))
                            .toLowerCase(),
                        style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold))),
              ],
            )
            // RichText(
            //     text: TextSpan(
            //         children: [
            //           TextSpan(text: msg.message, style: const TextStyle(color: Colors.white)),
            //           const TextSpan(text: ' '),
            //           TextSpan(text: DateFormat('h:mm a').format(msg.time).toLowerCase(), style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
            //         ]
            //     )),
            //Text("${msg.message}  ${DateFormat('h:mm a').format(msg.time).toLowerCase()}", style: const TextStyle(color: Colors.white)),
            ),
      ],
    );
  }

  Widget friendBubble(ChatMsg msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .80),
            decoration: const BoxDecoration(
                color: Color.fromRGBO(53, 56, 63, 1)),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle( fontSize: 16,fontWeight: FontWeight.w400)),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                        DateFormat('h:mm a')
                            .format(DateTime.parse(msg.time))
                            .toLowerCase(),
                        style: const TextStyle(
                            fontSize: 8,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))),
              ],
            )
            //Text("${msg.message}  ${DateFormat('h:mm a').format(msg.time).toLowerCase()}", style: const TextStyle(color: Colors.black)),
            ),
      ],
    );
  }
}
