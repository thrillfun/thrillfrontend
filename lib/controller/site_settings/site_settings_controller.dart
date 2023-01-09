import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

     Get.defaultDialog(title: "",content:
     InkWell(
       onTap:()async=>await launchUrl(Uri.parse(siteSettings.value.data![adLinkIndex].value.toString())),
       child: CachedNetworkImage(
         height: Get.height,
           width: Get.width,
           fit: BoxFit.fill,
           imageUrl: "https://thrill.fun/uploads/profile_images/"+siteSettings.value.data![adUrlIndex].value.toString()),));
   }
  }
}