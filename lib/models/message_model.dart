import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

MsgData MsgDataFromJson(String str) => MsgData.fromJson(json.decode(str));

String MsgDataToJson(MsgData data) => json.encode(data.toJson());

class MsgData {
  Timestamp sent;
  List printed;
  int status;
  String body;
  String type;
  String from;
  List forwarded;
  String url;
  String id;

  MsgData({
    @required this.sent,
    @required this.printed,
    @required this.status,
    @required this.forwarded,
    @required this.body,
    @required this.type,
    @required this.url,
    @required this.from,
    @required this.id,
  });

  factory MsgData.fromJson(Map<String, dynamic> json) => MsgData(
        sent: json["sent"],
        printed: json["printed"],
        status: json["status"],
        body: json["body"],
        type: json["type"],
        url: json["url"],
        from: json["from"],
        id: json["id"],
        forwarded: json["forwarded"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sent": sent,
        "printed": printed,
        "status": status,
        "body": body,
        "type": type,
        "url": url,
        "from": from,
        "forwarded": forwarded,
      };
}
