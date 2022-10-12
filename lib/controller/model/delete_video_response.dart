class DeleteVideoResponse {
  bool? status;
  List<String>? data;
  String? message;
  bool? error;

  DeleteVideoResponse({this.status, this.data, this.message, this.error});

  DeleteVideoResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'].cast<String>();
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['data'] = this.data;
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}
