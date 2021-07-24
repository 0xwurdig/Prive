import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/screens/chat_room.dart';
import 'package:shimmer/shimmer.dart';

import '../app_theme.dart';

class RecentChats extends StatefulWidget {
  final String conversation;
  final function;
  const RecentChats({@required this.conversation, this.function});

  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Controller controller = Get.find();
  String contact;
  String unreadCount;
  Map message;
  bool loading;
  Color col = Colors.white;
  StreamSubscription streamSubscription;

  @override
  void initState() {
    setState(() {
      contact = widget.conversation.split('-')[0] == controller.user.name
          ? widget.conversation.split('-')[01]
          : widget.conversation.split('-')[0];
    });
    unReads();
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  unReads() async {
    streamSubscription = _firestore
        .collection("${controller.user.org}")
        .doc('${widget.conversation}')
        .snapshots()
        .listen((snapshots) async {
      if (snapshots.data() == null) {
        await _firestore
            .collection("${controller.user.org}")
            .doc('${widget.conversation}')
            .set({"messages": []});
      } else {
        if (snapshots.data()['messages'].length != 0 &&
            message !=
                snapshots.data()['messages']
                    [snapshots.data()['messages'].length - 1]) {
          int c = 0;
          snapshots.data()['messages'].forEach((msg) {
            msg['status'] == 0 && msg['from'] != controller.user.name
                ? c = c + 1
                : c = c;
          });
          setState(() {
            unreadCount = c.toString();
            message = snapshots.data()['messages']
                [snapshots.data()['messages'].length - 1];
            loading = false;
          });
        } else {
          message = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (contact != null) {
      return GestureDetector(
        onLongPress: () {
          widget.function(contact);
        },
        onTap: () {
          Get.to(() => ChatRoom(conversation: widget.conversation));
        },
        child: Container(
            color: col,
            margin: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  // foregroundColor: Colors.white,
                  // backgroundColor: MyTheme.kAccentColorVariant,
                  child: Text(
                    contact[0].toUpperCase(),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          contact[0].toUpperCase() + contact.substring(1),
                          style: MyTheme.heading2.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        if (message != null)
                          Container(
                            width: 150,
                            child: Text(
                              message['type'] == 'txt'
                                  ? message['body']
                                  : "Photo",
                              style: MyTheme.bodyText1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    unreadCount != null && unreadCount != '0'
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: MyTheme.kUnreadChatBG,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            child: Text(
                              unreadCount,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : SizedBox(
                            height: 10,
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    if (message != null)
                      Text(
                        DateFormat.Hm().format(DateTime.parse(
                            message['sent'].toDate().toString())),
                        style: MyTheme.bodyTextTime,
                      )
                  ],
                ),
              ],
            )),
      );
    } else {
      return Container(
        width: 200.0,
        height: 100.0,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    // foregroundColor: Colors.white,
                    // backgroundColor: MyTheme.kAccentColorVariant,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.amber,
                      ),
                      Container(
                        width: 240,
                        height: 20,
                        color: Colors.amber,
                      )
                    ],
                  ),
                ],
              )),
        ),
      );
    }
  }
}
