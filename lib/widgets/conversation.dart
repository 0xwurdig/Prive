import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:prive/counterState.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  const Conversation({
    Key key,
    @required this.messages,
  }) : super(key: key);
  final List messages;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  Controller controller = Get.find();
  int range = 20;
  void loadMore() {
    setState(() {
      range = range + 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          loadMore();
        }
      },
      child: ListView.builder(
          reverse: true,
          itemCount: widget.messages.length,
          itemBuilder: (context, int index) {
            final message = widget.messages[index];
            bool isMe = message['from'] == controller.user.name;
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                            color:
                                isMe ? MyTheme.kAccentColor : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            )),
                        child: message["type"] == "txt"
                            ? Text(
                                message['body'],
                                style: MyTheme.bodyTextMessage.copyWith(
                                    color:
                                        isMe ? Colors.white : Colors.grey[800]),
                              )
                            : message["status"] == null
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Center(
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Get.to(() => View(
                                            url: message['body'],
                                          ));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Image.network(message["body"]),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          SizedBox(
                            width: 10,
                          ),
                        if (isMe)
                          message['status'] == null
                              ? Icon(
                                  Icons.lock_clock,
                                  size: 20,
                                  color: MyTheme.bodyTextTime.color,
                                )
                              : message['status'] == 1
                                  ? Icon(
                                      Icons.done_all,
                                      size: 20,
                                      color: MyTheme.bodyTextTime.color,
                                    )
                                  : Icon(
                                      Icons.done,
                                      size: 20,
                                      color: MyTheme.bodyTextTime.color,
                                    ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          DateFormat.Hm().format(DateTime.parse(
                              message['sent'].toDate().toString())),
                          style: MyTheme.bodyTextTime,
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class View extends StatelessWidget {
  const View({this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(url),
    ));
  }
}
