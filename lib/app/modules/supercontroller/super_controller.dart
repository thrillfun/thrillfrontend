import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../utils/utils.dart';
import '../login/views/login_view.dart';

class AppSuperController extends GetxController
   {


  @override
  void onInit() {
    getDynamicLink();
    super.onInit();
  }




  getDynamicLink() async {

  }
}
