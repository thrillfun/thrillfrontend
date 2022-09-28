class AddSoundModel {
  int id, userId, category;
  String sound, name, createDate, uploadDate;
  bool isSoundFromGallery;

  AddSoundModel(this.id, this.userId, this.category, this.sound, this.name,
      this.createDate, this.uploadDate, this.isSoundFromGallery);

  factory AddSoundModel.fromJson(dynamic json) {
    return AddSoundModel(
        int.tryParse(json['id'].toString()) ?? 0,
        int.tryParse(json['user_id'].toString()) ?? 0,
        int.tryParse(json['category'].toString()) ?? 0,
        json['sound'] ?? '',
        json['name'] ?? '',
        json['created_at'] ?? '',
        json['updated_at'] ?? '',
        false);
  }
}
