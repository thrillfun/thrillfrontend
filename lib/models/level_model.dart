class LevelModel {
  String? current, next, progress, max_level;

  LevelModel(this.current, this.next, this.progress, this.max_level);

  factory LevelModel.fromJson(dynamic json) {
    return LevelModel(json['current'] ?? '0', json['next'] ?? '0',
        json['progress'] ?? '0', json['max_level'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['current'] = current;
    data['next'] = next;
    data['progress'] = progress;
    data['max_level'] = max_level;
    return data;
  }
}
