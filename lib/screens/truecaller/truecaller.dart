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
          appBar: AppBar(
            title: const Text('Truecaller SDK example'),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    TruecallerSdk.initializeSDK(
                        sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP);
                    TruecallerSdk.isUsable.then((isUsable) {
                      if (isUsable) {
                        TruecallerSdk.getProfile;
                      } else {
                        final snackBar = SnackBar(content: Text("Not Usable"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        print("***Not usable***");
                      }
                    });
                  },
                  child: Text(
                    "Initialize SDK & Get Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                StreamBuilder<TruecallerSdkCallback>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data!.result) {
                          case TruecallerSdkCallbackResult.success:
                            Get.to(()=> BottomNavigation());
                            return Text(

                                "Hi, ${snapshot.data!.profile!.firstName} ${snapshot.data!.profile!.lastName}"
                                    "\nBusiness Profile: ${snapshot.data!.profile!.isBusiness}");

                          case TruecallerSdkCallbackResult.failure:
                            return Text(
                                "Oops!! Error type ${snapshot.data!.error!.code}");

                          case TruecallerSdkCallbackResult.verification:
                            return Column(
                              children: [
                                Text("Verification Required : "
                                    "${snapshot.data!.error != null ? snapshot.data!.error!.code : ""}"),
                                MaterialButton(
                                  color: Colors.green,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NonTcVerification()));
                                  },
                                  child: const Text(
                                    "Do manual verification",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            );
                          default:
                            return const Text("Invalid result");
                        }
                      } else
                        return const Text("");
                    }),
              ],
            ),
          )),
    );
  }
}
