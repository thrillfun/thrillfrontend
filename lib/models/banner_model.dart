class BannerModel {
  int id;
  String image;

  BannerModel(this.id, this.image);

  factory BannerModel.fromJson(dynamic json) {
    return BannerModel(
        json['id'] ?? 0, json['image'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}