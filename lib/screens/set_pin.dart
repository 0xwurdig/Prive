import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/models/user.dart';
import 'package:prive/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import '../screens/screen.dart';

class SetPin extends StatefulWidget {
  final org;
  final name;
  SetPin({@required this.org, @required this.name});
  @override
  _SetPinState createState() => _SetPinState();
}

class _SetPinState extends State<SetPin> {
  TextEditingController pin1 = TextEditingController();
  TextEditingController pin2 = TextEditingController();
  String employee;
  SharedPreferences prefs;
  User user = new User();
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      employee = widget.name[0].toUpperCase() + widget.name.substring(1);
    });
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
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: Text("Please set your security pin ,",
                            style: TextStyle(
                                fontFamily: "Elianto",
                                fontSize: 40,
                                color: MyTheme.kPrimaryColor)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Text("$employee",
                          style: TextStyle(
                              fontFamily: "Elianto",
                              fontSize: 40,
                              color: MyTheme.kPrimaryColor)),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    tinput("Enter PIN", pin1),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    tinput("Re-enter PIN", pin2),
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
              bool a = await setPin(
                  pin: pin2.text, name: widget.name, org: widget.org);
              await prefs
                  .setStringList("det", [widget.org, widget.name, pin2.text]);
              user.org = prefs.getStringList("det")[0];
              user.name = prefs.getStringList("det")[1];
              user.pin = prefs.getStringList("det")[2];
              print(user.org);
              print(user.name);
              print(user.pin);
              controller.add(user);
              pin1.text == pin2.text
                  ? a
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LogIn()),
                        )
                      : Get.rawSnackbar(
                          messageText: Text(
                          "Error! Check your connection and try again",
                          textAlign: TextAlign.center,
                        ))
                  : Get.rawSnackbar(
                      messageText: Text("Error! Pins do not match!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)));
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
                child: Text("Set Pin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      width: 300,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
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

Future<bool> setPin({String pin, String org, String name}) async {
  bool success;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  await _firestore
      .collection(org)
      .doc(name)
      .set({"pin": pin}, SetOptions(merge: true)).whenComplete(() {
    success = true;
  }).catchError((e) {
    success = false;
  });
  // print(success);
  return success;
  // print(org + name + pin);
}
