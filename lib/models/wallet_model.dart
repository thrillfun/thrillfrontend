class WalletBalance{
  String code,symbol,image;
  double amount;

  WalletBalance(this.code, this.amount,this.symbol,this.image);

  factory WalletBalance.fromJson(dynamic json) {
    return WalletBalance(
      json['code'] ?? '',
      double.tryParse(json['amount'].toString()) ?? 0,
      json['symbol'] ?? '',
      json['image'] ?? '',
    );
  }
}