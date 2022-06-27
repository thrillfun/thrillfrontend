import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/strings.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({Key? key}) : super(key: key);

  @override
  State<ManageAccount> createState() => _ManageAccountState();

  static const String routeName = '/manageAccount';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const ManageAccount(),
    );
  }
}

class _ManageAccountState extends State<ManageAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          manageAccount,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              accountControl,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Username",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              "Phone",
              style: TextStyle(color: Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Request"),
      onPressed:  () {
        Navigator.pop(context);
        deactiveAccount();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Manage Account"),
      content: const Text("Would you like to send Deactivate Account request to admin?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deactiveAccount()async{
    progressDialogue(context);
    var result= await RestApi.deactiveAccount();
    var json=jsonDecode(result.body);
    if(json['status']){
      closeDialogue(context);
      showSuccessToast(context, json['message']);
    }else{
      closeDialogue(context);
      showErrorToast(context, json['message']);
    }
  }
}
