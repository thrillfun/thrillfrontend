part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  const VideoState();
}

class VideoInitial extends VideoState {
  @override
  List<Object> get props => [];
}

class VideoLoded extends VideoState {

  List<VideoModel> list;
  String message;
  bool status;

  VideoLoded(this.list,{required this.status, required this.message});
  
  
  @override
  List<Object> get props => [list,status,message];
}

class LikeDislike extends VideoState {
  int counter;

  LikeDislike(this.counter);


  @override
  List<Object> get props => [counter];
}
