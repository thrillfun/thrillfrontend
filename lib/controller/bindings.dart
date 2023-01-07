import 'package:get/get.dart';
import 'package:thrill/controller/Favourites/favourites_controller.dart';
import 'package:thrill/controller/InboxController.dart';
import 'package:thrill/controller/comments/comments_controller.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/hashtags/search_hashtags_controller.dart';
import 'package:thrill/controller/hashtags/top_hashtags_controller.dart';
import 'package:thrill/controller/home/home_controller.dart';
import 'package:thrill/controller/image/image_controller.dart';
import 'package:thrill/controller/privacy_and_conditions/privacy_and_conditions_controller.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users/followers_controller.dart';
import 'package:thrill/controller/users/other_users_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/controller/videos/UserVideosController.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/controller/wallet/wallet_balance_controller.dart';
import 'package:thrill/controller/wallet/wallet_currencies_controller.dart';
import 'package:thrill/controller/wallet_controller.dart';
import 'package:thrill/controller/wheel_controller.dart';

import 'data_controller.dart';
import 'videos/PrivateVideosController.dart';
import 'videos/like_videos_controller.dart';

class DataBindings extends Bindings {
  @override
  void dependencies() {
    //home
    Get.lazyPut(() => HomeController(), fenix: true);
    //users
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => FollowersController(), fenix: true);
    Get.lazyPut(() => UserDetailsController(), fenix: true);
    Get.lazyPut(() => OtherUsersController(), fenix: true);

    //videos

    Get.lazyPut(() => VideosController(), fenix: true);
    Get.lazyPut(() => RelatedVideosController(), fenix: true);
    Get.lazyPut(() => FollowingVideosController(), fenix: true);
    Get.lazyPut(() => LikedVideosController(), fenix: true);
    Get.lazyPut(() => PrivateVideosController(), fenix: true);
    Get.lazyPut(() => UserVideosController(), fenix: true);

    //
    Get.lazyPut(() => SoundsController(), fenix: true);
    Get.lazyPut(() => FavouritesController(), fenix: true);

    //
    Get.lazyPut(() => CommentsController(), fenix: true);

    // hastags
    Get.lazyPut(() => TopHashtagsController(), fenix: true);
    Get.lazyPut(() => DiscoverController(), fenix: true);
    Get.lazyPut(() => SearchHashtagsController(), fenix: true);

    //
    Get.lazyPut(() => WheelController(), fenix: true);

    // wallet
    Get.lazyPut(() => WalletController(), fenix: true);
    Get.lazyPut(() => WalletBalanceController(), fenix: true);
    Get.lazyPut(() => WalletCurrenciesController(), fenix: true);

    //inbox
    Get.lazyPut(() => InboxController(), fenix: true);

    //privacy
    Get.lazyPut(() => PrivacyAndConditionsController(), fenix: true);
    //image
    Get.lazyPut(() => ImageController(), fenix: true);
  }
}
