import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_api.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();

  static const String routeName = '/privacyPolicy';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const PrivacyPolicy(),
    );
  }
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  String data = '';
  bool isLoading = true;

  @override
  void initState() {
    getPrivacyPolicy();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          privacyPolicy,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data,
                style: const TextStyle(fontSize: 13),
              ),
            )),
    );
  }

  getPrivacyPolicy() async {
    try {
      var response = await RestApi.getCmsPage('PrivacyPolicy');
      var json = jsonDecode(response.body);
      setState(() {
        data = json['data']['description'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        data = "Error!";
        isLoading = false;
      });
    }
  }
}
