class SoundCategoryModel {
  int id;
  String name, createDate, uploadDate;

  SoundCategoryModel(this.id, this.name, this.createDate, this.uploadDate);

  factory SoundCategoryModel.fromJson(dynamic json) {
    return SoundCategoryModel(
      int.tryParse(json['id'].toString()) ?? 0,
      json['name'] ?? '',
      json['created_at'] ?? '',
      json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_at'] = createDate;
    data['updated_at'] = uploadDate;
    return data;
  }
}
