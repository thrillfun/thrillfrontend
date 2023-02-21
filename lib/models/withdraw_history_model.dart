class WithdrawModel {
  bool? status;
  String? message;
  bool? error;
  List<Data>? data;

  WithdrawModel({this.status, this.message, this.error, this.data});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    error = json['error'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['error'] = this.error;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? currency;
  String? paymentAddressUser;
  int? commissionFeeAmount;
  int? amount;
  String? transactionStatus;
  String? from;
  String? transactionType;
  String? transactionId;
  String? description;
  String? createdAt;

  Data(
      {this.id,
      this.currency,
      this.paymentAddressUser,
      this.commissionFeeAmount,
      this.amount,
      this.transactionStatus,
      this.from,
      this.transactionType,
      this.transactionId,
      this.description,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    paymentAddressUser = json['payment_address_user'];
    commissionFeeAmount = json['commission_fee_amount'];
    amount = json['amount'];
    transactionStatus = json['transaction_status'];
    from = json['from'];
    transactionType = json['transaction_type'];
    transactionId = json['transaction_id'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['payment_address_user'] = this.paymentAddressUser;
    data['commission_fee_amount'] = this.commissionFeeAmount;
    data['amount'] = this.amount;
    data['transaction_status'] = this.transactionStatus;
    data['from'] = this.from;
    data['transaction_type'] = this.transactionType;
    data['transaction_id'] = this.transactionId;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    return data;
  }
}
