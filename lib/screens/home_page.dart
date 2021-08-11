import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/size_config.dart';
import 'package:prive/widgets/recent_chats.dart';
import 'package:prive/widgets/sildeToConfirm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController name = new TextEditingController();
  Controller controller = Get.find();
  List users = [];
  List asd = [];
  String pin;
  bool owner = false;
  bool limit = true;
  bool revoked = false;
  SharedPreferences prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    getPrefs();
    conversations();
    super.initState();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool> addContact(String name) async {
    await _firestore.collection(controller.user.org).doc('prive').update({
      "users": FieldValue.arrayUnion([name.toLowerCase()])
    }).catchError((_) {
      return false;
    });
    return true;
  }

  Future<void> revoke() async {
    try {
      await _firestore.collection(controller.user.org).doc("prive").update({
        "users": ["${controller.user.name}"]
      });
      await _firestore.collection(controller.user.org).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc.reference.toString() !=
                  "DocumentReference<Map<String, dynamic>>(${controller.user.org}/prive)" &&
              doc.reference.toString() !=
                  "DocumentReference<Map<String, dynamic>>(${controller.user.org}/${controller.user.name})")
            doc.reference.delete();
        }
      });
      final ref = FirebaseStorage.instance.ref("files/${controller.user.org}");
      await ref
          .listAll()
          .then((value) => value.prefixes.forEach((folderRef) => {
                folderRef.listAll().then((val) => val.items.forEach((element) {
                      element.delete();
                    }))
              }));
      // setState(() {
      //   revoked = true;
      // });
    } catch (e) {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColorVariant,
          messageText: Text("Error! Please Try Again Later!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
    }
  }

  Future<void> deleteContact(String name) async {
    TextEditingController pin = new TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: getHeight(20)),
        height: getHeight(300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(getText(20)),
              topRight: Radius.circular(getText(20))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: getWidth(300)),
              child: Text(
                "Enter your Security Pin",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: getText(24)),
              ),
            ),
            ninput("Pin", pin, true),
            ConfirmationSlider(
              height: getHeight(70),
              backgroundShape: BorderRadius.circular(getText(10)),
              width: getWidth(260),
              foregroundColor: Colors.red[800],
              foregroundShape: BorderRadius.circular(getText(10)),
              text: "DELETE",
              textStyle: TextStyle(fontSize: getText(20)),
              onConfirmation: () async {
                if (pin.text == controller.user.pin) {
                  try {
                    await _firestore
                        .collection(controller.user.org)
                        .doc('prive')
                        .update({
                      "users": FieldValue.arrayRemove([name.toLowerCase()])
                    });
                    await _firestore
                        .collection(controller.user.org)
                        .get()
                        .then((snapshot) {
                      for (DocumentSnapshot doc in snapshot.docs) {
                        if (doc.reference.toString().contains(name))
                          doc.reference.delete();
                      }
                    });
                    Get.back();
                    Get.rawSnackbar(
                        snackPosition: SnackPosition.TOP,
                        messageText: Text("Deleted",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)));
                  } catch (e) {
                    Get.rawSnackbar(
                        snackPosition: SnackPosition.TOP,
                        messageText: Text("Error! Please Try Again",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)));
                  }
                } else {
                  Get.rawSnackbar(
                      snackPosition: SnackPosition.TOP,
                      messageText: Text("Error! Wrong Pin",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)));
                }
              },
            )
          ],
        ),
      ),
    );
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
      if (!snapshots.data()['users'].contains(controller.user.name)) {
        prefs.clear();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        if (users != arr)
          setState(() {
            users = arr;
            if (snapshots.data()['users'].length >= snapshots.data()['limit'])
              limit = false;
            if (snapshots.data()['users'].length <= snapshots.data()['limit'])
              limit = true;
            if (pin != snapshots.data()['auth'])
              pin = snapshots.data()['auth'].toString();
            if (snapshots.data()['users'][0] == controller.user.name)
              owner = true;
            if (snapshots.data()['revoked']) revoked = true;
          });
      }
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
      drawer: Container(
        height: getHeight(500),
        width: getWidth(300),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(getText(30)),
              topRight: Radius.circular(getText(30)),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: getHeight(60),
            ),
            Text("privé Guard",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getText(30),
                    fontFamily: "Neptune")),
            SizedBox(
              height: getHeight(40),
            ),
            if (pin != null)
              GestureDetector(
                onTap: () async {
                  int ran = Random().nextInt(900000) + 100000;
                  await _firestore
                      .collection(controller.user.org)
                      .doc('prive')
                      .update({"auth": ran}).catchError((_) => Get.rawSnackbar(
                          messageText: Text("Error! Please Try Again Later",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black))));
                },
                child: Text(
                  pin,
                  style: GoogleFonts.bebasNeue(
                      fontSize: getText(50),
                      letterSpacing: 15,
                      color: Color(0xff0f3659)),
                ),
              ),
            SizedBox(
              height: getHeight(10),
            ),
            Text(
              "tap to Change",
              style: TextStyle(
                  fontSize: getText(16), letterSpacing: 2, color: Colors.black),
            ),
            SizedBox(
              height: getHeight(100),
            ),
            GestureDetector(
              onTap: () async {
                if (!revoked && users.length > 0) {
                  Get.back();
                  Get.bottomSheet(
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: getHeight(300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(getText(20)),
                            topRight: Radius.circular(getText(20))),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: Text(
                              "Enter your Security Pin",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: getText(24)),
                            ),
                          ),
                          ninput("Pin", name, true),
                          ConfirmationSlider(
                            height: getHeight(70),
                            backgroundShape: BorderRadius.circular(getText(10)),
                            width: getWidth(260),
                            foregroundColor: Colors.red[900],
                            foregroundShape: BorderRadius.circular(getText(10)),
                            text: "Revoke",
                            textStyle: TextStyle(fontSize: getText(20)),
                            onConfirmation: () {
                              if (name.text == controller.user.pin) {
                                revoke();
                                Get.back();
                              } else {
                                Get.rawSnackbar(
                                    snackPosition: SnackPosition.TOP,
                                    messageText: Text("Error! Wrong Pin",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)));
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
              child: !revoked && users.length > 0
                  ? Container(
                      height: getHeight(80),
                      width: getWidth(200),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(getText(30)),
                            topLeft: Radius.circular(getText(30)),
                          ),
                          border: Border.all(color: Colors.red[900], width: 5)),
                      child: Center(
                        child: Text("REVOKE",
                            style: TextStyle(
                                color: Colors.red[900],
                                fontSize: getText(30),
                                fontFamily: "Neptune")),
                      ),
                    )
                  : Container(
                      height: getHeight(80),
                      width: getWidth(200),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(getText(30)),
                            topLeft: Radius.circular(getText(30)),
                          ),
                          border:
                              Border.all(color: Colors.grey[500], width: 5)),
                      child: Center(
                        child: Text("REVOKED",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: getText(30),
                                fontFamily: "Neptune")),
                      ),
                    ),
            ),
            SizedBox(
              height: getHeight(60),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: getHeight(150),
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'privé',
                style: GoogleFonts.bebasNeue(
                    fontSize: getText(50),
                    letterSpacing: 4,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  owner
                      ? Builder(builder: (context) {
                          return GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Icon(
                              Icons.menu,
                              size: 30,
                              color: Colors.white,
                            ),
                          );
                        })
                      : SizedBox(width: 30),
                  GestureDetector(
                    onTap: () async {
                      Get.bottomSheet(
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          height: getHeight(300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(getText(20)),
                                topRight: Radius.circular(getText(20))),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 300),
                                child: Text(
                                  "Enter your Security Pin",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: getText(24)),
                                ),
                              ),
                              ninput("Pin", name, true),
                              ConfirmationSlider(
                                height: getHeight(70),
                                backgroundShape:
                                    BorderRadius.circular(getText(10)),
                                width: getWidth(260),
                                foregroundColor: MyTheme.kPrimaryColor,
                                foregroundShape:
                                    BorderRadius.circular(getText(10)),
                                text: "Log Out",
                                textStyle: TextStyle(fontSize: getText(20)),
                                onConfirmation: () {
                                  if (name.text == controller.user.pin) {
                                    prefs.clear();
                                    SystemChannels.platform
                                        .invokeMethod('SystemNavigator.pop');
                                  } else {
                                    Get.rawSnackbar(
                                        snackPosition: SnackPosition.TOP,
                                        messageText: Text("Error! Wrong Pin",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white)));
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.phonelink_erase,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
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
      floatingActionButton: limit && owner
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
                    Icons.add,
                    color: Colors.white,
                    size: 35,
                  ), //child widget inside this button
                  onPressed: () {
                    Get.bottomSheet(
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        height: getHeight(300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(getText(20)),
                              topRight: Radius.circular(getText(20))),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Enter the Contact Name",
                              style: TextStyle(fontSize: getText(24)),
                            ),
                            ninput("Name", name, false),
                            ConfirmationSlider(
                              backgroundShape:
                                  BorderRadius.circular(getText(10)),
                              width: getWidth(260),
                              height: getHeight(70),
                              foregroundColor: MyTheme.kPrimaryColor,
                              foregroundShape:
                                  BorderRadius.circular(getText(10)),
                              text: "Add",
                              textStyle: TextStyle(fontSize: getText(20)),
                              onConfirmation: () async {
                                if (name.text.length >= 3) {
                                  bool a = await addContact(name.text);
                                  if (a) {
                                    Get.back();
                                    name.clear();
                                    Get.rawSnackbar(
                                        messageText: Text("Added",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white)));
                                  } else {
                                    Get.rawSnackbar(
                                        messageText: Text(
                                            "Error! Check your connection and try again",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white)));
                                  }
                                } else {
                                  Get.rawSnackbar(
                                      snackPosition: SnackPosition.TOP,
                                      messageText: Text(
                                          "Error! Enter atleast 3 characters for name",
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.white)));
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
                    //task to execute when this button is pressed
                  },
                ),
              ),
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget chat(List users) {
    return users.length > 0
        ? ListView(
            children: users.map((e) {
              return owner
                  ? RecentChats(
                      owner: owner,
                      conversation: e,
                      function: deleteContact,
                    )
                  : RecentChats(
                      owner: owner,
                      conversation: e,
                    );
            }).toList(),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Oops! You have no contacts added yet, add them?",
                style: TextStyle(fontSize: getText(24), color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          );
  }
}

Widget ninput(String a, TextEditingController b, bool obscure) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: getHeight(80),
      width: getWidth(300),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        height: getHeight(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getText(20)),
          border: Border.all(
            //                    <--- top side
            color: Colors.black,
            width: getWidth(3.0),
          ),
        ),
        child: Center(
          child: TextField(
            obscureText: obscure ? true : false,
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
        ),
      ));
}
