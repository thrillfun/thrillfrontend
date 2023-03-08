import 'package:get/get.dart';

import '../modules/discover/bindings/discover_binding.dart';
import '../modules/discover/hash_tags_details/bindings/hash_tags_details_binding.dart';
import '../modules/discover/hash_tags_details/views/hash_tags_details_view.dart';
import '../modules/discover/search/bindings/search_binding.dart';
import '../modules/discover/search/views/search_view.dart';
import '../modules/discover/views/discover_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/otpverify/bindings/otpverify_binding.dart';
import '../modules/login/otpverify/views/otpverify_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/others_profile/views/others_profile_view.dart' as others;
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/user_liked_videos/bindings/user_liked_videos_binding.dart';
import '../modules/profile/user_liked_videos/views/user_liked_videos_view.dart';
import '../modules/profile/user_private_videos/bindings/user_private_videos_binding.dart';
import '../modules/profile/user_private_videos/views/user_private_videos_view.dart';
import '../modules/profile/user_videos/bindings/user_videos_binding.dart';
import '../modules/profile/user_videos/views/user_videos_view.dart';
import '../modules/profile/users_following/bindings/users_following_binding.dart';
import '../modules/profile/users_following/followers/bindings/followers_binding.dart';
import '../modules/profile/users_following/followers/views/followers_view.dart';
import '../modules/profile/users_following/followings/bindings/followings_binding.dart';
import '../modules/profile/users_following/followings/views/followings_view.dart';
import '../modules/profile/users_following/views/users_following_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/related_videos/bindings/related_videos_binding.dart';
import '../modules/related_videos/views/related_videos_view.dart';
import '../modules/sounds/bindings/sounds_binding.dart';
import '../modules/sounds/views/sounds_view.dart';
import '../modules/spin_wheel/bindings/spin_wheel_binding.dart';
import '../modules/spin_wheel/user_levels/bindings/user_levels_binding.dart';
import '../modules/spin_wheel/user_levels/views/user_levels_view.dart';
import '../modules/spin_wheel/views/spin_wheel_view.dart';
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';
import '../modules/wallet/wallet_trasactions/bindings/wallet_trasactions_binding.dart';
import '../modules/wallet/wallet_trasactions/views/wallet_trasactions_view.dart';

import '../modules/others_profile/bindings/others_profile_binding.dart'
    as others;
import '../modules/others_profile/other_user_videos/bindings/other_user_videos_binding.dart'
    as others;
import '../modules/others_profile/other_user_videos/views/other_user_videos_view.dart'
    as others;
import '../modules/others_profile/others_following/bindings/others_following_binding.dart'
    as others;
import '../modules/others_profile/others_following/followers/bindings/followers_binding.dart'
    as others;
import '../modules/others_profile/others_following/followers/views/followers_view.dart'
    as others;
import '../modules/others_profile/others_following/following/bindings/following_binding.dart'
    as others;
import '../modules/others_profile/others_following/following/views/following_view.dart'
    as others;
import '../modules/others_profile/others_following/views/others_following_view.dart'
    as others;
import '../modules/others_profile/others_liked_videos/bindings/others_liked_videos_binding.dart'
    as others;
import '../modules/others_profile/others_liked_videos/views/others_liked_videos_view.dart'
    as others;

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
      children: [
        GetPage(
          name: _Paths.OTPVERIFY,
          page: () => OtpverifyView(),
          binding: OtpverifyBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.RELATED_VIDEOS,
      page: () => RelatedVideosView(),
      binding: RelatedVideosBinding(),
    ),
    GetPage(
      name: _Paths.DISCOVER,
      page: () => const DiscoverView(),
      binding: DiscoverBinding(),
      children: [
        GetPage(
          name: _Paths.SEARCH,
          page: () => SearchView(),
          binding: SearchBinding(),
        ),
        GetPage(
          name: _Paths.HASH_TAGS_DETAILS,
          page: () => const HashTagsDetailsView(),
          binding: HashTagsDetailsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.WALLET,
      page: () => const WalletView(),
      binding: WalletBinding(),
      children: [
        GetPage(
          name: _Paths.WALLET_TRASACTIONS,
          page: () => const WalletTrasactionsView(),
          binding: WalletTrasactionsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      children: [
        GetPage(
          name: _Paths.USER_VIDEOS,
          page: () => const UserVideosView(),
          binding: UserVideosBinding(),
        ),
        GetPage(
          name: _Paths.USER_PRIVATE_VIDEOS,
          page: () => const UserPrivateVideosView(),
          binding: UserPrivateVideosBinding(),
        ),
        GetPage(
          name: _Paths.USER_LIKED_VIDEOS,
          page: () => const UserLikedVideosView(),
          binding: UserLikedVideosBinding(),
        ),
        GetPage(
          name: _Paths.USERS_FOLLOWING,
          page: () => const UsersFollowingView(),
          binding: UsersFollowingBinding(),
          children: [
            GetPage(
              name: _Paths.FOLLOWINGS,
              page: () => const FollowingsView(),
              binding: FollowingsBinding(),
            ),
            GetPage(
              name: _Paths.FOLLOWERS,
              page: () => const FollowersView(),
              binding: FollowersBinding(),
              children: [
                GetPage(
                  name: _Paths.FOLLOWERS,
                  page: () => const FollowersView(),
                  binding: FollowersBinding(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GetPage(
      name: _Paths.SPIN_WHEEL,
      page: () => SpinWheelView(),
      binding: SpinWheelBinding(),
      children: [
        GetPage(
          name: _Paths.USER_LEVELS,
          page: () => const UserLevelsView(),
          binding: UserLevelsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.OTHERS_PROFILE,
      page: () => const others.OthersProfileView(),
      binding: others.OthersProfileBinding(),
      children: [
        GetPage(
          name: _Paths.OTHER_USER_VIDEOS,
          page: () => const others.OtherUserVideosView(),
          binding: others.OtherUserVideosBinding(),
        ),
        GetPage(
          name: _Paths.OTHERS_LIKED_VIDEOS,
          page: () => const others.OthersLikedVideosView(),
          binding: others.OthersLikedVideosBinding(),
        ),
        GetPage(
          name: _Paths.OTHERS_FOLLOWING,
          page: () => const others.OthersFollowingView(),
          binding: others.OthersFollowingBinding(),
          children: [
            GetPage(
              name: _Paths.FOLLOWING,
              page: () => const others.FollowingView(),
              binding: others.FollowingBinding(),
            ),
          ],
        ),
      ],
    ),
    GetPage(
      name: _Paths.SOUNDS,
      page: () => const SoundsView(),
      binding: SoundsBinding(),
    ),
  ];
}
