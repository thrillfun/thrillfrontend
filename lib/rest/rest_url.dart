class RestUrl {
  static const String baseUrl = "https://9starinfosolutions.com/thrill/api/";
  static const String profileUrl = "https://9starinfosolutions.com/thrill/uploads/profile_images/";
  static const String videoUrl = "https://thrillvideo.s3.amazonaws.com/test/";
  static const String bannerUrl = "https://9starinfosolutions.com/thrill/uploads/banners/";
  static const String thambUrl = "https://9starinfosolutions.com/thrill/uploads/videos/";
  static const String soundUrl = "https://9starinfosolutions.com/thrill/";
  static const String gifUrl = "https://thrillvideo.s3.amazonaws.com/gif/";

  static const String login = baseUrl + "login";
  static const String register = baseUrl + "register";
  static const String socialLR = baseUrl + "SocialLogin";
  static const String updateProfile = baseUrl + "user/edit";
  static const String getVideoList = baseUrl + "video/list";
  static const String likeDislike = baseUrl + "video/like";
  static const String checkPhone = baseUrl + "forgot-password";
  static const String resetPass = baseUrl + "reset-password";
  static const String getUserProfile = baseUrl + "user/get-profile";
  static const String postNewVideo = baseUrl + "video/post";
  static const String getCommentList = baseUrl + "video/comments";
  static const String likeDislikeComment = baseUrl + "video/like";
  static const String postComment = baseUrl + "video/comment";
  static const String wheelDetails = baseUrl + "spin-wheel/data";
  static const String wheelUpdate = baseUrl + "spin-wheel/reward-won";
  static const String wheelEarned = baseUrl + "spin-wheel/earned-spin";
  static const String getVideoFields = baseUrl + "video/field-data";
  static const String getBanner = baseUrl + "banners";
  static const String getVideoByHashtag = baseUrl + "hashtag/top-hashtags-videos";
  static const String postCommentOnVideo = baseUrl + "video/comment";
  static const String commentLikeDislike = baseUrl + "video/comment-like";
  static const String followUnfollow = baseUrl + "user/follow-unfollow-user";
  static const String getSoundList = baseUrl + "sound/list";
  static const String downloadSound = soundUrl + "uploads/sounds/";
  static const String viewCount = baseUrl + "video/view";
  static const String favrateSundHastagRemoveAdd = baseUrl + "favorite/add-to-favorite";
  static const String getFavriteList = baseUrl + "favorite/user-favorites-list";
  static const String getSoundCategories = baseUrl + "sound/categories";
  static const String notificationSetting = baseUrl + "user/push-notification-settings";
  static const String deactiveAc = baseUrl + "user/deactivate-account-request";
  static const String checkAcStatus = baseUrl + "user/check-user-status";
  static const String userVerification = baseUrl + "user/request-verification";

  static const String getPrivateVideo = baseUrl + "video/private";


  static const String userAllVideo = baseUrl + "video/user-videos";
  static const String userLikedVideo = baseUrl + "user/user-liked-videos";
  static const String userPrivateVideo = baseUrl + "video/private";

  static const String getHashtagList = baseUrl + "hashtag/list";

}
