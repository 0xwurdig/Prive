import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:prive/counterState.dart';
import 'package:intl/intl.dart';
import 'package:prive/screens/forwardScreen.dart';
import 'package:prive/screens/home_page.dart';
import 'package:prive/size_config.dart';
import 'package:prive/widgets/sildeToConfirm.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Conversation extends StatefulWidget {
  const Conversation({
    Key key,
    this.conversation,
    this.owner,
    @required this.messages,
  }) : super(key: key);
  final List messages;
  final String conversation;
  final bool owner;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  TextEditingController pin = new TextEditingController();
  String current = DateFormat.MMMEd().format(DateTime.now());
  Controller controller = Get.find();
  bool forward = false;
  List forwardList = [];
  int range = 20;
  void loadMore() {
    setState(() {
      range + 20 <= widget.messages.length
          ? range = range + 20
          : range = widget.messages.length;
    });
  }

  infoPrint(List<String> url) async {
    if (!widget.owner) {
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.symmetric(vertical: getHeight(20)),
          height: widget.owner ? getHeight(120) : getHeight(300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getText(20)),
                topRight: Radius.circular(getText(20))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: getWidth(300)),
                child: Text(
                  "Enter Pin",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: getText(24)),
                ),
              ),
              ninput("Pin", pin, true),
              ConfirmationSlider(
                height: getHeight(70),
                backgroundShape: BorderRadius.circular(getText(10)),
                width: getWidth(260),
                foregroundColor: MyTheme.kPrimaryColor,
                foregroundShape: BorderRadius.circular(getText(10)),
                text: "PRINT",
                textStyle: TextStyle(fontSize: getText(20)),
                onConfirmation: () async {
                  if (pin.text == controller.user.pin || widget.owner) {
                    try {
                      final FirebaseFirestore _firestore =
                          FirebaseFirestore.instance;
                      await _firestore
                          .collection(controller.user.org)
                          .doc('prive')
                          .get()
                          .then((doc) {
                        if (doc.data()['auth'].toString() == pin.text) {
                          int ran = Random().nextInt(900000) + 100000;
                          _firestore
                              .collection(controller.user.org)
                              .doc('prive')
                              .update({"auth": ran});
                        } else {
                          Get.rawSnackbar(
                              snackPosition: SnackPosition.TOP,
                              messageText: Text("Error! Incorrect Pin",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white)));
                        }
                      });
                      Get.back();
                      final doc = pw.Document();
                      url.forEach((element) async {
                        final img =
                            await flutterImageProvider(NetworkImage(element));
                        doc.addPage(pw.Page(build: (pw.Context context) {
                          return pw.Center(
                            child: pw.Image(img),
                          ); // Center
                        }));
                      });
                      await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => doc.save());
                      // final pdf = pw.Document();
                      // final img = await http.get(Uri.parse(url));
                      // pdf.addPage(pw.Page(build: (pw.Context context) {
                      //   return pw.Center(
                      //     child: pw.Image(pw.MemoryImage(img.bodyBytes)),
                      //   ); // Center
                      // })); // Page

                    } catch (e) {
                      Get.rawSnackbar(
                          snackPosition: SnackPosition.TOP,
                          messageText: Text("Error! Please Try Again",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)));
                    }
                  } else {
                    Get.rawSnackbar(
                        snackPosition: SnackPosition.TOP,
                        messageText: Text("Error! Wrong Pin",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)));
                  }
                },
              )
            ],
          ),
        ),
      );
    } else {
      final doc = pw.Document();
      url.forEach((element) async {
        final img = await flutterImageProvider(NetworkImage(element));
        doc.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(img),
          ); // Center
        }));
      });
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              loadMore();
              return true;
            }
            return false;
          },
          child: ListView.builder(
              reverse: true,
              itemCount:
                  widget.messages.length > 20 ? range : widget.messages.length,
              itemBuilder: (context, int index) {
                final message = widget.messages[index];
                bool isMe = message['from'] == controller.user.name;
                bool date = DateFormat.MMMEd().format(
                        DateTime.parse(message['sent'].toDate().toString())) ==
                    current;
                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      forward = true;
                      forwardList.add(message);
                    });
                  },
                  onTap: () {
                    forward
                        ? setState(() {
                            !forwardList.contains(message)
                                ? forwardList.add(message)
                                : forwardList.remove(message);
                            if (forwardList.length == 0) forward = false;
                          })
                        : FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    color: forward && forwardList.contains(message)
                        ? Colors.blue[100].withOpacity(0.4)
                        : Colors.transparent,
                    child: Container(
                      margin: EdgeInsets.only(top: getHeight(10)),
                      child: Column(
                        children: [
                          if (!date)
                            Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    height: getHeight(30),
                                    width: getWidth(120),
                                    decoration: BoxDecoration(
                                        color: MyTheme.kAccentColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(current.toString())))),
                          Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: getWidth(10),
                              ),
                              Container(
                                padding: EdgeInsets.all(getWidth(10)),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: BoxDecoration(
                                    color: isMe
                                        ? MyTheme.kAccentColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(getText(16)),
                                      topRight: Radius.circular(getText(16)),
                                      bottomLeft: Radius.circular(
                                          isMe ? getText(12) : 0),
                                      bottomRight: Radius.circular(
                                          isMe ? 0 : getText(12)),
                                    )),
                                child: message["type"] == "txt"
                                    ? SelectableText(
                                        message['body'],
                                        style: MyTheme.bodyTextMessage.copyWith(
                                            fontSize: getText(16),
                                            color: isMe
                                                ? Colors.white
                                                : Colors.grey[800]),
                                      )
                                    : message["status"] == null
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
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
                                          )
                                        : GestureDetector(
                                            // onLongPress: () {
                                            //   infoPrint(message['url']);
                                            // },
                                            onTap: () {
                                              forward
                                                  ? setState(() {
                                                      !forwardList
                                                              .contains(message)
                                                          ? forwardList
                                                              .add(message)
                                                          : forwardList
                                                              .remove(message);
                                                      if (forwardList.length ==
                                                          0) forward = false;
                                                    })
                                                  : Get.to(() => View(
                                                        url: message['url'],
                                                      ));
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.all(getWidth(5)),
                                              child: Column(
                                                  crossAxisAlignment: isMe
                                                      ? CrossAxisAlignment.end
                                                      : CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxHeight:
                                                                  getHeight(
                                                                      150)),
                                                      child: Image.network(
                                                        message["url"],
                                                        fit: BoxFit.scaleDown,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Container(
                                                            height: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3),
                                                            width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.5),
                                                            child: Center(
                                                              child: SizedBox(
                                                                height:
                                                                    getText(40),
                                                                width:
                                                                    getText(40),
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    if (message['body'] != "")
                                                      SizedBox(
                                                        height: getHeight(10),
                                                      ),
                                                    if (message['body'] != "")
                                                      Text(
                                                        message['body'],
                                                        style: MyTheme
                                                            .bodyTextMessage
                                                            .copyWith(
                                                                fontSize:
                                                                    getText(16),
                                                                color: isMe
                                                                    ? Colors
                                                                        .white
                                                                    : Colors.grey[
                                                                        800]),
                                                      )
                                                  ]),
                                            ),
                                          ),
                              ),
                            ],
                          ),
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
                                              color: Colors.blue,
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
                    ),
                  ),
                );
              })),
      if (forward)
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: getHeight(10)),
            width: getWidth(200),
            height: getWidth(50),
            decoration: BoxDecoration(
                color: MyTheme.kAccentColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => ForwardScreen(
                          conversation: widget.conversation,
                          messages: forwardList,
                        )).then((value) => setState(() {
                          forwardList.clear();
                          forward = false;
                        }));
                  },
                  child: Container(
                    child: Text("Forward",
                        style: MyTheme.bodyTextMessage.copyWith(
                            fontSize: getText(16), color: Colors.black)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    List<String> urls = [];
                    forwardList.forEach((element) {
                      urls.add(element["url"]);
                    });
                    urls.contains(null)
                        ? Get.rawSnackbar(
                            snackPosition: SnackPosition.TOP,
                            messageText: Text(
                                "Error! Only images can be printed",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white)))
                        : infoPrint(urls);
                  },
                  child: Container(
                    child: Text("Print",
                        style: MyTheme.bodyTextMessage.copyWith(
                            fontSize: getText(16), color: Colors.black)),
                  ),
                )
                // Container(child: Text("Print"))
              ],
            ),
          ),
        ),
    ]);
  }
}

class View extends StatelessWidget {
  const View({this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: PhotoView(
        initialScale: PhotoViewComputedScale.contained * 0.8,
        minScale: PhotoViewComputedScale.contained,
        imageProvider: NetworkImage(url),
      )),
    );
  }
}
