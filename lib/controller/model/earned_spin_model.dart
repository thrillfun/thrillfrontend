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
  dynamic? name;
  dynamic? currentLevel;
  dynamic? nextLevel;
  dynamic? conditions;
  dynamic? earnedSpins;
  dynamic? totalSpin;
  dynamic? maxLevel;
  dynamic? progress;
  dynamic? totalView;
  dynamic? currentView;
  dynamic? nextLvlView;

  Activities(
      {this.name,
      this.currentLevel,
      this.nextLevel,
      this.conditions,
      this.earnedSpins,
      this.totalSpin,
      this.maxLevel,
      this.progress,
      this.totalView,
      this.currentView,
      this.nextLvlView});

  Activities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    currentLevel = json['current_level'];
    nextLevel = json['next_level'];
    conditions = json['conditions'];
    earnedSpins = json['earned_spins'];
    totalSpin = json['total_spin'];
    maxLevel = json['max_level'];
    progress = json['progress'];
    totalView = json['total_view'];
    currentView = json['current_view'];
    nextLvlView = json['next_lvl_view'];
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
    data['total_view'] = this.totalView;
    data['current_view'] = this.currentView;
    data['next_lvl_view'] = this.nextLvlView;
    return data;
  }
}
