import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import '../screens/screen.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController pin1 = TextEditingController();
  Controller controller = Get.find();
  String name;
  // @override
  // void initState() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   User user = new User();
  //   user.org = prefs.getStringList("det")[0];
  //   user.name = prefs.getStringList("det")[0];
  //   user.pin = prefs.getStringList("det")[0];
  //   super.initState();
  // }

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    // final prefs = await SharedPreferences.getInstance();
    // User user = new User();
    // user.org = prefs.getStringList("det")[0];
    // user.name = prefs.getStringList("det")[1];
    // user.pin = prefs.getStringList("det")[2];
    setState(() {
      name = controller.user.name[0].toUpperCase() +
          controller.user.name.substring(1);
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
                        child: Text("Please enter your security pin ,",
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
                      child: Text("$name",
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
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              print(controller.user.pin);
              print(controller.user.name);
              print(controller.user.org);
              pin1.text == controller.user.pin
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    )
                  : Get.rawSnackbar(
                      messageText: Text(
                      "Error! Check your pin and try again",
                      textAlign: TextAlign.center,
                    ));
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
                child: Text("Log In",
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
