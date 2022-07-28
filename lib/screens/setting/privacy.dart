import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:thrill/models/safety_preference_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';
import '../../common/strings.dart';

class Privacy extends StatefulWidget {
  const Privacy({Key? key}) : super(key: key);

  @override
  State<Privacy> createState() => _PrivacyState();

  static const String routeName = '/privacy';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const Privacy(),
    );
  }
}

class _PrivacyState extends State<Privacy> {

  SafetyPreference? safetyPreference;
  bool isLoading = true;

  @override
  void initState() {
    getSafetyPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          privacy,
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
      safetyPreference==null?
      Center(child: Text('Safety Preferences Not Found!', style: Theme.of(context).textTheme.headline3,),):
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              safety,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Row(
            //   children: const [
            //     Expanded(child: Text(allowYourVideosToBeDownloaded)),
            //     Text(on)
            //   ],
            // ),
            // const Text(
            //   allowYourVideosToBeDownloadedDialog,
            //   style: TextStyle(color: Colors.grey),
            // ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Expanded(child: Text(whoCanSendYouDirectMessage, style: TextStyle(fontSize: 13),)),
                DropdownButton(
                    value: safetyPreference!.whoCanSendDirectMessages.toUpperCase(),
                    isDense: true,
                    icon: const SizedBox(),
                    underline: const SizedBox(),
                    alignment: Alignment.topRight,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: ["EVERYONE","FOLLOWERS","ME"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newVal)async{
                      if(newVal != safetyPreference!.whoCanSendDirectMessages.toUpperCase()){
                        try{
                          progressDialogue(context);
                          var response = await RestApi.saveSafetyPreference("safety_pref_who_send_direct_message", "$newVal");
                          var json = jsonDecode(response.body);
                          closeDialogue(context);
                          if(json['status']){
                            showSuccessToast(context, json['message'].toString());
                            safetyPreference!.whoCanSendDirectMessages = newVal!;
                            setState(() {});
                          } else {
                            showErrorToast(context, json['message'].toString());
                          }
                        } catch(e){
                          closeDialogue(context);
                          showErrorToast(context,e.toString());
                        }
                      }
                    }
                )
              ],
            ),
            const Text(
              whoCanSendYouDirectMessageDialog,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Expanded(child: Text(whoCanDuetWithYourVideo, style: TextStyle(fontSize: 13),)),
                DropdownButton(
                    value: safetyPreference!.whoCanDuet.toUpperCase(),
                    isDense: true,
                    icon: const SizedBox(),
                    underline: const SizedBox(),
                    alignment: Alignment.topRight,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: ["EVERYONE","FOLLOWERS","ME"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newVal) async {
                      if(newVal != safetyPreference!.whoCanDuet.toUpperCase()){
                        try{
                          progressDialogue(context);
                          var response = await RestApi.saveSafetyPreference("who_can_duet_with_your_videos", "$newVal");
                          var json = jsonDecode(response.body);
                          closeDialogue(context);
                          if(json['status']){
                            showSuccessToast(context, json['message'].toString());
                            safetyPreference!.whoCanDuet = newVal!;
                            setState(() {});
                          } else {
                            showErrorToast(context, json['message'].toString());
                          }
                        } catch(e){
                          closeDialogue(context);
                          showErrorToast(context,e.toString());
                        }
                      }
                    }
                )
              ],
            ),
            const Text(
              whoCanDuetWithYourVideoDialog,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Expanded(child: Text(whoCanViewYourLikedVideos, style: TextStyle(fontSize: 13),)),
                DropdownButton(
                    value: safetyPreference!.whoCanViewLikeVideos.toUpperCase(),
                    isDense: true,
                    icon: const SizedBox(),
                    underline: const SizedBox(),
                    alignment: Alignment.topRight,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: ["EVERYONE","FOLLOWERS","ME"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newVal) async {
                      if(newVal != safetyPreference!.whoCanViewLikeVideos.toUpperCase()){
                        try{
                          progressDialogue(context);
                          var response = await RestApi.saveSafetyPreference("who_can_view_your_liked_videos", "$newVal");
                          var json = jsonDecode(response.body);
                          closeDialogue(context);
                          if(json['status']){
                            showSuccessToast(context, json['message'].toString());
                            safetyPreference!.whoCanViewLikeVideos = newVal!;
                            setState(() {});
                          } else {
                            showErrorToast(context, json['message'].toString());
                          }
                        } catch(e){
                          closeDialogue(context);
                          showErrorToast(context,e.toString());
                        }
                      }
                    }
                )
              ],
            ),
            const Text(
              whoCanViewYourLikedVideosDialog,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Expanded(child: Text(whoCanCommentOnYourVideos, style: TextStyle(fontSize: 13),)),
                DropdownButton(
                    value: safetyPreference!.whoCanCommentOnYourVideos.toUpperCase(),
                    isDense: true,
                    icon: const SizedBox(),
                    underline: const SizedBox(),
                    alignment: Alignment.topRight,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    items: ["EVERYONE","FOLLOWERS","ME"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newVal) async {
                      if(newVal != safetyPreference!.whoCanCommentOnYourVideos.toUpperCase()){
                        try{
                          progressDialogue(context);
                          var response = await RestApi.saveSafetyPreference("safety_pref_who_comment_your_videos", "$newVal");
                          var json = jsonDecode(response.body);
                          closeDialogue(context);
                          if(json['status']){
                            showSuccessToast(context, json['message'].toString());
                            safetyPreference!.whoCanCommentOnYourVideos = newVal!;
                            setState(() {});
                          } else {
                            showErrorToast(context, json['message'].toString());
                          }
                        } catch(e){
                          closeDialogue(context);
                          showErrorToast(context,e.toString());
                        }
                      }
                    }
                )
              ],
            ),
            const Text(
              whoCanCommentOnYourVideosDialog,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  getSafetyPreferences()async{
    try{
      var response = await RestApi.getSafetyPreference();
      var json = jsonDecode(response.body);
      if(json['status']){
        setState(() {
          safetyPreference = SafetyPreference.fromJson(json['data']);
          isLoading = false;
        });
      } else {
        showErrorToast(context, json['message']);
        setState(()=>isLoading = false);
      }
    } catch(e){
      Navigator.pop(context);
      showErrorToast(context, e.toString());
    }
  }

}
