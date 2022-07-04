class AddSoundModel {
  int id, category;
  String sound, name, createDate, uploadDate;

  AddSoundModel(this.id, this.category, this.sound, this.name, this.createDate, this.uploadDate);

  factory AddSoundModel.fromJson(dynamic json) {
    return AddSoundModel(
        int.tryParse(json['id'].toString()) ?? 0,
        int.tryParse(json['category'].toString()) ?? 0,
        json['sound'] ?? '',
        json['name'] ?? '',
        json['created_at'] ?? '',
        json['updated_at'] ?? '',
    );
  }
}
