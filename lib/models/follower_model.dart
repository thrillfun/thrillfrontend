class FollowerModel {
  int id;
  String image, name, email, date, userName;

  FollowerModel(
      this.id, this.image, this.name, this.email, this.date, this.userName);

  factory FollowerModel.fromJson(dynamic json) {
    return FollowerModel(
      int.tryParse(json['id'].toString()) ?? 0,
      json['avtars'] ?? '',
      json['name'] ?? '',
      json['email'] ?? '',
      json['created_at'] ?? '',
      json['username'] ?? '',
    );
  }
}
