class CategoryModel {
  int id;
  String title, status;

  CategoryModel(this.id, this.title, this.status);

  factory CategoryModel.fromJson(dynamic json) {
    return CategoryModel(
        json['id'] ?? 0, json['title'] ?? '', json['status'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['status'] = status;
    return data;
  }
}
