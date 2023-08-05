// https://javiercbk.github.io/json_to_dart/
class UserModel {
  String? uid;
  String? username;
  String? apiKey;

  UserModel({this.uid, this.username, this.apiKey});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    apiKey = json['apiKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['username'] = this.username;
    data['apiKey'] = this.apiKey;
    return data;
  }
}
