import 'dart:async';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../rest/rest_url.dart';

VideoPlayerController? reelsPlayerController;
bool shouldAutoPlayReel = true;

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl, filter;
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final int videoId;
  final VoidCallback? callback;
  final String speed;

  const VideoPlayerItem(
      {Key? key,
      required this.videoUrl,
      required this.pageIndex,
      required this.currentPageIndex,
      required this.isPaused,
      required this.filter,
      required this.videoId,
      required this.speed,
        this.callback})
      : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  bool isLoading = true;
  bool showGIF = false;
  bool initialized = false;
  bool isDispose= false;
  Timer? _timer;
  int _start = 40;
  bool isBuffering = false;

  @override
  void initState() {
    super.initState();
    reelsPlayerController?.pause();
      reelsPlayerController = VideoPlayerController.network(
          '${RestUrl.videoUrl}${widget.videoUrl}')
        ..initialize().then((value) {
          if (reelsPlayerController!.value.isInitialized) {
            reelsPlayerController!.setPlaybackSpeed(widget.speed.contains('x')?double.parse(widget.speed.replaceAll('x', '')):double.parse(widget.speed));
            if (shouldAutoPlayReel) reelsPlayerController!.play();
            reelsPlayerController!.setLooping(true);
            reelsPlayerController!.setVolume(1);
            initialized = true;
            showGIF = true;
            _start = reelsPlayerController!.value.duration.inSeconds~/2;
            startTimer();
            if (mounted) setState(() {});
            reelsPlayerController?.addListener(() {
              if(reelsPlayerController!.value.isBuffering){
                if (mounted) setState(()=>isBuffering = true);
              } else {
                if (mounted && isBuffering && !reelsPlayerController!.value.isBuffering) setState(()=>isBuffering = false);
              }
            });
          }
        });

  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    //if(reelsPlayerController!=null){reelsPlayerController!.dispose();}
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
                timer.cancel();
              callViewApi();
            } else {
                _start--;
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.pageIndex == widget.currentPageIndex &&
    //     !widget.isPaused &&
    //     initialized) {
    //   if (!reelsPlayerController!.value.isPlaying) reelsPlayerController!.play();
    // } else {
    //   reelsPlayerController!.pause();
    // }
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
                  : VideoPlayer(reelsPlayerController!),
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
                    visible: reelsPlayerController!.value.volume==0?true:false,
                    child: IconButton(
                      icon: const Icon(Icons.volume_off,color: Colors.white,size: 40,),
                      onPressed: ()=> reelsPlayerController!.setVolume(1).then((value) => setState((){})),
                    ),
                  )),
              Visibility(
                visible: isBuffering,
                child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          const WidgetSpan(child: CircularProgressIndicator()),
                          TextSpan(text: '\n\nBuffering', style: Theme.of(context).textTheme.headline3!.copyWith(
                            shadows: [const Shadow(color: Colors.white, offset: Offset(0,0), blurRadius: 30)]
                          ))
                        ])
                    )
                ),
              ),
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
      // reelsPlayerController!.pause();
      // if (d < 60) {
      //   reelsPlayerController!.pause();
      //   if (initialized &&
      //       widget.pageIndex == widget.currentPageIndex &&
      //       !widget.isPaused) {
      //     reelsPlayerController!.pause();
      //   }
      // } else {
      //   reelsPlayerController!.play();
      // }
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
    reelsPlayerController?.pause();
  }

  onLongPressEnd(LongPressEndDetails d){
    setState((){showGIF = true;});
    reelsPlayerController?.play();
  }

  onTap(){
    if(reelsPlayerController!.value.volume>=1){
      reelsPlayerController!.setVolume(0).then((value) => setState((){}));
    } else {
      reelsPlayerController!.setVolume(1).then((value) => setState((){}));
    }
  }

}
