import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/withdraw_controller.dart';

class WithdrawView extends StatefulWidget {
  const WithdrawView();

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  var controller = Get.find<WithdrawController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw"),
      ),
      body: controller.obx((state) => Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      myLabel("Currency"),
                      InkWell(
                        onTap: () => Get.bottomSheet(
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Select Coin",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            controller.currenciesList.length,
                                        itemBuilder: (context, index) =>
                                            InkWell(
                                              onTap: () {
                                                controller.selectedCurrency
                                                    .value = controller
                                                        .currenciesList[index]
                                                        .code ??
                                                    "";
                                                controller
                                                    .selectedCurrencyController
                                                    .value
                                                    .text = controller
                                                        .currenciesList[index]
                                                        .symbol ??
                                                    "";
                                                controller.netList!.value =
                                                    controller
                                                        .currenciesList[index]
                                                        .networks!;
                                                controller
                                                    .selectedNetworkController
                                                    .value
                                                    .text = controller
                                                        .currenciesList[index]
                                                        .networks![0]
                                                        .networkName ??
                                                    "";
                                                controller.networkFee.value =
                                                    controller
                                                        .currenciesList[index]
                                                        .networks![0]
                                                        .feeDigit!
                                                        .formatCrypto();

                                                controller.feeCtr.value.text =
                                                    controller
                                                        .netList![0].feeDigit!
                                                        .formatCrypto();

                                                controller.minAmount.value =
                                                    controller
                                                        .currenciesList[index]
                                                        .networks![0]
                                                        .minAmount!
                                                        .formatCrypto();

                                                controller.maxAmount.value =
                                                    controller
                                                        .currenciesList[index]
                                                        .networks![0]
                                                        .maxAmount!
                                                        .formatCrypto();
                                                controller.availableBalance
                                                        .value =
                                                    controller
                                                        .currenciesList[index]
                                                        .balance
                                                        .toString();
                                                controller.currencyName.value =
                                                    controller
                                                        .currenciesList[index]
                                                        .symbol
                                                        .toString();

                                                Get.back();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                margin: const EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 30,
                                                      width: 30,
                                                      child: ClipOval(
                                                        child: CachedNetworkImage(
                                                            fit: BoxFit.contain,
                                                            imageUrl: controller
                                                                    .currenciesList[
                                                                        index]
                                                                    .image ??
                                                                ""),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            controller
                                                                    .currenciesList[
                                                                        index]
                                                                    .symbol ??
                                                                "",
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            "Available Balance : " +
                                                                controller
                                                                    .currenciesList[
                                                                        index]
                                                                    .balance
                                                                    .toString() +
                                                                " ${controller.currenciesList[index].code}",
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          )
                                                        ],
                                                      ),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 50,
                                    )
                                  ],
                                )),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            isScrollControlled: true,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor),
                        child: Obx(() => TextFormField(
                              maxLength: 10,
                              controller:
                                  controller.selectedCurrencyController.value,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(fontSize: 14),
                              readOnly: true,
                              decoration: const InputDecoration(
                                enabled: false,
                                filled: true,
                              ),
                            )),
                      ),
                      Row(
                        children: [
                          Text(
                            "Network",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () => infoDialog(
                                title: "Transfer Network",
                                content:
                                    "Please make sure that the currency is charged and withdrawn on the same network, otherwise the currency withdrawal cannot be successful.The different effects of the network are the rate, thie minimum amount of money withdrawn and the transfer time.",
                                buttonText: "I Understand"),
                            child: Icon(
                              Icons.info,
                              color: ColorManager.colorAccent,
                              size: 20,
                            ),
                          ),

                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () => Get.bottomSheet(
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Select Network",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Flexible(
                                      child: Text(
                                    "Ensure the network matches the withdrawal address and the deposit platform supports it, or assets may be lost.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  )),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: controller.netList!.length,
                                      itemBuilder: (context, index) =>
                                          Container(
                                            child: InkWell(
                                              onTap: () {
                                                controller
                                                    .selectedNetworkController
                                                    .value
                                                    .text = controller
                                                        .netList![index]
                                                        .networkName ??
                                                    "";

                                                controller.feeCtr.value.text =
                                                    controller.netList![index]
                                                        .feeDigit!
                                                        .formatCrypto();

                                                controller.minAmount.value =
                                                    controller.netList![index]
                                                        .minAmount!
                                                        .formatCrypto();

                                                controller.maxAmount.value =
                                                    controller.netList![index]
                                                        .maxAmount!
                                                        .formatCrypto();

                                                controller.networkFee.value =
                                                    controller.netList![index]
                                                        .feeDigit!
                                                        .formatCrypto();
                                                Get.back();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                margin: const EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        controller
                                                                .netList![index]
                                                                .networkName ??
                                                            "",
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                    Text(
                                                      "Fee: " +
                                                          double.parse(controller
                                                                  .netList![
                                                                      index]
                                                                  .feeDigit
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  4)
                                                              .toString() +
                                                          " ${controller.selectedCurrency.value}",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )),
                                  SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            isScrollControlled: true,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor),
                        child: Obx(() => TextFormField(
                              controller:
                                  controller.selectedNetworkController.value,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                enabled: false,
                                filled: true,
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.warning_2,
                            color: ColorManager.colorAccent,
                            size: 20,
                          ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(child: Obx(() => Text(
                          "The network you have selected is ${controller.selectedNetworkController.value.text}. Please ensure that the withdrawal address supports the ${controller.selectedNetworkController.value.text} network. You will potentialy loose you asset if the chosen platform does not support refunds of wrongfully deposited assets.",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12),
                        ))),
                      ],),
                      const SizedBox(
                        height: 10,
                      ),
                      myLabel("Address"),
                      Obx(() => TextFormField(
                            controller: controller.upiCtr.value,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Withdrawal Address",
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      myLabel("Amount"),
                      Obx(() => TextFormField(
                            controller: controller.amtCtr.value,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText:
                                  "Minimum ${controller.minAmount.value} ${controller.selectedCurrency.value}",
                            ),
                            onChanged: (value) {
                              controller.withdrawAmount.value = value;

                              if (double.parse(value) >
                                  double.parse(controller.maxAmount.value)) {
                                controller.isAmountOverLimit.value = true;
                              } else {
                                controller.isAmountOverLimit.value = false;
                              }
                              if (double.parse(value) <
                                  double.parse(controller.minAmount.value)) {
                                controller.isAmountUnderLimit.value = true;
                              } else {
                                controller.isAmountUnderLimit.value = false;
                              }
                            },
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => Visibility(
                            visible: controller.isAmountOverLimit.isTrue,
                            child: const Text(
                              "Please enter a valid amount",
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            "Minimum Withdrawal Amount:",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 14),
                          )),
                          Obx(() => Text(
                              " ${controller.minAmount.value} ${controller.selectedCurrency.value} ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text("Maximum Withdrawal Amount:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14))),
                          Obx(() => Text(
                              " ${controller.maxAmount.value} ${controller.selectedCurrency.value} ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text("Available Amount:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14))),
                          Obx(() => Text(
                              controller.availableBalance.value +
                                  " ${controller.selectedCurrency.value}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade400)),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  padding: const EdgeInsets.all(10),
                  width: Get.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Received Amount",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Obx(() => Text(
                                  controller.withdrawAmount.isEmpty ||
                                          controller.withdrawAmount.value ==
                                              "0" ||
                                          controller.isAmountOverLimit.isTrue ||
                                          controller.isAmountUnderLimit.isTrue
                                      ? "0 " + controller.selectedCurrency.value
                                      : (double.parse(controller
                                                      .withdrawAmount.value) -
                                                  double.parse(controller
                                                      .networkFee.value))
                                              .toString() +
                                          " " +
                                          controller.selectedCurrency.value,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Row(
                              children: [
                                Flexible(child: Obx(() => Text(
                                    "Network fee " +
                                        controller.networkFee.value +
                                        " ${controller.selectedCurrency.value}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400)))),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () => infoDialog(
                                      title: "Network fee",
                                      content:
                                          "The network fee is determined by the network and may be adjusted by the network in the event of network congestion.",
                                      buttonText: "I Understand"),
                                  child: Icon(
                                    Icons.info,
                                    color: ColorManager.colorAccent,
                                    size: 20,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                      ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (controller.upiCtr.value.text.isEmpty) {
                              errorToast("Enter Withdraw Address");
                            } else {
                              if (controller.amtCtr.value.text.isEmpty) {
                                errorToast("Enter Amount");
                              } else {
                                if (double.parse(controller.amtCtr.value.text) <
                                    double.parse(
                                        controller.minAmount.value ?? "0.0")) {
                                  errorToast(
                                      "Enter Min Amount ${controller.minAmount.value} ");
                                } else {
                                  if (double.parse(
                                          controller.amtCtr.value.text) >
                                      double.parse(controller.maxAmount.value ??
                                          "0.0")) {
                                    errorToast(
                                        "Enter Max Amount ${controller.maxAmount.value} ");
                                  } else {
                                    try {
                                      controller.sendWithdrawRequest(
                                          controller.selectedCurrency.value,
                                          controller.upiCtr.value.text,
                                          controller.selectedNetworkController
                                              .value.text,
                                          controller.amtCtr.value.text,
                                          controller.feeCtr.value.text
                                              .toString());
                                    } catch (e) {
                                      errorToast(e.toString());
                                    }
                                  }
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: ColorManager.colorAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            "Withdraw",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ))
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget myLabel(String txt) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            txt,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ));
  }

  infoDialog({String? title, String? content, String? buttonText}) =>
      Get.defaultDialog(
          titlePadding: EdgeInsets.only(top: 30, bottom: 10),
          title: title ?? "",
          titleStyle: TextStyle(fontWeight: FontWeight.w700),
          middleText: content ?? "",
          middleTextStyle: TextStyle(
            fontWeight: FontWeight.w400,
          ),
          confirm: InkWell(
            onTap: () => Get.back(),
            child: Container(
              width: Get.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ColorManager.colorAccent,
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Text(
                buttonText ?? "",
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ));
}
