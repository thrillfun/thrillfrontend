import 'package:flutter/material.dart';

import '../../common/strings.dart';

class FreeUpSpace extends StatefulWidget {
  const FreeUpSpace({Key? key}) : super(key: key);

  @override
  State<FreeUpSpace> createState() => _FreeUpSpaceState();

  static const String routeName = '/freeSpace';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const FreeUpSpace(),
    );
  }
}

class _FreeUpSpaceState extends State<FreeUpSpace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          freeUpSpace,
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
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Expanded(
                    child: Text(
                  cache + '512.2 KB',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                )),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        side: const BorderSide(color: Colors.grey, width: 1)),
                    child: const Text(
                      clear,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              clearCacheDialog,
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(
              height: 50,
              color: Colors.grey,
              thickness: 1,
            ),
            Row(
              children: [
                const Expanded(
                    child: Text(
                  download + '219.7 MB',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                )),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        side: const BorderSide(color: Colors.grey, width: 1)),
                    child: const Text(
                      clear,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              clearDownloadDialog,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
