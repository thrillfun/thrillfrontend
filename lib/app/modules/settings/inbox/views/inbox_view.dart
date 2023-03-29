import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/inbox_controller.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InboxView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'InboxView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
