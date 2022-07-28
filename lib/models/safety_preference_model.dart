class SafetyPreference {
  String whoCanSendDirectMessages, whoCanDuet, whoCanViewLikeVideos, whoCanCommentOnYourVideos;

  SafetyPreference({
    required this.whoCanCommentOnYourVideos,
    required this.whoCanSendDirectMessages,
    required this.whoCanDuet,
    required this.whoCanViewLikeVideos,
  });

  factory SafetyPreference.fromJson(dynamic json) {
    return SafetyPreference(
      whoCanCommentOnYourVideos: json['safety_pref_who_comment_your_videos'] ?? "Everyone",
      whoCanSendDirectMessages: json['safety_pref_who_send_direct_message'] ?? "Everyone",
      whoCanViewLikeVideos: json['who_can_view_your_liked_videos'] ?? "Everyone",
      whoCanDuet: json['who_can_duet_with_your_videos'] ?? "Everyone"
    );
  }
}
