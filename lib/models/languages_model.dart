class LanguagesModel{
  int id;
  String code,name;

  LanguagesModel(this.id, this.code, this.name);

  factory LanguagesModel.fromJson(dynamic json) {
    return LanguagesModel(json['id'] ?? 0, json['code'] ?? '', json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}