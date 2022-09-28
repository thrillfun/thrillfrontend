import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/inbox_model.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();

  static const String routeName = '/inbox';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const Inbox(),
    );
  }
}

class _InboxState extends State<Inbox> {
  bool isLoading = true;
  List<InboxModel> inboxList = List<InboxModel>.empty(growable: true);

  @override
  void initState() {
    getInbox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF2F8897),
                    Color(0xff1F2A52),
                    Color(0xff1F244E)
                  ]),
            ),
          ),
          elevation: 0.5,
          title: const Text(
            inbox,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : inboxList.isEmpty
                ? Center(
                    child: Text(
                      "Inbox is Empty!",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  )
                : ListView.builder(
                    itemCount: inboxList.length,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, '/chatScreen',
                                  arguments: inboxList[index])
                              .then((value) {
                            if (value != null) {
                              InboxModel _inboxModel = value as InboxModel;
                              for (InboxModel im in inboxList) {
                                if (im.id == _inboxModel.id) {
                                  setState(() => inboxList.replaceRange(
                                      inboxList.indexOf(im),
                                      inboxList.indexOf(im) + 1,
                                      [_inboxModel]));
                                  break;
                                }
                              }
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                padding: const EdgeInsets.all(2),
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: ColorManager.spinColorDivider)),
                                child: ClipOval(
                                  child: inboxList[index].userImage.isEmpty
                                      ? SvgPicture.asset(
                                          'assets/profile.svg',
                                          width: 10,
                                          height: 10,
                                        )
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          errorWidget: (a, b, c) => Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: SvgPicture.asset(
                                              'assets/profile.svg',
                                              width: 10,
                                              height: 10,
                                            ),
                                          ),
                                          imageUrl:
                                              '${RestUrl.profileUrl}${inboxList[index].userImage}',
                                          placeholder: (a, b) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          inboxList[index].name.capitalize(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          inboxList[index].message,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w200,
                                              fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  getComparedTime(inboxList[index].msgDate),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
  }

  String getComparedTime(String dateTime) {
    Duration difference = DateTime.now().difference(DateTime.parse(dateTime));
    final List prefix = [
      "just now",
      "second(s) ago",
      "minute(s) ago",
      "hour(s) ago",
      "day(s) ago",
      "month(s) ago",
      "year(s) ago"
    ];
    if (difference.inDays == 0) {
      if (difference.inMinutes == 0) {
        if (difference.inSeconds < 20) {
          return (prefix[0]);
        } else {
          return ("${difference.inSeconds} ${prefix[1]}");
        }
      } else {
        if (difference.inMinutes > 59) {
          return ("${(difference.inMinutes / 60).floor()} ${prefix[3]}");
        } else {
          return ("${difference.inMinutes} ${prefix[2]}");
        }
      }
    } else {
      if (difference.inDays > 30) {
        if (((difference.inDays) / 30).floor() > 12) {
          return ("${((difference.inDays / 30) / 12).floor()} ${prefix[6]}");
        } else {
          return ("${(difference.inDays / 30).floor()} ${prefix[5]}");
        }
      } else {
        return ("${difference.inDays} ${prefix[4]}");
      }
    }
  }

  getInbox() async {
    try {
      var response = await RestApi.getInbox();
      var json = jsonDecode(response.body);
      if (json['status']) {
        List jsonList = json['data'] as List;
        if (jsonList.isNotEmpty)
          inboxList = jsonList.map((e) => InboxModel.fromJson(e)).toList();
        isLoading = false;
        setState(() {});
      } else {
        showErrorToast(context, json['message'].toString());
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
}
