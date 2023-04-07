import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/wallet_trasactions_controller.dart';

class WalletTrasactionsView extends GetView<WalletTrasactionsController> {
  const WalletTrasactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recent Transactions",style:         TextStyle(color: Colors.black, fontWeight: FontWeight.w700,fontSize: 24),
          ),),
      body: controller.obx(
          (state) => ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: state!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: state[index].transactionStatus == "Completed"
                      ? Colors.green.shade600
                      : state[index].transactionStatus == "Pending"
                      ? Colors.yellow.shade600
                      : state[index].transactionStatus == "failed"
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                  borderRadius:
                  BorderRadius.all(Radius.circular(10))),
              child: Container(
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    color: state[index].transactionStatus == "Completed"
                        ? Colors.green.shade50
                        : state[index].transactionStatus == "Pending"
                        ? Colors.yellow.shade50
                        : state[index].transactionStatus == "failed"
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
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
                              child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.payment,
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
                                    state[index]
                                        .transactionId
                                        .toString(),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: Text(convertUTC(state[index]
                                    .createdAt
                                    .toString()))),
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
                                        .transactionId.toString().isNotEmpty
                                        ? Colors.green.shade600
                                        : Colors.red),
                              ),
                            ])
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
