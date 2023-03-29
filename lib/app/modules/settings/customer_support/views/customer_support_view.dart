import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/customer_support_controller.dart';

class CustomerSupportView extends GetView<CustomerSupportController> {
  const CustomerSupportView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomerSupportView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'CustomerSupportView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
