import 'package:get/get.dart';
import 'package:thrill/app/modules/discover/controllers/discover_controller.dart';
import 'package:thrill/app/modules/discover/hash_tags_details/controllers/hash_tags_details_controller.dart';
import 'package:thrill/app/modules/discover/search/controllers/search_controller.dart';
import 'package:thrill/app/modules/home/controllers/home_controller.dart';
import 'package:thrill/app/modules/login/otpverify/controllers/otpverify_controller.dart';
import 'package:thrill/app/modules/others_profile/controllers/others_profile_controller.dart';
import 'package:thrill/app/modules/others_profile/other_user_videos/controllers/other_user_videos_controller.dart';
import 'package:thrill/app/modules/others_profile/others_following/controllers/others_following_controller.dart';
import 'package:thrill/app/modules/others_profile/others_following/following/controllers/others_following_controller.dart';
import 'package:thrill/app/modules/others_profile/others_following/followers/controllers/others_followers_controller.dart' as others;

import 'package:thrill/app/modules/profile/controllers/profile_controller.dart';
import 'package:thrill/app/modules/profile/user_liked_videos/controllers/user_liked_videos_controller.dart';
import 'package:thrill/app/modules/profile/user_private_videos/controllers/user_private_videos_controller.dart';
import 'package:thrill/app/modules/profile/user_videos/controllers/user_videos_controller.dart';
import 'package:thrill/app/modules/profile/users_following/controllers/users_following_controller.dart';
import 'package:thrill/app/modules/profile/users_following/followers/controllers/followers_controller.dart';
import 'package:thrill/app/modules/profile/users_following/followings/controllers/followings_controller.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/modules/sounds/controllers/sounds_controller.dart';
import 'package:thrill/app/modules/spin_wheel/controllers/spin_wheel_controller.dart';
import 'package:thrill/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:thrill/app/modules/wallet/wallet_trasactions/controllers/wallet_trasactions_controller.dart';

import '../login/controllers/login_controller.dart';
import '../others_profile/others_liked_videos/controllers/others_liked_videos_controller.dart';
import '../spin_wheel/user_levels/controllers/user_levels_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(),fenix: true);
    Get.lazyPut(() => HomeController(),fenix: true);
    Get.lazyPut(() => OtpverifyController(),fenix: true);
    Get.lazyPut(() => RelatedVideosController(),fenix: true);
    Get.lazyPut(() => DiscoverController(),fenix: true);
    Get.lazyPut(() => WalletController(),fenix: true);
    Get.lazyPut(() => WalletTrasactionsController(),fenix: true);
    Get.lazyPut(() => ProfileController(),fenix: true);
    Get.lazyPut(() => UserVideosController(),fenix: true);
    Get.lazyPut(() => UserPrivateVideosController(),fenix: true);
    Get.lazyPut(() => UserLikedVideosController(),fenix: true);
    Get.lazyPut(() => SearchController(),fenix: true);
    Get.lazyPut(() => UsersFollowingController(),fenix: true);
    Get.lazyPut(() => FollowingsController(),fenix: true);
    Get.lazyPut(() => FollowersController(),fenix: true);
    Get.lazyPut(() => SpinWheelController(),fenix: true);
    Get.lazyPut(() => UserLevelsController(),fenix: true);
    Get.lazyPut(() => OthersProfileController(),fenix: true);
    Get.lazyPut(() => OtherUserVideosController(),fenix: true);
    Get.lazyPut(() => OthersLikedVideosController(),fenix: true);
    Get.lazyPut(() => OtherssFollowingController(),fenix: true);
    Get.lazyPut(() => OthersFollowingController(),fenix: true);
    Get.lazyPut(() => others.OtherFollowersController(),fenix: true);
    Get.lazyPut(() => HashTagsDetailsController(),fenix: true);
    Get.lazyPut(() => SoundsController(),fenix: true);










  }

}