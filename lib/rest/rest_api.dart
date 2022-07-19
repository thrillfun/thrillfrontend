import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/social_url_model.dart';
import 'package:thrill/rest/rest_client.dart';
import 'package:thrill/rest/rest_url.dart';
import '../models/user.dart';

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
      String firstName,
      String lastName,
      String profileImg,
      String username,
      String gender,
      String websiteUrl,
      String bio,
      List<SocialUrlModel> list
   ) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(RestUrl.updateProfile));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
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
          response = http.Response(jsonEncode(response.body), 200,headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });
        } else if (response.statusCode == 404) {
          response = http.Response(jsonEncode({'status': false, 'message': '404'}), 200);
        } else if (response.statusCode == 401) {
          response = response;
        }
      } else {
        response = http.Response(jsonEncode({'status': false, 'message': 'Unable to Connect to Server!'}), 200);
      }
    } catch (e) {
      response = http.Response(jsonEncode({'status': false, 'message': e.toString()}), 200);
    }
    return response;
  }

  static Future<http.Response> getAllVideo() async {
    http.Response response;

    var result = await RestClient.getData(
      RestUrl.getVideoList,
    );

    response = http.Response(jsonEncode(result), 200,headers: {
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
      body: {
        'phone': phone
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> resetPassword(String phone,String password) async {
    http.Response response;
    var result = await RestClient.postData(
      RestUrl.resetPass,
      body: {
        'phone': phone,
        'password':password
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> getUserProfile(int userid) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.getUserProfile,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'id': userid.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200);
    return response;
  }

  static Future<http.Response> postVideo(String videoUrl,
      String sound,String soundName,String category,String hashtags,String visibility,
      int isCommentAllowed,String description,String filterImg,String language, String gifName, String speed) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

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
        'is_comment_allowed':isCommentAllowed.toString(),
        'description':description,
        'gif_image':gifName,
        'speed': speed
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> likeDislikeComment(
      int videoId,int isLike) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

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
      int videoId,int userId,String commentMsg) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

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

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCommentListOnVideo(int videoId) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.getCommentList,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'video_id': videoId.toString(),
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getWheelDetails() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.wheelDetails,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> updateWheel(int rewardId) async {
    http.Response response;

    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

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
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.wheelEarned,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideoFields() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getVideoFields,
      headers: {
        'Authorization': 'Bearer $token',
      }
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getDiscoverBanner() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getBanner,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideoWithHash() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getVideoByHashtag,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getPrivateVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getPrivateVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getSounds() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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
    var token = instance.getString('currentToken');

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

  static Future<http.Response> followUserAndUnfollow(int publisherId, String action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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

  static Future<http.Response> commentLikeAndDislike(int commentId, int isLike) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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

  static Future<http.Response> addAndRemoveFavariteSoundHastag(int id, String type,int action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getFavriteList,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getSoundCategories() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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
    var token = instance.getString('currentToken');
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

  static Future<http.Response> setNotificationSetting(String type,int action) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getNotificationSetting() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.notificationSetting,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> deactiveAccount() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.deactiveAc,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> sendVerification(
      String fullname,
      String fileImg,
      String username
      ) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
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
          response = http.Response(jsonEncode({'status': false, 'message': '404'}), 200);

        } else if (response.statusCode == 401) {
          response = response;
        }
      } else {
        response = http.Response(jsonEncode({'status': false, 'message': 'Unable to Connect to Server!'}), 200);
      }
    } catch (e) {
      response = http.Response(jsonEncode({'status': false, 'message': e.toString()}), 200);
    }
    return response;
  }

  static Future<http.Response> checkAccountStatus() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.checkAcStatus,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> getUserPublicVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var loginData=instance.getString('currentUser');
    UserModel user=UserModel.fromJson(jsonDecode(loginData!));
    var result = await RestClient.postData(
      RestUrl.userAllVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': user.id.toString(),
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> getUserLikedVideo({int? userID}) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var loginData=instance.getString('currentUser');
    UserModel user=UserModel.fromJson(jsonDecode(loginData!));

    var result = await RestClient.postData(
      RestUrl.userLikedVideo,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': userID==null?user.id.toString():userID.toString(),
      }
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> getUserPrivateVideo() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var result = await RestClient.getData(
        RestUrl.userPrivateVideo,
        headers: {
          'Authorization': 'Bearer $token',
        },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> getHashtagList() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
        RestUrl.getHashtagList,
        headers: {
          'Authorization': 'Bearer $token',
        },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> getCommissionSetting() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.settingAdminCommission,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
  static Future<http.Response> getWalletBalance() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getUserWalletBalance,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> sendWithdrawlRequest(String currency,String upiId,String payMethod,String amount) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.withdrawRequest,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'currency': currency,
        'payment_address_user': upiId,
        'payment_network_user': payMethod,
        'amount': amount
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getPaymentHistory() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.paymentHistory,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  static Future<http.Response> getVideosBySound(String sound) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.videoBySound,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'sound': sound
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }




  static Future<http.Response> getAvailableProbilityCounter() async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.getData(
      RestUrl.getProbilityCounter,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
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
      body: {
        'slug': slug
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
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

    response = http.Response(jsonEncode(result), 200,headers: {
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
      body: {
        'user_id': id.toString()
      },
    );

    response = http.Response(jsonEncode(result), 200,headers: {
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
    response = http.Response(jsonEncode(result), 200,headers: {
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
    response = http.Response(jsonEncode(result), 200,headers: {
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
      body: {
        'phone': mobileNumber
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

  static Future<http.Response> verifyOTP(String mobileNumber, String otp) async {
    http.Response response;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var result = await RestClient.postData(
      RestUrl.verifyOTP,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'phone': mobileNumber,
        'otp': otp
      },
    );
    response = http.Response(jsonEncode(result), 200,headers: {
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
    response = http.Response(jsonEncode(result), 200,headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });
    return response;
  }

}
