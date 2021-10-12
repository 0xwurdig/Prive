import 'package:get/get.dart';

import 'models/user.dart';

class Controller extends GetxController {
  User user = new User();
  add(User a) async {
    this.user = a;
    update();
  }
}
