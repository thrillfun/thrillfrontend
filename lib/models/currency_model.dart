class CurrencyModel{
  int id,isActive;
  String code,symbol,image;
  List<Networks> networks;

  CurrencyModel(this.id, this.isActive, this.code, this.symbol, this.image,this.networks);

  factory CurrencyModel.fromJson(dynamic json) {
    List<Networks> networkList=List<Networks>.empty(growable: true);

    List jsonList= json['networks'] as List;
    networkList = jsonList.map((e) => Networks.fromJson(e)).toList();

    return CurrencyModel(
        json['id']?? 0,
        json['is_active'] ?? 0,
        json['code'] ?? '',
        json['symbol'] ?? '',
        json['image'] ?? '',
        networkList
    );
  }

}

class Networks {
  int id,currencyId;
  String networkName;
  double minAmount,maxAmount,feeDigit;

  Networks(this.id,
      this.currencyId,
      this.networkName,
      this.minAmount,this.maxAmount,this.feeDigit
      );

  factory Networks.fromJson(dynamic json) {

    return Networks(
       json['id'] ?? 0,
       json['currency_id'] ?? 0.toDouble(),
       json['network_name'] ?? "",
       double.tryParse(json['min_amount'].toString())??0.0,
       double.tryParse(json['max_amount'].toString())??0.0,
        double.tryParse(json['fee_digit'].toString())??0.0,
    );
  }
}
