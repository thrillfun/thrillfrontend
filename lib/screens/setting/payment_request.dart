import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/color.dart';
import '../../models/currency_model.dart';
import '../../models/wallet_model.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class PaymentRequest extends StatefulWidget {
  const PaymentRequest({Key? key, required this.balanceList}) : super(key: key);
  final List<WalletBalance> balanceList;

  @override
  State<PaymentRequest> createState() => _PaymentRequestState();

  static const String routeName = '/paymentRequest';

  static Route route(List<WalletBalance> listBalance) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => PaymentRequest(
        balanceList: listBalance,
      ),
    );
  }
}

class _PaymentRequestState extends State<PaymentRequest> {
  bool isLoading = true;
  int adminCommission = 0;

  TextEditingController feeCtr = TextEditingController();
  TextEditingController upiCtr = TextEditingController();
  TextEditingController amtCtr = TextEditingController();
  List<CurrencyModel> curList = List<CurrencyModel>.empty(growable: true);
  CurrencyModel? model;
  List<Networks>? netList;
  Networks? networks;

  @override
  void initState() {
    loadWalletInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff21252E),
        centerTitle: true,
        title: const Text("Withdrawal Request"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear)),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    myLabel("Address"),
                    TextFormField(
                      controller: upiCtr,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: "Enter upi or address",
                        isDense: true,
                        counterText: '',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myLabel("Currency"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey.shade100,
                      ),
                      child: DropdownButton<CurrencyModel>(
                        menuMaxHeight: 180,
                        value: model,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 35,
                        ),
                        onChanged: (CurrencyModel? value) {
                          setState(() {
                            model = value!;
                            netList = value.networks;
                            networks = netList!.first;
                            feeCtr.text = netList!.first.feeDigit.toString();
                          });
                        },
                        items: curList.map((CurrencyModel item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.code),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myLabel("Network"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton<Networks>(
                        menuMaxHeight: 180,
                        value: networks,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 35,
                        ),
                        onChanged: (Networks? value) {
                          setState(() {
                            networks = value!;
                            feeCtr.text = value.feeDigit.toString();
                          });
                        },
                        items: netList!.map((Networks item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.networkName),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myLabel("Amount"),
                    TextFormField(
                      controller: amtCtr,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: "Amount",
                        isDense: true,
                        counterText: '',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myLabel("Fees"),
                    TextFormField(
                      controller: feeCtr,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 12),
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: "Fee",
                        isDense: true,
                        counterText: '',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                        height: 100,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorManager.cyan,
                                ColorManager.deepPurple
                              ]),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  const TextSpan(text: "Available Amount\n\n"),
                                  TextSpan(
                                      text: getAvailableAmount(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ])),
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  const TextSpan(
                                      text: "24h Withdrawal Limit\n\n"),
                                  TextSpan(
                                      text:
                                          "${netList?.first.maxAmount} ${model?.code}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ])),
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Do not withdraw directly to a crowdfund or ICO."
                        "\n"
                        "We will not credit your account with token from that sale",
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (upiCtr.text.isEmpty) {
                              showErrorToast(context, "Enter Upi or address");
                            } else {
                              if (amtCtr.text.isEmpty) {
                                showErrorToast(context, "Enter Amount");
                              } else {
                                if (double.parse(amtCtr.text) <
                                    networks!.minAmount) {
                                  showErrorToast(context,
                                      "Enter Min Amount ${networks!.minAmount} ");
                                } else {
                                  if (double.parse(amtCtr.text) >
                                      networks!.maxAmount) {
                                    showErrorToast(context,
                                        "Enter Max Amount ${networks!.maxAmount} ");
                                  } else {
                                    progressDialogue(context);
                                    try {
                                      var result =
                                          await RestApi.sendWithdrawlRequest(
                                              model!.code,
                                              upiCtr.text,
                                              networks!.networkName,
                                              networks!.feeDigit.toString(),
                                              amtCtr.text);
                                      var json = jsonDecode(result.body);
                                      if (json['status']) {
                                        amtCtr.text = "";
                                        upiCtr.text = "";
                                        setState(() {});
                                        closeDialogue(context);
                                        showSuccessToast(
                                            context, json['message']);
                                      } else {
                                        closeDialogue(context);
                                        showErrorToast(
                                            context, json['message']);
                                      }
                                    } catch (e) {
                                      closeDialogue(context);
                                      showErrorToast(context, e.toString());
                                    }
                                  }
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text(
                            "Withdraw",
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void loadWalletInfo() async {
    try {
      var result = await RestApi.getCurrencyDeatils();
      var json = jsonDecode(result.body);
      curList = List<CurrencyModel>.from(
              json['data'].map((i) => CurrencyModel.fromJson(i)))
          .toList(growable: true);
      model = curList[0];
      netList = curList[0].networks;
      networks = curList[0].networks[0];
      feeCtr.text = curList[0].networks[0].feeDigit.toString();
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      showErrorToast(context, e.toString());
      setState(() {});
    }
  }

  Widget myLabel(String txt) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            txt,
            style: const TextStyle(
                color: Color(0xff21252E),
                fontWeight: FontWeight.w900,
                fontSize: 13),
          ),
        ));
  }

  String getAvailableAmount() {
    String avBal = '';
    for (var element in widget.balanceList) {
      if (element.code == model!.code) {
        avBal = "${element.amount} ${element.code}";
        break;
      }
    }
    return avBal;
  }
}
