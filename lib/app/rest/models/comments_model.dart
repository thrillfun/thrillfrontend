class CommentsModel {
  bool? status;
  String? message;
  List<CommentData>? commentsData;

  CommentsModel({this.status, this.message, this.commentsData});

  CommentsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      commentsData = <CommentData>[];
      json['data'].forEach((v) {
        commentsData!.add(new CommentData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.commentsData != null) {
      data['data'] = this.commentsData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommentData {
  int? id;
  String? comment;
  int? userId;
  String? avatar;
  String? name;
  int? commentLikeCounter;

  CommentData(
      {this.id,
        this.comment,
        this.userId,
        this.avatar,
        this.name,
        this.commentLikeCounter});

  CommentData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    comment = json['comment'] ?? '';
    userId = json['user_id'] ?? '';
    avatar = json['avatar'] ?? '';
    name = json['name'] ?? '';
    commentLikeCounter = json['comment_like_counter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['user_id'] = this.userId;
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['comment_like_counter'] = this.commentLikeCounter;
    return data;
  }
}