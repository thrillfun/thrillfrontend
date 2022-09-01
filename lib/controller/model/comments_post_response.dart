class CommentsPostResponse {
  bool? status;
  Data? data;
  String? message;
  bool? error;

  CommentsPostResponse({this.status, this.data, this.message, this.error});

  CommentsPostResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class Data {
  String? videoId;
  String? commentBy;
  String? comment;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.videoId,
        this.commentBy,
        this.comment,
        this.updatedAt,
        this.createdAt,
        this.id});

  Data.fromJson(Map<String, dynamic> json) {
    videoId = json['video_id'];
    commentBy = json['comment_by'];
    comment = json['comment'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['video_id'] = this.videoId;
    data['comment_by'] = this.commentBy;
    data['comment'] = this.comment;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}

