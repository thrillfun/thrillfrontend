import 'dart:convert';
import 'package:flutter/material.dart';
import '../../common/color.dart';
import '../../models/currency_model.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class PaymentRequest extends StatefulWidget {
  const PaymentRequest({Key? key}) : super(key: key);

  @override
  State<PaymentRequest> createState() => _PaymentRequestState();

  static const String routeName = '/paymentRequest';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const PaymentRequest(),
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
      body:  isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: getWidth(context) * .85,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<CurrencyModel>(
                  menuMaxHeight: 180,
                  value: model,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 17),
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
                      netList=value.networks;
                      networks=netList!.first;
                      feeCtr.text=netList!.first.feeDigit.toString();
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
              TextFormField(
                controller: upiCtr,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter upi or address",
                  isDense: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  constraints:
                      BoxConstraints(maxWidth: getWidth(context) * .85),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: getWidth(context) * .85,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<Networks>(
                  menuMaxHeight: 180,
                  value: networks,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 17),
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
                      feeCtr.text=value.feeDigit.toString();
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
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextFormField(
                      controller: amtCtr,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Amount",
                        isDense: true,
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(10)),
                        constraints:
                            BoxConstraints(maxWidth: getWidth(context) / 2.3),
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
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(10)),
                        constraints:
                            BoxConstraints(maxWidth: getWidth(context) / 2.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (upiCtr.text.isEmpty) {
                      showErrorToast(context, "Enter Upi or address");
                    } else {
                      if (amtCtr.text.isEmpty) {
                        showErrorToast(context, "Enter Amount");
                      } else {
                        if(double.parse(amtCtr.text) < networks!.minAmount){
                          showErrorToast(context, "Enter Min Amount ${networks!.minAmount} ");
                        }else{
                          if(double.parse(amtCtr.text) > networks!.maxAmount){
                            showErrorToast(context, "Enter Max Amount ${networks!.maxAmount} ");
                          }else{
                             progressDialogue(context);
                            try {
                          var result = await RestApi.sendWithdrawlRequest(
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
                            showSuccessToast(context, json['message']);
                          } else {
                            closeDialogue(context);
                            showErrorToast(context, json['message']);
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
                      primary: ColorManager.deepPurple,
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * .60, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: const Text(
                    "Request",
                    style: TextStyle(fontSize: 20),
                  )),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
    );
  }

  void loadWalletInfo() async {
    try {
      var result = await RestApi.getCurrencyDeatils();
      var json = jsonDecode(result.body);
      curList = List<CurrencyModel>.from(json['data'].map((i) => CurrencyModel.fromJson(i))).toList(growable: true);
      model=curList[0];
      netList=curList[0].networks;
      networks=curList[0].networks[0];
      feeCtr.text=curList[0].networks[0].feeDigit.toString();
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      showErrorToast(context, e.toString());
      setState(() {});
    }
  }

}
