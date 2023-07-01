import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset("assets/background.json"),
            Lottie.asset(
              "assets/no_internet.json",
            )
          ],
        ),
        Text(
          "No Internet Connection!",
          style: TextStyle(fontSize: 25),
        )
      ],
    );
  }
}
