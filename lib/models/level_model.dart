class LevelModel {
  String current, next, progress;

  LevelModel(this.current, this.next, this.progress);

  factory LevelModel.fromJson(dynamic json) {
    return LevelModel(json['current'] ?? '0', json['next'] ?? '0', json['progress'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['current'] = current;
    data['next'] = next;
    data['progress'] = progress;
    return data;
  }
}
