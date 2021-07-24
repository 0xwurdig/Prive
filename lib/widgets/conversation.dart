import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:prive/counterState.dart';
import 'package:intl/intl.dart';
import 'package:prive/size_config.dart';

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
          return true;
        }
        return false;
      },
      child: ListView.builder(
          reverse: true,
          itemCount: widget.messages.length,
          itemBuilder: (context, int index) {
            final message = widget.messages[index];
            bool isMe = message['from'] == controller.user.name;
            return Container(
              margin: EdgeInsets.only(top: getHeight(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: getWidth(10),
                      ),
                      Container(
                        padding: EdgeInsets.all(getWidth(10)),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                            color:
                                isMe ? MyTheme.kAccentColor : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(getText(16)),
                              topRight: Radius.circular(getText(16)),
                              bottomLeft:
                                  Radius.circular(isMe ? getText(12) : 0),
                              bottomRight:
                                  Radius.circular(isMe ? 0 : getText(12)),
                            )),
                        child: message["type"] == "txt"
                            ? Text(
                                message['body'],
                                style: MyTheme.bodyTextMessage.copyWith(
                                    fontSize: getText(16),
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
                                        height: getText(40),
                                        width: getText(40),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Get.to(() => View(
                                            url: message['url'],
                                          ));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(getWidth(5)),
                                      child: Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Image.network(
                                              message["url"],
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  height:
                                                      (MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.3),
                                                  width: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5),
                                                  child: Center(
                                                    child: SizedBox(
                                                      height: getText(40),
                                                      width: getText(40),
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (message['body'] != "")
                                              SizedBox(
                                                height: getHeight(10),
                                              ),
                                            if (message['body'] != "")
                                              Text(
                                                message['body'],
                                                style: MyTheme.bodyTextMessage
                                                    .copyWith(
                                                        fontSize: getText(16),
                                                        color: isMe
                                                            ? Colors.white
                                                            : Colors.grey[800]),
                                              )
                                          ]),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                  if (index == 0)
                    Padding(
                      padding: EdgeInsets.only(top: getHeight(5)),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            SizedBox(
                              width: getWidth(10),
                            ),
                          if (isMe)
                            message['status'] == null
                                ? Icon(
                                    Icons.lock_clock,
                                    size: getText(20),
                                    color: MyTheme.bodyTextTime.color,
                                  )
                                : message['status'] == 1
                                    ? Icon(
                                        Icons.done_all,
                                        size: getText(20),
                                        color: MyTheme.bodyTextTime.color,
                                      )
                                    : Icon(
                                        Icons.done,
                                        size: getText(20),
                                        color: MyTheme.bodyTextTime.color,
                                      ),
                          SizedBox(
                            width: getWidth(8),
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
