import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/video/video_bloc.dart';
import 'package:thrill/rest/rest_api.dart';
import '../../common/strings.dart';
import '../../models/comment_model.dart';
import '../../models/user.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';
import '../../widgets/image_rotate.dart';
import '../../widgets/video_item.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int selectedTopIndex = 0;
  List<String> likeList = List<String>.empty(growable: true);
  List<Comments> commentList = List<Comments>.empty(growable: true);
  List<String> likeComment = List<String>.empty(growable: true);
  TextEditingController msgCtr = TextEditingController();
  List<String> followList = List<String>.empty(growable: true);

  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  int _currentPage = 0;
  bool _isOnPageTurning = false;
  String isError = '';

  @override
  void initState() {
    loadLikes();
    _pageController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<VideoBloc, VideoState>(builder: (context, state) {
      if (state is VideoInitial) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.lightBlueAccent),
        );
      } else if (state is VideoLoded) {
        if (state.list.isEmpty) {
          return Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/splash.png'))),
              child: const Center(
                child: Text(
                  "oops! Try again",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ));
        } else {
          return Stack(
            children:[
              PageView.builder(
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
                          if (likeList.isEmpty) {
                            likeList.add(state.list[index].id.toString());
                            state.list[index]
                                .copyWith(likes: state.list[index].likes++);
                          } else {
                            if (likeList.contains(
                                state.list[index].id.toString())) {
                              likeList
                                  .remove(state.list[index].id.toString());
                              state.list[index].copyWith(
                                  likes: state.list[index].likes--);
                            } else {
                              likeList.add(state.list[index].id.toString());
                              state.list[index].copyWith(
                                  likes: state.list[index].likes++);
                            }
                          }
                          SharedPreferences pref =
                          await SharedPreferences.getInstance();
                          pref.setStringList('likeList', likeList);

                          BlocProvider.of<VideoBloc>(context).add(
                              AddRemoveLike(
                                  isAdded: likeList.contains(
                                      state.list[index].id.toString())
                                      ? 1
                                      : 0,
                                  videoId: state.list[index].id));
                          setState(() {});
                        },
                      ),
                      Positioned(
                        bottom: 160,
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
                                    await isLogined().then((value) {
                                      if (value) {
                                        Navigator.pushNamed(
                                            context, "/viewProfile", arguments: {
                                          "userModel": state.list[index].user,
                                          "getProfile": false
                                        });
                                      } else {
                                        showAlertDialog(context);
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
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
                              child: likeList
                                      .contains(state.list[index].id.toString())
                                  ? const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 28,
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
                                onTap: () {},
                                child: SvgPicture.asset(
                                  'assets/share.svg',
                                  height: 22,
                                  width: 22,
                                )),
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
                                      Text(
                                        '@${state.list[index].user.username}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(color: Colors.white),
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
                                      InkWell(
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
                                        child: Text(
                                          state.list[index].sound_name.isEmpty
                                              ? 'Original sound - @Fintory'
                                              : '${state.list[index].sound_name} - @${state.list[index].sound_category_name}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const RotatedImage("test.png"),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
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
                            selectedTopIndex = 0;
                          });
                        },
                        child: Text(
                          following,
                          style: TextStyle(
                              color: selectedTopIndex == 0
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 18),
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
                            selectedTopIndex = 1;
                          });
                        },
                        child: Text(
                          related,
                          style: TextStyle(
                              color: selectedTopIndex == 1
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 18),
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
                            selectedTopIndex = 2;
                          });
                        },
                        child: Text(
                          liveUsers,
                          style: TextStyle(
                              color: selectedTopIndex == 2
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 18),
                        )),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: ()async {
                          await isLogined().then((value) {
                            if (value) {
                              Navigator.pushNamed(context, "/record");
                            } else {
                              showAlertDialog(context);
                            }
                          });
                        },
                        iconSize: 28,
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ]
          );
        }
      }
      return Container();
    }));
  }

  showComments(BuildContext context, int videoId) async {
    try {
      progressDialogue(context);
      var result = await RestApi.getCommentListOnVideo(videoId);
      var json = jsonDecode(result.body);
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
                                                      color:
                                                          Colors.grey.shade700))
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
                                                        size: 28,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .favorite_border_outlined,
                                                        color: Colors.grey,
                                                        size: 28,
                                                      ),
                                              ),
                                              Text(
                                                  '${commentList[index].comment_like_counter}')
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
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  progressDialogue(context);
                                  var pref =
                                      await SharedPreferences.getInstance();
                                  var currentUser =
                                      pref.getString('currentUser');
                                  UserModel current = UserModel.fromJson(
                                      jsonDecode(currentUser!));
                                  var resultComment = await RestApi.postComment(
                                      videoId, current.id, msgCtr.text);
                                  try {
                                    var jsonComment =
                                        jsonDecode(resultComment.body);
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
                                      setState(() {});
                                      closeDialogue(context);
                                    } else {
                                      closeDialogue(context);
                                    }
                                  } catch (_) {
                                    closeDialogue(context);
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
            });
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
  }

  void _scrollListener() {
    if (_isOnPageTurning &&
        _pageController.page == _pageController.page!.roundToDouble()) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
        _isOnPageTurning = false;
      });
    } else if (!_isOnPageTurning &&
        _currentPage.toDouble() != _pageController.page) {
      if ((_currentPage.toDouble() - _pageController.page!).abs() > 0.7) {
        setState(() {
          _isOnPageTurning = true;
        });
      }
    }
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
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("CANCEL"),
      onPressed: () async {
        Navigator.pop(context);
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
}
