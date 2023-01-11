import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:thrill/controller/model/site_settings_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteSettingsController extends GetxController with StateMixin<Rx<SiteSettingsModel>>{
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));
  var siteSettings = SiteSettingsModel().obs;

  SiteSettingsController(){
    getSiteSettings().then((value) {
    });
  }

  Future<void> getSiteSettings()async {
    change(siteSettings,status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/SiteSettings").then((value) {
      if(value.data["status"]==true){
        siteSettings = SiteSettingsModel.fromJson(value.data).obs;
        change(siteSettings,status: RxStatus.success());
        showAd();

      }
      else{
        errorToast(value.data["message"]);
        change(siteSettings,status: RxStatus.error());

      }
    }).onError((error, stackTrace) {
      change(siteSettings,status: RxStatus.error());
    });
  }

  showAd(){
   if(siteSettings.value.data!=null){
     int adUrlIndex = siteSettings.value.data!.indexWhere((f) => f.name == "advertisement_image");
     int adLinkIndex = siteSettings.value.data!.indexWhere((f) => f.name == "advertisement_link");
     int adEndIndex = siteSettings.value.data!.indexWhere((f) => f.name == "advertisement_end");
     DateTime endDate  =  DateTime.parse(siteSettings.value.data![adEndIndex].value);

     if(endDate.isAfter(DateTime.now())){
       Get.defaultDialog(
           backgroundColor: Colors.transparent.withOpacity(0.0),
           title: "",content:
       Container(
         height: Get.height/2,
         width: Get.width,
         decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
         child: Stack(
           alignment: Alignment.topRight,
           children: [
             Flexible(child: imgNet(
                 RestUrl.profileUrl+siteSettings.value.data![adUrlIndex].value.toString())),
             InkWell(
               onTap:()=> Get.back(),
               child: Icon(IconlyLight.close_square,color: Colors.red,),)

           ],),)
       );
     }





   }
  }
}