class WheelDataModel {
  bool? status;
  WheelData? data;
  String? message;
  bool? error;

  WheelDataModel({this.status, this.data, this.message, this.error});

  WheelDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new WheelData.fromJson(json['data']) : null;
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

class WheelData {
  List<RecentRewards>? recentRewards;
  String? availableChance;
  String? usedChance;
  String? lastReward;
  List<WheelRewards>? wheelRewards;

  WheelData(
      {this.recentRewards,
      this.availableChance,
      this.usedChance,
      this.lastReward,
      this.wheelRewards});

  WheelData.fromJson(Map<String, dynamic> json) {
    if (json['recent_rewards'] != null) {
      recentRewards = <RecentRewards>[];
      json['recent_rewards'].forEach((v) {
        recentRewards!.add(new RecentRewards.fromJson(v));
      });
    }
    availableChance = json['available_chance'];
    usedChance = json['used_chance'];
    lastReward = json['last_reward'];
    if (json['wheel_rewards'] != null) {
      wheelRewards = <WheelRewards>[];
      json['wheel_rewards'].forEach((v) {
        wheelRewards!.add(new WheelRewards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recentRewards != null) {
      data['recent_rewards'] =
          this.recentRewards!.map((v) => v.toJson()).toList();
    }
    data['available_chance'] = this.availableChance;
    data['used_chance'] = this.usedChance;
    data['last_reward'] = this.lastReward;
    if (this.wheelRewards != null) {
      data['wheel_rewards'] =
          this.wheelRewards!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RecentRewards {
  String? username;
  num? amount;
  String? currency;
  String? currencySymbol;

  RecentRewards(
      {this.username, this.amount, this.currency, this.currencySymbol});

  RecentRewards.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    amount = json['amount'];
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['currency_symbol'] = this.currencySymbol;
    return data;
  }
}

class WheelRewards {
  num? id;
  num? amount;
  String? currency;
  String? currencySymbol;
  num? probability;
  num? probabilityCounter;
  num? isImage;
  String? imagePath;
  String? createdAt;
  String? updatedAt;

  WheelRewards(
      {this.id,
      this.amount,
      this.currency,
      this.currencySymbol,
      this.probability,
      this.probabilityCounter,
      this.isImage,
      this.imagePath,
      this.createdAt,
      this.updatedAt});

  WheelRewards.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
    probability = json['probability'];
    probabilityCounter = json['probability_counter'];
    isImage = json['is_image'];
    imagePath = json['image_path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['currency_symbol'] = this.currencySymbol;
    data['probability'] = this.probability;
    data['probability_counter'] = this.probabilityCounter;
    data['is_image'] = this.isImage;
    data['image_path'] = this.imagePath;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
