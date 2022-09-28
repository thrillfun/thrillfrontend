class WalletBalance {
  String code, symbol, image;
  double amount;
  int isActive;

  WalletBalance(this.code, this.amount, this.symbol, this.image, this.isActive);

  factory WalletBalance.fromJson(dynamic json) {
    return WalletBalance(
      json['code'] ?? '',
      double.tryParse(json['amount'].toString()) ?? 0,
      json['symbol'] ?? '',
      json['image'] ?? '',
      json['is_active'] ?? 0,
    );
  }
}
