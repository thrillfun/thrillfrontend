import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:thrill/models/notification_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import '../../common/strings.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);
  static const String routeName = '/notifications';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const Notifications(),
    );
  }

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  List<NotificationModel> notificationList = List<NotificationModel>.empty(growable: true);
  bool isLoading = true;

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          title: const Text(
            notifications,
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // leading: IconButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     color: Colors.black,
          //     icon: const Icon(Icons.arrow_back_ios)),
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
        ),
        body: isLoading?
            const Center(child: CircularProgressIndicator(),):
            notificationList.isEmpty?
            Center(child: Text("No Notifications to Display!", style: Theme.of(context).textTheme.headline3,),):
            ListView.builder(
                itemCount: notificationList.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: (){
                      String redirectType = notificationList[index].redirectType;
                      if(redirectType=='video' && notificationList[index].videoModel!=null){
                        Navigator.pushReplacementNamed(context, '/', arguments: {'videoModel': notificationList[index].videoModel});
                      } else if(redirectType=='comment' && notificationList[index].videoModel!=null){
                        Navigator.pushReplacementNamed(context, '/', arguments: {'videoModel': notificationList[index].videoModel});
                      } else if(redirectType=='user' && notificationList[index].userId!=0){
                        Navigator.pushNamed(context, "/viewProfile", arguments: {"id":notificationList[index].userId, "getProfile":true});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1)),
                        child: Image.asset('assets/logo_.png'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: '${notificationList[index].title}\n',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: notificationList[index].body,
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          )
                        ])),
                      ),
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: Container(
                      //     margin: const EdgeInsets.only(left: 5),
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 8, vertical: 4),
                      //     decoration: BoxDecoration(
                      //         color: ColorManager.cyan,
                      //         borderRadius: BorderRadius.circular(5)),
                      //     child: const Text(
                      //       watch,
                      //       style: TextStyle(
                      //           color: Colors.white, fontWeight: FontWeight.bold),
                      //     ),
                      //   ),
                      // )
                    ],
                ),
              ),
                  );
            }));
  }

  getNotifications()async{
    try{
      var response = await RestApi.getNotificationList();
      var json = jsonDecode(response.body);
      if(json['status']){
        List jsonList = json['data'] as List;
        if (jsonList.isNotEmpty) notificationList = jsonList.map((e) => NotificationModel.fromJson(e)).toList();
        isLoading = false;
        setState((){});
      } else {
        showErrorToast(context, json['message']);
      }
    } catch(e){
      setState(()=>isLoading = false);
      showErrorToast(context, "Notification Fetch Ended with Error:\n$e");
    }
  }
}
