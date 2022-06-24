import 'package:flutter/material.dart';

import '../../common/strings.dart';

class Privacy extends StatefulWidget {
  const Privacy({Key? key}) : super(key: key);

  @override
  State<Privacy> createState() => _PrivacyState();
  static const String routeName = '/privacy';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const Privacy(),
    );
  }
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          privacy,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              safety,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Expanded(child: Text(allowYourVideosToBeDownloaded)),
                Text(on)
              ],
            ),
            const Text(
              allowYourVideosToBeDownloadedDialog,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Expanded(child: Text(whoCanSendYouDirectMessage)),
                Text(everyone)
              ],
            ),
            const Text(
              whoCanSendYouDirectMessageDialog,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Expanded(child: Text(whoCanDuetWithYourVideo)),
                Text(everyone)
              ],
            ),
            const Text(
              whoCanDuetWithYourVideoDialog,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Expanded(child: Text(whoCanViewYourLikedVideos)),
                Text(me)
              ],
            ),
            const Text(
              whoCanViewYourLikedVideosDialog,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Expanded(child: Text(whoCanCommentOnYourVideos)),
                Text(everyone)
              ],
            ),
            const Text(
              whoCanCommentOnYourVideosDialog,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
