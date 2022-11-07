class EarnedSpinModel {
  bool? status;
  Data? data;
  String? message;
  bool? error;

  EarnedSpinModel({this.status, this.data, this.message, this.error});

  EarnedSpinModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class Data {
  List<Activities>? activities;

  Data({this.activities});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(new Activities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.activities != null) {
      data['activities'] = this.activities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Activities {
  String? name;
  String? currentLevel;
  String? nextLevel;
  String? conditions;
  String? earnedSpins;
  String? totalSpin;
  String? maxLevel;
  int? progress;

  Activities(
      {this.name,
        this.currentLevel,
        this.nextLevel,
        this.conditions,
        this.earnedSpins,
        this.totalSpin,
        this.maxLevel,
        this.progress});

  Activities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    currentLevel = json['current_level'];
    nextLevel = json['next_level'];
    conditions = json['conditions'];
    earnedSpins = json['earned_spins'];
    totalSpin = json['total_spin'];
    maxLevel = json['max_level'];
    progress = json['progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['current_level'] = this.currentLevel;
    data['next_level'] = this.nextLevel;
    data['conditions'] = this.conditions;
    data['earned_spins'] = this.earnedSpins;
    data['total_spin'] = this.totalSpin;
    data['max_level'] = this.maxLevel;
    data['progress'] = this.progress;
    return data;
  }
}
