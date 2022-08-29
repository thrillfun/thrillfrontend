import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:thrill/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isLoading=true;
  UserModel? user;

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          manageAccount,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF2F8897),
                  Color(0xff1F2A52),
                  Color(0xff1F244E)]),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.lightBlue),): Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
             Text(
              accountDetails.toUpperCase(),
              style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Username : ${user!.username}",
              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Name : ${user!.name}",
              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              user!.social_login_type=='normal'?
              "Phone : ${user!.phone}":
              "Email : ${user!.email}",
              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Login Type : ${user!.social_login_type}",
              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
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


  getProfile()async{
    try{
      var instance = await SharedPreferences.getInstance();
      var loginData=instance.getString('currentUser');
      user=UserModel.fromJson(jsonDecode(loginData!));
      isLoading=false;
    } catch(e){
      isLoading=false;
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
    setState((){});
  }
}
