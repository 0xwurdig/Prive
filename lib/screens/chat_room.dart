import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:prive/counterState.dart';
import 'package:path/path.dart';
import 'package:prive/models/message_model.dart';
import 'package:prive/widgets/conversation.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String conversation;
  const ChatRoom({Key key, @required this.conversation});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController text = new TextEditingController();
  StreamSubscription streamSubscription;
  List messages = [];
  Future<void> _pickImage() async {
    final selected = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (selected != null) {
      uploadFile(File(selected.path));
    } else {
      print('No image selected.');
    }
  }

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

  unReads() async {
    streamSubscription = _firestore
        .collection("${controller.user.org}")
        .doc('${widget.conversation}')
        .snapshots()
        .listen((snapshots) {
      if (messages != snapshots.data()['messages']) {
        setState(() {
          messages = snapshots.data()['messages'].map((msg) {
            if (msg['status'] == 0 && msg['from'] != controller.user.name)
              msg['status'] = 1;
            return msg;
          }).toList();
        });
      }
      _firestore
          .collection("${controller.user.org}")
          .doc('${widget.conversation}')
          .update({"messages": messages});
    });
  }
  // Future<void> _cropImage(var image) async {
  //   File cropped = await ImageCropper.cropImage(
  //       sourcePath: image.path,
  //       androidUiSettings: AndroidUiSettings(
  //           toolbarColor: Color(0xFFD4B132),
  //           toolbarTitle: 'Crop',
  //           toolbarWidgetColor: Colors.white));
  //   setState(() {
  //     if (cropped != null) {
  //       file = File(cropped.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

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
            height: 100,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => {Get.back()},
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Text(
                  controller.user.name[0].toUpperCase() +
                      controller.user.name.substring(1),
                  style: GoogleFonts.montserrat(
                      fontSize: 28, letterSpacing: 4, color: Colors.white),
                ),
                Text(
                  "...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    letterSpacing: 3,
                  ),
                )
              ],
            )),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: messages != null
                  ? Conversation(messages: List.from(messages.reversed))
                  : Container(),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            // height: 80,
            // color: Colors.green,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
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
                    // uploadFile();
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
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: MyTheme.kAccentColor,
                    child: Container(
                      padding: EdgeInsets.only(left: 4),
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

  // Future selectFile() async {
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);

  //   if (result == null) return;
  //   final path = result.files.single.path;

  //   setState(() => file = File(path));
  // }

  Future uploadFile(File file) async {
    Map msg;
    msg = {
      "sent": Timestamp.now(),
      "type": "file",
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
      print('Download-Link: $urlDownload');
      msg = {
        "status": 0,
        "body": urlDownload,
        "sent": Timestamp.now(),
        "type": "file",
        "from": controller.user.name
      };
      send(msg);
    } on FirebaseException catch (e) {
      print(e);
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
      print(e);
    }
  }
}
