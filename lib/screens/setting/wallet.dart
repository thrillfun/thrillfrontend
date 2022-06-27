import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/color.dart';
import '../../common/strings.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();

  static const String routeName = '/wallet';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const Wallet(),
    );
  }

}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/splash.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              const Border(bottom: BorderSide(color: Colors.white, width: 1)),
          centerTitle: true,
          title: const Text(wallet),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/rupee.svg',
                ),
                const SizedBox(
                  width: 10,
                ),
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: availableBalance + '\n',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  TextSpan(
                      text: '500.00/-',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                ]))
              ],
            ),
            const Spacer(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .75,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  availableBal(currency: 'dollar'),
                  const SizedBox(
                    height: 20,
                  ),
                  availableBal(currency: 'euro'),
                  const SizedBox(
                    height: 20,
                  ),
                  availableBal(currency: 'sar'),
                  const Spacer(
                    flex: 5,
                  ),
                  TextButton(
                      onPressed: () {
                       Navigator.pushNamed(context, '/paymentHistory');
                      },
                      child: const Text(
                        paymentHistory,
                        style:
                            TextStyle(color: ColorManager.cyan, fontSize: 18),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          primary: ColorManager.deepPurple,
                          fixedSize:
                              Size(MediaQuery.of(context).size.width * .60, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: const Text(
                        withdrawAmount,
                        style: TextStyle(fontSize: 20),
                      )),
                  const Spacer(
                    flex: 1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  availableBal({required String currency}) {
    return SizedBox(
      height: 70,
      width: MediaQuery.of(context).size.width * .85,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Image.asset(currency == 'dollar'
                  ? 'assets/dollar.png'
                  : currency == 'euro'
                      ? 'assets/euro.png'
                      : 'assets/sar.png'),
              const SizedBox(
                width: 5,
              ),
              const Expanded(child: Text(availableBalanceDollar)),
              Text(
                (currency == 'dollar'
                        ? '\$'
                        : currency == 'euro'
                            ? '€ '
                            : 'SAR ') +
                    ' 6.59',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
