import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../common/color.dart';
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
        body: ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.only(left: 20, right: 20),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                child: Row(
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
                        imageUrl:
                            'https://www.w3schools.com/howto/img_avatar.png',
                        placeholder: (a, b) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                            text: 'Bill Gates\n',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'East or west, Apple is the best! Apple! Apple!! Apple!!! ',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700))
                      ])),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: ColorManager.cyan,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Text(
                          watch,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }));
  }
}
