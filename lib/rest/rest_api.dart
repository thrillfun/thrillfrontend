import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/models/social_url_model.dart';
import 'package:thrill/rest/rest_client.dart';
import 'package:thrill/rest/rest_url.dart';

class RestApi {
  static Future<http.Response> login(String phone, String password) async {
    http.Response response;

    String? token = await FirebaseMessaging.instance.getToken();

    var result = await RestClient.postData(
      RestUrl.login,
      body: {'phone': phone, 'password': password, 'firebase_token': token},
    );

    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> register(
      String fullName, String phone, String dob, String password) async {
    http.Response response;
    String? token = await FirebaseMessaging.instance.getToken();
    var result = await RestClient.postData(
      RestUrl.register,
      body: {
        'phone': phone,
        'name': fullName,
        'dob': dob,
        'password': password,
        'social_login_type': 'normal',
        'firebase_token': token,
        'gender': "Male"
      },
    );

    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> socialLoginRegister(
      String id, String type, String email, String name) async {
    http.Response response;
    String? token = await FirebaseMessaging.instance.getToken();
    var result = await RestClient.postData(
      RestUrl.socialLR,
      body: {
        'social_login_id': id,
        'social_login_type': type,
        'email': email,
        'name': name,
        'firebase_token': token
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> updateProfile(
      String fullName,
      String firstName,
      String lastName,
      String profileImg,
      String username,
      String gender,
      String websiteUrl,
      String bio,
      List<SocialUrlModel> list) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(RestUrl.updateProfile));
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['name'] = fullName;
      request.fields['username'] = username;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['gender'] = gender;
      request.fields['website_url'] = websiteUrl;
      request.fields['bio'] = bio;
      request.fields['youtube'] = list[0].url;
      request.fields['facebook'] = list[1].url;
      request.fields['instagram'] = list[2].url;
      request.fields['twitter'] = list[3].url;

      if (profileImg.isNotEmpty) {
        http.MultipartFile file =
            await http.MultipartFile.fromPath('avatar', profileImg);
        request.files.add(file);
      }
      response = await http.Response.fromStream(await request.send());
      if (response != null) {
        if (response.statusCode == 200) {
          response = http.Response(jsonEncode(response.body), 200, headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });
        } else if (response.statusCode == 404) {
          response = http.Response(
              jsonEncode({'status': false, 'message': '404'}), 200);
        } else if (response.statusCode == 401) {
          response = response;
        }
      } else {
        response = http.Response(
            jsonEncode(
                {'status': false, 'message': 'Unable to Connect to Server!'}),
            200);
      }
    } catch (e) {
      response = http.Response(
          jsonEncode({'status': false, 'message': e.toString()}), 200);
    }
    return response;
  }

  static Future<http.Response> getAllVideo() async {
    http.Response response;

    var result = await RestClient.getData(
      RestUrl.getVideoList,
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> likeAndDislike(int videoId, int isLike) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.likeDislike,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'video_id': videoId.toString(),
        'is_like': isLike.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> checkPhone(String phone) async {
    http.Response response;
    var result = await RestClient.postData(
      RestUrl.checkPhone,
      body: {'phone': phone},
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> resetPassword(
      String phone, String password) async {
    http.Response response;
    var result = await RestClient.postData(
      RestUrl.resetPass,
      body: {'phone': phone, 'password': password},
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> getUserProfile(int userid) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.getUserProfile,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'id': userid.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> postVideo(
      String videoUrl,
      String sound,
      String soundName,
      String category,
      String hashtags,
      String visibility,
      int isCommentAllowed,
      String description,
      String filterImg,
      String language,
      String gifName,
      String speed,
      bool isDuetable,
      bool isCommentable,
      String? duetFrom,
      bool isDuet,
      int soundOwnerId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var currentUser = instance.getString('currentUser');
    User current = User.fromJson(jsonDecode(currentUser!));

    var result = await RestClient.postData(
      RestUrl.postNewVideo,
      headers: {
        'Authorization': 'Bearer $token',
        "Accept": 'application/json; charset=utf-8'
      },
      body: {
        'user_id': current.id.toString(),
        'video': videoUrl,
        'sound': sound,
        'sound_name': soundName,
        'filter': filterImg,
        'language': language,
        'category': category,
        'hashtags': hashtags,
        'visibility': visibility,
        'is_comment_allowed': isCommentAllowed.toString(),
        'description': description,
        'gif_image': gifName,
        'speed': speed,
        'is_duetable': isDuetable ? "Yes" : "No",
        'is_commentable': isCommentable ? "Yes" : "No",
        'is_duet': isDuet ? "Yes" : "No",
        'duet_from': duetFrom ?? '',
        'sound_owner': soundOwnerId.toString()
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> likeDislikeComment(
      int videoId, int isLike) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");

    var result = await RestClient.postData(
      RestUrl.likeDislikeComment,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'video_id': videoId.toString(),
        'is_like': isLike.toString(),
      },
    );

    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> postComment(
      int videoId, int userId, String commentMsg) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");

    var result = await RestClient.postData(
      RestUrl.postComment,
      headers: {
        'Authorization': 'Bearer $token',
        "Accept": 'application/json; charset=utf-8'
      },
      body: {
        'video_id': videoId.toString(),
        'comment_by': userId.toString(),
        'comment': commentMsg,
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCommentListOnVideo(int videoId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.getCommentList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'video_id': videoId.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getWheelDetails() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.wheelDetails,
      headers: {
        'Authorization': 'Bearer ${GetStorage().read("token")}',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> updateWheel(int rewardId) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");

    var result = await RestClient.postData(
      RestUrl.wheelUpdate,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'reward_id': rewardId.toString(),
      },
    );

    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> getWheelEarnedDetails() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.wheelEarned,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideoFields() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(RestUrl.getVideoFields, headers: {
      'Authorization': 'Bearer $token',
    });
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getDiscoverBanner() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getBanner,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideoWithHash() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getVideoByHashtag,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getPrivateVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getPrivateVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getSounds() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.getSoundList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {},
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> countViewVideo(int videoId) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");

    var result = await RestClient.postData(
      RestUrl.viewCount,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'video_id': videoId.toString(),
      },
    );

    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> followUserAndUnfollow(
      int publisherId, String action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.followUnfollow,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'publisher_user_id': publisherId.toString(),
        'action': action,
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> commentLikeAndDislike(
      int commentId, int isLike) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.commentLikeDislike,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'comment_id': commentId.toString(),
        'is_like': isLike.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> addAndRemoveFavariteSoundHastag(
      int id, String type, int action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.favrateSundHastagRemoveAdd,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'id': id.toString(),
        'type': type,
        'action': action.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> getFavriteItems() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getFavriteList,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getSoundCategories() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getSoundCategories,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> getSoundList() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.getSoundList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        //"category_id": categoryId.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> setNotificationSetting(
      String type, int action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.notificationSetting,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'type': type,
        'action': action.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getNotificationSetting() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.notificationSetting,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> deactiveAccount() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.deactiveAc,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> sendVerification(
      String fullname, String fileImg, String username) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(RestUrl.userVerification));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields['username'] = username;
      request.fields['full_name'] = fullname;

      if (fileImg.isNotEmpty) {
        http.MultipartFile file =
            await http.MultipartFile.fromPath('file', fileImg);
        request.files.add(file);
      }
      response = await http.Response.fromStream(await request.send());
      if (response != null) {
        if (response.statusCode == 200) {
          response = response;
        } else if (response.statusCode == 404) {
          response = http.Response(
              jsonEncode({'status': false, 'message': '404'}), 200);
        } else if (response.statusCode == 401) {
          response = response;
        }
      } else {
        response = http.Response(
            jsonEncode(
                {'status': false, 'message': 'Unable to Connect to Server!'}),
            200);
      }
    } catch (e) {
      response = http.Response(
          jsonEncode({'status': false, 'message': e.toString()}), 200);
    }
    return response;
  }

  static Future<http.Response> checkAccountStatus() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.checkAcStatus,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getUserPublicVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var loginData = instance.getString('currentUser');
    User user = User.fromJson(jsonDecode(loginData!));
    var result = await RestClient.postData(
      RestUrl.userAllVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': user.id.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getUserLikedVideo({int? userID}) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var loginData = instance.getString('currentUser');
    User user = User.fromJson(jsonDecode(loginData!));
    var result = await RestClient.postData(RestUrl.userLikedVideo, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'user_id': userID == null ? user.id.toString() : userID.toString(),
    });
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getUserPrivateVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");

    var result = await RestClient.getData(
      RestUrl.userPrivateVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getHashtagList() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getHashtagList,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCommissionSetting() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.settingAdminCommission,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }

  static Future<http.Response> getWalletBalance() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.getUserWalletBalance,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> sendWithdrawlRequest(String currency,
      String upiId, String network, String fee, String amount) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.withdrawRequest,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'currency': currency,
        'address_upi': upiId,
        'network_name': network,
        'network_fee': fee,
        'amount': amount
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getPaymentHistory() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.paymentHistory,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideosBySound(String sound) async {
    http.Response response;

    var token = GetStorage().read("token");
    var result = await RestClient.postData(
      RestUrl.videoBySound,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'sound': sound},
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getAvailableProbilityCounter() async {
    http.Response response;
    var tempToken =
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzdkZWQ4Y2VkNDUwZDE1NWQ0NzY5NjFkYmUzOGNlZjJlODk4ZDAxNjk0NzdiNTZmMmIxMGI1MGYxZTI4OTcwYzljYmRlMGFiNzk2OWM2NjIiLCJpYXQiOjE2NjYzNDE0MzkuNjYzOTk0LCJuYmYiOjE2NjYzNDE0MzkuNjYzOTk3LCJleHAiOjE2OTc4Nzc0MzkuNjU5NDExLCJzdWIiOiIxNiIsInNjb3BlcyI6W119.wQrhTRwPK8IeEhAfYiZId3COXKOoQhzTQay9qnsY64JfYUUEAbgwbhJ-t7OAwJ3Xj8An1Fn6r0j4CkPA96Y_gE3cMQkposykW6p5yoB2lk7xgY602JPRTMDC752pP-ePZqP7WOyV-AiC0Obs2kbMtIbsNqd6NufAIVpXTY8HzHdXivXgnHqOazcsJAffo8mkcEW--bQy4gnT6TZuxQ7sxdc4Br-IYbft-MksrfzVsERg91K5lkWSjlmvOY9fqi3rmvitpv1g6TOlQ6WiU5GEdIZAs_kQGWWOVksGYCv2tubOd5VAHbn_reL7u2R1KgJ8UwcvI21NS4CmjYqTNz_C_zCeVjBT6Zvxr4vjn4AjWvKm0HoS2WwbtOBdXTwRnO6riPjjLt06w-Ez3j4tvlp0ZOGfw_wLj8S-VqNO3AvanySEhyusEyYsOSqywy9tiztA0Uxos_VENpCkAcDn5YlU0QUsil1xPaQwwpaqOo3eFKfV_LgSVuvKG1kO0yBGW2vDd8F2F3Xuchls_HAHaJ2ePy8V1w4Mrnychq6mv1BD1uxjp113bR3NSjWPsk2oDbdii-zSp-MwxR3UX3zvNPbU6NeVFqsS6-6Oc84PQqO9VGVlhkTZBRzfZEXnKaO0Rh2XhX6NTgOb6XIv972WkCUijggOUbjKfGKAAyUdm5jKdro";

    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getProbilityCounter,
      headers: {
        'Authorization': tempToken,
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCmsPage(String slug) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.cmsPage,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'slug': slug},
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getSiteSettings() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.siteSettings,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        //'slug': slug
      },
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getUserPublicVideos(int id) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var result = await RestClient.postData(
      RestUrl.userAllVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'user_id': id.toString()},
    );

    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getPopularVideos() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.popularVideos,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getFollowingVideos() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.followingVideos,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> sendOTP(String mobileNumber) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.sendOTP,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'phone': mobileNumber},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> verifyOTP(
      String mobileNumber, String otp) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.verifyOTP,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'phone': mobileNumber, 'otp': otp},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getNotificationList() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.notificationList,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getInbox() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = GetStorage().read("token");
    var result = await RestClient.getData(
      RestUrl.inbox,
      headers: {
        'Authorization':
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiZjM0NmQ0Zjk0MzY3NDg0MGVlZTRkZWQzNTFjOGQ2Y2NmMjMzM2E4ZGIwYWE2MjMzMGNiZGYxNjI4MWM1YzU2MGU5NjkzZjNlNzg4YjkyNWEiLCJpYXQiOjE2NTgzOTk5NjguMzY3NTE4LCJuYmYiOjE2NTgzOTk5NjguMzY3NTIyLCJleHAiOjE2ODk5MzU5NjguMzYyMzMxLCJzdWIiOiIyIiwic2NvcGVzIjpbXX0.L6P2281VvL7BDqLWeKvZA8h7PEaYQZXjy5ysGxjDFF8qyeUh6GT3FJ4YbKZ_sfiZkCv1FdZCrML8Kr4OulOl4JGBnBXj_lNoP2mHfmOI-anx4fb_tipINA8kQ0PLM2HDyXV7ZtTDQt-Oyw1u8M7A3NB9NMXg377mZvkt_ZuoUpqX4ScJYJ-uNrhBBZEK_LTXJl_tlCDpJEbmFlOvKu6xCuiC-Iaj2KabYuWbDT3FZ7W6hr2-YVQsvlOqXRU5ynLhSekAdo-4kAEUxT_T_isXNSCQiDkWGDDmlwlAqAqdKE5VfyOB3Dgjb5QoTyH8Om3E-bY43xKa3Q9J9Ibpvu6iVeQRlQgRsU2nRGecOvTzr3WQN_pB3R78fmtqk2AJ-sjAzCf1AxWKc5JgAqixkYqBUJPksoIM9voyAQn0wd1-652LUtUeapd16W0-nNB1LTqMEFuq3cwJyjMUdZ-RwBKXA087lbfKut6fy3UQy-1fXDsBKd1cH4wJMG1N2BUhaZXmZNQyf37TDoWxC4YdkemKY0t0GVKHLduCO1q530g8wHjvE6Mpp60YWERsMkKaQ0eXC1o-OatDhAPbAobLM4GJnaSWe3s-wX_SMvp9ZgiP5zMUPKgWCTMzU43URWn2YMiqOPJjN5l6KoAaVMCZw6AsDIGdcFs4Xc9QItRFPtwvO7M',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> sendChatNotification(
      String otherUserId, String message) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.sendChatNotification,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'other_user_id': otherUserId, 'message': message},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> saveSafetyPreference(
      String type, String change) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.safetyPreference,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'type': type, 'action': change},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getSafetyPreference() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.safetyPreference,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getFollowerList(int? userId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.followerList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'user_id': userId.toString()},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getFollowingList(int userId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.followingList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'user_id': userId.toString()},
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> reportUser(int userId, String reason) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.reportUser,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'reported_user': userId.toString(),
        'report_reason': reason,
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> checkBlock(int userId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.checkBlock,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'blocked_user': userId.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> blockUnblockUser(int userId, bool block) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.blockUnblockUser,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'blocked_user': userId.toString(),
        'action': block ? "Unblock" : "Block"
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> deleteVideo(int videoId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.deleteVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'video_id': videoId.toString()},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> publishPrivateVideo(int videoId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.publishPrivateVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'video_id': videoId.toString()},
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCurrencyDeatils() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.currencyDetails,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }

  static Future<http.Response> checkVideoReport(int videoId, int userId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(RestUrl.checkReport, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'video_id': videoId.toString(),
      'reported_by': userId.toString()
    });
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }

  static Future<http.Response> reportVideo(
      int videoId, int userId, String reason) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(RestUrl.reportVideo, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'video_id': videoId.toString(),
      'reported_by': userId.toString(),
      'reason': reason
    });
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }

  static Future<http.Response> favUnFavVideo(int videoId, String action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(RestUrl.favUnfavVideo, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'video_id': videoId.toString(),
      'action': action
    });
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }

  static Future<http.Response> getFavVideos() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.favVideos,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    });

    return response;
  }
}
