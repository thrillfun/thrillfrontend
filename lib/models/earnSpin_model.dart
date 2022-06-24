class EarnSpin {
  String name, current_level, next_level, conditions;
  String earned_spins, total_spin;

  EarnSpin(this.name, this.current_level, this.next_level, this.conditions,
      this.earned_spins, this.total_spin);

  factory EarnSpin.fromJson(dynamic json) {
    return EarnSpin(
        json['name'] ?? '',
        json['current_level'] ?? '',
        json['next_level'] ?? '',
        json['conditions'] ?? '',
        json['earned_spins'] ?? '',
        json['total_spin'] ?? '');
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['name'] = name;
    data['current_level'] = current_level;
    data['next_level'] = next_level;
    data['conditions'] = conditions;
    data['earned_spins'] = earned_spins;
    data['total_spin'] = earned_spins;

    return data;
  }
}
