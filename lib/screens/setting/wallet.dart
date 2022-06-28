import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrill/models/wallet_model.dart';
import 'package:thrill/rest/rest_api.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../utils/util.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();

  static const String routeName = '/wallet';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const Wallet(),
    );
  }
}

class _WalletState extends State<Wallet> {
  bool isLoading = true;
  List<String> payType = List<String>.empty(growable: true);
  List<String> currencyType = List<String>.empty(growable: true);
  int adminCommission = 0;
  List<WalletBalance> balanceList = List<WalletBalance>.empty(growable: true);
  TextEditingController feeCtr = TextEditingController();
  TextEditingController upiCtr = TextEditingController();
  TextEditingController amtCtr = TextEditingController();
  String selectedCurrecny="",selectedPayment="";

  @override
  void initState() {
    loadWalletInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/splash.png'), fit: BoxFit.cover)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlue,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
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
                            text: TextSpan(children: [
                          const TextSpan(
                              text: availableBalance + '\n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          TextSpan(
                              text: '${balanceList[0].amount}/-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32)),
                        ]))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 60),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height + 120,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 35,
                          ),
                          SizedBox(
                            width: getWidth(context) * .90,
                            height: balanceList.length * 80,
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: balanceList.length,
                                itemBuilder: (BuildContext context, index) {
                                  return availableBal(balanceList[index]);
                                }),
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          const Text(
                            "Withdraw",
                            style: TextStyle(
                                color: ColorManager.cyan, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: getWidth(context) * .85,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton(
                              menuMaxHeight: 180,
                              value: selectedCurrecny,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 17),
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: 35,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  setState(() {});
                                });
                              },
                              items: currencyType.map((String item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: upiCtr,
                            maxLength: 10,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: "Enter upi",
                              isDense: true,
                              counterText: '',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 2),
                                  borderRadius: BorderRadius.circular(10)),
                              constraints: BoxConstraints(
                                  maxWidth: getWidth(context) * .85),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: getWidth(context) * .85,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton(
                              menuMaxHeight: 180,
                              value: selectedPayment,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 17),
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: 35,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  setState(() {});
                                });
                              },
                              items: payType.map((String item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 22, right: 22),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextFormField(
                                  maxLength: 10,
                                  controller: amtCtr,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: "Amount",
                                    isDense: true,
                                    counterText: '',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    constraints: BoxConstraints(
                                        maxWidth: getWidth(context) / 2.3),
                                  ),
                                ),
                                TextFormField(
                                  controller: feeCtr,
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "Fee",
                                    isDense: true,
                                    counterText: '',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    constraints: BoxConstraints(
                                        maxWidth: getWidth(context) / 2.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if(upiCtr.text.isEmpty){
                                  showErrorToast(context, "Enter Upi");
                                }else{
                                  if(amtCtr.text.isEmpty){
                                    showErrorToast(context, "Enter Amount");
                                  }else{
                                    print(selectedCurrecny);
                                    print(upiCtr.text);
                                    print(selectedPayment);
                                    print(amtCtr.text);
                                    print(feeCtr.text);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: ColorManager.deepPurple,
                                  fixedSize: Size(
                                      MediaQuery.of(context).size.width * .60,
                                      50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: const Text(
                                withdrawAmount,
                                style: TextStyle(fontSize: 20),
                              )),
                          const SizedBox(
                            height: 25,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/paymentHistory');
                              },
                              child: const Text(
                                paymentHistory,
                                style: TextStyle(
                                    color: ColorManager.cyan, fontSize: 18),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  availableBal(WalletBalance walletBalance) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width * .85,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Center(
                    child: Text(
                      walletBalance.symbol,
                      style: const TextStyle(fontSize: 21),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Text("Available Balance in ${walletBalance.code}")),
                Text(
                  walletBalance.code + ' ${walletBalance.amount.toString()}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadWalletInfo() async {
    try {
      var result = await RestApi.getCommissionSetting();
      var json = jsonDecode(result.body);
      var arrayList = jsonDecode(json['data'][0]['value']);
      List<String> payTitle = List<String>.from(arrayList);
      payType.addAll(payTitle);
      selectedPayment=payType[0];
      adminCommission = int.parse(json['data'][1]['value']);

      var resultBal = await RestApi.getWalletBalance();
      var jsonBal = jsonDecode(resultBal.body);

      balanceList = List<WalletBalance>.from(
              jsonBal['data'].map((i) => WalletBalance.fromJson(i)))
          .toList(growable: true);

      var arrayListCurrency = json['data'][2]['value'];
      List<String> currencyTitle = List<String>.from(arrayListCurrency);
      currencyType.addAll(currencyTitle);
      selectedCurrecny=currencyType[0];
      feeCtr.text= '${adminCommission.toString()}% fees';
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
    }
  }
}
