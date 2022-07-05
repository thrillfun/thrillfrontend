class ProbilityCounter{
  int id,probability_counter;

  ProbilityCounter(this.id, this.probability_counter);

  factory ProbilityCounter.fromJson(dynamic json) {
    return ProbilityCounter(
        json['id'] ?? 0,
        json['probability_counter'] ?? 0,
    );
  }

}