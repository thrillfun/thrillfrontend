class WheelRewards{
  int id;
  int amount,is_image;
  String currency,currency_symbol,image_path;

  WheelRewards(this.id, this.amount, this.currency, this.currency_symbol,this.is_image,this.image_path);

  factory WheelRewards.fromJson(dynamic json) {
    return WheelRewards(json['id'] ?? 0, json['amount'] ?? 0, json['currency'] ?? '',json['currency_symbol'] ?? '',json['is_image'] ?? 0,json['image_path'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['currency'] = currency;
    data['currency_symbol'] = currency_symbol;
    data['is_image'] = is_image;
    data['image_path'] = image_path;
    return data;
  }
}