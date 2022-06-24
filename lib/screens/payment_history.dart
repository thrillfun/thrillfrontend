import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/strings.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();

  static const String routeName = '/paymentHistory';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const PaymentHistory(),
    );
  }
}

class _PaymentHistoryState extends State<PaymentHistory> {
  String dateTimeFormat = 'dd MMMM, h:mm a';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        centerTitle: true,
        title: const Text(
          history,
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: ListView.builder(
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: Image.asset('assets/paytm.png'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                            text: paytm + '\n',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black)),
                        const WidgetSpan(
                            child: SizedBox(
                          height: 20,
                        )),
                        TextSpan(
                            text: DateFormat(dateTimeFormat)
                                .format(DateTime.now()),
                            style: const TextStyle(color: Colors.grey))
                      ]),
                    ),
                  ),
                  const Text(
                    '₹ ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  Text(
                    '${Random().nextInt(1000)}/-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            );
          }),
    );
  }
}
