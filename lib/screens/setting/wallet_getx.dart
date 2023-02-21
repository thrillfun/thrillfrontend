
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/wallet/wallet_balance_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/setting/transactions_history.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/dashedline_vertical_painter.dart';

class WalletGetx extends StatelessWidget {
  const WalletGetx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          backgroundWallet(),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: walletHistoryLayout())
        ],
      ),
    );
  }

  backgroundWallet() => const WalletBalance();

  walletOptionslayout() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          walletOptionsButton(Icons.wallet, "Deposit", () {}),
          Container(
            height: 50,
            child: CustomPaint(
              painter: DashedLineVerticalPainter(Colors.grey[300]!),
            ),
          ),
          walletOptionsButton(Icons.download, "Withdraw", () {}),
          Container(
            height: 50,
            child: CustomPaint(
              painter: DashedLineVerticalPainter(Colors.grey[300]!),
            ),
          ),
          walletOptionsButton(Icons.graphic_eq, "Earn", () {})
        ],
      );

  walletOptionsButton(IconData icon, String text, VoidCallback callback) =>
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: InkWell(
          onTap: callback,
          child: Column(
            children: [
              ClipOval(
                child: Container(
                  height: 40,
                  width: 40,
                  child: Icon(
                    icon,
                    color: ColorManager.dayNightText,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    color: ColorManager.dayNightText,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );

  walletHistoryLayout() => const WalletHistory();
}

class WalletHistory extends GetView<WalletBalanceController> {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: Get.width,
              height: Get.height,
              decoration: BoxDecoration(
                  color: ColorManager.dayNight,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Portfolio",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                            color: ColorManager.dayNightText),
                      ),
                       InkWell(child: const Icon(Icons.book),onTap: ()=>Get.to(TransactionsHistory()),),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state!.length,
                          itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                                fit: BoxFit.contain,
                                                imageUrl: state![index]
                                                            .image
                                                            .toString()
                                                            .isEmpty ||
                                                        state[index].image ==
                                                            null
                                                    ? "https://cdn1.iconfinder.com/data/icons/cryptocurrency-set-2018/375/Asset_1480-512.png"
                                                    : RestUrl.currencyUrl +
                                                        state[index]
                                                            .image
                                                            .toString()),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (state[index].code!).toString(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Text(
                                                state[index].symbol.toString(),
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                state[index].amount.toString(),
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              index==0?Text(
                                                      "Coming soon",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .dayNightText,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight
                                                              .w400)): Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Obx(() => Text(
                                                      "\$${index == 0 ? controller.thrillPrice.value : index == 1 ? controller.btcPrice.value : index == 2 ? controller.ethPrice.value : index == 3 ? controller.bnbPrice.value : index == 4 ? controller.shibPrice.value : index == 5 ? controller.dogePrice.value : index == 6 ? controller.luncPrice.value : controller.thrillPrice.value} ",
                                                      style: TextStyle(
                                                          color: ColorManager
                                                              .dayNightText,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight
                                                              .w400))),
                                                  Obx(() => Text(
                                                        "(${index == 0 ? controller.thrillPer.value + " %" : index == 1 ? controller.btcPer.value + " %" : index == 2 ? controller.ethPer.value + " %" : index == 3 ? controller.bnbPer.value + " %" : index == 4 ? controller.shibPer.value + " %" : index == 5 ? controller.dogePer.value + " %" : index == 6 ? controller.luncPer.value + " %" : controller.thrillPer.value + " %"}) ",
                                                        style: TextStyle(
                                                            color: index == 0 &&
                                                                    controller
                                                                        .thrillPer
                                                                        .value
                                                                        .contains(
                                                                            "-")
                                                                ? Colors.red
                                                                : index == 1 &&
                                                                        controller
                                                                            .btcPer
                                                                            .value
                                                                            .contains(
                                                                                "-")
                                                                    ? Colors.red
                                                                    : index == 2 &&
                                                                            controller.ethPer.value.contains(
                                                                                "-")
                                                                        ? Colors
                                                                            .red
                                                                        : index == 3 &&
                                                                                controller.bnbPer.value.contains("-")
                                                                            ? Colors.red
                                                                            : index == 4 && controller.shibPer.value.contains("-")
                                                                                ? Colors.red
                                                                                : index == 5 && controller.dogePer.value.contains("-")
                                                                                    ? Colors.red
                                                                                    : index == 6 && controller.luncPer.value.contains("-")
                                                                                        ? Colors.red
                                                                                        : Colors.green,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700),
                                                      ))
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: const Divider(),
                                    ),
                                  ],
                                ),
                              )))
                ],
              ),
            ),
        onLoading: loader());
  }
}

class WalletBalance extends GetView<WalletBalanceController> {
  const WalletBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTextVisible = true.obs;

    return controller.obx(
        (state) => Container(
              decoration: const BoxDecoration(
              
                  gradient: ColorManager.walletGradient,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              width: Get.width,
              height: Get.height / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Balance(BTC)",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400),
                            ),
                            InkWell(
                              onTap: () => isTextVisible.toggle(),
                              child: Obx(() => isTextVisible.isTrue
                                  ? Icon(
                                      Icons.visibility_off,
                                      color: Colors.white.withOpacity(0.6),
                                    )
                                  : Icon(
                                      Icons.visibility,
                                      color: Colors.white.withOpacity(0.6),
                                    )),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Obx(() => TextFormField(
                              enabled: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '',
                              ),
                              controller: textEditingController.value,
                              obscuringCharacter: '*',
                              obscureText: isTextVisible.value,
                              style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                      Obx(() =>  Text(
                              controller.totalbalance.value,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400),
                            )),
                    ],
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () => null,
                        child: Card(
                          color: ColorManager.dayNight,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.money),
                                Text("Deposit")
                              ],
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () => Get.to(PaymentRequest()),
                        child: Card(
                          color: ColorManager.dayNight,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.book),
                                Text("Withdraw")
                              ],
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () => null,
                        child: Card(
                          color: ColorManager.dayNight,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.card_giftcard),
                                Text("Earn")
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
        onLoading: Center(
          child: loader(),
        ));
  }
}
