class Comments {
  int id, comment_like_counter,user_id;
  String avatar, name, comment;

  Comments(this.id, this.comment_like_counter, this.avatar, this.name,
      this.comment,this.user_id);

  factory Comments.fromJson(dynamic json) {
    return Comments(json['id'] ?? 0, json['comment_like_counter'] ?? 0,
        json['avatar'] ?? '', json['name'] ?? '', json['comment'] ?? '',json['user_id'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['comment_like_counter'] = comment_like_counter;
    data['name'] = name;
    data['comment'] = comment;
    data['user_id'] = user_id;
    return data;
  }
}
