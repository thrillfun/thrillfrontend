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

  bool isLoading  = true;
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
          elevation: 0.5,
          title: const Text(
            inbox,
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
               Navigator.pop(context);
              },
              color: Colors.black,
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: isLoading?
            const Center(child: CircularProgressIndicator(),):
            inboxList.isEmpty?
            Center(child: Text("Inbox is Empty!", style: Theme.of(context).textTheme.headline3,),):
            ListView.builder(
                itemCount: inboxList.length,
                padding: const EdgeInsets.only(left: 20, right: 20),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: ()async{
                      await Navigator.pushNamed(context, '/chatScreen', arguments: inboxList[index]);
                      setState(() {
                        isLoading = true;
                        getInbox();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            height: 65,
                            width: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorManager.spinColorDivider
                                )
                            ),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              errorWidget: (a,b,c)=> Padding(
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
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: RichText(
                                maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: inboxList[index].name,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: '\n${inboxList[index].message}',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.grey.shade700
                                            ),
                                        ),
                                      ]
                                  ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              getComparedTime(inboxList[index].msgDate),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
      "seconds ago",
      "minutes ago",
      "hours ago",
      "days ago",
      "months ago",
      "years ago"
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

  getInbox()async{
    try{
      var response = await RestApi.getInbox();
      var json = jsonDecode(response.body);
      print(json);
      if(json['status']){
        List jsonList = json['data'] as List;
        if(jsonList.isNotEmpty)inboxList = jsonList.map((e) => InboxModel.fromJson(e)).toList();
        isLoading = false;
        setState(() {});
      } else {
        showErrorToast(context, json['message'].toString());
        setState(()=>isLoading=false);
      }
    } catch(e){
      setState(()=>isLoading=false);
    }
  }
}