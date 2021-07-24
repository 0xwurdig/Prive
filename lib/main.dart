import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_checker/memory_checker.dart';
import 'package:prive/counterState.dart';
import 'package:prive/screens/login.dart';
import 'package:prive/screens/welcome_screen.dart';
import 'package:prive/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_theme.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool registered = false;
  Controller controller = Get.put(Controller());
  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    User user = new User();
    if (prefs.getStringList("det") != null) {
      user.org = prefs.getStringList("det")[0];
      user.name = prefs.getStringList("det")[1];
      user.pin = prefs.getStringList("det")[2];
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
              navigatorObservers: [LeakObserver()],
              debugShowCheckedModeBanner: false,
              title: 'Chattie UI',
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
