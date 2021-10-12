import 'dart:convert';

UserData UserDataFromJson(String str) => UserData.fromJson(json.decode(str));

String UserDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  String fcmToken;
  String publicKey;
  String name;
  String id;
  String pin;

  UserData({
    this.publicKey,
    this.fcmToken,
    this.name,
    this.id,
    this.pin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        publicKey: json["publicKey"],
        fcmToken: json["fcmToken"],
        name: json["name"],
        id: json["id"],
        pin: json["pin"],
      );

  Map<String, dynamic> toJson() => {
        "publicKey": publicKey,
        "fcmToken": fcmToken,
        "name": name,
        "id": id,
        "pin": pin,
      };
}

class User {
  String org;
  String privateKey;
  String id;
  String pin;
  String name;

  User({
    this.org,
    this.pin,
    this.name,
    this.id,
    this.privateKey,
  });
}
