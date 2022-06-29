import 'dart:async';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../rest/rest_url.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl, filter;
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final int videoId;
  final VoidCallback? callback;

  const VideoPlayerItem(
      {Key? key,
      required this.videoUrl,
      required this.pageIndex,
      required this.currentPageIndex,
      required this.isPaused,
      required this.filter,
      required this.videoId,
        this.callback})
      : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? videoPlayerController;
  bool isLoading = true;
  bool showGIF = false;
  bool initialized = false;
  bool isDispose= false;
  Timer? _timer;
  int _start = 40;

  @override
  void initState() {
    super.initState();
      videoPlayerController = VideoPlayerController.network(
          '${RestUrl.videoUrl}${widget.videoUrl}')
        ..initialize().then((value) {
          if (videoPlayerController!.value.isInitialized) {
            if (!showGIF) videoPlayerController!.play();
            videoPlayerController!.setLooping(true);
            videoPlayerController!.setVolume(1);
            initialized = true;
            showGIF = true;
            startTimer();
            setState(() {});
          }
        });

  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    if(videoPlayerController!=null){videoPlayerController!.dispose();}
    isDispose=true;
  }

  void startTimer()async {
    const oneSec = Duration(seconds: 1);
    if(mounted){
      var instance = await SharedPreferences.getInstance();
      var loginData=instance.getString('currentUser');
      if(loginData !=null){
        _timer = Timer.periodic(
          oneSec,
              (Timer timer) {
            if (_start == 0) {
              setState(() {
                timer.cancel();
              });
              callViewApi();
            } else {
              setState(() {
                _start--;
              });
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageIndex == widget.currentPageIndex &&
        !widget.isPaused &&
        initialized) {
      videoPlayerController!.play();
    } else {
      videoPlayerController!.pause();
    }
    return VisibilityDetector(
      onVisibilityChanged: _handleVisibilityDetector,
      key: Key('my-widget-${widget.pageIndex}'),
      child: Container(
        width: getWidth(context),
        height: getHeight(context),
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: GestureDetector(
          onLongPressStart: onLongPressStart,
          onLongPressEnd: onLongPressEnd,
          onDoubleTap: widget.callback,
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              !initialized
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : VideoPlayer(videoPlayerController!),
              widget.filter.isEmpty
                  ? const SizedBox(width: 10)
                  : !showGIF
                      ? const SizedBox(width: 10)
                      : Image.asset(
                          widget.filter,
                          fit: BoxFit.cover,
                          width: getWidth(context),
                          height: getHeight(context),
                        ),
              Positioned(
                top: 70,
                  child: Visibility(
                    visible: videoPlayerController!.value.volume==0?true:false,
                    child: IconButton(
                      icon: const Icon(Icons.volume_off,color: Colors.white,size: 40,),
                      onPressed: ()=> videoPlayerController!.setVolume(1).then((value) => setState((){})),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void _handleVisibilityDetector(VisibilityInfo info) {
    double d=info.visibleFraction*100;
    print(d);
    if(mounted){
      videoPlayerController!.pause();
      if (d < 60) {
        videoPlayerController!.pause();
        if (initialized &&
            widget.pageIndex == widget.currentPageIndex &&
            !widget.isPaused) {
          videoPlayerController!.pause();
        }
      } else {
        videoPlayerController!.play();
      }
    } else {
      videoPlayerController!.pause();
    }
  }

  void callViewApi() async {
    var pref = await SharedPreferences.getInstance();
    List<String> viewList = List<String>.empty(growable: true);
    viewList = pref.getStringList('likeList') ?? [];
    if (!viewList.contains(widget.videoId.toString())) {
      var result = await RestApi.countViewVideo(widget.videoId);
      var json = jsonDecode(result.body);
      if (json['status']) {
        viewList.add(widget.videoId.toString());
        pref.setStringList('viewList', viewList);
        setState(() {});
      }
    }
  }

  onLongPressStart(LongPressStartDetails d)async{
    setState((){showGIF = false;});
    await Future.delayed(const Duration(milliseconds: 250));
    videoPlayerController!.pause();
  }

  onLongPressEnd(LongPressEndDetails d){
    setState((){showGIF = true;});
  }

  onTap(){
    if(videoPlayerController!.value.volume>=1){
      videoPlayerController!.setVolume(0).then((value) => setState((){}));
    } else {
      videoPlayerController!.setVolume(1).then((value) => setState((){}));
    }
  }

}
