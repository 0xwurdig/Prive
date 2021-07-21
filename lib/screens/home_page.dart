import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prive/counterState.dart';
import 'package:prive/models/user.dart';
import 'package:prive/widgets/recent_chats.dart';
import 'package:prive/widgets/sildeToConfirm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController name = new TextEditingController();
  Controller controller = Get.find();
  List users = [];
  String pin;
  bool owner;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    conversations();
    super.initState();
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
          users = arr;
        });
      if (pin != snapshots.data()['auth']) {
        setState(() {
          pin = snapshots.data()['auth'].toString();
        });
      }
    }).onError((_) {
      print("error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.kPrimaryColor,
      // appBar: AppBar(
      //   toolbarHeight: 150,
      //   leading: GestureDetector(
      //               onTap: () {
      //                 return Drawer(
      //                   child: Text("asdasds"),
      //                 );
      //               },
      //               child: Icon(
      //                 Icons.menu,
      //                 size: 30,
      //                 color: Colors.white,
      //               ),
      //             ),
      //   title: Center(
      //     child: Text(
      //       'privé',
      //       style: GoogleFonts.bebasNeue(
      //           fontSize: 50, letterSpacing: 4, color: Colors.white),
      //     ),
      //   ),
      //   actions: [
      //     Icon(
      //       Icons.phonelink_erase,
      //       size: 30,
      //       color: Colors.white,
      //     )
      //   ],
      // ),
      drawer: Container(
        height: 600,
        width: 300,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              topRight: Radius.circular(30),
            )),
        child: Column(
          children: [
            Text(
              "privé Guard",
              style: GoogleFonts.bebasNeue(
                  fontSize: 30, letterSpacing: 4, color: Colors.black),
            ),
            if (pin != null)
              Text(
                pin,
                style: GoogleFonts.bebasNeue(
                    fontSize: 50, letterSpacing: 4, color: Color(0xff0f3659)),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'privé',
                style: GoogleFonts.bebasNeue(
                    fontSize: 50, letterSpacing: 4, color: Colors.white),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: Colors.white,
                      ),
                    );
                  }),
                  Icon(
                    Icons.phonelink_erase,
                    size: 30,
                    color: Colors.white,
                  )
                ],
              )),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Container(
                  child: users != []
                      ? ListView(
                          children: users.map((e) {
                            return RecentChats(conversation: e);
                          }).toList(),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Oops! You have no contacts added yet, add them?",
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
            ),
          )
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(10),
      //   child: SizedBox(
      //     height: 80,
      //     width: 80,
      //     child: FloatingActionButton(
      //       shape:
      //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //       child: Icon(
      //         Icons.add,
      //         color: Colors.white,
      //         size: 35,
      //       ), //child widget inside this button
      //       onPressed: () {
      //         Get.bottomSheet(
      //           Container(
      //             padding: EdgeInsets.symmetric(vertical: 20),
      //             height: 300,
      //             decoration: BoxDecoration(
      //               color: Colors.white,
      //               borderRadius: BorderRadius.only(
      //                   topLeft: Radius.circular(20),
      //                   topRight: Radius.circular(20)),
      //             ),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   "Enter the Contact Name",
      //                   style: TextStyle(fontSize: 24),
      //                 ),
      //                 ninput("Name", name),
      //                 ConfirmationSlider(
      //                   backgroundShape: BorderRadius.circular(10),
      //                   width: 260,
      //                   foregroundColor: MyTheme.kPrimaryColor,
      //                   foregroundShape: BorderRadius.circular(10),
      //                   text: "Add",
      //                   textStyle: TextStyle(fontSize: 20),
      //                   onConfirmation: () async {
      //                     bool a = await addContact(name.text);
      //                     if (a) {
      //                       Get.back();
      //                       name.clear();
      //                       print("added");
      //                     }
      //                   },
      //                 )
      //               ],
      //             ),
      //           ),
      //         );
      //         //task to execute when this button is pressed
      //       },
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Widget ninput(String a, TextEditingController b) {
//   return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       height: 80,
//       width: 300,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 14),
//         height: 60,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             //                    <--- top side
//             color: Colors.black,
//             width: 3.0,
//           ),
//         ),
//         child: TextField(
//           textAlign: TextAlign.center,
//           controller: b,
//           style: TextStyle(fontSize: 30, letterSpacing: 5),
//           decoration: InputDecoration(
//             border: InputBorder.none,
//             hintText: a,
//             hintStyle: TextStyle(color: Colors.grey[500], letterSpacing: 0),
//           ),
//         ),
//       ));
// }
