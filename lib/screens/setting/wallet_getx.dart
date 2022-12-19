import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/wallet/wallet_balance_controller.dart';
import 'package:thrill/controller/wallet/wallet_currencies_controller.dart';
import 'package:thrill/controller/wallet_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/dashedline_vertical_painter.dart';

class WalletGetx extends StatelessWidget {
  const WalletGetx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: Stack(
        children: [
          GetX<WalletController>(
              builder: (walletController) =>
                  walletController.isCurrenciesLoading.value
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            backgroundWallet(),
                            const SizedBox(
                              height: 20,
                            ),
                            walletOptionslayout(),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(child: walletHistoryLayout())
                          ],
                        ))
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
      InkWell(
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
      );

  walletHistoryLayout() => const WalletHistory();
}

class WalletHistory extends GetView<WalletCurrenciesController> {
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
                      Icon(Icons.book),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: state!.length,
                          itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            padding: const EdgeInsets.all(10),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  height: 30,
                                                  width: 30,
                                                  imageUrl: state[index]
                                                              .image
                                                              .toString()
                                                              .isEmpty ||
                                                          state[index]
                                                                  .image
                                                                  .toString() ==
                                                              "null"
                                                      ? "https://cdn1.iconfinder.com/data/icons/cryptocurrency-set-2018/375/Asset_1480-512.png"
                                                      : RestUrl.currencyUrl +
                                                          state[index]
                                                              .image
                                                              .toString()),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              state[index].code.toString(),
                                              style: TextStyle(
                                                  color:
                                                      ColorManager.dayNightText,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(state[index].code.toString(),
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                                        Expanded(
                                            child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            children: [
                                              Text(
                                                state[index]
                                                    .networks
                                                    .toString(),
                                                style: TextStyle(
                                                    color: ColorManager
                                                        .dayNightText,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ))
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
    return controller.obx((state) => Container(
          margin: const EdgeInsets.only(top: 10),
          width: Get.width,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.loose,
            children: [
              SvgPicture.asset(
                "assets/wallet_stars.svg",
                fit: BoxFit.fill,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset("assets/thrill_token.png"),
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/logo.png",
                            width: 60,
                            height: 40,
                            fit: BoxFit.fill,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      controller.balance.first.symbol.toString() +
                          controller.balance.first.amount.toString(),
                      style: TextStyle(
                          color: ColorManager.dayNightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
