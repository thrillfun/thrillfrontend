class RecentRewards{
String username,currency,currency_symbol;
int amount;

RecentRewards(
      this.username, this.currency, this.currency_symbol, this.amount);

factory RecentRewards.fromJson(dynamic json) {

  return RecentRewards(
      json['username'] ?? '',
      json['currency'] ?? '',
      json['currency_symbol'] ?? '',
      json['amount'] ?? 0);
}
}
