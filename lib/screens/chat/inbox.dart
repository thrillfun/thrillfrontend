import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../common/strings.dart';

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
  List inboxList = List.empty(growable: true);

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
        body: ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.only(left: 20, right: 20),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: 'https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-Vector-PNG-Clipart.png',
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
                            text: TextSpan(
                                children: [
                                  const TextSpan(
                                      text: 'Peter Drinklage',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: '\nHi, Lorem Ipsum, test some, do some...',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey.shade700
                                      ),
                                  ),
                                ]
                            ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        '10 day ago',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
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

  }
}