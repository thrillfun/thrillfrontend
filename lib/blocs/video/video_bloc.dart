import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thrill/main.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/repository/video/video_repository.dart';
import 'package:thrill/screens/home/home.dart';
import 'package:thrill/utils/util.dart';
part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;
  List<VideoModel> list = List<VideoModel>.empty(growable: true);
  VideoBloc({required VideoRepository videoRepository})
      : _videoRepository = videoRepository,
        super(VideoInitial()) {
    on<VideoLoading>(_onVideoLoading);
    on<AddRemoveLike>(_onAddLike);
    on<FollowUnfollow>(_onFollowUnfollow);
  }

  void _onVideoLoading(VideoLoading event, Emitter<VideoState> emit) async {
    emit(VideoInitial());
    var result;
    if(selectedTopIndex == 0){
      result = await _videoRepository.getFollowingVideos();
    } else if (selectedTopIndex == 1){
      result = await _videoRepository.getVideo();
    } else {
      result = await _videoRepository.getPopularVideos();
    }
    if (result['status']) {
      try {
        list = List<VideoModel>.from(
                result['data'].map((i) => VideoModel.fromJson(i)))
            .toList(growable: true);

        emit(VideoLoded(list, status: true, message: 'success'));
      } catch (e) {
        showErrorToast(navigatorKey.currentContext!, e.toString());
        emit(VideoLoded(const [], status: false, message: e.toString()));
      }
    } else {
      emit(VideoLoded(const [], status: false, message: result['message']));
    }
  }

  void _onAddLike(AddRemoveLike event, Emitter<VideoState> emit) async {
    var result =
        await _videoRepository.likeDislike(event.videoId, event.isAdded);
  }
  void _onFollowUnfollow(FollowUnfollow event, Emitter<VideoState> emit) async {
    var result =
    await _videoRepository.followUnfollow(event.publisherId, event.action);
  }
}
