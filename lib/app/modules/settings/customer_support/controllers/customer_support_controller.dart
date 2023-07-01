import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../../../rest/models/site_settings_model.dart';
import '../../../../rest/rest_urls.dart';

class CustomerSupportController extends GetxController {
  //TODO: Implement CustomerSupportController

  var number = ''.obs;
  var email = ''.obs;
  RxList<SiteSettings> siteSettingsList = RxList();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  @override
  void onReady() {
    getSiteSettings();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getSiteSettings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("SiteSettings").then((value) {
      siteSettingsList.value = SiteSettingsModel.fromJson(value.data).data!;
      // showCustomAd();
      if (siteSettingsList.isNotEmpty) {
        siteSettingsList.forEach((element) {
          if (element.name == "phone") {
            number.value = element.value.toString();
          } else if (element.name == "email") {
            email.value = element.value.toString();
          }
        });
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}
