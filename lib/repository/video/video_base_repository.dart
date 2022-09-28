abstract class VideoBaseRepository {
  Future<void> getVideo();

  Future<void> likeDislike(int videoId, int isLike);

  Future<void> followUnfollow(int publisherId, String action);
}
