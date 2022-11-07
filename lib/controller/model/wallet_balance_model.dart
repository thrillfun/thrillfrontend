class WalletBalanceModel {
  bool? status;
  bool? error;
  String? message;
  List<Balance>? data;

  WalletBalanceModel({this.status, this.error, this.message, this.data});

  WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Balance>[];
      json['data'].forEach((v) {
        data!.add(new Balance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Balance {
  String? code;
  int? amount;
  String? symbol;
  String? image;
  int? isActive;
  String? networkName;
  int? minAmount;
  int? maxAmount;
  int? feeDigit;

  Balance(
      {this.code,
        this.amount,
        this.symbol,
        this.image,
        this.isActive,
        this.networkName,
        this.minAmount,
        this.maxAmount,
        this.feeDigit});

  Balance.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    amount = json['amount'];
    symbol = json['symbol'];
    image = json['image'];
    isActive = json['is_active'];
    networkName = json['network_name'];
    minAmount = json['min_amount'];
    maxAmount = json['max_amount'];
    feeDigit = json['fee_digit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['amount'] = this.amount;
    data['symbol'] = this.symbol;
    data['image'] = this.image;
    data['is_active'] = this.isActive;
    data['network_name'] = this.networkName;
    data['min_amount'] = this.minAmount;
    data['max_amount'] = this.maxAmount;
    data['fee_digit'] = this.feeDigit;
    return data;
  }
}
