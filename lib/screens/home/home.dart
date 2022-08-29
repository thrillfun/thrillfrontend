import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/video/video_bloc.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/screens/auth/login.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../common/strings.dart';
import '../../models/comment_model.dart';
import '../../models/user.dart';
import '../../rest/rest_url.dart';
import '../../utils/home_bottomsheet_layout.dart';
import '../../utils/util.dart';
import '../../widgets/image_rotate.dart';
import '../../widgets/video_item.dart';
import 'package:velocity_x/velocity_x.dart';

int selectedTopIndex = 1;
class Home extends StatefulWidget {
  const Home({Key? key, this.vModel}) : super(key: key);
  final VideoModel? vModel;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver{

  List<int> favList = List<int>.empty(growable: true);
  List<String> likeList = List<String>.empty(growable: true);
  List<Comments> commentList = List<Comments>.empty(growable: true);
  List<String> likeComment = List<String>.empty(growable: true);
  TextEditingController msgCtr = TextEditingController();
  List<String> followList = List<String>.empty(growable: true);
  final PageController _pageController = PageController(initialPage: 0, keepPage: true);
  int _currentPage = 0;
  bool _isOnPageTurning = false;
  String isError = '';
  UserModel? userModel;
  List<int> adIndexes = [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290,300];
  InterstitialAd? interstitialAd;
  PreloadPageController? preloadPageController;
  int current = 0;
  bool isOnPageTurning = false;

  @override
  void initState() {
    shouldAutoPlayReel = true;
    loadInterstitialAd();
    loadLikes();
    getUserData();
    //_pageController.addListener(_scrollListener);
    preloadPageController = PreloadPageController();
    //preloadPageController!.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<VideoBloc, VideoState>(builder: (context, state) {
      if (state is VideoInitial) {
        return Container(
          height: getHeight(context),
          width: getWidth(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/splash.png').image,
              fit: BoxFit.cover
            )
          ),
          child: const CircularProgressIndicator(color: Colors.lightBlueAccent),
        );
      } else if (state is VideoLoded) {
        if(widget.vModel!=null){
          if(state.list.isNotEmpty){
            if(state.list[0].id!=widget.vModel!.id){
              state.list.insert(0, widget.vModel!);
            }
          }
        }
          return Stack(
            children:[
             /* PageView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: state.list.length,
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayerItem(
                        videoUrl: state.list[index].video,
                        isPaused: _isOnPageTurning,
                        currentPageIndex: _currentPage,
                        pageIndex: index,
                        filter: state.list[index].filter,
                        videoId: state.list[index].id,
                        callback: ()async{
                          await isLogined().then((value) async {
                            if (value) {
                              if (likeList.isEmpty) {
                                likeList
                                    .add(state.list[index].id.toString());
                                state.list[index].copyWith(
                                    likes: state.list[index].likes++);
                              } else {
                                if (likeList.contains(
                                    state.list[index].id.toString())) {
                                  likeList.remove(
                                      state.list[index].id.toString());
                                  state.list[index].copyWith(
                                      likes: state.list[index].likes--);
                                } else {
                                  likeList
                                      .add(state.list[index].id.toString());
                                  state.list[index].copyWith(
                                      likes: state.list[index].likes++);
                                }
                              }
                              SharedPreferences pref =
                              await SharedPreferences.getInstance();
                              pref.setStringList('likeList', likeList);

                              BlocProvider.of<VideoBloc>(context).add(
                                  AddRemoveLike(
                                      isAdded: likeList.contains(state
                                          .list[index].id
                                          .toString())
                                          ? 1
                                          : 0,
                                      videoId: state.list[index].id));
                              setState(() {});
                            } else {
                              showAlertDialog(context);
                            }
                          });
                        },
                      ),
                      Positioned(
                        bottom: 120,
                        right: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await isLogined().then((value) async {
                                      if (value) {
                                        reelsPlayerController?.pause();
                                        await Navigator.pushNamed(
                                            context, "/viewProfile", arguments: {
                                          "userModel": state.list[index].user,
                                          "getProfile": false
                                        });
                                        reelsPlayerController?.play();
                                      } else {
                                        showAlertDialog(context);
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: state
                                                .list[index].user.avatar.isEmpty
                                            ? 'https://cdn2.iconfinder.com/data/icons/circle-avatars-1/128/050_girl_avatar_profile_woman_suit_student_officer-512.png'
                                            : '${RestUrl.profileUrl}${state.list[index].user.avatar}',
                                        fit: BoxFit.cover,
                                        placeholder: (a, b) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 28,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await isLogined().then((value) async {
                                  if (value) {
                                    if (likeList.isEmpty) {
                                      likeList
                                          .add(state.list[index].id.toString());
                                      state.list[index].copyWith(
                                          likes: state.list[index].likes++);
                                    } else {
                                      if (likeList.contains(
                                          state.list[index].id.toString())) {
                                        likeList.remove(
                                            state.list[index].id.toString());
                                        state.list[index].copyWith(
                                            likes: state.list[index].likes--);
                                      } else {
                                        likeList
                                            .add(state.list[index].id.toString());
                                        state.list[index].copyWith(
                                            likes: state.list[index].likes++);
                                      }
                                    }
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    pref.setStringList('likeList', likeList);

                                    BlocProvider.of<VideoBloc>(context).add(
                                        AddRemoveLike(
                                            isAdded: likeList.contains(state
                                                    .list[index].id
                                                    .toString())
                                                ? 1
                                                : 0,
                                            videoId: state.list[index].id));
                                    setState(() {});
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: likeList
                                    .contains(state.list[index].id.toString())
                                    ? const Icon(
                                  Icons.favorite,
                                  key: ValueKey("like"),
                                  color: Colors.red,
                                  size: 28,
                                )
                                    : const Icon(
                                  Icons.favorite_border,
                                  key: ValueKey("unlike"),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            Text(
                              state.list[index].likes.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  await isLogined().then((value) {
                                    if (value) {
                                      showComments(context, state.list[index].id);
                                    } else {
                                      showAlertDialog(context);
                                    }
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/comment.svg',
                                  height: 26,
                                  width: 26,
                                )),
                            Text(
                              state.list[index].comments.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            GestureDetector(
                                onTap: () async {},
                                child: SvgPicture.asset(
                                  'assets/duet.svg',
                                  height: 30,
                                  width: 30,
                                )),
                            const SizedBox(
                              height: 18,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  Share.share('You need to watch this awesome video only on Thrill!!!');
                                },
                                child: SvgPicture.asset(
                                  'assets/share.svg',
                                  height: 22,
                                  width: 22,
                                ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: SvgPicture.asset(
                            'assets/shadow.svg',
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          )),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await isLogined().then((value) async {
                                            if (value) {
                                              reelsPlayerController?.pause();
                                              await Navigator.pushNamed(context, "/viewProfile", arguments: {
                                                "userModel": state.list[index].user, "getProfile": false
                                              });
                                              reelsPlayerController?.play();
                                            } else {
                                              showAlertDialog(context);
                                            }
                                          });
                                        },
                                        child: Text(
                                          '@${state.list[index].user.username}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      state.list[index].user.is_verified
                                              .contains('1')
                                          ? SvgPicture.asset(
                                              'assets/verified.svg',
                                            )
                                          : const SizedBox(width: 2),
                                      Visibility(
                                        visible: userModel?.id==state.list[index].user.id?false:true,
                                        child: InkWell(
                                          onTap: () async {
                                            await isLogined().then((value) async {
                                              if (value) {
                                                if (followList.contains(state
                                                    .list[index].id
                                                    .toString())) {
                                                  followList.remove(state
                                                      .list[index].id
                                                      .toString());
                                                  int followers = int.parse(state
                                                      .list[index].user.followers);
                                                  followers--;
                                                  state.list[index].user.followers =
                                                      followers.toString();
                                                  state.list[index].copyWith(
                                                      user: state.list[index].user);
                                                } else {
                                                  followList.add(state
                                                      .list[index].id
                                                      .toString());
                                                  int followers = int.parse(state
                                                      .list[index].user.followers);
                                                  followers++;
                                                  state.list[index].user.followers =
                                                      followers.toString();
                                                  state.list[index].copyWith(
                                                      user: state.list[index].user);
                                                }
                                                SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                                pref.setStringList(
                                                    'followList', followList);

                                                BlocProvider.of<VideoBloc>(context)
                                                    .add(FollowUnfollow(
                                                    action: followList.contains(
                                                        state.list[index].id
                                                            .toString())
                                                        ? "follow"
                                                        : "unfollow",
                                                    publisherId: state
                                                        .list[index].user.id));
                                                setState(() {});
                                              } else {
                                                showAlertDialog(context);
                                              }
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.white, width: 1)),
                                            child:  Center(
                                              child: Text(
                                                followList.contains(state.list[index].id.toString())
                                                    ? "Following" : "Follow",
                                                style:
                                                const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state.list[index].description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(color: Colors.white),
                                      ),

                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SvgPicture.asset('assets/music.svg'),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child:
                                          state.list[index].sound_name.isEmpty
                                              ? "Original Sound".marquee(textStyle:const TextStyle(color: Colors.white)).h2(context)
                                              : "${state.list[index].sound_name} - @${state.list[index].sound_category_name}".marquee(textStyle: const TextStyle(color: Colors.white)).h2(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap:() async {
                                await isLogined().then((value) async {
                                  if (value) {
                                    if(state.list[index].sound.isNotEmpty){
                                      reelsPlayerController?.pause();
                                      await Navigator.pushNamed(context, "/soundDetails", arguments: {"sound": state.list[index].sound, "user": state.list[index].user.name});
                                      reelsPlayerController?.play();
                                    }
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                                child: const RotatedImage("test.png")),
                          ],
                        ),
                      ),
                    ],
                  );
                }),*/
              state.list.isEmpty?
              Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/splash.png'))),
                  child:  Center(
                    child:  Text("No ${selectedTopIndex==0?"Following":selectedTopIndex==1?"Related":"Popular"} Videos Found!",
                      style: const TextStyle(color: Colors.white, fontSize: 14),),
                  )):
              PageView.builder(
                  //controller: preloadPageController,
                controller: _pageController,
                  onPageChanged: (int index){
                    if(adIndexes.contains(index)){
                      showAd();
                    }
                  },
                  scrollDirection: Axis.vertical,
                  //preloadPagesCount: 3,
                  itemCount: state.list.length, //Notice this
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayerItem(
                      videoUrl: state.list[index].video,
                      speed: state.list[index].speed,
                      isPaused: _isOnPageTurning,
                      currentPageIndex: current,
                      pageIndex: index,
                      filter: state.list[index].filter,
                      videoId: state.list[index].id,
                      pageController: _pageController,
                      pagesLength: state.list.length,
                      callback: ()async{
                        await isLogined().then((value) async {
                          if (value) {
                            if (likeList.isEmpty) {
                              likeList
                                  .add(state.list[index].id.toString());
                              state.list[index].copyWith(
                                  likes: state.list[index].likes++);
                            } else {
                              if (likeList.contains(
                                  state.list[index].id.toString())) {
                                likeList.remove(
                                    state.list[index].id.toString());
                                state.list[index].copyWith(
                                    likes: state.list[index].likes--);
                              } else {
                                likeList
                                    .add(state.list[index].id.toString());
                                state.list[index].copyWith(
                                    likes: state.list[index].likes++);
                              }
                            }
                            SharedPreferences pref =
                            await SharedPreferences.getInstance();
                            pref.setStringList('likeList', likeList);

                            BlocProvider.of<VideoBloc>(context).add(
                                AddRemoveLike(
                                    isAdded: likeList.contains(state
                                        .list[index].id
                                        .toString())
                                        ? 1
                                        : 0,
                                    videoId: state.list[index].id));
                            setState(() {});
                          } else {
                            showAlertDialog(context);
                          }
                        });
                      },
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/shadow.svg',
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                        )),
                    Positioned(
                      bottom: 70,
                      right: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () async {
                                await isLogined().then((value) async {
                                  if (value) {
                                    try{
                                      progressDialogue(context);
                                      var response = await RestApi.checkVideoReport(state.list[index].id,userModel!.id);
                                      var json = jsonDecode(response.body);
                                      closeDialogue(context);
                                      if(json['status']){
                                        showErrorToast(context, "You have already reported this video!");
                                      } else {
                                        showReportDialog(state.list[index].id, state.list[index].user.username);
                                      }
                                    } catch(e){
                                      closeDialogue(context);
                                      showErrorToast(context, e.toString());
                                    }
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              iconSize: 28,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.white,
                              icon: const Icon(Icons.report)
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          IconButton(
                              onPressed: ()async{
                                await isLogined().then((value) async {
                                  if (value) {
                                    try{RestApi.favUnFavVideo(
                                        state.list[index].id,
                                        favList.contains(state.list[index].id)?
                                        "unfav":"fav"
                                    );
                                    }catch(e){
                                      showErrorToast(context, e.toString());
                                    }
                                    setState(() {
                                      if(favList.contains(state.list[index].id)){
                                        favList.remove(state.list[index].id);
                                      } else {
                                        favList.add(state.list[index].id);
                                      }
                                    });
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              iconSize: 28,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.white,
                              icon: Icon(favList.contains(state.list[index].id)? Icons.bookmark_outlined : Icons.bookmark_outline)
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await isLogined().then((value) async {
                                    if (value) {
                                      if(userModel?.id==state.list[index].user.id){
                                        reelsPlayerController?.pause();
                                        shouldAutoPlayReel = false;
                                        Navigator.pushReplacementNamed(context, '/', arguments: {'index' : 3});
                                      } else {
                                        reelsPlayerController?.pause();
                                        shouldAutoPlayReel = false;
                                        await Navigator.pushNamed(
                                            context, "/viewProfile", arguments: {
                                          "userModel": state.list[index].user,
                                          "getProfile": false
                                        });
                                        reelsPlayerController?.play();
                                        shouldAutoPlayReel = true;
                                        loadLikes();
                                      }
                                    } else {
                                      showAlertDialog(context);
                                    }
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      imageUrl: state
                                          .list[index].user.avatar.isEmpty
                                          ? 'https://cdn2.iconfinder.com/data/icons/circle-avatars-1/128/050_girl_avatar_profile_woman_suit_student_officer-512.png'
                                          : '${RestUrl.profileUrl}${state.list[index].user.avatar}',
                                      fit: BoxFit.cover,
                                      placeholder: (a, b) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await isLogined().then((value) async {
                                if (value) {
                                  if (likeList.isEmpty) {
                                    likeList
                                        .add(state.list[index].id.toString());
                                    state.list[index].copyWith(
                                        likes: state.list[index].likes++);
                                  } else {
                                    if (likeList.contains(
                                        state.list[index].id.toString())) {
                                      likeList.remove(
                                          state.list[index].id.toString());
                                      state.list[index].copyWith(
                                          likes: state.list[index].likes--);
                                    } else {
                                      likeList
                                          .add(state.list[index].id.toString());
                                      state.list[index].copyWith(
                                          likes: state.list[index].likes++);
                                    }
                                  }
                                  SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                                  pref.setStringList('likeList', likeList);

                                  BlocProvider.of<VideoBloc>(context).add(
                                      AddRemoveLike(
                                          isAdded: likeList.contains(state
                                              .list[index].id
                                              .toString())
                                              ? 1
                                              : 0,
                                          videoId: state.list[index].id));
                                  setState(() {});
                                } else {
                                  showAlertDialog(context);
                                }
                              });
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: likeList
                                  .contains(state.list[index].id.toString())
                                  ? const Icon(
                                Icons.favorite,
                                key: ValueKey("like"),
                                color: Colors.red,
                                size: 28,
                              )
                                  : const Icon(
                                Icons.favorite_border,
                                key: ValueKey("unlike"),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          Text(
                            state.list[index].likes.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          GestureDetector(
                              onTap: () async {
                                await isLogined().then((value) {
                                  if (value) {
                                    if(state.list[index].is_commentable=="Yes"){
                                      showComments(context, state.list[index].id, state.list[index]);
                                    } else {
                                      showErrorToast(context, "This user has disabled comments on the video!");
                                    }
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              child: SvgPicture.asset(
                                'assets/comment.svg',
                                height: 22,
                                width: 22,
                              )),
                          Text(
                            state.list[index].comments.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          GestureDetector(
                              onTap: () async {
                                await isLogined().then((value) async {
                                  if (value) {
                                    if(state.list[index].is_duetable=="Yes"){
                                      reelsPlayerController?.pause();
                                      shouldAutoPlayReel = false;
                                      await Navigator.pushNamed(context, '/recordDuet', arguments: state.list[index]);
                                      reelsPlayerController?.play();
                                      shouldAutoPlayReel = true;
                                    } else {
                                      showErrorToast(context, "This user has disabled duet on the video!");
                                    }
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              child: SvgPicture.asset(
                                'assets/duet.svg',
                                height: 25,
                                width: 25,
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              // showModalBottomSheet(context: context, builder: (context)=>
                              //   const BottomSheetHome();
                              // ;
                             Share.share('You need to watch this awesome video only on Thrill!!!');
                            },
                            child: SvgPicture.asset(
                              'assets/share.svg',
                              height: 16,
                              width: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await isLogined().then((value) async {
                                          if (value) {
                                            if(userModel?.id==state.list[index].user.id){
                                              reelsPlayerController?.pause();
                                              shouldAutoPlayReel = false;
                                              Navigator.pushReplacementNamed(context, '/', arguments: {'index':3});
                                            } else {
                                              reelsPlayerController?.pause();
                                              shouldAutoPlayReel = false;
                                              await Navigator.pushNamed(
                                                  context, "/viewProfile", arguments: {
                                                "userModel": state.list[index].user,
                                                "getProfile": false
                                              });
                                              reelsPlayerController?.play();
                                              shouldAutoPlayReel = true;
                                              loadLikes();
                                            }
                                          } else {
                                            showAlertDialog(context);
                                          }
                                        });
                                      },
                                      child: Text(
                                        '@${state.list[index].user.username}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    state.list[index].user.is_verified
                                        .contains('1')
                                        ? SvgPicture.asset(
                                      'assets/verified.svg',
                                    )
                                        : const SizedBox(width: 2),
                                    Visibility(
                                      visible: userModel?.id==state.list[index].user.id?false:true,
                                      child: InkWell(
                                        onTap: () async {
                                          await isLogined().then((value) async {
                                            if (value) {
                                              if (followList.contains(state.list[index].user.id.toString())) {
                                                followList.remove(state.list[index].user.id.toString());
                                                int followers = int.parse(state.list[index].user.followers);
                                                followers--;
                                                state.list[index].user.followers = followers.toString();
                                                state.list[index].copyWith(user: state.list[index].user);
                                              } else {
                                                followList.add(state.list[index].user.id.toString());
                                                int followers = int.parse(state.list[index].user.followers);
                                                followers++;
                                                state.list[index].user.followers = followers.toString();
                                                state.list[index].copyWith(user: state.list[index].user);
                                              }
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              pref.setStringList('followList', followList);

                                              BlocProvider.of<VideoBloc>(context).add(FollowUnfollow(
                                                  action: followList.contains(
                                                      state.list[index].user.id
                                                          .toString())
                                                      ? "follow"
                                                      : "unfollow",
                                                  publisherId: state
                                                      .list[index].user.id));
                                              setState(() {});
                                              BlocProvider.of<ProfileBloc>(context).add( const ProfileLoading());
                                            } else {
                                              showAlertDialog(context);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.white, width: 1)),
                                          child:  Center(
                                            child: Text(
                                              followList.contains(state.list[index].user.id.toString())
                                                  ? "Following" : "Follow",
                                              style:
                                              const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  getHashTagsToShow(state.list[index].hashtags)+
                                  state.list[index].description,
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SvgPicture.asset('assets/music.svg'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child:
                                      state.list[index].sound_owner.isEmpty
                                          ? "Original Sound by @${state.list[index].user.username}".marquee(textStyle:const TextStyle(color: Colors.white)).h2(context)
                                          : "${state.list[index].sound_name.isEmpty?"Original Sound":state.list[index].sound_name} by @${state.list[index].sound_owner}".marquee(textStyle: const TextStyle(color: Colors.white)).h2(context),
                                          //: "${state.list[index].sound_name} - @${state.list[index].sound_category_name}".marquee(textStyle: const TextStyle(color: Colors.white)).h2(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap:() async {
                                await isLogined().then((value) async {
                                  if (value) {
                                    if(state.list[index].sound.isNotEmpty){
                                      reelsPlayerController?.pause();
                                      shouldAutoPlayReel = false;
                                      await Navigator.pushNamed(context, "/soundDetails",
                                          arguments: {
                                        "sound": state.list[index].sound,
                                          "user": state.list[index].sound_owner.isEmpty?state.list[index].user.name :state.list[index].sound_owner,
                                          "soundName": state.list[index].sound_name,
                                          "title":state.list[index].sound_owner});
                                      reelsPlayerController?.play();
                                      shouldAutoPlayReel = true;
                                    }
                                  } else {
                                    showAlertDialog(context);
                                  }
                                });
                              },
                              child: const RotatedImage("test.png")),
                        ],
                      ),
                    ),
                  ],
                );
              }
              ),
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            reelsPlayerController?.pause();
                            selectedTopIndex = 0;
                            BlocProvider.of<VideoBloc>(context).add(
                                VideoLoading(selectedTabIndex: selectedTopIndex));
                          });
                        },
                        child: Text(
                          following,
                          style: TextStyle(
                              color: selectedTopIndex == 0
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 16),
                        )),
                    Container(
                      height: 15,
                      width: 1,
                      color:
                      selectedTopIndex == 0 || selectedTopIndex == 1
                          ? Colors.white
                          : Colors.white60,
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            reelsPlayerController?.pause();
                            selectedTopIndex = 1;
                            BlocProvider.of<VideoBloc>(context).add(
                                VideoLoading(selectedTabIndex: selectedTopIndex));
                          });
                        },
                        child: Text(
                          related,
                          style: TextStyle(
                              color: selectedTopIndex == 1
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 16),
                        )),
                    Container(
                      height: 15,
                      width: 1,
                      color:
                      selectedTopIndex == 1 || selectedTopIndex == 2
                          ? Colors.white
                          : Colors.white60,
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            reelsPlayerController?.pause();
                            selectedTopIndex = 2;
                            BlocProvider.of<VideoBloc>(context).add(
                                VideoLoading(selectedTabIndex: selectedTopIndex));
                          });
                        },
                        child: Text(
                          liveUsers,
                          style: TextStyle(
                              color: selectedTopIndex == 2
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 16),
                        )),
                    Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: ()async {
                            await isLogined().then((value) async {
                              if (value) {
                                reelsPlayerController?.pause();
                                shouldAutoPlayReel = false;
                                await Navigator.pushNamed(context, "/record");
                                reelsPlayerController?.play();
                                shouldAutoPlayReel = true;
                              } else {
                                showAlertDialog(context);
                              }
                            });
                          },
                          iconSize: 22,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
              ),
            ]
          );
        //}
      }
      return Container();
    }));
  }

  showComments(BuildContext context, int videoId, VideoModel vModel) async {
    try {
      progressDialogue(context);
      var result = await RestApi.getCommentListOnVideo(videoId);
      var json = jsonDecode(utf8.decode(result.bodyBytes));
      closeDialogue(context);
      if (json['status']) {
        commentList.clear();
        commentList =
            List<Comments>.from(json['data'].map((i) => Comments.fromJson(i)))
                .toList(growable: true);
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: MediaQuery.of(context).viewInsets,
                  height: 580,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: const EdgeInsets.only(right: 30),
                            icon: Image.asset('assets/x.png')),
                      ),
                      commentList.isEmpty
                          ? const Flexible(
                              child: Center(
                              child: Text("No comments"),
                            ))
                          : Flexible(
                              child: ListView.builder(
                                  itemCount: commentList.length,
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            height: 60,
                                            width: 60,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: commentList[index]
                                                      .avatar
                                                      .isEmpty
                                                  ? 'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3053232163929.567197ac6e6f5.png'
                                                  : '${RestUrl.profileUrl}${commentList[index].avatar}',
                                              placeholder: (a, b) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      '${commentList[index].name}\n',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: commentList[index]
                                                      .comment,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey.shade700))
                                            ])),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  if (likeComment.isEmpty) {
                                                    likeComment.add(
                                                        commentList[index]
                                                            .id
                                                            .toString());
                                                    commentList[index]
                                                        .comment_like_counter++;
                                                  } else {
                                                    if (likeComment.contains(
                                                        commentList[index]
                                                            .id
                                                            .toString())) {
                                                      likeComment.remove(
                                                          commentList[index]
                                                              .id
                                                              .toString());
                                                      if (commentList[index]
                                                              .comment_like_counter >
                                                          0) {
                                                        commentList[index]
                                                            .comment_like_counter--;
                                                      }
                                                    } else {
                                                      likeComment.add(
                                                          commentList[index]
                                                              .id
                                                              .toString());
                                                      commentList[index]
                                                          .comment_like_counter++;
                                                    }
                                                  }
                                                  SharedPreferences pref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  pref.setStringList(
                                                      'commentList',
                                                      likeComment);
                                                  RestApi.commentLikeAndDislike(
                                                      commentList[index].id,
                                                      likeComment.contains(
                                                              commentList[index]
                                                                  .id
                                                                  .toString())
                                                          ? 1
                                                          : 0);
                                                  setState(() {});
                                                },
                                                constraints:
                                                    const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                color: Colors.grey,
                                                icon: likeComment.contains(
                                                        commentList[index]
                                                            .id
                                                            .toString())
                                                    ? const Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                        size: 23,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .favorite_border_outlined,
                                                        color: Colors.grey,
                                                        size: 23,
                                                      ),
                                              ),
                                              Text(
                                                  ' ${commentList[index].comment_like_counter}')
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Divider(
                        height: 10,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: msgCtr,
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  hintText: leaveAComment,
                                  errorText: isError.isNotEmpty ? isError : ""),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                if (msgCtr.text.isEmpty) {
                                  isError = "Comment required";
                                  setState(() {});
                                } else {
                                  isError = "";
                                  setState(() {});
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  progressDialogue(context);
                                  var pref = await SharedPreferences.getInstance();
                                  var currentUser = pref.getString('currentUser');
                                  UserModel current = UserModel.fromJson(jsonDecode(currentUser!));
                                  var resultComment = await RestApi.postComment(videoId, current.id, msgCtr.text);
                                  var json = jsonDecode(resultComment.body);
                                  if(json['status']){
                                    try {
                                      var jsonComment = jsonDecode(resultComment.body);
                                      if (jsonComment['status']) {
                                        Comments c = Comments(
                                            jsonComment['data']['id'],
                                            0,
                                            current.avatar,
                                            current.name,
                                            msgCtr.text.toString(),
                                            current.id);
                                        commentList.add(c);
                                        msgCtr.text = "";

                                        setState(() {vModel.comments+=1;});
                                        closeDialogue(context);
                                      } else {
                                        closeDialogue(context);
                                      }
                                    } catch (_) {
                                      closeDialogue(context);
                                    }
                                  } else {
                                    closeDialogue(context);
                                    showErrorToast(context, json['message'].toString());
                                  }
                                }
                              },
                              padding: const EdgeInsets.only(right: 20),
                              icon: Image.asset('assets/send-fill.png'))
                        ],
                      )
                    ],
                  ),
                );
              });
            }).then((value) => setState((){}));
      } else {
        showErrorToast(context, json['message']);
      }
    } catch (e) {
      closeDialogue(context);
      showErrorToast(context, e.toString());
    }
  }

  void loadLikes() async {
    var likeData = await SharedPreferences.getInstance();
    likeList = likeData.getStringList('likeList') ?? [];
    likeComment = likeData.getStringList('commentList') ?? [];
    followList = likeData.getStringList('followList') ?? [];
    setState(() {});
    getFavVideos();
  }

  getFavVideos()async{
    try{
      var response = await RestApi.getFavVideos();
      var json = jsonDecode(response.body);
      if(json['status']){
        List jsonList = json['data'] as List;
        if(jsonList.isNotEmpty){
          favList.clear();
          for(var element in jsonList){
            favList.add(element['id']);
          }
          setState(() {});
        }
      }
    }catch(_){}
  }

  void _scrollListener() {
    // if (_isOnPageTurning &&
    //     _pageController.page == _pageController.page!.roundToDouble()) {
    //   setState(() {
    //     _currentPage = _pageController.page!.toInt();
    //     _isOnPageTurning = false;
    //   });
    // } else if (!_isOnPageTurning &&
    //     _currentPage.toDouble() != _pageController.page) {
    //   if ((_currentPage.toDouble() - _pageController.page!).abs() > 0.7) {
    //     setState(() {
    //       _isOnPageTurning = true;
    //     });
    //   }
    // }
  }

  void scrollListener() {
    // if (isOnPageTurning &&
    //     preloadPageController!.page ==
    //         preloadPageController!.page!.roundToDouble()) {
    //   setState(() {
    //     current = preloadPageController!.page!.toInt();
    //     isOnPageTurning = false;
    //   });
    // } else if (!isOnPageTurning &&
    //     current.toDouble() != preloadPageController!.page) {
    //   if ((current.toDouble() - preloadPageController!.page!).abs() > 0.1) {
    //     setState(() {
    //       isOnPageTurning = true;
    //     });
    //   }
    // }
  }

  Future<bool> isLogined() async {
    var instance = await SharedPreferences.getInstance();
    var loginData = instance.getString('currentUser');
    if (loginData != null) {
      return true;
    } else {
      return false;
    }
  }

  showAlertDialog(BuildContext context) {
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
   //     Navigator.pop(context);
        Get.back();
        reelsPlayerController?.pause();
        reelsPlayerController?.setVolume(0);
        shouldAutoPlayReel = false;
        // Get.to(LoginScreen());
        // Get.to(LoginScreen(isMultiLogin:"false"));
     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("CANCEL"),
      onPressed: () async {
        Get.back();

        //    Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Login"),
      content: const Text("Please login your account."),
      actions: [continueButton, cancelButton],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getUserData() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    if(currentUser!=null){
      UserModel current = UserModel.fromJson(jsonDecode(currentUser));
      setState(()=> userModel = current);
    }
  }

  loadInterstitialAd()async{
    InterstitialAd.load(
      adUnitId: homeInterstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback:
      InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
        interstitialAd = ad;
      }, onAdFailedToLoad: (LoadAdError error) {
        interstitialAd = null;
      }),
    );

  }

  showAd()async{
    if (interstitialAd != null ) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            interstitialAd = null;
            loadInterstitialAd();
            },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            ad.dispose();
            interstitialAd = null;
            loadInterstitialAd();
          });
      interstitialAd!.show();
    }
  }

  String getHashTagsToShow(List hashList){
    String hashTags = "";
    try{
      if(hashList.isEmpty){
        return hashTags;
      } else {
        if(hashList.length>=2){
          hashTags += "#${hashList.first} ";
          hashTags += "#${hashList.last}\n";
          return hashTags;
        } else {
          hashTags += "#${hashList.first}\n";
          return hashTags;
        }
      }
    } catch(e){
      return "";
    }
  }

  showReportDialog(int videoId, String name)async{
    String dropDownValue = "Reason";
    List<String> dropDownValues = ["Reason",];
    try{
      progressDialogue(context);
      var response = await RestApi.getSiteSettings();
      var json = jsonDecode(response.body);
      closeDialogue(context);
      if(json['status']){
        List jsonList = json['data'] as List;
        for(var element in jsonList){
          if(element['name']=='report_reason'){
            List reasonList = element['value'].toString().split(',');
            for(String reason in reasonList){
              dropDownValues.add(reason);
            }
            break;
          }
        }
      } else {
        showErrorToast(context, json['message'].toString());
        return;
      }
    }catch(e){
      closeDialogue(context);
      showErrorToast(context, e.toString());
      return;
    }
    showDialog(context: context, builder: (_)=>
        StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: getWidth(context)*.80,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text("Report $name's Video ?",
                          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 16), textAlign: TextAlign.center,),
                      ),
                      const SizedBox(height: 15,),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5)),
                        child: DropdownButton(
                          value: dropDownValue,
                          underline: Container(),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                            size: 35,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              dropDownValue = value??dropDownValues.first;
                            });
                          },
                          items: dropDownValues.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      ElevatedButton(
                          onPressed: dropDownValue=="Reason"?null:()async{
                            try{
                              var response = await RestApi.reportVideo(videoId,userModel!.id, dropDownValue);
                              var json = jsonDecode(response.body);
                              closeDialogue(context);
                              if(json['status']){
                                //Navigator.pop(context);
                                showSuccessToast(context, json['message'].toString());
                              } else {
                                //Navigator.pop(context);
                                showErrorToast(context, json['message'].toString());
                              }
                            }catch(e){
                              closeDialogue(context);
                              showErrorToast(context, e.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5)
                          ),
                          child: const Text("Report")
                      )
                    ],
                  )
                ),
              ),
            );
          },)
    );
  }
}
