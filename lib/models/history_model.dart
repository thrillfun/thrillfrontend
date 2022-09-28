class PaymentHistoryModel {
  int id;
  String currency,
      userPaymentAddress,
      transactionStatus,
      createDate,
      transaction_id;
  double commissionFeeAmount, amount;

  PaymentHistoryModel(
      {required this.id,
      required this.currency,
      required this.userPaymentAddress,
      required this.transactionStatus,
      required this.createDate,
      required this.transaction_id,
      required this.commissionFeeAmount,
      required this.amount});

  factory PaymentHistoryModel.fromJson(dynamic json) {
    return PaymentHistoryModel(
        id: json['id'] ?? 0,
        currency: json['currency'] ?? '',
        userPaymentAddress: json['payment_address_user'] ?? '',
        transactionStatus: json['transaction_status'] ?? '',
        createDate: json['created_at'] ?? '',
        transaction_id: json['transaction_id'] ?? '',
        commissionFeeAmount: (json['commission_fee_amount'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble());
  }
}
