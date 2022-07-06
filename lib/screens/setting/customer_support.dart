import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/strings.dart';

class CustomerSupport extends StatefulWidget {
  const CustomerSupport({Key? key}) : super(key: key);

  @override
  State<CustomerSupport> createState() => _CustomerSupportState();

  static const String routeName = '/customerSupport';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const CustomerSupport(),
    );
  }
}

class _CustomerSupportState extends State<CustomerSupport> {

  String number = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    getEmailAndNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          customerSupport,
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
      const Center(child: CircularProgressIndicator(),):
      SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/Image27.png'),
            const Text(
              howCanWeHelpYou,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
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
                    if(number.isNotEmpty){
                      try{
                        Uri emailURI = Uri(scheme: 'tel', path: number);
                        launchUrl(emailURI);
                      } catch(e){
                        showErrorToast(context, e.toString());
                      }
                    } else {
                      showErrorToast(context, "Something went wrong!");
                    }
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
                          callUs,
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
                    if(email.isNotEmpty){
                      try{
                        Uri emailURI = Uri(scheme: 'mailto', path: email);
                        launchUrl(emailURI);
                      } catch(e){
                        showErrorToast(context, e.toString());
                      }
                    } else {
                      showErrorToast(context, "Something went wrong!");
                    }
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
                          emailUs,
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

  getEmailAndNumber()async{
    try{
      var response = await RestApi.getSiteSettings();
      var json = jsonDecode(response.body);
      List jsonList = json['data'];
      for(var element in jsonList){
        if(element['name']=='phone'){
          setState(()=>number=element['value']);
        } else if(element['name']=='email'){
          setState(()=>email=element['value']);
        }
      }
      setState(()=>isLoading=false);
    } catch(e){
      setState(()=>isLoading=false);
      showErrorToast(context, e.toString());
    }
  }
}
