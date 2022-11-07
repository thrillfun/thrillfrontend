class CurrenciesModel {
  bool? status;
  List<Currencies>? data;
  String? message;
  bool? error;

  CurrenciesModel({this.status, this.data, this.message, this.error});

  CurrenciesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Currencies>[];
      json['data'].forEach((v) {
        data!.add(new Currencies.fromJson(v));
      });
    }
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class Currencies {
  int? id;
  String? code;
  String? symbol;
  String? image;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  List<Networks>? networks;

  Currencies(
      {this.id,
        this.code,
        this.symbol,
        this.image,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.networks});

  Currencies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    symbol = json['symbol'];
    image = json['image'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['networks'] != null) {
      networks = <Networks>[];
      json['networks'].forEach((v) {
        networks!.add(new Networks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['symbol'] = this.symbol;
    data['image'] = this.image;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.networks != null) {
      data['networks'] = this.networks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Networks {
  int? id;
  int? currencyId;
  String? networkName;
  String? minAmount;
  String? maxAmount;
  String? feeDigit;
  String? createdAt;
  String? updatedAt;

  Networks(
      {this.id,
        this.currencyId,
        this.networkName,
        this.minAmount,
        this.maxAmount,
        this.feeDigit,
        this.createdAt,
        this.updatedAt});

  Networks.fromJson(Map<String, dynamic> json) {
    id = json['id']??"";
    currencyId = json['currency_id']??'';
    networkName = json['network_name']??'';
    minAmount = json['min_amount']??"";
    maxAmount = json['max_amount']??"";
    feeDigit = json['fee_digit']??"";
    createdAt = json['created_at']??"";
    updatedAt = json['updated_at']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency_id'] = this.currencyId;
    data['network_name'] = this.networkName;
    data['min_amount'] = this.minAmount;
    data['max_amount'] = this.maxAmount;
    data['fee_digit'] = this.feeDigit;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
