import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/counterState.dart';
import 'package:path/path.dart';
import 'package:prive/size_config.dart';
import 'package:prive/widgets/conversation.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String conversation;
  final function;
  final owner;
  const ChatRoom(
      {Key key, @required this.conversation, this.function, this.owner});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController text = new TextEditingController();
  StreamSubscription streamSubscription;
  List messages = [];
  String contact = "";
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

  // delete(String conv, String cont) async {
  //   await _firestore.collection("${controller.user.org}").doc('prive').update({
  //     "users": FieldValue.arrayRemove([cont])
  //   });
  //   await _firestore.collection("${controller.user.org}").doc('$conv').delete();
  // }

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
      if (snapshots.data() != null) {
        if (messages != snapshots.data()['messages']) {
          setState(() {
            messages = snapshots.data()['messages'].map((msg) {
              if (msg['status'] == 0 && msg['from'] != controller.user.name)
                msg['status'] = 1;
              return msg;
            }).toList();
          });
        }
        await _firestore
            .collection("${controller.user.org}")
            .doc('${widget.conversation}')
            .update({"messages": messages});
      } else {
        await _firestore
            .collection("${controller.user.org}")
            .doc('${widget.conversation}')
            .set({"messages": []});
      }
    });
  }

  Future<void> _pickImage() async {
    final selected = await ImagePicker().pickImage(
      imageQuality: 80,
      source: ImageSource.camera,
    );
    if (selected != null) {
      print(await selected.length());
      uploadFile(File(selected.path), "");
      // ImageProperties prop =
      //     await FlutterNativeImage.getImageProperties(selected.path);
      // widget.func(File(selected.path));
      // setState(() {
      //   image = (File(selected.path));
      //   imageH = prop.height;
      //   imageW = prop.width;
      // });
    } else {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text("No Image Selected",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
      Get.back();
    }
  }

  Controller controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: MyTheme.kPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            height: getHeight(100),
            padding: EdgeInsets.symmetric(
                vertical: getHeight(7), horizontal: getWidth(20)),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => {Get.back()},
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                    size: getText(20),
                  ),
                ),
                Text(
                  contact[0].toUpperCase() + contact.substring(1),
                  style: GoogleFonts.montserrat(
                      fontSize: getText(28),
                      letterSpacing: getText(4),
                      color: Colors.white),
                ),
                widget.function != null
                    ? GestureDetector(
                        onTap: () {
                          Get.back();
                          widget.function(contact);
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: getText(25),
                        ),
                      )
                    : SizedBox(
                        width: getWidth(20),
                      )
              ],
            )),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
              child: messages != null
                  ? Conversation(
                      conversation: widget.conversation,
                      messages: List.from(messages.reversed),
                      owner: widget.owner)
                  : Container(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                bottom: getHeight(20), left: getWidth(20), right: getWidth(20)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: getWidth(14)),
                    height: getHeight(60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(getText(30)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type your message ...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: Icon(
                            Icons.camera_enhance,
                            color: Colors.grey[500],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () {
                    if (text.text != "") {
                      Map msg;
                      msg = {
                        "body": text.text,
                        "sent": Timestamp.now(),
                        "type": "txt",
                        "from": controller.user.name
                      };
                      setState(() {
                        messages.add(msg);
                        text.clear();
                      });
                      msg["status"] = 0;
                      send(msg);
                    }
                  },
                  child: CircleAvatar(
                    radius: getWidth(30),
                    backgroundColor: MyTheme.kAccentColor,
                    child: Container(
                      padding: EdgeInsets.only(left: getWidth(4)),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future uploadFile(File file, String text) async {
    Map msg;
    msg = {
      "sent": Timestamp.now(),
      "type": "file",
      "body": text,
      "from": controller.user.name
    };
    setState(() {
      messages.add(msg);
    });
    if (file == null) return;
    final fileName = basename(file.path);
    final destination =
        'files/${controller.user.org}/${widget.conversation}/$fileName';
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final snapshot = await ref.putFile(file).whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      msg = {
        "status": 0,
        "url": urlDownload,
        if (text != null) "body": text,
        "sent": Timestamp.now(),
        "type": "file",
        "from": controller.user.name
      };
      send(msg);
    } on FirebaseException catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text(e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }

  Future send(Map msg) async {
    try {
      _firestore
          .collection("${controller.user.org}")
          .doc('${widget.conversation}')
          .update({
        "messages": FieldValue.arrayUnion([msg])
      });
    } on FirebaseException catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text(e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }
}
