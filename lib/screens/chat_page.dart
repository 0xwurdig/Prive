// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:prive/app_theme.dart';
// import 'package:prive/counterState.dart';

// import '../widgets/widgets.dart';
// import 'package:flutter/material.dart';

// class ChatPage extends StatefulWidget {
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List users = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Controller controller = Get.find();
//   @override
//   void initState() {
//     conversations();
//     super.initState();
//   }

//   conversations() async {
//     _firestore
//         .collection(controller.user.org)
//         .doc('prive')
//         .snapshots()
//         .listen((snapshots) {
//       List arr = [];
//       snapshots.data()['users'].forEach((user) {
//         List varr = [controller.user.name];
//         if (user != varr[0]) varr.add(user);
//         if (varr.length > 1) {
//           varr.sort();
//           arr.add(varr.join('-'));
//         }
//       });
//       if (users != arr)
//         setState(() {
//           users = arr;
//         });
//     }).onError((_) {
//       print("error");
//     });
//     // await _firestore
//     //     .collection(controller.user.org)
//     //     .doc('prive')
//     //     .get()
//     //     .then((doc) => {
//     //           doc.data()['users'].forEach((user) {
//     //             List varr = [controller.user.name];
//     //             if (user != varr[0]) varr.add(user);
//     //             if (varr.length > 1) {
//     //               varr.sort();
//     //               arr.add(varr.join(''));
//     //             }
//     //           })
//     //         });
//     // setState(() {
//     //   users = arr;
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     conversations();
//     return Container(
//         child: users != []
//             ? ListView(
//                 children: users.map((e) {
//                   return RecentChats(conversation: e);
//                 }).toList(),
//               )
//             : Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     "Oops! You have no contacts added yet, add them?",
//                     style: TextStyle(fontSize: 24),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ));
//   }
// }
