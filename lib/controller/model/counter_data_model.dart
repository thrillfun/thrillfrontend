class CounterDataModel {
  bool? status;
  List<CounterData>? data;
  String? message;
  bool? error;

  CounterDataModel({this.status, this.data, this.message, this.error});

  CounterDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CounterData>[];
      json['data'].forEach((v) {
        data!.add(new CounterData.fromJson(v));
      });
    }
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class CounterData {
  num? id;
  num? probabilityCounter;
  num? probability;

  CounterData({this.id, this.probabilityCounter, this.probability});

  CounterData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    probabilityCounter = json['probability_counter'];
    probability = json["probability"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['probability_counter'] = this.probabilityCounter;
    data["probability"] = this.probability;
    return data;
  }
}
