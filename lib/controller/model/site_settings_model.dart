class SiteSettingsModel {
  bool? status;
  bool? error;
  String? message;
  List<SiteSettings>? data;

  SiteSettingsModel({this.status, this.error, this.message, this.data});

  SiteSettingsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SiteSettings>[];
      json['data'].forEach((v) {
        data!.add(new SiteSettings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SiteSettings {
  String? name;
  dynamic? value;

  SiteSettings({this.name, this.value});

  SiteSettings.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}
