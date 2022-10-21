import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/utils.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/rest/rest_api.dart';

import '../../common/strings.dart';
import 'chat_contrroller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.inboxModel}) : super(key: key);
  static const String routeName = '/chatScreen';
  final InboxModel inboxModel;

  static Route route(InboxModel senderInbox) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => ChatScreen(
        inboxModel: senderInbox,
      ),
    );
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController txtController = TextEditingController();
  String txtValue = '';
  List<ChatMsg> chats = List<ChatMsg>.empty(growable: true);
  User? userModel;
  late InboxModel inboxModel = widget.inboxModel;

  @override
  initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    if (currentUser != null) {
      User current = User.fromJson(jsonDecode(currentUser));
      setState(() => userModel = current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, inboxModel);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF171D22),
                  Color(0xff143035),
                  Color(0xff171D23)
                ],
              ),
            ),
          ),
          elevation: 0.5,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.inboxModel.name.capitalizeFirst!.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: widget.inboxModel.userImage == "null" ||
                        widget.inboxModel.userImage.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(2),
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: ColorManager.spinColorDivider)),
                        child: ClipOval(
                            child: SvgPicture.asset(
                          'assets/profile.svg',
                          width: 25,
                          height: 25,
                        )),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.inboxModel.userImage == "null" ||
                                widget.inboxModel.userImage.isEmpty
                            ? "https://www.worldpeacecouncil.net/images/photos/home/thumbnails/thumb_Gandhi1.jpg"
                            : widget.inboxModel.userImage,
                        fit: BoxFit.contain,
                        width: 35,
                        height: 35,
                      ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: GlassContainer(
            color: Colors.white.withOpacity(0.8),
            blur: 15,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF171D22), Color(0xff143035), Color(0xff171D23)],
            ),
            //--code to remove border
            border: Border.fromBorderSide(BorderSide.none),
            shadowStrength: 15,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(0),
            shadowColor: Colors.white.withOpacity(0.2),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/background.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    userModel == null
                        ? const SizedBox()
                        : Expanded(
                            child: StreamBuilder<List<ChatMsg>>(
                              stream: ChatController.getChatMsg(
                                userModel!.id! > widget.inboxModel.id
                                    ? '${userModel!.id}_${widget.inboxModel.id}'
                                    : '${widget.inboxModel.id}_${userModel!.id}',
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
                                        userModel?.id.toString()) {
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
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        if (txtController.text.isNotEmpty) {
                                          ChatMsg message = ChatMsg(
                                            msgId: '',
                                            message: txtValue,
                                            senderId: userModel!.id.toString(),
                                            time: DateTime.now().toString(),
                                            seen: false,
                                          );
                                          ChatController.sendMsg(
                                              userModel!.id! >
                                                      widget.inboxModel.id
                                                  ? '${userModel!.id}_${widget.inboxModel.id}'
                                                  : '${widget.inboxModel.id}_${userModel!.id}',
                                              message);
                                          txtValue = '';
                                          txtController.clear();
                                          inboxModel.message = message.message;
                                          inboxModel.msgDate = message.time;
                                          await RestApi.sendChatNotification(
                                              widget.inboxModel.id.toString(),
                                              message.message);
                                        }

                                        /// sendMessage();
                                      },
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.grey,
                                      )),
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
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )),
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
              color: Colors.black,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
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
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
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
