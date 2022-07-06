import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_api.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({Key? key}) : super(key: key);

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();

  static const String routeName = '/termsOfService';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const TermsOfService(),
    );
  }
}

class _TermsOfServiceState extends State<TermsOfService> {
  
  String data = '';
  bool isLoading = true;

  @override
  void initState() {
    getTermsOfService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          termsOfService,
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
      body: isLoading?
      const Center(
        child: CircularProgressIndicator(),
      ):
      SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(data),
          )),
    );
  }

  getTermsOfService()async{
    try{
      var response = await RestApi.getCmsPage('TermsConditions');
      var json = jsonDecode(response.body);
      setState(() {
        data = json['data']['description'] ?? '';
        isLoading = false;
      });
    } catch(e){
      setState(() {
        data = "Error!";
        isLoading = false;
      });
    }
  }
}
