import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/models/user.dart';
import 'package:prive/screens/login.dart';
import 'package:prive/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class SetPin extends StatefulWidget {
  final org;
  final name;
  final id;
  SetPin({@required this.org, @required this.name, @required this.id});
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
                padding: EdgeInsets.only(top: getHeight(80)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: getWidth(40)),
                      child: Center(
                        child: Text("Please set your security pin ,",
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
                      child: Text("$employee",
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
                    SizedBox(
                      height: getHeight(50),
                    ),
                    tinput("Re-enter PIN", pin2),
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
              if (pin1.text.length > 3 && pin2.text.length > 3) {
                bool a = await setPin(
                    pin: pin2.text,
                    name: widget.name,
                    org: widget.org,
                    userId: widget.id);
                await prefs.setStringList(
                    "det", [widget.org, widget.name, pin2.text, widget.id]);
                user.org = prefs.getStringList("det")[0];
                user.name = prefs.getStringList("det")[1];
                user.pin = prefs.getStringList("det")[2];
                user.id = prefs.getStringList("det")[3];
                // user.privateKey = prefs.getStringList("det")[4];
                controller.add(user);
                pin1.text == pin2.text
                    ? a
                        ? Get.off(() => LogIn())
                        : Get.rawSnackbar(
                            backgroundColor: MyTheme.kAccentColor,
                            messageText: Text(
                                "Error! Check your connection and try again",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black)))
                    : Get.rawSnackbar(
                        backgroundColor: MyTheme.kAccentColor,
                        messageText: Text("Error! Pins do not match!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black)));
              } else {
                Get.rawSnackbar(
                    backgroundColor: MyTheme.kAccentColor,
                    messageText: Text(
                        "Error! Please enter minimum 3 characters",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black)));
              }
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
                child: Text("Set Pin",
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
          keyboardType: TextInputType.number,
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

Future<bool> setPin(
    {String pin, String org, String name, String userId}) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference newUser =
      _firestore.collection(org).doc("data").collection("users").doc(userId);
  await newUser.set({
    "fcmToken": "asdasdsadasd",
    "id": newUser.id,
    "publicKey": "qweqweqwewqeqweqwe",
    "pin": pin,
    "name": name
  }, SetOptions(merge: true)).catchError((e) {
    return false;
  });
  return true;
}
