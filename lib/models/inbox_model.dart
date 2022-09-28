class InboxModel {
  int id;
  String userImage, message, msgDate, name;

  InboxModel({
    required this.id,
    required this.userImage,
    required this.message,
    required this.msgDate,
    required this.name,
  });

  factory InboxModel.fromJson(dynamic json) {
    return InboxModel(
      id: json['id'] ?? 0,
      msgDate: json['time'] ?? '',
      message: json['message'] ?? '',
      userImage: json['user_image'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
