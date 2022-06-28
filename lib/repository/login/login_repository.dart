import 'dart:convert';
import 'package:thrill/repository/login/login_base_repository.dart';
import '../../models/social_url_model.dart';
import '../../rest/rest_api.dart';

class LoginRepository extends BaseLoginRepository {
  @override
  Future<dynamic> loginUser(String phone, String password) async {
    try {
      var result = await RestApi.login(phone, password);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> registerUser(
      String fullName, String phone, String dob, String password) async {
    try {
      var result = await RestApi.register(fullName, phone, dob, password);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> socialLoginRegister(String id, String type, String email,String name)async {
    try {
      var result = await RestApi.socialLoginRegister(id, type, email,name);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> updateProfile(String username, String fname,String lname,String imageFile,String gender,String webUrl,String bio,List<SocialUrlModel> list)async {
    try {
      var result = await RestApi.updateProfile(fname, lname, imageFile, username, gender, webUrl, bio,list);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> isPhoneExist(String phone)async{
    try {
      var result = await RestApi.checkPhone(phone);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> resetPass(String phone,String password)async{
    try {
      var result = await RestApi.resetPassword(phone,password);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> getProfile(int userId)async {
    try {
      var result = await RestApi.getUserProfile(userId);
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> getLikesVideo()async {
    try {
      var result = await RestApi.getUserLikedVideo();
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> getPrivateVideo()async {
    try {
      var result = await RestApi.getUserPrivateVideo();
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }

  @override
  Future<dynamic> getPublicVideo()async {
    try {
      var result = await RestApi.getUserPublicVideo();
      var json = jsonDecode(result.body);
      return json;
    } catch (_) {}
    return null;
  }
}
