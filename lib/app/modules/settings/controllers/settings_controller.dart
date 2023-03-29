import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../utils/utils.dart';

class SettingsController extends GetxController {
  var storage = GetStorage();
  final count = 0.obs;


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> signOutUser() async {
    await storage.erase();
    await signOutGoogle();
  }

  Future<void> signOutGoogle() async {
    try {
      final GoogleSignIn googleUser = GoogleSignIn(scopes: <String>["email"]);

      await GoogleSignIn().disconnect().catchError((e, stack) {});
      await FirebaseAuth.instance.signOut();
      googleUser.signOut();
    } on Exception catch (e) {
      errorToast(e.toString());
    }

  }
  Future<String> createDynamicLink(
      String id, String? type, String? name, String? avatar) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun?type=$type&id=$id&name=$name&something=$avatar"),
      androidParameters: const AndroidParameters(
        packageName: 'com.thrill.media',
        minimumVersion: 1,
      ),
    );
    final dynamicLink =
    await FirebaseDynamicLinks.instance.buildLink(parameters);

    return dynamicLink.toString();
  }
}

