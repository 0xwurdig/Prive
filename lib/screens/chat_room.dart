import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ntp/ntp.dart';
import 'package:prive/counterState.dart';
import 'package:path/path.dart';
import 'package:prive/models/message_model.dart';
import 'package:prive/size_config.dart';
import 'package:prive/widgets/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String conversation;
  final function;
  final owner;
  final name;
  const ChatRoom(
      {Key key,
      @required this.conversation,
      this.function,
      @required this.owner,
      @required this.name});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController text = new TextEditingController();
  StreamSubscription streamSubscription;
  Map messages = new Map();
  List<MsgData> unsent = [];
  String contact;
  String conv = "";
  @override
  void initState() {
    setState(() {
      conv = getConversationId(widget.conversation, controller.user.id);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List conv = [widget.conversation, controller.user.id];
    try {
      String conv = getConversationId(widget.conversation, controller.user.id);
      _firestore
          .collection("${controller.user.org}")
          .doc("data")
          .collection("conversations")
          .doc(conv)
          .collection("messages")
          .get()
          .then((value) {
        if (value.docs.length == 0) {
          setState(() {
            contact = prefs.getString(widget.conversation);
            messages = {};
          });
        } else {
          String conv =
              getConversationId(widget.conversation, controller.user.id);
          streamSubscription = _firestore
              .collection("${controller.user.org}")
              .doc("data")
              .collection("conversations")
              .doc(conv)
              .collection("messages")
              .orderBy("sent")
              .snapshots()
              .listen((snapshots) async {
            snapshots.docChanges.forEach((docChange) async {
              if (docChange.doc.data()['status'] == 0 &&
                  docChange.doc.data()['from'] != controller.user.id) {
                await docChange.doc.reference.update({'status': 1});
              }
              MsgData msg = MsgData.fromJson(docChange.doc.data());
              setState(() {
                contact = prefs.getString(widget.conversation);
                unsent.clear();
                docChange.type == DocumentChangeType.removed
                    ? messages.remove(docChange.doc.id)
                    : messages[docChange.doc.id] = msg;
              });
            });
            // await _firestore
            //     .collection("${controller.user.org}")
            //     .doc("data")
            //     .collection("conversations")
            //     .doc(getConversationId(widget.conversation, controller.user.id))
            //     .collection("messages")
            //     .where({"status"}, isEqualTo: 0)
            //     .where({"from"}, isNotEqualTo: controller.user.id)
            //     .get()
            //     .then((snapshots) => snapshots.docChanges.forEach((doc) {
            //           doc.doc.reference.update({"status": 0});
            //         }));
          });
        }
      });
    } catch (e) {
      Get.back();
    }
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
                  contact != null
                      ? contact[0].toUpperCase() + contact.substring(1)
                      : "",
                  // contact[0].toUpperCase() + contact.substring(1),
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
              child: messages != {} || messages != null
                  ? Conversation(
                      conversation: widget.conversation,
                      messages:
                          messages.values.map<MsgData>((e) => e).toList() +
                              unsent,
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
                  onTap: () async {
                    if (text.text != "") {
                      MsgData msg = MsgData(
                          body: text.text,
                          from: controller.user.id,
                          sent: Timestamp.fromDate(await NTP.now()),
                          type: "txt",
                          id: "",
                          printed: [],
                          url: "",
                          status: null,
                          forwarded: [widget.conversation]);
                      // msg = {
                      //   "id": "",
                      //   "url": "",
                      //   "body": text.text,
                      //   "sent": FieldValue.serverTimestamp(),
                      //   "type": "txt",
                      //   "from": controller.user.id,
                      //   "printed": [],
                      //   "status": null,

                      // };
                      setState(() {
                        unsent.add(msg);
                        text.clear();
                      });
                      msg.status = 0;
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
    MsgData msg = MsgData(
        body: text,
        from: controller.user.id,
        sent: Timestamp.fromDate(await NTP.now()),
        type: "file",
        id: "",
        printed: [],
        url: "",
        status: null,
        forwarded: [widget.conversation]);
    // msg = {
    //   "sent": Timestamp.now(),
    //   "type": "file",
    //   "body": text,
    //   "from": controller.user.id,
    //   "id":"",
    //   "printed":[],
    //   "url":"",
    //   "status":null
    // };
    setState(() {
      unsent.add(msg);
    });
    if (file == null) return;
    final fileName = basename(file.path);
    final destination =
        'files/${controller.user.org}/${widget.conversation}/$fileName';
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final snapshot = await ref.putFile(file).whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      msg = MsgData(
          body: text ?? "",
          from: controller.user.id,
          sent: Timestamp.fromDate(await NTP.now()),
          type: "file",
          id: "",
          printed: [],
          url: urlDownload,
          status: 0,
          forwarded: [widget.conversation]);
      // msg = {
      //   "status": 0,
      //   "url": urlDownload,
      //   if (text != null) "body": text,
      //   "sent": Timestamp.now(),
      //   "type": "file",
      //   "from": controller.user.id
      // };
      send(msg);
    } on FirebaseException catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text(e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }

  Future send(MsgData msg) async {
    try {
      String conv = getConversationId(widget.conversation, controller.user.id);
      DocumentReference doc = _firestore
          .collection("${controller.user.org}")
          .doc("data")
          .collection("conversations")
          .doc(conv)
          .collection("messages")
          .doc();
      msg.id = doc.id;
      Map data = msg.toJson();
      print(data);
      await doc.set(data);
      //     .update({
      //   "messages": FieldValue.arrayUnion([msg])
      // });
    } on FirebaseException catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text(e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }
}
