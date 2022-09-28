import 'package:thrill/models/social_url_model.dart';

abstract class BaseLoginRepository {
  Future<void> loginUser(String phone, String password);

  Future<void> registerUser(
      String fullName, String phone, String dob, String password);

  Future<void> socialLoginRegister(
      String id, String type, String email, String name);

  Future<void> updateProfile(
      String fullName,
      String username,
      String fname,
      String lname,
      String imageFile,
      String gender,
      String webUrl,
      String bio,
      List<SocialUrlModel> list);

  Future<void> isPhoneExist(String phone);

  Future<void> resetPass(String phone, String password);

  Future<void> getProfile(int userId);

  Future<void> getLikesVideo();

  Future<void> getPrivateVideo();

  Future<void> getPublicVideo();
}
