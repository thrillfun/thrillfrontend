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
  num? amount;
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

class CryptoModel {
  String? symbol;
  String? priceChange;
  String? priceChangePercent;
  String? weightedAvgPrice;
  String? openPrice;
  String? highPrice;
  String? lowPrice;
  String? lastPrice;
  String? volume;
  String? quoteVolume;
  int? openTime;
  int? closeTime;
  int? firstId;
  int? lastId;
  int? count;

  CryptoModel(
      {this.symbol,
        this.priceChange,
        this.priceChangePercent,
        this.weightedAvgPrice,
        this.openPrice,
        this.highPrice,
        this.lowPrice,
        this.lastPrice,
        this.volume,
        this.quoteVolume,
        this.openTime,
        this.closeTime,
        this.firstId,
        this.lastId,
        this.count});

  CryptoModel.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    priceChange = json['priceChange'];
    priceChangePercent = json['priceChangePercent'];
    weightedAvgPrice = json['weightedAvgPrice'];
    openPrice = json['openPrice'];
    highPrice = json['highPrice'];
    lowPrice = json['lowPrice'];
    lastPrice = json['lastPrice'];
    volume = json['volume'];
    quoteVolume = json['quoteVolume'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    firstId = json['firstId'];
    lastId = json['lastId'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbol'] = this.symbol;
    data['priceChange'] = this.priceChange;
    data['priceChangePercent'] = this.priceChangePercent;
    data['weightedAvgPrice'] = this.weightedAvgPrice;
    data['openPrice'] = this.openPrice;
    data['highPrice'] = this.highPrice;
    data['lowPrice'] = this.lowPrice;
    data['lastPrice'] = this.lastPrice;
    data['volume'] = this.volume;
    data['quoteVolume'] = this.quoteVolume;
    data['openTime'] = this.openTime;
    data['closeTime'] = this.closeTime;
    data['firstId'] = this.firstId;
    data['lastId'] = this.lastId;
    data['count'] = this.count;
    return data;
  }
}