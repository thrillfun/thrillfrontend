import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thrill/models/history_model.dart';
import 'package:thrill/rest/rest_api.dart';

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
  List<PaymentHistoryModel> paymentHistoryList = List<PaymentHistoryModel>.empty(growable: true);
  bool isLoading = true;

  @override
  void initState() {
    getPaymentHistory();
    super.initState();
  }
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
      body: isLoading?
      const Center(child: CircularProgressIndicator(),):
      paymentHistoryList.isEmpty?
      Center(child: Text("Payment History Not Found!", style: Theme.of(context).textTheme.headline3,),):
      ListView.builder(
          shrinkWrap: true,
          itemCount: paymentHistoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    padding: const EdgeInsets.all(5),
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
                            text: paymentHistoryList[index].transactionStatus,
                            style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: paymentHistoryList[index].transactionStatus=="Pending"
                                ? Colors.blue :
                                paymentHistoryList[index].transactionStatus=="Completed"
                                    ? Colors.green
                                :Colors.red)),
                        const TextSpan(text: '\n'),
                        const WidgetSpan(
                            child: SizedBox(
                          height: 20,
                        )),
                        TextSpan(
                            text: DateFormat(dateTimeFormat)
                                .format(DateTime.parse(paymentHistoryList[index].createDate)

                            ),
                            style: const TextStyle(color: Colors.grey)),
                        const WidgetSpan(
                            child: SizedBox(
                              width: 5,
                            )),

                      ]),
                    ),
                  ),
                  Text(
                    paymentHistoryList[index].currency,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    ' ${paymentHistoryList[index].amount}/-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
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

  getPaymentHistory()async{
    try{
      var response = await RestApi.getPaymentHistory();
      var json = jsonDecode(response.body);
      final List jsonList = json["data"];
      paymentHistoryList = jsonList.map((e) => PaymentHistoryModel.fromJson(e)).toList();
      isLoading = false;
      setState((){});
    } catch(e){
      print(e.toString());
      setState(()=>isLoading = false);
    }
  }
}
