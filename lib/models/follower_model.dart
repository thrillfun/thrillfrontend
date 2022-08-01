class FollowerModel {
  int id;
  String image, name;

  FollowerModel(this.id, this.image, this.name);

  factory FollowerModel.fromJson(dynamic json) {
    return FollowerModel(
      int.tryParse(json['id'].toString()) ?? 0,
      json['avtars'] ?? '',
      json['name'] ?? '',
    );
  }
}
