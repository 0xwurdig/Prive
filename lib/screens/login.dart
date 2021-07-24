import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/screens/home_page.dart';
import 'package:prive/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController pin1 = TextEditingController();
  Controller controller = Get.find();
  String name;
  String pin;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  getPrefs() async {
    setState(() {
      name = controller.user.name[0].toUpperCase() +
          controller.user.name.substring(1);
    });
    try {
      prefs = await SharedPreferences.getInstance();
      var doc = await _firestore
          .collection("${controller.user.org}")
          .doc("${controller.user.name}")
          .get();
      if (doc.data() != null) {
        setState(() {
          pin = doc.data()["pin"];
        });
      } else {
        prefs.clear();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text("Error! Please Try Again Later",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: getHeight(80)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: getWidth(40)),
                      child: Center(
                        child: Text("Please enter your security pin ,",
                            style: TextStyle(
                                fontFamily: "Elianto",
                                fontSize: getText(40),
                                color: MyTheme.kPrimaryColor)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidth(40), vertical: getHeight(20)),
                      child: Text("$name",
                          style: TextStyle(
                              fontFamily: "Elianto",
                              fontSize: getText(40),
                              color: MyTheme.kPrimaryColor)),
                    ),
                    SizedBox(
                      height: getHeight(50),
                    ),
                    tinput("Enter PIN", pin1),
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
              pin1.text == pin
                  ? Get.off(() => HomePage())
                  : Get.rawSnackbar(
                      backgroundColor: MyTheme.kAccentColor,
                      messageText: Text(
                        "Error! Check your pin and try again",
                        textAlign: TextAlign.center,
                      ));
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
                child: Text("Log In",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: getText(30),
                        fontFamily: "Elianto")),
              ),
            ),
          ),
        ],
      ),
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
              color: Colors.black,
              width: 3.0,
            ),
          ),
        ),
        child: TextField(
          obscureText: true,
          obscuringCharacter: "#",
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
