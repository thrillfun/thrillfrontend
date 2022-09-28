class HashtagModel {
  int id, is_active;
  String name;

  HashtagModel(this.id, this.is_active, this.name);

  factory HashtagModel.fromJson(dynamic json) {
    return HashtagModel(
        json['id'] ?? 0, json['is_active'] ?? 0, json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['is_active'] = is_active;
    data['name'] = name;
    return data;
  }
}
