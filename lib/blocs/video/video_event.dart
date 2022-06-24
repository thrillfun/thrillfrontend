part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}
class VideoLoading extends VideoEvent {
   const VideoLoading();

  @override
  List<Object?> get props => [];
}

class AddRemoveLike extends VideoEvent {
  int isAdded;
  int videoId;
  AddRemoveLike({required this.videoId,required this.isAdded});

  @override
  List<Object?> get props => [videoId,isAdded];
}

class FollowUnfollow extends VideoEvent {
  int publisherId;
  String action;
  FollowUnfollow({required this.publisherId,required this.action});

  @override
  List<Object?> get props => [publisherId,action];
}