import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import 'chat_contrroller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.senderModel}): super(key: key);
  static const String routeName = '/chatScreen';
  final UserModel senderModel;

  static Route route(UserModel sendrModel) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => ChatScreen(senderModel: sendrModel,),
    );
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController txtController = TextEditingController();
  String txtValue = '';
  List<ChatMsg> chats = List<ChatMsg>.empty(growable: true);
  UserModel? userModel;

  @override
  initState(){
    getUserData();
    super.initState();
  }

  getUserData() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    if(currentUser!=null){
      UserModel current = UserModel.fromJson(jsonDecode(currentUser));
      setState(()=> userModel = current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          widget.senderModel.name,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Column(
        children: [
          userModel==null?const SizedBox():
          Expanded(
            child: StreamBuilder<List<ChatMsg>>(
              stream: ChatController.getChatMsg(
                userModel!.id > widget.senderModel.id
                ? '${userModel!.id}_${widget.senderModel.id}'
                    : '${widget.senderModel.id}_${userModel!.id}',
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

                    if (chat.senderId ==  userModel?.id.toString()) {
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
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.grey.shade200,
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: txtController,
                    onChanged: (txt) => setState(() => txtValue = txt),
                    decoration: InputDecoration(
                      hintText: type,
                      hintStyle: const TextStyle(color: Colors.white, fontSize: 13),
                      fillColor: Colors.grey.shade400,
                      filled: true,
                      constraints: const BoxConstraints(maxHeight: 40),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.only(left: 15, right: 15),
                    ),
                  ),
                ),
                IconButton(
                        onPressed: () {
                          if(txtController.text.isNotEmpty){
                            ChatMsg message = ChatMsg(
                              msgId: '',
                              message: txtValue,
                              senderId: userModel!.id.toString(),
                              time: DateTime.now(),
                              seen: false,
                            );
                            ChatController.sendMsg(
                                userModel!.id > widget.senderModel.id
                                    ? '${userModel!.id}_${widget.senderModel.id}'
                                    : '${widget.senderModel.id}_${userModel!.id}',
                                message);
                            txtValue = '';
                            txtController.clear();
                          }

                          /// sendMessage();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.grey,
                        ))
              ],
            ),
          )
        ],
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
                Text("${msg.message} ",
                    style: const TextStyle(color: Colors.white)),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                        DateFormat('h:mm a').format(msg.time).toLowerCase(),
                        style: const TextStyle(
                            fontSize: 10,
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
                Text("${msg.message} ",
                    style: const TextStyle(color: Colors.black)),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                        DateFormat('h:mm a').format(msg.time).toLowerCase(),
                        style: const TextStyle(
                            fontSize: 10,
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
