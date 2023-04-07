import 'package:get/get.dart';

import '../modules/camera/bindings/camera_binding.dart';
import '../modules/camera/post_screen/bindings/post_screen_binding.dart';
import '../modules/camera/post_screen/views/post_screen_view.dart';
import '../modules/camera/select_sound/bindings/select_sound_binding.dart';
import '../modules/camera/select_sound/views/select_sound_view.dart';
import '../modules/camera/views/camera_view.dart';
import '../modules/comments/bindings/comments_binding.dart';
import '../modules/comments/views/comments_view.dart';
import '../modules/discover/bindings/discover_binding.dart';
import '../modules/discover/discover_video_player/bindings/discover_video_player_binding.dart';
import '../modules/discover/discover_video_player/views/discover_video_player_view.dart';
import '../modules/discover/hash_tags_details/bindings/hash_tags_details_binding.dart';
import '../modules/discover/hash_tags_details/hash_tags_video_player/bindings/hash_tags_video_player_binding.dart';
import '../modules/discover/hash_tags_details/hash_tags_video_player/views/hash_tags_video_player_view.dart';
import '../modules/discover/hash_tags_details/views/hash_tags_details_view.dart';
import '../modules/discover/search/bindings/search_binding.dart';
import '../modules/discover/search/search_videos_player/bindings/search_videos_player_binding.dart';
import '../modules/discover/search/search_videos_player/views/search_videos_player_view.dart';
import '../modules/discover/search/views/search_view.dart';
import '../modules/discover/views/discover_view.dart';
import '../modules/following_videos/bindings/following_videos_binding.dart';
import '../modules/following_videos/views/following_videos_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/home_videos_player/bindings/home_videos_player_binding.dart';
import '../modules/home/home_videos_player/views/home_videos_player_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/otpverify/bindings/otpverify_binding.dart';
import '../modules/login/otpverify/views/otpverify_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/others_profile/others_liked_videos_player/bindings/others_liked_videos_player_binding.dart';
import '../modules/others_profile/others_liked_videos_player/views/others_liked_videos_player_view.dart';
import '../modules/others_profile/others_profile_videos/bindings/others_profile_videos_binding.dart';
import '../modules/others_profile/others_profile_videos/views/others_profile_videos_view.dart';
import '../modules/others_profile/views/others_profile_view.dart' as others;
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/profile/edit_profile/views/edit_profile_view.dart';
import '../modules/profile/liked_video_player/bindings/liked_video_player_binding.dart';
import '../modules/profile/liked_video_player/views/liked_video_player_view.dart';
import '../modules/profile/private_videos_player/bindings/private_videos_player_binding.dart';
import '../modules/profile/private_videos_player/views/private_videos_player_view.dart';
import '../modules/profile/profile_videos/bindings/profile_videos_binding.dart';
import '../modules/profile/profile_videos/views/profile_videos_view.dart';
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
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/customer_support/bindings/customer_support_binding.dart';
import '../modules/settings/customer_support/views/customer_support_view.dart';
import '../modules/settings/favourites/bindings/favourites_binding.dart';
import '../modules/settings/favourites/favourite_hashtags/bindings/favourite_hashtags_binding.dart';
import '../modules/settings/favourites/favourite_hashtags/views/favourite_hashtags_view.dart';
import '../modules/settings/favourites/favourite_sounds/bindings/favourite_sounds_binding.dart';
import '../modules/settings/favourites/favourite_sounds/views/favourite_sounds_view.dart';
import '../modules/settings/favourites/favourite_videos/bindings/favourite_videos_binding.dart';
import '../modules/settings/favourites/favourite_videos/favourite_video_player/bindings/favourite_video_player_binding.dart';
import '../modules/settings/favourites/favourite_videos/favourite_video_player/views/favourite_video_player_view.dart';
import '../modules/settings/favourites/favourite_videos/views/favourite_videos_view.dart';
import '../modules/settings/favourites/views/favourites_view.dart';
import '../modules/settings/inbox/bindings/inbox_binding.dart';
import '../modules/settings/inbox/views/inbox_view.dart';
import '../modules/settings/notifications_settings/bindings/notifications_settings_binding.dart';
import '../modules/settings/notifications_settings/views/notifications_settings_view.dart';
import '../modules/settings/privacy/bindings/privacy_binding.dart';
import '../modules/settings/privacy/views/privacy_view.dart';
import '../modules/settings/profile_details/bindings/profile_details_binding.dart';
import '../modules/settings/profile_details/views/profile_details_view.dart';
import '../modules/settings/qr_code/bindings/qr_code_binding.dart';
import '../modules/settings/qr_code/views/qr_code_view.dart';
import '../modules/settings/referal/bindings/referal_binding.dart';
import '../modules/settings/referal/views/referal_view.dart';
import '../modules/settings/terms_of_service/bindings/terms_of_service_binding.dart';
import '../modules/settings/terms_of_service/views/terms_of_service_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/sounds/bindings/sounds_binding.dart';
import '../modules/sounds/views/sounds_view.dart';
import '../modules/spin_wheel/bindings/spin_wheel_binding.dart';
import '../modules/spin_wheel/user_levels/bindings/user_levels_binding.dart';
import '../modules/spin_wheel/user_levels/views/user_levels_view.dart';
import '../modules/spin_wheel/views/spin_wheel_view.dart';
import '../modules/trending_videos/bindings/trending_videos_binding.dart';
import '../modules/trending_videos/views/trending_videos_view.dart';
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
      page: () => LoginView(true.obs),
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
      children: [
        GetPage(
          name: _Paths.HOME_VIDEOS_PLAYER,
          page: () => const HomeVideosPlayerView(),
          binding: HomeVideosPlayerBinding(),
        ),
      ],
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
          children: [
            GetPage(
              name: _Paths.SEARCH_VIDEOS_PLAYER,
              page: () => const SearchVideosPlayerView(),
              binding: SearchVideosPlayerBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.HASH_TAGS_DETAILS,
          page: () => const HashTagsDetailsView(),
          binding: HashTagsDetailsBinding(),
          children: [
            GetPage(
              name: _Paths.HASH_TAGS_VIDEO_PLAYER,
              page: () => const HashTagsVideoPlayerView(),
              binding: HashTagsVideoPlayerBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.DISCOVER_VIDEO_PLAYER,
          page: () => const DiscoverVideoPlayerView(),
          binding: DiscoverVideoPlayerBinding(),
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
        GetPage(
          name: _Paths.PROFILE_VIDEOS,
          page: () => const ProfileVideosView(),
          binding: ProfileVideosBinding(),
        ),
        GetPage(
          name: _Paths.LIKED_VIDEO_PLAYER,
          page: () => const LikedVideoPlayerView(),
          binding: LikedVideoPlayerBinding(),
        ),
        GetPage(
          name: _Paths.PRIVATE_VIDEOS_PLAYER,
          page: () => const PrivateVideosPlayerView(),
          binding: PrivateVideosPlayerBinding(),
        ),
        GetPage(
          name: _Paths.EDIT_PROFILE,
          page: () => const EditProfileView(),
          binding: EditProfileBinding(),
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
        GetPage(
          name: _Paths.OTHERS_PROFILE_VIDEOS,
          page: () => const OthersProfileVideosView(),
          binding: OthersProfileVideosBinding(),
        ),
        GetPage(
          name: _Paths.OTHERS_LIKED_VIDEOS_PLAYER,
          page: () => const OthersLikedVideosPlayerView(),
          binding: OthersLikedVideosPlayerBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.SOUNDS,
      page: () => const SoundsView(),
      binding: SoundsBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA,
      page: () => const CameraView(),
      binding: CameraBinding(),
      children: [
        GetPage(
          name: _Paths.SELECT_SOUND,
          page: () => const SelectSoundView(),
          binding: SelectSoundBinding(),
        ),
        GetPage(
          name: _Paths.POST_SCREEN,
          page: () => PostScreenView(),
          binding: PostScreenBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      children: [
        GetPage(
          name: _Paths.PROFILE_DETAILS,
          page: () => const ProfileDetailsView(),
          binding: ProfileDetailsBinding(),
        ),
        GetPage(
          name: _Paths.REFERAL,
          page: () => const ReferalView(),
          binding: ReferalBinding(),
        ),
        GetPage(
          name: _Paths.FAVOURITES,
          page: () => const FavouritesView(),
          binding: FavouritesBinding(),
          children: [
            GetPage(
              name: _Paths.FAVOURITE_SOUNDS,
              page: () => const FavouriteSoundsView(),
              binding: FavouriteSoundsBinding(),
            ),
            GetPage(
              name: _Paths.FAVOURITE_VIDEOS,
              page: () => const FavouriteVideosView(),
              binding: FavouriteVideosBinding(),
              children: [
                GetPage(
                  name: _Paths.FAVOURITE_VIDEO_PLAYER,
                  page: () => const FavouriteVideoPlayerView(),
                  binding: FavouriteVideoPlayerBinding(),
                ),
              ],
            ),
            GetPage(
              name: _Paths.FAVOURITE_HASHTAGS,
              page: () => const FavouriteHashtagsView(),
              binding: FavouriteHashtagsBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.INBOX,
          page: () => const InboxView(),
          binding: InboxBinding(),
        ),
        GetPage(
          name: _Paths.QR_CODE,
          page: () => const QrCodeView(),
          binding: QrCodeBinding(),
        ),
        GetPage(
          name: _Paths.NOTIFICATIONS_SETTINGS,
          page: () => const NotificationsSettingsView(),
          binding: NotificationsSettingsBinding(),
        ),
        GetPage(
          name: _Paths.TERMS_OF_SERVICE,
          page: () => const TermsOfServiceView(),
          binding: TermsOfServiceBinding(),
        ),
        GetPage(
          name: _Paths.CUSTOMER_SUPPORT,
          page: () => const CustomerSupportView(),
          binding: CustomerSupportBinding(),
        ),
        GetPage(
          name: _Paths.PRIVACY,
          page: () => const PrivacyView(),
          binding: PrivacyBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.COMMENTS,
      page: () => CommentsView(),
      binding: CommentsBinding(),
    ),
    GetPage(
      name: _Paths.FOLLOWING_VIDEOS,
      page: () => FollowingVideosView(),
      binding: FollowingVideosBinding(),
    ),
    GetPage(
      name: _Paths.TRENDING_VIDEOS,
      page: () =>  TrendingVideosView(),
      binding: TrendingVideosBinding(),
    ),
  ];
}
