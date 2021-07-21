import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prive/screens/set_pin.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widgets.dart';
import '../screens/screen.dart';

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

  // void onTabChange() {
  //   setState(() {
  //     currentTabIndex = tabController.index;
  //     print(currentTabIndex);
  //   });
  // }

  // @override
  // void initState() {
  //   tabController = TabController(length: 3, vsync: this);

  //   tabController.addListener(() {
  //     onTabChange();
  //   });
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   tabController.addListener(() {
  //     onTabChange();
  //   });

  //   tabController.dispose();

  //   super.dispose();
  // }
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
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Center(
                      child: Text('WELCOME',
                          style: TextStyle(
                              fontFamily: "Neptune",
                              fontSize: 60,
                              color: MyTheme.kPrimaryColor)),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    tinput("ORGANIZATION", org),
                    SizedBox(
                      height: 50,
                    ),
                    tinput("NAME", name),
                    SizedBox(
                      height: 50,
                    ),
                    tinput("PIN", pin),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await auth(org.text, name.text, pin.text) == true
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetPin(
                              org: org.text, name: name.text.toLowerCase())),
                    )
                  : print("Auth Error");
            },
            child: Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: MyTheme.kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Center(
                child: Text("LogIn",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      width: 300,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        height: 60,
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
          style: TextStyle(fontSize: 30, letterSpacing: 5),
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

  // print(success);
  return success;
  // print(org + name + pin);
}
