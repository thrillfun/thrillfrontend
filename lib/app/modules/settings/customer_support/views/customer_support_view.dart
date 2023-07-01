import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/customer_support_controller.dart';

class CustomerSupportView extends GetView<CustomerSupportController> {
  const CustomerSupportView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/Image27.png'),
            const Text(
              'How can we help you?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Text(
                'You can connect with us by either mobile number or by email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Uri emailURI =
                        Uri(scheme: 'tel', path: controller.number.value);
                    launchUrl(emailURI);
                  },
                  child: Container(
                    height: 180,
                    width: 155,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.call,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Call us",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Uri emailURI =
                        Uri(scheme: 'mailto', path: controller.email.value);
                    launchUrl(emailURI);
                  },
                  child: Container(
                    height: 180,
                    width: 155,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.email,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Email Us",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
