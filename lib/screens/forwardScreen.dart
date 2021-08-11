import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/size_config.dart';
import 'package:prive/widgets/forwardTiles.dart';
import 'package:prive/widgets/recent_chats.dart';
import 'package:prive/widgets/sildeToConfirm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForwardScreen extends StatefulWidget {
  final List messages;
  final String conversation;
  ForwardScreen({this.messages, this.conversation});
  @override
  _ForwardScreenState createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  TextEditingController name = new TextEditingController();
  Controller controller = Get.find();
  List users = [];
  List<String> forwardTo = [];
  String from;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    conversations();
    super.initState();
  }

  Future send() async {
    forwardTo.forEach((conversation) {
      try {
        try {
          _firestore
              .collection("${controller.user.org}")
              .doc('$conversation')
              .update({
            "messages": FieldValue.arrayUnion(widget.messages),
          });
        } catch (e) {
          _firestore
              .collection("${controller.user.org}")
              .doc('$conversation')
              .set({
            "messages": widget.messages,
          });
        }
      } on FirebaseException catch (e) {
        Get.rawSnackbar(
            backgroundColor: MyTheme.kAccentColor,
            messageText: Text(e.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black)));
      }
    });
  }

  conversations() async {
    _firestore
        .collection(controller.user.org)
        .doc('prive')
        .snapshots()
        .listen((snapshots) {
      List arr = [];
      snapshots.data()['users'].forEach((user) {
        List varr = [controller.user.name];
        if (user != varr[0]) varr.add(user);
        if (varr.length > 1) {
          varr.sort();
          arr.add(varr.join('-'));
        }
      });
      if (users != arr)
        setState(() {
          from = widget.messages[0]["from"];
          users = arr;
        });
    }).onError((_) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text(_,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.kPrimaryColor,
      body: Column(
        children: [
          Container(
            height: getHeight(150),
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Forward To',
                style: GoogleFonts.bebasNeue(
                    fontSize: getText(40),
                    letterSpacing: 4,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getText(30)),
                  topRight: Radius.circular(getText(30)),
                )),
            child: Container(child: chat(users)),
          ))
        ],
      ),
      floatingActionButton: forwardTo.length != 0
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: getHeight(50),
                width: getWidth(70),
                child: FloatingActionButton(
                    backgroundColor: Colors.blueGrey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(getText(20))),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 35,
                    ), //child widget inside this button
                    onPressed: () {
                      send();
                      Get.back();
                    }),
              ),
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget chat(List users) {
    users.remove(widget.conversation);
    return ListView(
      children: users.map((e) {
        // if (e != widget.conversation)
        return GestureDetector(
            onTap: () {
              setState(() {
                !forwardTo.contains(e) ? forwardTo.add(e) : forwardTo.remove(e);
              });
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(getText(20)),
                  color: forwardTo.contains(e)
                      ? MyTheme.kAccentColor.withOpacity(0.6)
                      : Colors.transparent,
                ),
                child: ForwardTiles(conversation: e)));
      }).toList(),
    );
  }
}
