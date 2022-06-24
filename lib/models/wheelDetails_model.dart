import 'package:thrill/models/recent_rewards.dart';
import 'package:thrill/models/wheel_rewards.dart';

class WheelDetails{
String available_chance,used_chance;
List<WheelRewards> wheelRewards;
List<RecentRewards> recentRewards;

WheelDetails(this.used_chance,this.available_chance,this.wheelRewards,this.recentRewards);

factory WheelDetails.fromJson(dynamic json) {
  List<WheelRewards> rewards=List<WheelRewards>.empty(growable: true);
  List jsonList= json['wheel_rewards'] as List;
  rewards = jsonList.map((e) => WheelRewards.fromJson(e)).toList();

  List<RecentRewards> recentRewards=List<RecentRewards>.empty(growable: true);
  List jsonRecentList= json['recent_rewards'] as List;
  recentRewards = jsonRecentList.map((e) => RecentRewards.fromJson(e)).toList();

  return WheelDetails(
      json['used_chance'] ?? '',
      json['available_chance'] ?? '',
      rewards,
      recentRewards);
}
}