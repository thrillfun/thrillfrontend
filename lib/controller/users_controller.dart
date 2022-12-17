import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dioClient;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/block_status_response.dart';
import 'package:thrill/controller/model/favourites_model.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart'
    as profileModel;
import 'package:thrill/controller/model/user_details_model.dart' as authUser;
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/utils/util.dart';

class UserController extends GetxController {
  var videosController = Get.find<VideosController>();

  var userModel = authUser.User().obs;
  var isProfileLoading = false.obs;
  var isFollowersLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isLoggingIn = false.obs;

  var followersModel = RxList<Followers>();
  var followingModel = RxList<Followers>();

  var userFollowersModel = RxList<Followers>();
  var userFollowingModel = RxList<Followers>();

  var isInboxLoading = false.obs;

  var userBlocked = false.obs;
  var userId = 0.obs;
  var isMyProfile = false.obs;

  var userProfile = profileModel.User().obs;

  var otherProfile = profileModel.User().obs;

  var storage = GetStorage();

  var dio = dioClient.Dio(dioClient.BaseOptions(
      baseUrl: RestUrl.baseUrl,
      headers: {"Authorization": "Bearer ${GetStorage().read("token")}"}));

  var selectedIndex = 0.obs;

  RxList<FavouriteVideos> favouriteSounds = RxList();
  RxList<FavouriteHashTags> favouriteHashtags = RxList();

  Future<void> getUserProfile(int userId) async {
    if (storage.read("token") == null || storage.read("userId") == null) {
      Get.to(LoginGetxScreen());
    } else {
      isProfileLoading.value = true;
      dio.post('/user/get-profile', queryParameters: {"id": "$userId"}).then(
          (result) {
        userProfile =
            profileModel.ProfileModelPojo.fromJson(result.data).data!.user!.obs;

        storage.write('user', userProfile.value);
        videosController.getOtherUserVideos(userProfile.value.id!);
        videosController.getOthersLikedVideos(userProfile.value.id!);
        isProfileLoading.value = false;
      }).onError((error, stackTrace) {
        isProfileLoading.value = false;
      });
    }
  }

  Future<void> getOthersProfile(int userId) async {
    isProfileLoading.value = true;

    dio.post('/user/get-profile', queryParameters: {"id": "$userId"}).then(
        (result) {
      otherProfile =
          profileModel.ProfileModelPojo.fromJson(result.data).data!.user!.obs;

      videosController.getOtherUserVideos(otherProfile.value.id!);
      videosController.getOthersLikedVideos(otherProfile.value.id!);
      isProfileLoading.value = false;
    }).onError((error, stackTrace) {
      isProfileLoading.value = false;
    });
  }

  getUserFollowers(int userId) async {
    isFollowersLoading.value = true;

    if (followersModel.isNotEmpty) followersModel.clear();

    dio.options.headers['Authorization'] =
        "Bearer ${GetStorage().read("token")}";
    dio
        .post('${RestUrl.baseUrl}/user/get-followers',
            queryParameters: {"user_id": "$userId"})
        .timeout(const Duration(seconds: 10))
        .then((result) {
          followersModel = FollowersModel.fromJson(result.data).data!.obs;
          isFollowersLoading.value = false;
        })
        .onError((error, stackTrace) {
          isFollowersLoading.value = false;

          print(error);
        });
  }

  getUserFollowing(int userId) async {
    isFollowingLoading.value = true;
    dio
        .post('/user/get-followings', queryParameters: {"user_id": "$userId"})
        .timeout(const Duration(seconds: 10))
        .then((result) {
          if (followingModel.isNotEmpty) {
            followingModel.value =
                FollowersModel.fromJson(result.data).data!.obs;
          } else {
            followingModel = FollowersModel.fromJson(result.data).data!.obs;
          }
          isFollowingLoading.value = false;
        })
        .onError((error, stackTrace) {
          isFollowingLoading.value = false;
        });
  }

  Future<void> addToFavourites(int id, String type, int action) async {
    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/favorite/add-to-favorite'),
          headers: {
            "Authorization": "Bearer ${GetStorage().read("token")}"
          },
          body: {
            "id": "$id",
            "type": "$type",
            "action": "$action"
          }).timeout(const Duration(seconds: 10));

      var result = jsonDecode(response.body);
      successToast(result["message"]);
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> getfavouriteSounds() async {
    try {
      var response = await http
          .get(
            Uri.parse('${RestUrl.baseUrl}/favorite/user-favorites-list'),
            headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          )
          .timeout(const Duration(seconds: 10))
          .then((value) {
            favouriteSounds.value =
                FavouritesModel.fromJson(jsonDecode(value.body)).data!.videos!;

            favouriteHashtags.value =
                FavouritesModel.fromJson(jsonDecode(value.body))
                    .data!
                    .hashTags!;
          })
          .onError((error, stackTrace) {
            errorToast(error.toString());
          });
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  followUnfollowUser(int userId, String action, {int? id}) async {
    isFollowersLoading.value = true;
    var response = await http.post(
        Uri.parse('${RestUrl.baseUrl}/user/follow-unfollow-user'),
        headers: {
          "Authorization": "Bearer ${GetStorage().read("token")}"
        },
        body: {
          "publisher_user_id": "$userId",
          "action": action
        }).timeout(const Duration(seconds: 10));
    var result = jsonDecode(response.body);
    successToast(result["message"]);
    if (id != null) {
      getUserFollowing(id);
      getUserFollowers(id);
    }
    videosController.getAllVideos();
    if (id != null) {
      getUserFollowers(id);
    }
    isFollowersLoading.value = false;
    update();
  }

  isUserBlocked(int userId) async {
    isFollowersLoading.value = true;

    try {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/user/is-user-blocked'), headers: {
        "Authorization": "Bearer ${GetStorage().read("token")}"
      }, body: {
        "blocked_user": "$userId"
      }).timeout(const Duration(seconds: 10));

      var result = jsonDecode(response.body);
      try {
        userBlocked = BlockStatusResponse.fromJson(result).status!.obs;
      } on HttpException catch (e) {
        errorToast(BlockStatusResponse.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  blockUnblockUser(int userId, String action) async {
    isFollowersLoading.value = true;

    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/block-unblock-user'),
          headers: {
            "Authorization": "Bearer ${GetStorage().read("token")}"
          },
          body: {
            "blocked_user": "$userId",
            "action": action
          }).timeout(const Duration(seconds: 10));

      var result = jsonDecode(response.body);
      try {
        userBlocked = BlockStatusResponse.fromJson(result).status!.obs;

        print(BlockStatusResponse.fromJson(result).message);
        successToast(BlockStatusResponse.fromJson(result).message.toString());
      } on HttpException catch (e) {
        errorToast(BlockStatusResponse.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  loginUser(var phone, var password) async {
    isLoggingIn.value = true;

    try {
      var response = await http.post(Uri.parse('${RestUrl.baseUrl}/login'),
          body: {
            "phone": phone,
            "password": password
          }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          var userData = authUser.UserDetailsModel.fromJson(result).data;
          var user = userData!.user;
          var token = userData!.token;

          storage.write('token', token).toString();

          await storage
              .write('user', user)
              .then((value) => successToast(result['message']));

          update();

          Get.to(LandingPageGetx());
        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isLoggingIn.value = false;
  }

  authUser.User userDataModel() {
    final map = storage.read('user') ?? {};
    return authUser.User.fromJson(map);
  }

  Future<void> socialLoginRegister(var social_login_id, social_login_type,
      email, phone, firebase_token, name) async {
    isLoggingIn.value = true;
    try {
      createDynamicLink("123456").then((value) async {
        var response =
            await http.post(Uri.parse('${RestUrl.baseUrl}/SocialLogin'), body: {
          "social_login_id": social_login_id,
          "social_login_type": social_login_type,
          "email": email,
          // "phone": phone,
          "firebase_token": firebase_token,
          "name": name,
          "referral_code": value.toString(),
        }).timeout(const Duration(seconds: 10));

        var result = jsonDecode(response.body);
        try {
          var userData = authUser.UserDetailsModel.fromJson(result).data;

          storage.write("userId", userData!.user!.id);

          storage.write('token', userData.token!).toString();

          await storage.write("user", userData).then((_) {
            print(storage.read("user"));
            Get.to(LandingPageGetx());
          });

          // var data = authUser.User.fromJson(jsonDecode(storage.read("user")));

          successToast(result['message']);
        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      });
    } on Exception catch (e) {
      log(e.toString());
    }

    isLoggingIn.value = false;
  }

  signinTrueCaller(var social_login_id, social_login_type, phone,
      firebase_token, name) async {
    isLoggingIn.value = true;

    try {
      createDynamicLink("123456").then((value) async {
        var response = await http
            .post(Uri.parse('${RestUrl.baseUrl}/SocialLogin'), body: {
              "social_login_id": social_login_id,
              "social_login_type": social_login_type,
              "phone": phone,
              "firebase_token": firebase_token,
              "name": name,
              "referral_code": value.toString(),
            })
            .timeout(const Duration(seconds: 10))
            .then((value) {
              var result = jsonDecode(value.body);
              try {
                var userData = authUser.UserDetailsModel.fromJson(result).data;

                storage.write('token', userData!.token!).toString();
                storage.write('user', userData.user).then((value) {
                  userModel =
                      authUser.User.fromJson(GetStorage().read("user")).obs;
                  Get.to(LandingPageGetx());
                });

                successToast(result['message']);
              } on HttpException {
                errorToast(result['message']);
              } on Exception catch (e) {
                errorToast(e.toString());
              }
            })
            .onError((error, stackTrace) {
              errorToast(error.toString());
            });
      });
    } on Exception catch (e) {
      log(e.toString());
    }

    isLoggingIn.value = false;
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    // fetch the auth details from the request made earlier
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // Create a new credential for signing in with google
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    await socialLoginRegister(googleUser.id, "google", googleUser.email, "",
        googleAuth.accessToken, googleUser.displayName ?? "");
  }

  Future<void> signOut() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    final GoogleSignIn googleUser =
        await GoogleSignIn(scopes: <String>["email"]);

    if (googleUser != null) {
      await GoogleSignIn().disconnect().catchError((e, stack) {});
      await FirebaseAuth.instance.signOut();
      googleUser.signOut();
    }
    selectedIndex.value = 0;
    update();
  }

  Future<Uri> createDynamicLink(String videoName) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.fun/',
      link: Uri.parse('https://thrillvideo.s3.amazonaws.com/test/$videoName'),
      androidParameters: AndroidParameters(
        packageName: 'com.thrill',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await parameters.link;
    final Uri shortUrl = dynamicUrl;
    return shortUrl;
  }

  
}
