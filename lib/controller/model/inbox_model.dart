class InboxModel {
  bool? status;
  String? message;
  bool? error;
  List<Inbox>? data;

  InboxModel({this.status, this.message, this.error, this.data});

  InboxModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    error = json['error'];
    if (json['data'] != null) {
      data = <Inbox>[];
      json['data'].forEach((v) {
        data!.add(new Inbox.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['error'] = this.error;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Inbox {
  int? id;
  String? userImage;
  String? name;
  String? message;
  String? time;

  Inbox({this.id, this.userImage, this.name, this.message, this.time});

  Inbox.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userImage = json['user_image'];
    name = json['name'];
    message = json['message'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_image'] = this.userImage;
    data['name'] = this.name;
    data['message'] = this.message;
    data['time'] = this.time;
    return data;
  }
}
