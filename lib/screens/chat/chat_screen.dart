import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:http/http.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../common/strings.dart';
import 'chat_contrroller.dart';

var usersController = Get.find<UserDetailsController>();

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
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.keyboard_backspace)),
                Text(
                  widget.inboxModel!.name.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 24),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
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
                                image: imageProvider, fit: BoxFit.cover),
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
                            imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        image: imageProvider, fit: BoxFit.fill),
                                  ),
                                ),
                            imageUrl: RestUrl.placeholderImage),
                    imageUrl: widget.inboxModel!.userImage == null
                        ? RestUrl.placeholderImage
                        : RestUrl.profileUrl + widget.inboxModel!.userImage!),
              ),
            ),
            Text(
              "@" + widget.inboxModel!.name.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMsg>>(
                stream: ChatController.getChatMsg(
                  '${widget.inboxModel!.id}',
                ),
                builder: (context, snapshot) {
                  chats = snapshot.data ?? [];

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: chats.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) => chats[index].senderId ==
                            usersController.userProfile.value.id.toString()
                        ? myBubble(chats[index])
                        : friendBubble(chats[index]),
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
              border: const Border.fromBorderSide(BorderSide.none),
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
                        onChanged: (txt) => setState(() => txtValue = txt),
                        decoration: const InputDecoration(
                          hintText: type,
                          hintStyle:
                              TextStyle(color: Colors.black26, fontSize: 13),
                          fillColor: Colors.white,
                          filled: true,
                          constraints: BoxConstraints(maxHeight: 40),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.only(left: 15, right: 15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          if (txtController.text.isNotEmpty) {
                            ChatMsg message = ChatMsg(
                              msgId: '',
                              message: txtValue,
                              senderId: usersController.userProfile.value.id
                                  .toString(),
                              time: DateTime.now().toString(),
                              seen: false,
                            );
                            ChatController.sendMsg(
                                '${usersController.userProfile.value.id}',
                                message);
                            txtValue = '';
                            txtController.clear();
                            widget.inboxModel?.message = message.message;
                            widget.inboxModel!.time = message.time;
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
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Color.fromRGBO(255, 77, 103, 0.12),
                              Color.fromRGBO(45, 203, 200, 1),
                            ])),
                            child: Icon(
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent.withOpacity(0.0),
                    ColorManager.colorAccent
                  ]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(20)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent.withOpacity(0.0),
                    ColorManager.colorAccentTransparent
                  ]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text("${msg.message}  ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
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

class ChatPage extends StatefulWidget {

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Chat(
      messages: _messages,
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
    ),
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }
}
