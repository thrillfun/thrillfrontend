import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:thrill/models/wallet_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
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
  List<WalletBalance> balanceList = List<WalletBalance>.empty(growable: true);
  WalletBalance? walBalance;

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
          centerTitle: true,
          title: const Text(""),
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
                child: CircularProgressIndicator(
                  color: Colors.lightBlue,
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/paymentRequest').then((value) => {
                            loadWalletInfo()
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "Withdraw",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.grey, width: 1)),
                              child: Center(
                                child: walBalance!.symbol.isEmpty
                                    ? Image.network(
                                  RestUrl.currencyUrl + walBalance!.image,
                                  width: 20,
                                  height: 20,
                                )
                                    : Text(
                                  walBalance!.symbol,
                                  style: const TextStyle(fontSize: 15,color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: availableBalance + '\n',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              TextSpan(
                                  text: '${walBalance!.amount}/-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32)),
                            ])),
                            const SizedBox(
                              width: 10,
                            ),
                          ]),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/paymentHistory').then((value)=>{
                            loadWalletInfo()
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "History",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: getWidth(context) * .90,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: balanceList.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return availableBal(balanceList[index]);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  availableBal(WalletBalance walletBalance) {
    return InkWell(
      onTap: (){
        setState(() {
          walBalance=walletBalance;
        });
      },
      child: Container(
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
                      child: walletBalance.symbol.isEmpty
                          ? Image.network(
                              RestUrl.currencyUrl + walletBalance.image,
                              width: 20,
                              height: 20,
                            )
                          : Text(
                              walletBalance.symbol,
                              style: const TextStyle(fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text("Available Balance in ${walletBalance.code}"),
                      const SizedBox(height: 2),
                      Text("Status : ${walletBalance.isActive==1 ? "active" :"suspended"}"),
                        ],
                      ),),
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
      ),
    );
  }

  void loadWalletInfo() async {
    try {
      var resultBal = await RestApi.getWalletBalance();
      var jsonBal = jsonDecode(resultBal.body);

      balanceList = List<WalletBalance>.from(
              jsonBal['data'].map((i) => WalletBalance.fromJson(i)))
          .toList(growable: true);
      walBalance=balanceList[0];
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
    }
  }
}
