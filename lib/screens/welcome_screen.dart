import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prive/screens/set_pin.dart';
import 'package:prive/size_config.dart';
import 'dart:math';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class WelcmScreen extends StatefulWidget {
  @override
  _WelcmScreenState createState() => _WelcmScreenState();
}

class _WelcmScreenState extends State<WelcmScreen> {
  TextEditingController org = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController pin = TextEditingController();
  TabController tabController;
  int currentTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: MyTheme.kPrimaryColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: getHeight(80)),
                child: Column(
                  children: [
                    Center(
                      child: Text('WELCOME',
                          style: TextStyle(
                              fontFamily: "Neptune",
                              fontSize: getText(60),
                              color: MyTheme.kPrimaryColor)),
                    ),
                    SizedBox(
                      height: getHeight(50),
                    ),
                    tinput("ORGANIZATION", org),
                    SizedBox(
                      height: getHeight(50),
                    ),
                    tinput("NAME", name),
                    SizedBox(
                      height: getHeight(50),
                    ),
                    tinput("PIN", pin),
                    SizedBox(
                      height: getHeight(50),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await auth(org.text, name.text.toLowerCase(),
                          pin.text.toLowerCase()) ==
                      true
                  ? Get.off(() =>
                      SetPin(org: org.text, name: name.text.toLowerCase()))
                  : Get.rawSnackbar(
                      backgroundColor: MyTheme.kAccentColorVariant,
                      messageText: Text("Error! Credentials do not match!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black)));
            },
            child: Container(
              height: getHeight(120),
              padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
              decoration: BoxDecoration(
                  color: MyTheme.kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(getText(30)),
                    topRight: Radius.circular(getText(30)),
                  )),
              child: Center(
                child: Text("LogIn",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: getText(30),
                        fontFamily: "Neptune")),
              ),
            ),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.login),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Widget tinput(String a, TextEditingController b) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
      height: getHeight(80),
      width: 300,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: getWidth(14)),
        height: getHeight(60),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              //                    <--- top side
              color: Colors.black,
              width: 3.0,
            ),
          ),
        ),
        child: TextField(
          textAlign: TextAlign.center,
          controller: b,
          style: TextStyle(fontSize: getText(30), letterSpacing: 5),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: a,
            hintStyle: TextStyle(color: Colors.grey[500], letterSpacing: 0),
          ),
        ),
      ));
}

Future<bool> auth(String org, name, pin) async {
  bool success;
  // final prefs = await SharedPreferences.getInstance();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  await _firestore.collection(org).doc('prive').get().then((doc) {
    if (doc.data()['users'].contains(name) &&
        doc.data()['auth'].toString() == pin) {
      success = true;
      int ran = Random().nextInt(900000) + 100000;
      _firestore.collection(org).doc('prive').update({"auth": ran});
    } else {
      success = false;
    }
  });
  return success;
}
