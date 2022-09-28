import 'package:firebase_database/firebase_database.dart';

class ChatController {
  static String generateChatId(
      {required String buddyId, required String userId}) {
    return '${buddyId}_$userId';
  }

  static Future<void> sendMsg(String chatId, ChatMsg message) {
    return FirebaseDatabase.instance
        .ref()
        .child('chats')
        .child(chatId)
        .push()
        .set(message.toJson());
  }

  static Stream<List<ChatMsg>> getChatMsg(String chatId) {
    return FirebaseDatabase.instance
        .ref()
        .child('chats')
        .child(chatId)
        .onValue
        .map((event) {
      List<ChatMsg> chats = [];
      for (var chat in event.snapshot.children) {
        ChatMsg temp = ChatMsg.fromJson(chat.key ?? '', chat.value);
        chats.add(temp);
      }
      return chats.reversed.toList();
    });
  }
}

class ChatMsg {
  String msgId;
  String message;
  String senderId;
  bool seen;
  String time;

  ChatMsg({
    required this.msgId,
    required this.message,
    required this.senderId,
    required this.time,
    required this.seen,
  });

  factory ChatMsg.fromJson(String id, json) {
    return ChatMsg(
      msgId: id,
      message: json['message'] ?? '',
      senderId: json['senderId'] ?? '',
      time: json['time'] ?? '',
      seen: json['seen'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'time': time,
      'seen': seen,
    };
  }
}
