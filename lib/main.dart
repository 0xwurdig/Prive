import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prive/counterState.dart';
import 'package:prive/screens/login.dart';
import 'package:prive/screens/welcome_screen.dart';
import 'package:prive/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_theme.dart';
import 'models/user.dart';
import 'package:package_info/package_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: false,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool registered = false;
  String version;
  Controller controller = Get.put(Controller());
  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version.toString() +
            "+" +
            packageInfo.buildNumber.toString();
      });
    });
    super.initState();
    getPrefs();
    versionControl();
  }

  versionControl() {
    FirebaseFirestore.instance
        .collection("PRIVE")
        .doc('prive')
        .snapshots()
        .listen((snapshots) {
      if (snapshots.data()["version"] != version) {
        print(snapshots.data()["version"]);
        Get.bottomSheet(
            Container(
              padding: EdgeInsets.symmetric(vertical: getHeight(20)),
              height: getHeight(200),
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
                      "New Version is Available!! Please Update",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: getText(24)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    child: Container(
                      height: getHeight(50),
                      width: getWidth(200),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(getText(10)),
                          color: MyTheme.kPrimaryColor),
                      child: Center(
                        child: Text(
                          'Ok',
                          style: GoogleFonts.bebasNeue(
                              fontSize: getText(30),
                              letterSpacing: 4,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            isDismissible: false);
      }
    });
  }

  void getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    User user = new User();
    if (prefs.getStringList("det") != null) {
      user.org = prefs.getStringList("det")[0];
      user.name = prefs.getStringList("det")[1];
      user.pin = prefs.getStringList("det")[2];
      user.id = prefs.getStringList("det")[3];
      // user.privateKey = prefs.getStringList("det")[4];
      controller.add(user);
      setState(() {
        registered = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Prive',
              theme: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                primaryColor: MyTheme.kPrimaryColor,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: registered ? LogIn() : WelcmScreen(),
            );
          },
        );
      },
    );
  }
}
