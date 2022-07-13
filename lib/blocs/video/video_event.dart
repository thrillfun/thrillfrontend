part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}
class VideoLoading extends VideoEvent {
   const VideoLoading({required this.selectedTabIndex});
   final int selectedTabIndex;

  @override
  List<Object?> get props => [selectedTabIndex];
}

class AddRemoveLike extends VideoEvent {
  final int isAdded;
  final int videoId;
  const AddRemoveLike({required this.videoId,required this.isAdded});

  @override
  List<Object?> get props => [videoId,isAdded];
}

class FollowUnfollow extends VideoEvent {
  final int publisherId;
  final String action;
  const FollowUnfollow({required this.publisherId,required this.action});

  @override
  List<Object?> get props => [publisherId,action];
}