import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/wallet/transactions_controller.dart';
import 'package:thrill/utils/util.dart';

class TransactionsHistory extends GetView<TransactionsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.obx(
          (state) => SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        "Recent Transactions",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ListView.builder(
                      itemCount: state!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            width: Get.width,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: ColorManager.colorAccent
                                        .withOpacity(0.2),
                                    child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state[index].from.toString(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          state[index].transactionId.toString(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Text(convertUTC(
                                          state[index].createdAt.toString()))),
                                  Column(children: [
                                    Text(
                                      "${state[index].currency} " +
                                          state[index]
                                              .amount!
                                              .toStringAsFixed(4)
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: state[index]
                                                  .from!
                                                  .toLowerCase()
                                                  .contains("bonus")
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                  ])
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            indent: 20,
                            endIndent: 10,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
          onLoading: Container(
            height: Get.height,
            alignment: Alignment.center,
            width: Get.width,
            child: loader(),
          )),
    );
  }
}
