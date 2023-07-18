import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/widgets/no_search_result.dart';

import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import '../../../utils/utils.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTextVisible = true.obs;
    controller.getBalance();
    return Scaffold(
        body: controller.obx(
      (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 0, right: 10),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Obx(() => TextFormField(
                              enabled: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: '',
                              ),
                              controller:
                                  controller.textEditingController.value,
                              obscuringCharacter: '*',
                              obscureText: isTextVisible.value,
                              style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Obx(() => TextFormField(
                              enabled: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: '',
                              ),
                              controller: controller.textDollarController.value,
                              obscuringCharacter: '*',
                              obscureText: isTextVisible.value,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                    ),
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Get.toNamed(Routes.WITHDRAW, arguments: {
                          "balance": controller.totalbalance.value
                        });
                        // Get.to(PaymentRequest());
                      },
                      child: Card(
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
                      onTap: () => Get.toNamed(Routes.SPIN_WHEEL),
                      child: Card(
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
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () => Get.toNamed(Routes.WALLET_TRASACTIONS),
                      child: Card(
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
                              Text("History")
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: Get.width,
            height: Get.height,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
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
                    const Text(
                      "Portfolio",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                      ),
                    ),
                    // InkWell(
                    //   child: const Icon(Icons.book),
                    //   onTap: () {
                    //     Get.toNamed(Routes.WALLET_TRASACTIONS);
                    //   },
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state!.length,
                        itemBuilder: (context, index) => Visibility(
                            visible: state[index].isActive != 0,
                            child: Container(
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
                                                      state[index].image == null
                                                  ? "https://cdn1.iconfinder.com/data/icons/cryptocurrency-set-2018/375/Asset_1480-512.png"
                                                  : state[index]
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
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              state[index].symbol.toString(),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
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
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            index == 0
                                                ? const Text("Coming soon",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400))
                                                : Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Obx(() => Text(
                                                          "\$${index == 0 ? controller.thrillPrice.value : index == 1 ? controller.btcPrice.value : index == 2 ? controller.ethPrice.value : index == 3 ? controller.bnbPrice.value : index == 4 ? controller.shibPrice.value : index == 5 ? controller.dogePrice.value : index == 6 ? controller.luncPrice.value : index == 7 ? controller.pepePrice.value : controller.thrillPrice.value} ",
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))),
                                                      Obx(() => Text(
                                                            "(${index == 0 ? controller.thrillPer.value + " %" : index == 1 ? controller.btcPer.value + " %" : index == 2 ? controller.ethPer.value + " %" : index == 3 ? controller.bnbPer.value + " %" : index == 4 ? controller.shibPer.value + " %" : index == 5 ? controller.dogePer.value + " %" : index == 6 ? controller.luncPer.value + " %" : index == 7 ? controller.pepePer.value + " %" : controller.thrillPer.value + " %"}) ",
                                                            style: TextStyle(
                                                                color: index ==
                                                                            0 &&
                                                                        controller
                                                                            .thrillPer
                                                                            .value
                                                                            .contains(
                                                                                "-")
                                                                    ? Colors.red
                                                                    : index == 1 &&
                                                                            controller.btcPer.value.contains(
                                                                                "-")
                                                                        ? Colors
                                                                            .red
                                                                        : index == 2 &&
                                                                                controller.ethPer.value.contains("-")
                                                                            ? Colors.red
                                                                            : index == 3 && controller.bnbPer.value.contains("-")
                                                                                ? Colors.red
                                                                                : index == 4 && controller.shibPer.value.contains("-")
                                                                                    ? Colors.red
                                                                                    : index == 5 && controller.dogePer.value.contains("-")
                                                                                        ? Colors.red
                                                                                        : index == 6 && controller.luncPer.value.contains("-")
                                                                                            ? Colors.red
                                                                                            : index == 7 && controller.luncPer.value.contains("-")
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
                            ))))
              ],
            ),
          ))
        ],
      ),
      onLoading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: loader(),
          )
        ],
      ),
      onError: (error) => Center(
        child: NoSearchResult(
          text: error,
        ),
      ),
      onEmpty: Center(
        child: NoSearchResult(
          text: "Nothing found!",
        ),
      ),
    ));
  }

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
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );
}
