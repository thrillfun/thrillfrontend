import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../../../rest/models/followers_model.dart';

import '../../../rest/models/user_details_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';

class SettingsController extends GetxController with StateMixin<Rx<User>> {
  var storage = GetStorage();
  final count = 0.obs;
  var userProfile = User().obs;
  var isSimCardAvailable = true.obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var qrData = "".obs;
  var followersModel = RxList<Followers>();
  var followersLoading = false.obs;


  @override
  void onInit() {
    getUserProfile();
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
      await firebase.FirebaseAuth.instance.signOut();
      googleUser.signOut();
    } on Exception catch (e) {
      Logger().wtf(e);
    }
  }
  Future<void> getUserProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile,status: RxStatus.loading());
    dio.post('/user/get-profile', queryParameters: {
      "id": "${GetStorage().read("userId")}"
    }).then((result) {
      userProfile = UserDetailsModel.fromJson(result.data).data!.user!.obs;
      change(userProfile,status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(userProfile,status: RxStatus.error(error.toString()));

    });
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

