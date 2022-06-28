class PaymentHistoryModel{
  int id, transactionId;
  String currency, userPaymentAddress, transactionStatus, createDate;
  double commissionFeeAmount, amount;

  PaymentHistoryModel(
      {required this.id,
      required this.transactionId,
      required this.currency,
      required this.userPaymentAddress,
      required this.transactionStatus,
      required this.createDate,
      required this.commissionFeeAmount,
      required this.amount});

  factory PaymentHistoryModel.fromJson(dynamic json) {
    return PaymentHistoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      transactionId: int.tryParse(json['transaction_id'].toString()) ?? 0,
      currency: json['currency'] ?? '',
      userPaymentAddress: json['payment_address_user'] ?? '',
      transactionStatus: json['transaction_status'] ?? '',
      createDate: json['created_at'] ?? '',
      commissionFeeAmount: double.tryParse(json['commission_fee_amount']) ?? 0.0,
      amount: double.tryParse(json['amount']) ?? 0.0
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['currency'] = currency;
    data['payment_address_user'] = userPaymentAddress;
    data['transaction_status'] = transactionStatus;
    data['created_at'] = createDate;
    data['commission_fee_amount'] = commissionFeeAmount;
    data['amount'] = amount;
    return data;
  }
}