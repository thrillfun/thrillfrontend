import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/route_manager.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'non_tc_verification.dart';

class TrueCallerScreen extends StatefulWidget {
  const TrueCallerScreen({Key? key}) : super(key: key);

  @override
  State<TrueCallerScreen> createState() => _TrueCallerScreenState();
}

class _TrueCallerScreenState extends State<TrueCallerScreen> {
  late Stream<TruecallerSdkCallback>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = TruecallerSdk.streamCallbackData;
  }

  @override
  void dispose() {
    _stream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () {

              },
              child: const Text(
                "Verify Account",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),

          ],
        ),
      )),
    );
  }
}
