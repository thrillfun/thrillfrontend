import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  bool isLoading=true;

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
        body: SingleChildScrollView(
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
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 60),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height+120,
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
                    const SizedBox(
                      height: 28,
                    ),
                    const Text(
                      "Withdraw",
                      style:
                          TextStyle(color: ColorManager.cyan, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      width:getWidth(context) * .85,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2,color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: DropdownButton(
                        menuMaxHeight: 180,
                        value:"USD",
                        style: const TextStyle(color: Colors.grey, fontSize: 17),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 35,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            setState(() {

                            });
                          });
                        },
                        items: ["USD","INR","EUR"].map((String item) {
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
                                color: Colors.grey.shade300,
                                width: 2),
                            borderRadius: BorderRadius.circular(10)),
                        constraints: BoxConstraints(
                            maxWidth:getWidth(context) * .85),),
                    ),
                     const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width:getWidth(context) * .85,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2,color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: DropdownButton(
                        menuMaxHeight: 180,
                        value:"Phone Pay",
                        style: const TextStyle(color: Colors.grey, fontSize: 17),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 35,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            setState(() {

                            });
                          });
                        },
                        items: ["Phone Pay","Paytm","Google Pay"].map((String item) {
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
                      padding: const EdgeInsets.only(left: 22,right: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            maxLength: 10,
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
                                      color: Colors.grey.shade300,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(10)),
                              constraints: BoxConstraints(
                                  maxWidth:getWidth(context)/2.3),),
                          ),
                          TextFormField(
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
                                      color: Colors.grey.shade300,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(10)),
                              constraints: BoxConstraints(
                                  maxWidth:getWidth(context) /2.5),),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            primary: ColorManager.deepPurple,
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .60, 50),
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
                          style:
                          TextStyle(color: ColorManager.cyan, fontSize: 18),
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

  void loadWalletInfo()async {

  }
}
