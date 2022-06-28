class WalletBalance{
  String code,symbol;
  double amount;

  WalletBalance(this.code, this.amount,this.symbol);

  factory WalletBalance.fromJson(dynamic json) {
    return WalletBalance(
      json['code'] ?? '',
      double.tryParse(json['amount'].toString()) ?? 0,
      json['symbol'] ?? '',
    );
  }
}