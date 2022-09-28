class DiscoverModel {
  int? id;
  String? image;
  String? createdAt;
  String? updatedAt;

  DiscoverModel({this.id, this.image, this.createdAt, this.updatedAt});

  DiscoverModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
