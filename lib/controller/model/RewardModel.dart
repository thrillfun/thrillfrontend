class RewardModel {
  bool? status;
  RewardData? data;
  String? message;
  bool? error;

  RewardModel({this.status, this.data, this.message, this.error});

  RewardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new RewardData.fromJson(json['data']) : null;
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

class RewardData {
  String? availableChance;
  String? usedChance;

  RewardData({this.availableChance, this.usedChance});

  RewardData.fromJson(Map<String, dynamic> json) {
    availableChance = json['available_chance'];
    usedChance = json['used_chance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available_chance'] = this.availableChance;
    data['used_chance'] = this.usedChance;
    return data;
  }
}
