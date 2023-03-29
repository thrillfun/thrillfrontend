import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../utils/utils.dart';

class AppSuperController extends FullLifeCycleController
    with FullLifeCycleMixin {
  // Mandatory
  @override
  void onDetached() {
    successToast("on detached");
  }

  // Mandatory
  @override
  void onInactive() {
    successToast("on inactive");
  }

  // Mandatory
  @override
  void onPaused() {
    successToast("on paused");
  }

  // Mandatory
  @override
  void onResumed() {
    successToast("on resume");
    getDynamicLink();
  }

  @override
  void onInit() {
    getDynamicLink();
    super.onInit();
  }

  getDynamicLink() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();



  }
}
