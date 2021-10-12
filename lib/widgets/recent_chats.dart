import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/models/message_model.dart';
import 'package:prive/screens/chat_room.dart';
import 'package:prive/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../app_theme.dart';

class RecentChats extends StatefulWidget {
  final String conversation;
  final function;
  final bool owner;
  const RecentChats({@required this.conversation, this.function, this.owner});

  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Controller controller = Get.find();
  String contact = '';
  String unreadCount;
  MsgData message;
  bool loading;
  Color col = Colors.white;
  StreamSubscription streamSubscription;

  @override
  void initState() {
    unReads();
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  String getConversationId(String a, String b) {
    List<int> ac = a.codeUnits;
    List<int> bc = b.codeUnits;
    List<int> qwe = [];
    for (int i = 0; i < ac.length; i++) {
      qwe.add(((ac[i] + bc[i]) / 2).round());
    }
    return String.fromCharCodes(qwe);
  }

  unReads() async {
    String conv = getConversationId(widget.conversation, controller.user.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    streamSubscription = _firestore
        .collection("${controller.user.org}")
        .doc("data")
        .collection('conversations')
        .doc(conv)
        .collection("messages")
        .orderBy("sent")
        .snapshots()
        .listen((snapshots) async {
      if (snapshots.docChanges.length != 0 &&
          message !=
              MsgData.fromJson(snapshots
                  .docChanges[snapshots.docChanges.length - 1].doc
                  .data())) {
        int c = 0;
        snapshots.docChanges.forEach((msg) {
          msg.doc.data()['status'] == 0 &&
                  msg.doc.data()['from'] != controller.user.id
              ? c = c + 1
              : c = c;
        });
        await _firestore
            .collection("${controller.user.org}")
            .doc("data")
            .collection('users')
            .doc(widget.conversation)
            .get()
            .then((value) {
          setState(() {
            unreadCount = c.toString();
            message = MsgData.fromJson(snapshots
                .docChanges[snapshots.docChanges.length - 1].doc
                .data());
            loading = false;
            contact = value.data()["name"];
            prefs.setString(widget.conversation, contact);
          });
        });
      } else {
        try {
          await _firestore
              .collection("${controller.user.org}")
              .doc("data")
              .collection('users')
              .doc(widget.conversation)
              .get()
              .then((value) {
            print(value.data());
            setState(() {
              message = null;
              contact = value["name"];
              prefs.setString(widget.conversation, contact);
            });
          });
        } catch (e) {
          print(e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(contact);
    if (widget.conversation != null && contact != "") {
      // String contact = widget.conversation.split('-')[0] == controller.user.id
      //     ? widget.conversation.split('-')[1]
      //     : widget.conversation.split('-')[0];
      return GestureDetector(
        onLongPress: () {
          if (widget.function != null) widget.function(widget.conversation);
        },
        onTap: () {
          Get.to(() => ChatRoom(
                name: contact,
                owner: widget.owner,
                conversation: widget.conversation,
                function: widget.function,
              ));
        },
        child: Container(
            color: col,
            margin: EdgeInsets.symmetric(
                horizontal: getWidth(15), vertical: getHeight(15)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: getText(30),
                  // foregroundColor: Colors.white,
                  // backgroundColor: MyTheme.kAccentColorVariant,
                  child: Text(
                    contact[0].toUpperCase(),
                  ),
                ),
                SizedBox(
                  width: getWidth(20),
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
                            fontSize: getText(16),
                          ),
                        ),
                        if (message != null)
                          Container(
                            width: getWidth(150),
                            child: Text(
                              message.type == 'txt' ? message.body : "Photo",
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
                                horizontal: getWidth(8),
                                vertical: getHeight(2)),
                            decoration: BoxDecoration(
                                color: MyTheme.kUnreadChatBG,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(getText(6)))),
                            child: Text(
                              unreadCount,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getText(11),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : SizedBox(
                            height: getHeight(10),
                          ),
                    SizedBox(
                      height: getHeight(10),
                    ),
                    if (message != null)
                      Text(
                        DateFormat.Hm().format((message.sent).toDate()),
                        style: MyTheme.bodyTextTime,
                      )
                  ],
                ),
              ],
            )),
      );
    } else {
      return Container(
        width: getWidth(200),
        height: getHeight(100),
        child: Container(
          margin: EdgeInsets.all(getWidth(15)),
          child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: getText(30),
                    // foregroundColor: Colors.white,
                    // backgroundColor: MyTheme.kAccentColorVariant,
                  ),
                  SizedBox(
                    width: getWidth(20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: getWidth(150),
                        height: getHeight(20),
                        color: Colors.amber,
                      ),
                      Container(
                        width: getWidth(240),
                        height: getHeight(20),
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
